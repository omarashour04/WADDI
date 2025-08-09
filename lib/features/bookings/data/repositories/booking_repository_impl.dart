import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepositoryImpl(this._firestore);

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingEntity.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by start time (nearest first) and filter out cancelled bookings from the top
      bookings.sort((a, b) {
        // First, sort by status priority: upcoming > in_progress > completed > cancelled
        final statusPriority = {
          'confirmed': 1,
          'pending': 2,
          'in_progress': 3,
          'completed': 4,
          'cancelled': 5,
        };
        
        final aPriority = statusPriority[a.status] ?? 6;
        final bPriority = statusPriority[b.status] ?? 6;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // If same status, sort by start time (nearest first)
        return a.startTime.compareTo(b.startTime);
      });
      
      return bookings;
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  @override
  Future<List<BookingEntity>> getVenueBookings(String venueId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('venueId', isEqualTo: venueId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingEntity.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch venue bookings: $e');
    }
  }

  @override
  Future<List<BookingEntity>> getRoomBookings(String venueId, String roomId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('venueId', isEqualTo: venueId)
          .where('roomId', isEqualTo: roomId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingEntity.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch room bookings: $e');
    }
  }

  @override
  Future<BookingEntity?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingEntity.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  @override
  Future<String> createBooking(BookingEntity booking) async {
    try {
      // Guard: reject creating bookings in the past
      final now = DateTime.now();
      if (booking.startTime.isBefore(now)) {
        throw Exception('Cannot create a booking in the past');
      }
      if (booking.endTime.isBefore(booking.startTime)) {
        throw Exception('Invalid time range');
      }
      final docRef = await _firestore.collection('bookings').add(booking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<void> updateBooking(BookingEntity booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toMap());
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  @override
  Future<List<DateTime>> getRoomAvailability(String venueId, String roomId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final bookingsSnapshot = await _firestore
          .collection('venues')
          .doc(venueId)
          .collection('rooms')
          .doc(roomId)
          .collection('bookings')
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', whereIn: ['confirmed', 'pending']) // Exclude cancelled bookings
          .get();

      List<DateTime> availableTimes = [];
      // Assuming rooms are available from 9 AM to 10 PM for simplicity
      DateTime current = DateTime(date.year, date.month, date.day, 9);
      while (current.hour < 22) {
        final potentialSlot = current;
        bool isBooked = false;
        for (final doc in bookingsSnapshot.docs) {
          final booking = BookingEntity.fromMap(doc.data(), doc.id);
          if (potentialSlot.isBefore(booking.endTime) && potentialSlot.add(const Duration(hours: 1)).isAfter(booking.startTime)) {
            isBooked = true;
            break;
          }
        }
        if (!isBooked) {
          availableTimes.add(potentialSlot);
        }
        current = current.add(const Duration(hours: 1));
      }
      return availableTimes;
    } catch (e) {
      throw Exception('Failed to get room availability: $e');
    }
  }

  @override
  Future<bool> isRoomAvailable(String venueId, String roomId, DateTime startTime, DateTime endTime) async {
    try {
      // Guard: cannot check availability for past start times
      if (startTime.isBefore(DateTime.now())) {
        return false;
      }
      final snapshot = await _firestore
          .collection('bookings')
          .where('venueId', isEqualTo: venueId)
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: ['confirmed', 'pending']) // Exclude cancelled bookings
          .get();

      for (final doc in snapshot.docs) {
        final booking = BookingEntity.fromMap(doc.data(), doc.id);
        
        // Check for overlap
        if (startTime.isBefore(booking.endTime) && endTime.isAfter(booking.startTime)) {
          return false; // Room is not available
        }
      }

      return true; // Room is available
    } catch (e) {
      throw Exception('Failed to check room availability: $e');
    }
  }

  @override
  Future<void> checkInByRoomScan({
    required String userId,
    required String venueId,
    required String roomId,
  }) async {
    // Find an active booking for this user/venue/room within 15-minute window
    final now = DateTime.now();
    final fifteenMinsAfter = now.add(const Duration(minutes: 0));

    final qs = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('venueId', isEqualTo: venueId)
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    if (qs.docs.isEmpty) {
      throw Exception('No active booking found for this room.');
    }

    // Pick the booking that is within the window
    final candidates = qs.docs
        .map((d) => BookingEntity.fromMap(d.data(), d.id))
        .where((b) {
          final windowEnd = b.startTime.add(const Duration(minutes: 15));
          return b.startTime.isBefore(now.add(const Duration(minutes: 1))) && now.isBefore(windowEnd) && !b.isCheckedIn;
        })
        .toList();

    if (candidates.isEmpty) {
      throw Exception('Booking not within check-in window or already checked in.');
    }

    final booking = candidates.first;

    await _firestore.runTransaction((trx) async {
      final ref = _firestore.collection('bookings').doc(booking.id);
      final snap = await trx.get(ref);
      if (!snap.exists) throw Exception('Booking not found');
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] != 'confirmed') throw Exception('Booking not confirmed');
      if ((data['isCheckedIn'] ?? false) == true) throw Exception('Already checked in');
      final start = (data['startTime'] as Timestamp).toDate();
      if (DateTime.now().isAfter(start.add(const Duration(minutes: 15)))) {
        throw Exception('Check-in window expired');
      }
      trx.update(ref, {
        'isCheckedIn': true,
        'checkedInAt': FieldValue.serverTimestamp(),
        'checkedInBy': userId,
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> ownerCheckIn({required String bookingId, required String ownerUserId}) async {
    await _firestore.runTransaction((trx) async {
      final ref = _firestore.collection('bookings').doc(bookingId);
      final snap = await trx.get(ref);
      if (!snap.exists) throw Exception('Booking not found');
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] != 'confirmed') throw Exception('Booking not confirmed');
      if ((data['isCheckedIn'] ?? false) == true) throw Exception('Already checked in');
      final start = (data['startTime'] as Timestamp).toDate();
      if (DateTime.now().isAfter(start.add(const Duration(minutes: 15)))) {
        throw Exception('Check-in window expired');
      }
      trx.update(ref, {
        'isCheckedIn': true,
        'checkedInAt': FieldValue.serverTimestamp(),
        'checkedInBy': ownerUserId,
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<int> enforceNoShowCancellations({String? userId, String? venueId}) async {
    // Client-side sweep (recommended server cron for production)
    Query q = _firestore.collection('bookings').where('status', isEqualTo: 'confirmed').where('isCheckedIn', isEqualTo: false);
    if (userId != null) q = q.where('userId', isEqualTo: userId);
    if (venueId != null) q = q.where('venueId', isEqualTo: venueId);
    final now = DateTime.now();
    final qs = await q.get();
    int updated = 0;
    final batch = _firestore.batch();
    for (final d in qs.docs) {
      final start = (d['startTime'] as Timestamp).toDate();
      if (now.isAfter(start.add(const Duration(minutes: 15)))) {
        batch.update(d.reference, {
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updated++;
      }
    }
    if (updated > 0) await batch.commit();
    return updated;
  }

  /// Check if room is available for open-ended booking starting at the given time
  /// This checks if there are any bookings after the start time
  @override
  Future<bool> isRoomAvailableForOpenEndedBooking(String venueId, String roomId, DateTime startTime) async {
    try {
      if (startTime.isBefore(DateTime.now())) {
        return false;
      }
      final snapshot = await _firestore
          .collection('bookings')
          .where('venueId', isEqualTo: venueId)
          .where('roomId', isEqualTo: roomId)
          .where('status', whereIn: ['confirmed', 'pending']) // Exclude cancelled bookings
          .get();

      for (final doc in snapshot.docs) {
        final booking = BookingEntity.fromMap(doc.data(), doc.id);
        
        // For open-ended bookings, check if there are any bookings that start after our start time
        // or if there are any bookings that overlap with our start time
        if (booking.startTime.isAfter(startTime) || 
            (booking.startTime.isBefore(startTime) && booking.endTime.isAfter(startTime))) {
          return false; // Room is not available for open-ended booking
        }
      }

      return true; // Room is available for open-ended booking
    } catch (e) {
      throw Exception('Failed to check room availability for open-ended booking: $e');
    }
  }

  /// Find the best available room for a given capacity and time
  /// Returns the room with the smallest capacity that can accommodate the group
  @override
  Future<Map<String, dynamic>?> findBestAvailableRoom({
    required String venueId,
    required int numberOfPeople,
    required DateTime startTime,
    required DateTime endTime,
    required bool isOpenEnded,
  }) async {
    try {
      // Get all rooms for the venue
      final roomsSnapshot = await _firestore
          .collection('venues')
          .doc(venueId)
          .collection('rooms')
          .where('isClosedForMaintenance', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> availableRooms = [];

      for (final roomDoc in roomsSnapshot.docs) {
        final roomData = roomDoc.data();
        final capacity = roomData['capacity'] ?? 0;
        
        // Check if room can accommodate the group
        if (capacity >= numberOfPeople) {
          // Check availability
          bool isAvailable;
          if (isOpenEnded) {
            isAvailable = await isRoomAvailableForOpenEndedBooking(venueId, roomDoc.id, startTime);
          } else {
            isAvailable = await isRoomAvailable(venueId, roomDoc.id, startTime, endTime);
          }

          if (isAvailable) {
            availableRooms.add({
              'roomId': roomDoc.id,
              'roomName': roomData['name'] ?? '',
              'capacity': capacity,
              'hourlyPrice': (roomData['hourlyPrice'] ?? 0.0).toDouble(),
              'description': roomData['description'] ?? '',
            });
          }
        }
      }

      // Sort by capacity (smallest first) and then by price (cheapest first)
      availableRooms.sort((a, b) {
        if (a['capacity'] != b['capacity']) {
          return a['capacity'].compareTo(b['capacity']);
        }
        return a['hourlyPrice'].compareTo(b['hourlyPrice']);
      });

      return availableRooms.isNotEmpty ? availableRooms.first : null;
    } catch (e) {
      throw Exception('Failed to find best available room: $e');
    }
  }

  /// Get all rooms and their bookings for availability checking
  @override
  Future<Map<String, dynamic>> getVenueAvailabilityData({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      // First, try to get cached data
      // final cachedData = await _cacheService.getCachedAvailabilityData(
      //   venueId: venueId,
      //   date: date,
      // );
      
      // if (cachedData != null) {
      //   return cachedData;
      // }

      // If not cached, fetch from database
      final roomsSnapshot = await _firestore
          .collection('venues')
          .doc(venueId)
          .collection('rooms')
          .get();

      List<Map<String, dynamic>> rooms = [];
      List<Map<String, dynamic>> allBookings = [];

      for (final roomDoc in roomsSnapshot.docs) {
        final roomData = roomDoc.data();
        rooms.add({
          'id': roomDoc.id,
          'roomId': roomDoc.id,
          'name': roomData['name'] ?? '',
          'capacity': roomData['capacity'] ?? 0,
          'hourlyPrice': (roomData['hourlyPrice'] ?? 0.0).toDouble(),
          'description': roomData['description'] ?? '',
          'isClosedForMaintenance': roomData['isClosedForMaintenance'] ?? false,
        });

        // Get bookings for this room on the specified date
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Avoid composite index errors: query by a single field (roomId) and filter in memory by date window and status
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('roomId', isEqualTo: roomDoc.id)
          .get();

      for (final bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data();
        final start = (bookingData['startTime'] as Timestamp).toDate();
        final end = (bookingData['endTime'] as Timestamp).toDate();
        final status = (bookingData['status'] ?? 'confirmed') as String;
        if (start.isBefore(endOfDay) && end.isAfter(startOfDay) && (status == 'confirmed' || status == 'pending')) {
          allBookings.add({
            'roomId': roomDoc.id,
            'startTime': start,
            'endTime': end,
            'status': status,
          });
        }
      }
      }

      final result = {
        'rooms': rooms,
        'bookings': allBookings,
      };

      // Cache the result
      // await _cacheService.cacheAvailabilityData(
      //   venueId: venueId,
      //   date: date,
      //   data: result,
      // );

      return result;
    } catch (e) {
      throw Exception('Failed to get venue availability data: $e');
    }
  }

  /// Batch load availability data for multiple dates
  @override
  Future<Map<DateTime, Map<String, dynamic>>> batchGetVenueAvailabilityData({
    required String venueId,
    required List<DateTime> dates,
  }) async {
    try {
      final result = <DateTime, Map<String, dynamic>>{};
      
      // First, try to get cached data for all dates
      // final cachedData = await _cacheService.getBatchCachedAvailabilityData(
      //   venueId: venueId,
      //   dates: dates,
      // );
      
      // Add cached data to result
      // result.addAll(cachedData);
      
      // Find dates that need to be fetched
      final datesToFetch = dates.where((date) => !result.containsKey(date)).toList();
      
      if (datesToFetch.isNotEmpty) {
        // Batch fetch from database
        final batchData = <DateTime, Map<String, dynamic>>{};
        
        for (final date in datesToFetch) {
          try {
            final data = await getVenueAvailabilityData(
              venueId: venueId,
              date: date,
            );
            batchData[date] = data;
          } catch (e) {
            // Continue with other dates if one fails
            print('Error fetching availability for date $date: $e');
          }
        }
        
        // Cache batch data
        // await _cacheService.batchCacheAvailabilityData(
        //   venueId: venueId,
        //   dataMap: batchData,
        // );
        
        // Add to result
        result.addAll(batchData);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to batch get venue availability data: $e');
    }
  }

  @override
  Future<void> addReview(String bookingId, int rating, String review) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'rating': rating,
        'review': review,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }
} 