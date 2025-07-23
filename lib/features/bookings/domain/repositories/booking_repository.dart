import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity?> getBookingById(String id);
  Future<List<BookingEntity>> getBookingsForUser(String userId);
  Future<List<BookingEntity>> getBookingsForVenue(String venueId);
  Future<void> createBooking(BookingEntity booking);
  Future<void> updateBooking(BookingEntity booking);
  Future<void> deleteBooking(String id);
  Future<List<BookingEntity>> getBookingsForRoomOnDate(String roomId, DateTime date);
} 