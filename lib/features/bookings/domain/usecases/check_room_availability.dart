import '../repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckRoomAvailability {
  final BookingRepository repository;
  CheckRoomAvailability(this.repository);

  Future<List<TimeSlot>> call({required String roomId, required DateTime date}) async {
    // Fetch all bookings for the room on the given date
    final bookings = await repository.getBookingsForRoomOnDate(roomId, date);
    // Assume slots are hourly from 8am to 12am (customize as needed)
    final slots = <TimeSlot>[];
    for (int hour = 8; hour < 24; hour++) {
      final slotStart = DateTime(date.year, date.month, date.day, hour);
      final slotEnd = slotStart.add(const Duration(hours: 1));
      final isBooked = bookings.any((b) =>
        b.startTime.toDate().isBefore(slotEnd) && b.endTime.toDate().isAfter(slotStart)
      );
      slots.add(TimeSlot(start: slotStart, end: slotEnd, isAvailable: !isBooked));
    }
    return slots;
  }
}

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;
  TimeSlot({required this.start, required this.end, required this.isAvailable});
} 