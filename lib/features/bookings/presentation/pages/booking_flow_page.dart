import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/app_state_service.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../providers/booking_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';

class BookingFlowPage extends ConsumerStatefulWidget {
  final String venueId;
  final String roomId;
  final double hourlyPrice;
  final String userId;
  const BookingFlowPage({
    required this.venueId,
    required this.roomId,
    required this.hourlyPrice,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends ConsumerState<BookingFlowPage> {
  DateTime selectedDate = DateTime.now();
  DateTime? selectedTimeSlot;
  bool isSubmitting = false;
  String? feedback;
  bool isDatePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final savedState = await AppStateService.getPageState('booking_flow');
    if (savedState != null) {
      setState(() {
        if (savedState['selectedDate'] != null) {
          selectedDate = DateTime.parse(savedState['selectedDate']);
        }
        if (savedState['selectedTimeSlot'] != null) {
          selectedTimeSlot = DateTime.parse(savedState['selectedTimeSlot']);
        }
      });
    }
  }

  // Debounce timer for setState calls
  bool _isUpdating = false;

  // Optimized date formatting
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Optimized time formatting
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Debounced setState to prevent rapid rebuilds
  void _debouncedSetState(VoidCallback fn) {
    if (!_isUpdating) {
      setState(() {
        _isUpdating = true;
        fn();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkAvailability = ref.watch(checkRoomAvailabilityProvider);
    final authState = ref.watch(authProvider);

    // Save booking flow state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = {
        'venueId': widget.venueId,
        'roomId': widget.roomId,
        'hourlyPrice': widget.hourlyPrice,
        'userId': widget.userId,
        'selectedDate': selectedDate.toIso8601String(),
        'selectedTimeSlot': selectedTimeSlot?.toIso8601String(),
      };
      AppStateService.savePageState('booking_flow', currentState);
      ref.read(navigationStateProvider.notifier).updateCurrentRoute('/booking-flow');
    });

    // Check if user is a guest user and redirect to login
    if (authState.isGuestUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Guest users cannot make bookings. Please log in to continue.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        );
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Book Room')),
        body: const Center(child: Text('Redirecting to login...')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (isDatePickerOpen) return; // Prevent multiple taps

                      _debouncedSetState(() {
                        isDatePickerOpen = true;
                      });
                      
                      try {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(
                                  context,
                                ).colorScheme.copyWith(primary: Colors.blue),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                        if (mounted) {
                          _debouncedSetState(() {
                        isDatePickerOpen = false;
                      if (picked != null) {
                          selectedDate = picked;
                          selectedTimeSlot = null; // Reset time selection when date changes
                            }
                        });
                        
                          if (picked != null) {
                        // Show feedback to user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                                content: Text('Date selected: ${_formatDate(picked)}'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          _debouncedSetState(() {
                            isDatePickerOpen = false;
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(_formatDate(selectedDate), style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Select Time Slot:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FutureBuilder(
              future: checkAvailability.call(roomId: widget.roomId, date: selectedDate),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text('Error loading time slots: ${snapshot.error}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // This will trigger a rebuild and retry
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Loading available time slots...'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final slots = snapshot.data as List<TimeSlot>;
                
                if (slots.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange, size: 48),
                          const SizedBox(height: 8),
                          const Text('No time slots available for this date'),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Time Slots:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Select a 30-minute time slot:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((slot) {
                        final startLabel = _formatTime(slot.start);
                        final endLabel = _formatTime(slot.end);
                        final label = '$startLabel - $endLabel';
                        
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: slot.isAvailable ? null : Colors.white,
                              fontWeight: selectedTimeSlot == slot.start
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: selectedTimeSlot == slot.start,
                          onSelected: slot.isAvailable
                              ? (selected) {
                                  _debouncedSetState(() {
                                    selectedTimeSlot = selected ? slot.start : null;
                                  });
                                  if (selected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Time slot selected: $label'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          selectedColor: Colors.green,
                          disabledColor: Colors.grey.shade600,
                          backgroundColor: Colors.grey.shade100,
                          avatar: slot.isAvailable
                              ? null
                              : Icon(Icons.block, color: Colors.white, size: 16),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            if (selectedTimeSlot != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Summary',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Date', _formatDate(selectedDate)),
                      _buildSummaryRow(
                        'Time',
                        '${_formatTime(selectedTimeSlot!)} - ${_formatTime(selectedTimeSlot!.add(const Duration(minutes: 30)))}',
                      ),
                      _buildSummaryRow('Room', widget.roomId),
                      _buildSummaryRow('Venue', widget.venueId),
                      const Divider(),
                      _buildSummaryRow('Total Amount', '${widget.hourlyPrice} SAR', isTotal: true),
                    ],
                  ),
                ),
              ),
            if (selectedTimeSlot != null)
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        _debouncedSetState(() {
                          isSubmitting = true;
                          feedback = null;
                        });

                        try {
                        final start = selectedTimeSlot!;
                        final end = start.add(const Duration(minutes: 30));
                        final booking = BookingEntity(
                            id: '',
                          userId: widget.userId,
                          venueId: widget.venueId,
                          roomId: widget.roomId,
                          startTime: Timestamp.fromDate(start),
                          endTime: Timestamp.fromDate(end),
                            durationHours: 0,
                            roomFee: widget.hourlyPrice * 0.5,
                          reservationFee: 0,
                          totalAmount: widget.hourlyPrice * 0.5,
                          paymentStatus: 'pending',
                          bookingStatus: 'pending',
                          paymentIntentId: null,
                          createdAt: Timestamp.now(),
                          updatedAt: Timestamp.now(),
                        );

                          await ref.read(createBookingProvider).call(booking);

                          if (mounted) {
                            _debouncedSetState(() {
                            feedback = 'Booking successful!';
                            isSubmitting = false;
                          });

                            // Navigate to booking confirmation page
                            final bookingId = DateTime.now().millisecondsSinceEpoch.toString();
                            final venueName =
                                'The Pixel Palace'; // This should come from venue data
                            final roomName =
                                'Room ${widget.roomId}'; // This should come from room data
                            final bookingDate = selectedTimeSlot!;
                            final durationHours =
                                1; // 30 minutes = 0.5 hours, but showing as 1 hour for demo
                            final totalPrice = widget.hourlyPrice * 0.5;

                            context.go(
                              '/booking-confirmation?bookingId=$bookingId&venueName=${Uri.encodeComponent(venueName)}&roomName=${Uri.encodeComponent(roomName)}&bookingDate=${bookingDate.toIso8601String()}&durationHours=$durationHours&totalPrice=$totalPrice',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            _debouncedSetState(() {
                            feedback = 'Booking failed: $e';
                            isSubmitting = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          }
                        }
                      },
                      child: const Text('Confirm Booking'),
                    ),
            if (feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  feedback!,
                  style: TextStyle(
                    color: feedback!.contains('success') ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
} 
