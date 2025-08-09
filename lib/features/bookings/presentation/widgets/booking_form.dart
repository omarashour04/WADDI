import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'time_slot_selector.dart';
import '../../../../shared/utils/time_slot_utils.dart';
import 'package:go_router/go_router.dart';

class BookingForm extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final String roomId;
  final String roomName;
  final double hourlyPrice;
  final String openTime;
  final String closeTime;
  final int timeSlotDuration;
  final bool allowOpenEndedBookings;

  const BookingForm({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.roomId,
    required this.roomName,
    required this.hourlyPrice,
    required this.openTime,
    required this.closeTime,
    required this.timeSlotDuration,
    required this.allowOpenEndedBookings,
  });

  @override
  ConsumerState<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<BookingForm> {
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedTimeSlots = [];
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isOpenEndedBooking = false; // New field for open-ended booking
  final int _numberOfPeople = 1; // Added numberOfPeople variable

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue and Room Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.venueName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.roomName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          '\$${widget.hourlyPrice}/hour',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTimeSlots = [];
                });
              },
            ),
            const SizedBox(height: 24),

            // Open-ended booking toggle
            if (widget.allowOpenEndedBookings)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: _isOpenEndedBooking ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Type',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOpenEndedBooking = false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: !_isOpenEndedBooking ? Colors.blue[50] : Colors.grey[100],
                                  border: Border.all(
                                    color: !_isOpenEndedBooking ? Colors.blue : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: !_isOpenEndedBooking ? Colors.blue : Colors.grey,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Regular',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !_isOpenEndedBooking ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Fixed duration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: !_isOpenEndedBooking ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isOpenEndedBooking = true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isOpenEndedBooking ? Colors.orange[50] : Colors.grey[100],
                                  border: Border.all(
                                    color: _isOpenEndedBooking ? Colors.orange : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      color: _isOpenEndedBooking ? Colors.orange : Colors.grey,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Open-Ended',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isOpenEndedBooking ? Colors.orange : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Flexible duration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isOpenEndedBooking ? Colors.orange : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isOpenEndedBooking) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cash Payment Only',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                    Text(
                                      'Open-ended bookings require cash payment. Contact venue owner for end time and pricing details.',
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
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Time Slot Selection (only show if not open-ended booking)
            if (!_isOpenEndedBooking) ...[
              Text(
                'Select Time Slots',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TimeSlotSelector(
                openTime: widget.openTime,
                closeTime: widget.closeTime,
                slotDurationMinutes: widget.timeSlotDuration,
                selectedDate: _selectedDate,
                existingBookings: [], // This should come from booking data
                onTimeSlotsSelected: (slots) {
                  setState(() {
                    _selectedTimeSlots = slots;
                  });
                },
                isOpenEndedBooking: _isOpenEndedBooking,
              ),
            ],

            // Start Time Selection for Open-Ended Bookings
            if (_isOpenEndedBooking) ...[
              Text(
                'Select Start Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TimeSlotSelector(
                openTime: widget.openTime,
                closeTime: widget.closeTime,
                slotDurationMinutes: widget.timeSlotDuration,
                selectedDate: _selectedDate,
                existingBookings: [], // This should come from booking data
                onTimeSlotsSelected: (slots) {
                  setState(() {
                    _selectedTimeSlots = slots;
                  });
                },
                singleSelection: true, // Only allow one time slot for start time
                isOpenEndedBooking: true, // This is for open-ended booking
              ),
            ],
            const SizedBox(height: 24),

            // Notes
            Text(
              'Additional Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special requirements or notes...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Price Summary
            if (_selectedTimeSlots.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Duration:'),
                          Text('${_selectedTimeSlots.length} hour${_selectedTimeSlots.length != 1 ? 's' : ''}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rate:'),
                          Text('\$${widget.hourlyPrice}/hour'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${(widget.hourlyPrice * _selectedTimeSlots.length).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook() ? _createBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canBook() {
    return _selectedTimeSlots.isNotEmpty && !_isLoading;
  }

  Future<void> _createBooking() async {
    if (!_canBook()) return;

    final user = ref.read(authProvider).user;
    if (user == null || user.isGuestUser) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to make a booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert time slots to DateTime objects
      final startTime = TimeSlotUtils.timeSlotToDateTime(_selectedTimeSlots.first, _selectedDate);
      final endTime = _isOpenEndedBooking 
          ? startTime.add(const Duration(days: 365)) // 1 year from start for open-ended
          : TimeSlotUtils.timeSlotToDateTime(_selectedTimeSlots.last, _selectedDate);
      
      // Check if room is available for the selected time
      bool isAvailable;
      if (_isOpenEndedBooking) {
        // For open-ended bookings, check if there are no bookings after the start time
        isAvailable = await ref
            .read(bookingStateProvider.notifier)
            .isRoomAvailableForOpenEndedBooking(widget.venueId, widget.roomId, startTime);
      } else {
        // For regular bookings, check if the specific time slot is available
        isAvailable = await ref
            .read(bookingStateProvider.notifier)
            .isRoomAvailable(widget.venueId, widget.roomId, startTime, endTime);
      }

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isOpenEndedBooking 
                  ? 'Cannot book open-ended from this time. There are existing bookings after this time slot.'
                  : 'This time slot is no longer available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Calculate duration and price
      final durationHours = _isOpenEndedBooking 
          ? 0 // Will be determined later
          : (_selectedTimeSlots.length * 0.5).round(); // 30 min slots
      
      final totalPrice = _isOpenEndedBooking 
          ? 0.0 // Will be determined later
          : (widget.hourlyPrice * _selectedTimeSlots.length * 0.5); // 30 min slots

      // Add notes about open-ended booking if applicable
      String notes = _notesController.text.trim();
      if (_isOpenEndedBooking) {
        notes = notes.isEmpty 
            ? 'Open-ended booking - Cash payment only'
            : '$notes\n\nOpen-ended booking - Cash payment only';
      }

      final booking = BookingEntity(
        id: '',
        userId: user.id,
        venueId: widget.venueId,
        roomId: widget.roomId,
        venueName: widget.venueName,
        roomName: widget.roomName,
        startTime: startTime,
        endTime: endTime,
        durationHours: durationHours,
        totalPrice: totalPrice,
        status: _isOpenEndedBooking ? 'confirmed' : 'confirmed', // Auto-confirm open-ended bookings
        notes: notes,
        rating: 0,
        review: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        numberOfPeople: _numberOfPeople, // Added missing parameter
      );

      await ref.read(bookingStateProvider.notifier).createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isOpenEndedBooking 
                ? 'Open-ended booking created successfully! Please contact the venue owner for end time and pricing details.'
                : 'Booking created successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Navigate to bookings page
        context.go('/bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 