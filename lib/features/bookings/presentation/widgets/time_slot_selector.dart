import 'package:flutter/material.dart';
import '../../../../shared/utils/time_slot_utils.dart';

class TimeSlotSelector extends StatefulWidget {
  final String openTime;
  final String closeTime;
  final int slotDurationMinutes;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> existingBookings;
  final Function(List<String>) onTimeSlotsSelected;

  const TimeSlotSelector({
    super.key,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
    required this.selectedDate,
    required this.existingBookings,
    required this.onTimeSlotsSelected,
  });

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  final Set<String> selectedTimeSlots = {};

  @override
  void initState() {
    super.initState();
    // Don't call onTimeSlotsSelected during initState to avoid setState during build
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = TimeSlotUtils.generateTimeSlots(
      openTime: widget.openTime,
      closeTime: widget.closeTime,
      slotDurationMinutes: widget.slotDurationMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Time Slots',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Date: ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        if (timeSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No available time slots for this date',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((timeSlot) {
              final isAvailable = TimeSlotUtils.isTimeSlotAvailable(
                timeSlot: timeSlot,
                date: widget.selectedDate,
                existingBookings: widget.existingBookings,
              );
              
              final isSelected = selectedTimeSlots.contains(timeSlot);
              
              return FilterChip(
                label: Text(
                  TimeSlotUtils.formatTimeSlot(timeSlot),
                  style: TextStyle(
                    color: isAvailable 
                      ? (isSelected ? Colors.white : Colors.black)
                      : Colors.grey,
                  ),
                ),
                selected: isSelected,
                onSelected: isAvailable ? (selected) {
                  setState(() {
                    if (selected) {
                      selectedTimeSlots.add(timeSlot);
                    } else {
                      selectedTimeSlots.remove(timeSlot);
                    }
                  });
                  
                  // Notify parent of selected time slots
                  final sortedSlots = selectedTimeSlots.toList()..sort();
                  widget.onTimeSlotsSelected(sortedSlots);
                } : null,
                backgroundColor: isAvailable ? Colors.grey[200] : Colors.grey[100],
                selectedColor: Theme.of(context).primaryColor,
                checkmarkColor: Colors.white,
                disabledColor: Colors.grey[100],
              );
            }).toList(),
          ),
        
        if (selectedTimeSlots.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Time Slots (${selectedTimeSlots.length}):',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: (selectedTimeSlots.toList()..sort()).map((timeSlot) {
                    return Chip(
                      label: Text(
                        TimeSlotUtils.formatTimeSlot(timeSlot),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          selectedTimeSlots.remove(timeSlot);
                        });
                        final sortedSlots = selectedTimeSlots.toList()..sort();
                        widget.onTimeSlotsSelected(sortedSlots);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 