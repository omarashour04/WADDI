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

  const BookingForm({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.roomId,
    required this.roomName,
    required this.hourlyPrice,
  });

  @override
  ConsumerState<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<BookingForm> {
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedTimeSlots = [];
  final _notesController = TextEditingController();
  bool _isLoading = false;

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

            // Time Slot Selection
            TimeSlotSelector(
              openTime: '09:00', // This should come from venue data
              closeTime: '22:00', // This should come from venue data
              slotDurationMinutes: 30, // This should come from venue data
              selectedDate: _selectedDate,
              existingBookings: [], // This should come from booking data
              onTimeSlotsSelected: (timeSlots) {
                setState(() {
                  _selectedTimeSlots = timeSlots;
                });
              },
            ),
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
      final endTime = TimeSlotUtils.timeSlotToDateTime(_selectedTimeSlots.last, _selectedDate);
      
      // Check if room is available for the selected time
      final isAvailable = await ref
          .read(bookingStateProvider.notifier)
          .isRoomAvailable(widget.venueId, widget.roomId, startTime, endTime);

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This time slot is no longer available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
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
        durationHours: (_selectedTimeSlots.length * 0.5).round(), // 30 min slots
        totalPrice: widget.hourlyPrice * _selectedTimeSlots.length * 0.5, // 30 min slots
        status: 'confirmed',
        notes: _notesController.text.trim(),
        rating: 0,
        review: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(bookingStateProvider.notifier).createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
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