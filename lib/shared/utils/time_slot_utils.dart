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