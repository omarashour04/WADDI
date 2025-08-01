import '../repositories/booking_repository.dart';

class CheckRoomAvailability {
  final BookingRepository repository;

  CheckRoomAvailability(this.repository);

  Future<List<DateTime>> call(String venueId, String roomId, DateTime date) async {
    return await repository.getRoomAvailability(venueId, roomId, date);
  }
} 