import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/time_slot_utils.dart';
import '../providers/booking_provider.dart';

class SmartTimeSlotSelector extends ConsumerStatefulWidget {
  final String venueId;
  final String openTime;
  final String closeTime;
  final int slotDurationMinutes;
  final DateTime selectedDate;
  final int numberOfPeople;
  final bool isOpenEndedBooking;
  final Function(List<String>) onTimeSlotsSelected;

  const SmartTimeSlotSelector({
    super.key,
    required this.venueId,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
    required this.selectedDate,
    required this.numberOfPeople,
    required this.isOpenEndedBooking,
    required this.onTimeSlotsSelected,
  });

  @override
  ConsumerState<SmartTimeSlotSelector> createState() => _SmartTimeSlotSelectorState();
}

class _SmartTimeSlotSelectorState extends ConsumerState<SmartTimeSlotSelector> {
  final Set<String> selectedTimeSlots = {};
  bool _isLoading = true;
  List<String> _availableTimeSlots = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void didUpdateWidget(SmartTimeSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.numberOfPeople != widget.numberOfPeople ||
        oldWidget.isOpenEndedBooking != widget.isOpenEndedBooking) {
      _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      selectedTimeSlots.clear();
    });

    try {
      // Get venue availability data
      final availabilityData = await ref
          .read(bookingStateProvider.notifier)
          .getVenueAvailabilityData(
            venueId: widget.venueId,
            date: widget.selectedDate,
          );

      final rooms = List<Map<String, dynamic>>.from(availabilityData['rooms'] ?? []);
      final bookings = List<Map<String, dynamic>>.from(availabilityData['bookings'] ?? []);

      // Get available time slots for the capacity
      final availableSlots = TimeSlotUtils.getAvailableTimeSlotsForCapacity(
        openTime: widget.openTime,
        closeTime: widget.closeTime,
        slotDurationMinutes: widget.slotDurationMinutes,
        date: widget.selectedDate,
        numberOfPeople: widget.numberOfPeople,
        rooms: rooms,
        existingBookings: bookings,
        isOpenEnded: widget.isOpenEndedBooking,
      );

      setState(() {
        _availableTimeSlots = availableSlots;
        _isLoading = false;
      });

      // Notify parent of empty selection
      widget.onTimeSlotsSelected([]);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading availability: $e';
      });
    }
  }

  void _toggleTimeSlot(String timeSlot) {
    setState(() {
      if (widget.isOpenEndedBooking) {
        // For open-ended bookings, only allow single selection
        selectedTimeSlots.clear();
        selectedTimeSlots.add(timeSlot);
      } else {
        // For regular bookings, allow multiple selection
        if (selectedTimeSlots.contains(timeSlot)) {
          selectedTimeSlots.remove(timeSlot);
        } else {
          selectedTimeSlots.add(timeSlot);
        }
      }
    });

    // Notify parent of selection
    widget.onTimeSlotsSelected(selectedTimeSlots.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isOpenEndedBooking ? 'Select Start Time' : 'Select Time Slots',
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
        Text(
          'For ${widget.numberOfPeople} person${widget.numberOfPeople != 1 ? 's' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          )
        else if (_availableTimeSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No available time slots',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No rooms with capacity for ${widget.numberOfPeople} people are available at this time. Try a different date or reduce the number of people.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTimeSlots.map((timeSlot) {
              final isSelected = selectedTimeSlots.contains(timeSlot);
              
              return FilterChip(
                label: Text(
                  TimeSlotUtils.formatTimeSlot(timeSlot),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) => _toggleTimeSlot(timeSlot),
                backgroundColor: Colors.grey[200],
                selectedColor: widget.isOpenEndedBooking ? Colors.orange : Colors.blue,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected 
                      ? (widget.isOpenEndedBooking ? Colors.orange : Colors.blue)
                      : Colors.grey[400]!,
                ),
              );
            }).toList(),
          ),

        if (_availableTimeSlots.isNotEmpty && selectedTimeSlots.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isOpenEndedBooking
                        ? 'Start time selected: ${TimeSlotUtils.formatTimeSlot(selectedTimeSlots.first)}'
                        : '${selectedTimeSlots.length} time slot${selectedTimeSlots.length != 1 ? 's' : ''} selected',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 