import '../repositories/booking_repository.dart';
import '../entities/booking_entity.dart';

class CreateBooking {
  final BookingRepository repository;
  CreateBooking(this.repository);

  Future<void> call(BookingEntity booking) async {
    await repository.createBooking(booking);
  }
} 