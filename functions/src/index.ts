import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Helper: Check admin role
async function isAdmin(context: functions.https.CallableContext): Promise<boolean> {
    if (!context.auth) return false;
    const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
    return userDoc.exists && userDoc.data()?.role === 'admin';
}

// User Management
export const manageUser = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    const { action, targetUserId, updates } = data;
    if (!targetUserId) throw new functions.https.HttpsError('invalid-argument', 'No target user ID.');
    if (action === 'delete') {
        await admin.auth().deleteUser(targetUserId);
        await admin.firestore().collection('users').doc(targetUserId).delete();
        return { success: true };
    } else if (action === 'update') {
        await admin.firestore().collection('users').doc(targetUserId).update(updates);
        return { success: true };
    } else if (action === 'promote') {
        await admin.firestore().collection('users').doc(targetUserId).update({ role: 'venue_owner' });
        return { success: true };
    } else if (action === 'admin') {
        await admin.firestore().collection('users').doc(targetUserId).update({ role: 'admin' });
        return { success: true };
    } else {
        throw new functions.https.HttpsError('invalid-argument', 'Unknown action.');
    }
});

// Venue Management
export const manageVenue = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    const { action, venueId, updates } = data;
    if (!venueId) throw new functions.https.HttpsError('invalid-argument', 'No venue ID.');
    if (action === 'delete') {
        await admin.firestore().collection('venues').doc(venueId).delete();
        return { success: true };
    } else if (action === 'update') {
        await admin.firestore().collection('venues').doc(venueId).update(updates);
        return { success: true };
    } else if (action === 'approve') {
        await admin.firestore().collection('venues').doc(venueId).update({ status: 'approved' });
        return { success: true };
    } else if (action === 'reject') {
        await admin.firestore().collection('venues').doc(venueId).update({ status: 'rejected' });
        return { success: true };
    } else {
        throw new functions.https.HttpsError('invalid-argument', 'Unknown action.');
    }
});

// Booking Management
export const manageBooking = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    const { action, bookingId, venueId, roomId } = data;
    if (!bookingId || !venueId || !roomId) throw new functions.https.HttpsError('invalid-argument', 'Missing IDs.');
    if (action === 'delete') {
        await admin.firestore().collection('venues').doc(venueId).collection('rooms').doc(roomId).collection('bookings').doc(bookingId).delete();
        return { success: true };
    } else {
        throw new functions.https.HttpsError('invalid-argument', 'Unknown action.');
    }
});

// Analytics
export const getPlatformStats = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    // Aggregate stats (example: count users, venues, bookings, revenue)
    const usersSnap = await admin.firestore().collection('users').get();
    const venuesSnap = await admin.firestore().collection('venues').get();
    let totalBookings = 0;
    let totalRevenue = 0;
    for (const venue of venuesSnap.docs) {
        const roomsSnap = await venue.ref.collection('rooms').get();
        for (const room of roomsSnap.docs) {
            const bookingsSnap = await room.ref.collection('bookings').get();
            totalBookings += bookingsSnap.size;
            for (const booking of bookingsSnap.docs) {
                totalRevenue += booking.data().price || 0;
            }
        }
    }
    return {
        totalUsers: usersSnap.size,
        totalVenues: venuesSnap.size,
        totalBookings,
        totalRevenue,
    };
});

// Content Management
export const updateStaticContent = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    const { section, content } = data;
    if (!section || !content) throw new functions.https.HttpsError('invalid-argument', 'Missing section/content.');
    await admin.firestore().collection('static_content').doc(section).set({ content });
    return { success: true };
});

// Broadcast Notifications
export const sendBroadcastNotification = functions.https.onCall(async (data, context) => {
    if (!await isAdmin(context)) throw new functions.https.HttpsError('permission-denied', 'Admins only');
    const { message, segment } = data;
    // Implement FCM logic here (send to all or segment)
    // ...
    return { success: true };
});

// Cloud Function to add status field to existing venues
export const updateVenuesWithStatus = functions.https.onCall(async (data, context) => {
    try {
        // Check if user is admin
        if (!context.auth || context.auth.token.role !== 'admin') {
            throw new functions.https.HttpsError('permission-denied', 'Only admins can run this function');
        }

        const db = admin.firestore();
        const venuesRef = db.collection('venues');

        // Get all venues
        const snapshot = await venuesRef.get();

        if (snapshot.empty) {
            return { message: 'No venues found to update' };
        }

        const batch = db.batch();
        let updatedCount = 0;

        snapshot.docs.forEach((doc) => {
            const venueData = doc.data();

            // Only update if status field doesn't exist
            if (!venueData.status) {
                batch.update(doc.ref, {
                    status: 'approved', // Set existing venues as approved
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                });
                updatedCount++;
            }
        });

        if (updatedCount > 0) {
            await batch.commit();
            return {
                message: `Successfully updated ${updatedCount} venues with status field`,
                updatedCount
            };
        } else {
            return { message: 'All venues already have status field' };
        }

    } catch (error) {
        console.error('Error updating venues:', error);
        throw new functions.https.HttpsError('internal', 'Failed to update venues');
    }
});

// Cloud Function to clean up guest users
export const cleanupGuestUsers = functions.https.onCall(async (data, context) => {
    try {
        // Check if user is admin
        if (!context.auth || context.auth.token.role !== 'admin') {
            throw new functions.https.HttpsError('permission-denied', 'Only admins can run this function');
        }

        const db = admin.firestore();
        const usersRef = db.collection('users');

        // Get all users with empty email (guest users)
        const snapshot = await usersRef.where('email', '==', '').get();

        if (snapshot.empty) {
            return { message: 'No guest users found to clean up' };
        }

        const batch = db.batch();
        let deletedCount = 0;

        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
            deletedCount++;
        });

        await batch.commit();

        return {
            message: `Successfully deleted ${deletedCount} guest users`,
            deletedCount
        };

    } catch (error) {
        console.error('Error cleaning up guest users:', error);
        throw new functions.https.HttpsError('internal', 'Failed to clean up guest users');
    }
}); 