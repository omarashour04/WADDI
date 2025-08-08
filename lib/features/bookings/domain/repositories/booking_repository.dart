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
  Future<bool> isRoomAvailableForOpenEndedBooking(String venueId, String roomId, DateTime startTime);
  Future<Map<String, dynamic>?> findBestAvailableRoom({
    required String venueId,
    required int numberOfPeople,
    required DateTime startTime,
    required DateTime endTime,
    required bool isOpenEnded,
  });
  Future<Map<String, dynamic>> getVenueAvailabilityData({
    required String venueId,
    required DateTime date,
  });
  Future<Map<DateTime, Map<String, dynamic>>> batchGetVenueAvailabilityData({
    required String venueId,
    required List<DateTime> dates,
  });
  Future<void> addReview(String bookingId, int rating, String review);
} 