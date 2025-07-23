import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../data/repositories/booking_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/check_room_availability.dart';
import '../../domain/usecases/create_booking.dart';

final bookingRepositoryProvider = Provider((ref) => BookingRepositoryImpl(firestore: FirebaseFirestore.instance));

final bookingsForUserProvider = FutureProvider.family<List<BookingEntity>, String>((ref, userId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingsForUser(userId);
});

final bookingsForVenueProvider = FutureProvider.family<List<BookingEntity>, String>((ref, venueId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingsForVenue(venueId);
});

final bookingsForRoomOnDateProvider = StreamProvider.family<List<BookingEntity>, Map<String, dynamic>>((ref, params) {
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
      .map((snapshot) => snapshot.docs.map((doc) => BookingEntity.fromMap(doc.data(), doc.id)).toList());
});

final checkRoomAvailabilityProvider = Provider((ref) => CheckRoomAvailability(ref.watch(bookingRepositoryProvider)));
final createBookingProvider = Provider((ref) => CreateBooking(ref.watch(bookingRepositoryProvider))); 