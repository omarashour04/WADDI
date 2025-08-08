import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/time_slot_utils.dart';
import '../providers/booking_provider.dart';
import '../../../../shared/services/cache_service.dart';

class ProgressiveTimeSlotSelector extends ConsumerStatefulWidget {
  final String venueId;
  final String openTime;
  final String closeTime;
  final int slotDurationMinutes;
  final DateTime selectedDate;
  final int numberOfPeople;
  final bool isOpenEndedBooking;
  final Function(List<String>) onTimeSlotsSelected;
  final int initialLoadCount; // Number of time slots to load initially
  final int loadMoreCount; // Number of additional slots to load when scrolling

  const ProgressiveTimeSlotSelector({
    super.key,
    required this.venueId,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
    required this.selectedDate,
    required this.numberOfPeople,
    required this.isOpenEndedBooking,
    required this.onTimeSlotsSelected,
    this.initialLoadCount = 8,
    this.loadMoreCount = 4,
  });

  @override
  ConsumerState<ProgressiveTimeSlotSelector> createState() => _ProgressiveTimeSlotSelectorState();
}

class _ProgressiveTimeSlotSelectorState extends ConsumerState<ProgressiveTimeSlotSelector> {
  final Set<String> selectedTimeSlots = {};
  final List<String> _availableTimeSlots = [];
  final List<String> _displayedTimeSlots = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreSlots = true;
  String? _errorMessage;
  Map<String, dynamic>? _availabilityData;

  @override
  void initState() {
    super.initState();
    _loadAvailabilityData();
  }

  @override
  void didUpdateWidget(ProgressiveTimeSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.numberOfPeople != widget.numberOfPeople ||
        oldWidget.isOpenEndedBooking != widget.isOpenEndedBooking) {
      _resetAndReload();
    }
  }

  void _resetAndReload() {
    setState(() {
      _availableTimeSlots.clear();
      _displayedTimeSlots.clear();
      selectedTimeSlots.clear();
      _isLoading = true;
      _hasMoreSlots = true;
      _errorMessage = null;
    });
    _loadAvailabilityData();
  }

  Future<void> _loadAvailabilityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to get cached data first
      final cachedData = await CacheService.instance.getCachedAvailabilityData(
        venueId: widget.venueId,
        date: widget.selectedDate,
      );

      if (cachedData != null) {
        _processAvailabilityData(cachedData);
        return;
      }

      // If not cached, fetch from provider
      final availabilityData = await ref
          .read(bookingStateProvider.notifier)
          .getVenueAvailabilityData(
            venueId: widget.venueId,
            date: widget.selectedDate,
          );

      _processAvailabilityData(availabilityData);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading availability: $e';
      });
    }
  }

  void _processAvailabilityData(Map<String, dynamic> availabilityData) {
    final rooms = List<Map<String, dynamic>>.from(availabilityData['rooms'] ?? []);
    final bookings = List<Map<String, dynamic>>.from(availabilityData['bookings'] ?? []);

    // Get all available time slots for the capacity
    final allAvailableSlots = TimeSlotUtils.getAvailableTimeSlotsForCapacity(
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
      _availabilityData = availabilityData;
      _availableTimeSlots.clear();
      _availableTimeSlots.addAll(allAvailableSlots);
      _isLoading = false;
      _hasMoreSlots = allAvailableSlots.length > widget.initialLoadCount;
    });

    // Load initial batch
    _loadMoreSlots();
  }

  void _loadMoreSlots() {
    if (_isLoadingMore || !_hasMoreSlots) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final currentCount = _displayedTimeSlots.length;
      final nextBatch = _availableTimeSlots.skip(currentCount).take(widget.loadMoreCount).toList();
      
      setState(() {
        _displayedTimeSlots.addAll(nextBatch);
        _isLoadingMore = false;
        _hasMoreSlots = _displayedTimeSlots.length < _availableTimeSlots.length;
      });
    });
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
                IconButton(
                  onPressed: _loadAvailabilityData,
                  icon: Icon(Icons.refresh, color: Colors.red[700]),
                  iconSize: 20,
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
          Column(
            children: [
              // Time slots grid with progressive loading
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _displayedTimeSlots.map((timeSlot) {
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

              // Load more button
              if (_hasMoreSlots) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: _isLoadingMore ? null : _loadMoreSlots,
                    icon: _isLoadingMore 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(_isLoadingMore ? 'Loading...' : 'Load More'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
              ],

              // Progress indicator
              if (_availableTimeSlots.isNotEmpty) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _displayedTimeSlots.length / _availableTimeSlots.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing ${_displayedTimeSlots.length} of ${_availableTimeSlots.length} available slots',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),

        // Selection summary
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