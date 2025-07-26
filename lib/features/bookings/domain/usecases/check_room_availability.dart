import '../repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import '../entities/time_slot_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckRoomAvailability {
  final BookingRepository repository;
  CheckRoomAvailability(this.repository);

  Future<List<TimeSlot>> call({required String roomId, required DateTime date}) async {
    // Fetch all bookings for the room on the given date
    final bookings = await repository.getBookingsForRoomOnDate(roomId, date);
    
    // Create 30-minute slots from 8am to 12am (customize as needed)
    final slots = <TimeSlot>[];
    for (int hour = 8; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final slotStart = DateTime(date.year, date.month, date.day, hour, minute);
        final slotEnd = slotStart.add(const Duration(minutes: 30));
        
        // Check if this slot conflicts with any existing booking
        final isBooked = bookings.any((b) =>
          b.startTime.toDate().isBefore(slotEnd) && b.endTime.toDate().isAfter(slotStart)
        );
        
        slots.add(TimeSlot(start: slotStart, end: slotEnd, isAvailable: !isBooked));
      }
    }
    return slots;
  }
} 