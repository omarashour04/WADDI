import 'package:flutter/material.dart';

class TimeSlotUtils {
  /// Generate time slots based on venue operating hours
  static List<String> generateTimeSlots({
    required String openTime,
    required String closeTime,
    required int slotDurationMinutes,
  }) {
    final slots = <String>[];
    
    try {
      // Parse open and close times
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');
      
      if (openParts.length != 2 || closeParts.length != 2) {
        return slots;
      }
      
      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      final closeHour = int.parse(closeParts[0]);
      final closeMinute = int.parse(closeParts[1]);
      
      // Convert to minutes for easier calculation
      final openMinutes = openHour * 60 + openMinute;
      final closeMinutes = closeHour * 60 + closeMinute;
      
      // Generate slots
      for (int minutes = openMinutes; minutes < closeMinutes; minutes += slotDurationMinutes) {
        final hour = minutes ~/ 60;
        final minute = minutes % 60;
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(timeString);
      }
    } catch (e) {
      print('Error generating time slots: $e');
    }
    
    return slots;
  }
  
  /// Check if a time slot is available (not booked)
  static bool isTimeSlotAvailable({
    required String timeSlot,
    required DateTime date,
    required List<Map<String, dynamic>> existingBookings,
  }) {
    final bookingDate = DateTime(date.year, date.month, date.day);
    
    // Check if any existing booking conflicts with this time slot
    for (final booking in existingBookings) {
      final bookingStart = (booking['startTime'] as DateTime);
      final bookingEnd = (booking['endTime'] as DateTime);
      
      // If booking is on the same date
      if (bookingStart.year == bookingDate.year &&
          bookingStart.month == bookingDate.month &&
          bookingStart.day == bookingDate.day) {
        
        // Check if the time slot conflicts with existing booking
        final slotTime = _parseTimeString(timeSlot);
        final slotDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          slotTime.hour,
          slotTime.minute,
        );
        
        if (slotDateTime.isBefore(bookingEnd) && 
            slotDateTime.add(const Duration(minutes: 30)).isAfter(bookingStart)) {
          return false; // Conflict found
        }
      }
    }
    
    return true; // No conflicts
  }

  /// Check if a time slot is available for open-ended booking
  /// This checks if there are any bookings after the start time
  static bool isTimeSlotAvailableForOpenEndedBooking({
    required String timeSlot,
    required DateTime date,
    required List<Map<String, dynamic>> existingBookings,
  }) {
    final bookingDate = DateTime(date.year, date.month, date.day);
    
    // Parse the time slot
    final slotTime = _parseTimeString(timeSlot);
    final slotDateTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      slotTime.hour,
      slotTime.minute,
    );
    
    // Check if any existing booking starts after our start time
    // or if any booking overlaps with our start time
    for (final booking in existingBookings) {
      final bookingStart = (booking['startTime'] as DateTime);
      final bookingEnd = (booking['endTime'] as DateTime);
      
      // If booking is on the same date or later
      if (bookingStart.year == bookingDate.year &&
          bookingStart.month == bookingDate.month &&
          bookingStart.day == bookingDate.day) {
        
        // Check if booking starts after our start time
        if (bookingStart.isAfter(slotDateTime)) {
          return false; // There's a booking after our start time
        }
        
        // Check if booking overlaps with our start time
        if (bookingStart.isBefore(slotDateTime) && bookingEnd.isAfter(slotDateTime)) {
          return false; // There's a booking that overlaps with our start time
        }
      }
      
      // Check for bookings on future dates
      if (bookingStart.isAfter(slotDateTime)) {
        return false; // There's a booking after our start time
      }
    }
    
    return true; // No conflicts for open-ended booking
  }

  /// Check if a time slot is available across multiple rooms based on capacity
  /// Returns true if at least one room with sufficient capacity is available
  static bool isTimeSlotAvailableForCapacity({
    required String timeSlot,
    required DateTime date,
    required int numberOfPeople,
    required List<Map<String, dynamic>> rooms,
    required List<Map<String, dynamic>> existingBookings,
    required bool isOpenEnded,
  }) {
    // Filter rooms that can accommodate the group
    final suitableRooms = rooms.where((room) => 
      (room['capacity'] ?? 0) >= numberOfPeople && 
      (room['isClosedForMaintenance'] ?? false) == false
    ).toList();

    if (suitableRooms.isEmpty) {
      return false; // No suitable rooms available
    }

    // Check availability for each suitable room
    for (final room in suitableRooms) {
      final roomId = room['id'] ?? room['roomId'] ?? '';
      final roomBookings = existingBookings.where((booking) => 
        (booking['roomId'] ?? '') == roomId
      ).toList();

      bool isAvailable;
      if (isOpenEnded) {
        isAvailable = isTimeSlotAvailableForOpenEndedBooking(
          timeSlot: timeSlot,
          date: date,
          existingBookings: roomBookings,
        );
      } else {
        isAvailable = isTimeSlotAvailable(
          timeSlot: timeSlot,
          date: date,
          existingBookings: roomBookings,
        );
      }

      if (isAvailable) {
        return true; // At least one suitable room is available
      }
    }

    return false; // No suitable rooms are available for this time slot
  }

  /// Get all available time slots for a given capacity across all suitable rooms
  static List<String> getAvailableTimeSlotsForCapacity({
    required String openTime,
    required String closeTime,
    required int slotDurationMinutes,
    required DateTime date,
    required int numberOfPeople,
    required List<Map<String, dynamic>> rooms,
    required List<Map<String, dynamic>> existingBookings,
    required bool isOpenEnded,
  }) {
    final allTimeSlots = generateTimeSlots(
      openTime: openTime,
      closeTime: closeTime,
      slotDurationMinutes: slotDurationMinutes,
    );

    return allTimeSlots.where((timeSlot) => 
      isTimeSlotAvailableForCapacity(
        timeSlot: timeSlot,
        date: date,
        numberOfPeople: numberOfPeople,
        rooms: rooms,
        existingBookings: existingBookings,
        isOpenEnded: isOpenEnded,
      )
    ).toList();
  }
  
  /// Parse time string (HH:MM) to TimeOfDay
  static TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
  
  /// Format time slot for display
  static String formatTimeSlot(String timeSlot) {
    try {
      final parts = timeSlot.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeSlot;
    }
  }
  
  /// Convert time slot string to DateTime
  static DateTime timeSlotToDateTime(String timeSlot, DateTime date) {
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
} 