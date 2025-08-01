import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getUserBookings(String userId);
  Future<List<BookingEntity>> getVenueBookings(String venueId);
  Future<List<BookingEntity>> getRoomBookings(String venueId, String roomId);
  Future<BookingEntity?> getBooking(String bookingId);
  Future<String> createBooking(BookingEntity booking);
  Future<void> updateBooking(BookingEntity booking);
  Future<void> cancelBooking(String bookingId);
  Future<void> deleteBooking(String bookingId);
  Future<List<DateTime>> getRoomAvailability(String venueId, String roomId, DateTime date);
  Future<bool> isRoomAvailable(String venueId, String roomId, DateTime startTime, DateTime endTime);
  Future<void> addReview(String bookingId, int rating, String review);
} 