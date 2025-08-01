import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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