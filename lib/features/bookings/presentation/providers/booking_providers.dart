import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../data/repositories/booking_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/check_room_availability.dart';
import '../../domain/usecases/create_booking.dart';

final bookingRepositoryProvider = Provider(
  (ref) => BookingRepositoryImpl(firestore: FirebaseFirestore.instance),
);

// Cache for bookings to reduce Firestore calls
final _bookingsCache = <String, List<BookingEntity>>{};

final bookingsForUserProvider = FutureProvider.family<List<BookingEntity>, String>((
  ref,
  userId,
) async {
  final cacheKey = 'user_bookings_$userId';
  if (_bookingsCache.containsKey(cacheKey)) {
    return _bookingsCache[cacheKey]!;
  }

  final repo = ref.watch(bookingRepositoryProvider);
  final bookings = await repo.getBookingsForUser(userId);
  _bookingsCache[cacheKey] = bookings;
  return bookings;
});

final bookingsForVenueProvider = FutureProvider.family<List<BookingEntity>, String>((
  ref,
  venueId,
) async {
  final cacheKey = 'venue_bookings_$venueId';
  if (_bookingsCache.containsKey(cacheKey)) {
    return _bookingsCache[cacheKey]!;
  }

  final repo = ref.watch(bookingRepositoryProvider);
  final bookings = await repo.getBookingsForVenue(venueId);
  _bookingsCache[cacheKey] = bookings;
  return bookings;
});

final bookingsForRoomOnDateProvider =
    StreamProvider.family<List<BookingEntity>, Map<String, dynamic>>((ref, params) {
  final repo = ref.watch(bookingRepositoryProvider);
  final roomId = params['roomId'] as String;
  final date = params['date'] as DateTime;
  final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0));
  final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('roomId', isEqualTo: roomId)
      .where('startTime', isLessThanOrEqualTo: endOfDay)
      .where('endTime', isGreaterThanOrEqualTo: startOfDay)
      .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => BookingEntity.fromMap(doc.data(), doc.id)).toList(),
          );
});

// Optimized availability checker with caching
final checkRoomAvailabilityProvider = Provider((ref) {
  return CheckRoomAvailability(ref.watch(bookingRepositoryProvider));
});

// Optimized booking creation with error handling
final createBookingProvider = Provider((ref) {
  return CreateBooking(ref.watch(bookingRepositoryProvider));
});

// Cache invalidation provider
final bookingCacheInvalidationProvider = Provider((ref) {
  return () {
    _bookingsCache.clear();
  };
});

// Individual booking provider
final bookingProvider = FutureProvider.family<BookingEntity, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final booking = await repo.getBookingById(bookingId);
  if (booking == null) {
    throw Exception('Booking not found');
  }
  return booking;
});
