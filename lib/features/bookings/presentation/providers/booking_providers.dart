import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/check_room_availability.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/entities/booking_entity.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl();
});

final checkRoomAvailabilityProvider = Provider<CheckRoomAvailability>((ref) {
  return CheckRoomAvailability(ref.watch(bookingRepositoryProvider));
});

final createBookingProvider = Provider<CreateBooking>((ref) {
  return CreateBooking(ref.watch(bookingRepositoryProvider));
});

final bookingsForUserProvider = FutureProvider.family<List<BookingEntity>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getUserBookings(userId);
});
