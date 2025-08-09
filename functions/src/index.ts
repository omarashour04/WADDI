import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

admin.initializeApp();

// Email configuration
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: functions.config().email?.user || 'your-email@gmail.com',
        pass: functions.config().email?.password || 'your-app-password',
    },
});

// Helper: Check admin role
async function isAdmin(context: functions.https.CallableContext): Promise<boolean> {
    if (!context.auth) return false;
    const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
    return userDoc.exists && userDoc.data()?.role === 'admin';
}

// Helper: Generate booking receipt HTML
function generateBookingReceiptHTML(booking: any, userName: string, venueOwnerName: string): string {
    const startDate = new Date(booking.startTime).toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    const startTime = new Date(booking.startTime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });

    const endTime = new Date(booking.endTime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });

    return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Confirmation - WADDI Platform</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .receipt { background: white; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin: 20px 0; }
            .receipt-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
            .receipt-row:last-child { border-bottom: none; font-weight: bold; font-size: 1.1em; }
            .total { background: #f0f8ff; padding: 15px; border-radius: 5px; margin-top: 15px; }
            .footer { text-align: center; margin-top: 30px; color: #666; font-size: 0.9em; }
            .button { display: inline-block; background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
            .status-confirmed { color: #28a745; font-weight: bold; }
            .status-pending { color: #ffc107; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎉 Booking Confirmed!</h1>
                <p>Thank you for choosing WADDI Platform</p>
            </div>
            
            <div class="content">
                <h2>Hello ${userName},</h2>
                <p>Your booking has been successfully confirmed! Here are the details:</p>
                
                <div class="receipt">
                    <h3>📋 Booking Receipt</h3>
                    
                    <div class="receipt-row">
                        <span><strong>Booking ID:</strong></span>
                        <span>#${booking.id}</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Venue:</strong></span>
                        <span>${booking.venueName}</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Room:</strong></span>
                        <span>${booking.roomName}</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Date:</strong></span>
                        <span>${startDate}</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Time:</strong></span>
                        <span>${startTime} - ${endTime}</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Duration:</strong></span>
                        <span>${booking.durationHours} hour(s)</span>
                    </div>
                    
                    <div class="receipt-row">
                        <span><strong>Status:</strong></span>
                        <span class="status-${booking.status}">${booking.status.toUpperCase()}</span>
                    </div>
                    
                    ${booking.notes ? `
                    <div class="receipt-row">
                        <span><strong>Special Notes:</strong></span>
                        <span>${booking.notes}</span>
                    </div>
                    ` : ''}
                    
                    <div class="total">
                        <div class="receipt-row">
                            <span><strong>Total Amount:</strong></span>
                            <span><strong>EGP ${booking.totalPrice.toFixed(2)}</strong></span>
                        </div>
                    </div>
                </div>
                
                <h3>📍 Venue Contact Information</h3>
                <p><strong>Venue Owner:</strong> ${venueOwnerName}</p>
                <p>If you have any questions about your booking, please contact the venue owner directly.</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="https://waddi-platform.web.app/bookings" class="button">View My Bookings</a>
                    <a href="https://waddi-platform.web.app/support" class="button">Contact Support</a>
                </div>
                
                <div style="background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <h4>📝 Important Information</h4>
                    <ul>
                        <li>Please arrive 10 minutes before your scheduled time</li>
                        <li>Bring a valid ID for verification</li>
                        <li>Follow the venue's rules and regulations</li>
                        <li>Contact the venue owner if you need to make changes</li>
                    </ul>
                </div>
            </div>
            
            <div class="footer">
                <p>© 2024 WADDI Platform. All rights reserved.</p>
                <p>This is an automated email. Please do not reply to this message.</p>
            </div>
        </div>
    </body>
    </html>
    `;
}

// Helper: Generate booking cancellation HTML
function generateCancellationHTML(booking: any, userName: string, venueOwnerName: string): string {
    const startDate = new Date(booking.startTime).toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    const startTime = new Date(booking.startTime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });

    return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Cancelled - WADDI Platform</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #dc3545; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .booking-details { background: white; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 30px; color: #666; font-size: 0.9em; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>❌ Booking Cancelled</h1>
                <p>WADDI Platform</p>
            </div>
            
            <div class="content">
                <h2>Hello ${userName},</h2>
                <p>Your booking has been cancelled. Here are the details:</p>
                
                <div class="booking-details">
                    <h3>📋 Cancelled Booking Details</h3>
                    <p><strong>Booking ID:</strong> #${booking.id}</p>
                    <p><strong>Venue:</strong> ${booking.venueName}</p>
                    <p><strong>Room:</strong> ${booking.roomName}</p>
                    <p><strong>Date:</strong> ${startDate}</p>
                    <p><strong>Time:</strong> ${startTime}</p>
                    <p><strong>Amount:</strong> EGP ${booking.totalPrice.toFixed(2)}</p>
                </div>
                
                <p>If you have any questions about this cancellation, please contact the venue owner: <strong>${venueOwnerName}</strong></p>
                
                <p>We hope to see you again soon!</p>
            </div>
            
            <div class="footer">
                <p>© 2024 WADDI Platform. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    `;
}

// Helper: Generate booking reminder HTML
function generateReminderHTML(booking: any, userName: string, venueOwnerName: string): string {
    const startDate = new Date(booking.startTime).toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    const startTime = new Date(booking.startTime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });

    const endTime = new Date(booking.endTime).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
    });

    return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Booking Reminder - WADDI Platform</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #ffc107; color: #333; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .reminder { background: white; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 30px; color: #666; font-size: 0.9em; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>⏰ Booking Reminder</h1>
                <p>Your booking is coming up soon!</p>
            </div>
            
            <div class="content">
                <h2>Hello ${userName},</h2>
                <p>This is a friendly reminder about your upcoming booking:</p>
                
                <div class="reminder">
                    <h3>📅 Your Booking Details</h3>
                    <p><strong>Venue:</strong> ${booking.venueName}</p>
                    <p><strong>Room:</strong> ${booking.roomName}</p>
                    <p><strong>Date:</strong> ${startDate}</p>
                    <p><strong>Time:</strong> ${startTime} - ${endTime}</p>
                    <p><strong>Duration:</strong> ${booking.durationHours} hour(s)</p>
                    <p><strong>Amount:</strong> EGP ${booking.totalPrice.toFixed(2)}</p>
                </div>
                
                <p><strong>Venue Owner:</strong> ${venueOwnerName}</p>
                
                <p>Please arrive 10 minutes before your scheduled time. We look forward to seeing you!</p>
            </div>
            
            <div class="footer">
                <p>© 2024 WADDI Platform. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    `;
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

// Cloud Function to add maintenance fields to existing venues and rooms
export const addMaintenanceFields = functions.https.onCall(async (data, context) => {
    try {
        // Check if user is admin
        if (!context.auth || context.auth.token.role !== 'admin') {
            throw new functions.https.HttpsError('permission-denied', 'Only admins can run this function');
        }

        const db = admin.firestore();
        const venuesRef = db.collection('venues');

        // Get all venues
        const venuesSnapshot = await venuesRef.get();

        if (venuesSnapshot.empty) {
            return { message: 'No venues found to update' };
        }

        let venuesUpdated = 0;
        let roomsUpdated = 0;

        // Process each venue
        for (const venueDoc of venuesSnapshot.docs) {
            const venueData = venueDoc.data();
            const venueBatch = db.batch();
            let venueNeedsUpdate = false;

            // Check if venue needs maintenance field
            if (venueData.isClosedForMaintenance === undefined) {
                venueBatch.update(venueDoc.ref, {
                    isClosedForMaintenance: false,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                });
                venueNeedsUpdate = true;
                venuesUpdated++;
            }

            // Get all rooms for this venue
            const roomsSnapshot = await venueDoc.ref.collection('rooms').get();

            for (const roomDoc of roomsSnapshot.docs) {
                const roomData = roomDoc.data();

                // Check if room needs maintenance field
                if (roomData.isClosedForMaintenance === undefined) {
                    venueBatch.update(roomDoc.ref, {
                        isClosedForMaintenance: false,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                    roomsUpdated++;
                }
            }

            // Commit batch if there were updates
            if (venueNeedsUpdate || roomsUpdated > 0) {
                await venueBatch.commit();
            }
        }

        return {
            message: `Successfully updated ${venuesUpdated} venues and ${roomsUpdated} rooms with maintenance fields`,
            venuesUpdated,
            roomsUpdated
        };

    } catch (error) {
        console.error('Error adding maintenance fields:', error);
        throw new functions.https.HttpsError('internal', 'Failed to add maintenance fields');
    }
});

// Email Functions
export const sendBookingConfirmationEmail = functions.https.onCall(async (data, context) => {
    try {
        const { userEmail, userName, booking, venueOwnerEmail, venueOwnerName } = data;

        if (!userEmail || !userName || !booking) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
        }

        const htmlContent = generateBookingReceiptHTML(booking, userName, venueOwnerName);

        const mailOptions = {
            from: `"WADDI Platform" <${functions.config().email?.user || 'noreply@waddi.com'}>`,
            to: userEmail,
            subject: `🎉 Booking Confirmed - ${booking.venueName}`,
            html: htmlContent,
        };

        await transporter.sendMail(mailOptions);

        return { success: true, message: 'Booking confirmation email sent successfully' };
    } catch (error) {
        console.error('Error sending booking confirmation email:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send booking confirmation email');
    }
});

export const sendBookingCancellationEmail = functions.https.onCall(async (data, context) => {
    try {
        const { userEmail, userName, booking, venueOwnerEmail, venueOwnerName } = data;

        if (!userEmail || !userName || !booking) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
        }

        const htmlContent = generateCancellationHTML(booking, userName, venueOwnerName);

        const mailOptions = {
            from: `"WADDI Platform" <${functions.config().email?.user || 'noreply@waddi.com'}>`,
            to: userEmail,
            subject: `❌ Booking Cancelled - ${booking.venueName}`,
            html: htmlContent,
        };

        await transporter.sendMail(mailOptions);

        return { success: true, message: 'Booking cancellation email sent successfully' };
    } catch (error) {
        console.error('Error sending booking cancellation email:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send booking cancellation email');
    }
});

export const sendBookingReminderEmail = functions.https.onCall(async (data, context) => {
    try {
        const { userEmail, userName, booking, venueOwnerEmail, venueOwnerName } = data;

        if (!userEmail || !userName || !booking) {
            throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
        }

        const htmlContent = generateReminderHTML(booking, userName, venueOwnerName);

        const mailOptions = {
            from: `"WADDI Platform" <${functions.config().email?.user || 'noreply@waddi.com'}>`,
            to: userEmail,
            subject: `⏰ Booking Reminder - ${booking.venueName}`,
            html: htmlContent,
        };

        await transporter.sendMail(mailOptions);

        return { success: true, message: 'Booking reminder email sent successfully' };
    } catch (error) {
        console.error('Error sending booking reminder email:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send booking reminder email');
    }
}); 

// =============================
// Booking reminders + auto-cancel
// =============================

type BookingDoc = FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>;

function minutesUntil(date: Date, from: Date): number {
  return Math.round((date.getTime() - from.getTime()) / 60000);
}

async function fetchUserTokens(userId: string): Promise<string[]> {
  if (!userId) return [];
  const userSnap = await admin.firestore().collection('users').doc(userId).get();
  const data = userSnap.data() || {} as any;
  const tokens: string[] = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter((t: any) => typeof t === 'string') : [];
  return tokens;
}

async function sendPush(tokens: string[], title: string, body: string, data?: Record<string, string>) {
  if (!tokens.length) return;
  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: { title, body },
    data: data || {},
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default' } } },
  };
  await admin.messaging().sendEachForMulticast(message);
}

async function processRemindersAndNoShows(): Promise<{ reminders: number; cancelled: number; }> {
  const now = new Date();
  const db = admin.firestore();

  // Query top-level 'bookings' collection (primary in app)
  const bookingsSnap = await db.collection('bookings')
    .where('status', '==', 'confirmed')
    .where('startTime', '>=', admin.firestore.Timestamp.fromDate(new Date(now.getTime() - 24 * 60 * 60000)))
    .where('startTime', '<=', admin.firestore.Timestamp.fromDate(new Date(now.getTime() + 24 * 60 * 60000)))
    .get();

  let remindersSent = 0;
  let cancelledCount = 0;

  const batch = db.batch();

  for (const doc of bookingsSnap.docs) {
    const b = doc.data() as any;
    const start: Date = (b.startTime instanceof admin.firestore.Timestamp) ? b.startTime.toDate() : new Date(b.startTime);
    const mins = minutesUntil(start, now);
    const userId: string = b.userId || b.userID || '';
    const bookingId: string = doc.id;
    const venueName: string = b.venueName || 'Your Venue';
    const roomName: string = b.roomName || 'Room';

    // Auto-cancel: not checked in within 15 mins after start
    const isCheckedIn = Boolean(b.isCheckedIn);
    if (!isCheckedIn && now.getTime() >= start.getTime() + 15 * 60000) {
      batch.update(doc.ref, {
        status: 'cancelled',
        cancellationReason: 'no_show',
        autoCancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      cancelledCount += 1;
      continue; // no reminders after cancellation
    }

    // Reminders windows (run every ~5m)
    const reminder24hSent = Boolean(b.reminder24hSent);
    const reminder1hSent = Boolean(b.reminder1hSent);
    const reminder15mSent = Boolean(b.reminder15mSent);

    // 24h: mins ~ 1440 +- 5
    if (!reminder24hSent && mins <= 1440 && mins >= 1435) {
      const tokens = await fetchUserTokens(userId);
      await sendPush(tokens, 'Booking tomorrow', `Your ${roomName} at ${venueName} is tomorrow at ${start.toLocaleTimeString()}`, {
        type: 'booking_reminder_24h', bookingId,
      });
      batch.update(doc.ref, { reminder24hSent: true });
      remindersSent += 1;
    }

    // 1h: mins ~ 60 +- 5
    if (!reminder1hSent && mins <= 60 && mins >= 55) {
      const tokens = await fetchUserTokens(userId);
      await sendPush(tokens, 'Booking in 1 hour', `Your ${roomName} at ${venueName} starts in 1 hour`, {
        type: 'booking_reminder_1h', bookingId,
      });
      batch.update(doc.ref, { reminder1hSent: true });
      remindersSent += 1;
    }

    // 15m: mins ~ 15 +- 5
    if (!reminder15mSent && mins <= 15 && mins >= 10) {
      const tokens = await fetchUserTokens(userId);
      await sendPush(tokens, 'Booking in 15 minutes', `Your ${roomName} at ${venueName} starts soon. Please arrive and scan the room QR to check in.`, {
        type: 'booking_reminder_15m', bookingId,
      });
      batch.update(doc.ref, { reminder15mSent: true });
      remindersSent += 1;
    }
  }

  // Commit batched updates
  await batch.commit();

  return { reminders: remindersSent, cancelled: cancelledCount };
}

// Run every 5 minutes
export const scheduleBookingRemindersAndAutoCancel = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('UTC')
  .onRun(async () => {
    const res = await processRemindersAndNoShows();
    console.log('Reminders sent:', res.reminders, 'Auto-cancelled:', res.cancelled);
  });