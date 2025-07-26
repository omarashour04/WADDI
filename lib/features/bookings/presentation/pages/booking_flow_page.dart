import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../providers/booking_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingFlowPage extends ConsumerStatefulWidget {
  final String venueId;
  final String roomId;
  final double hourlyPrice;
  final String userId;
  const BookingFlowPage({required this.venueId, required this.roomId, required this.hourlyPrice, required this.userId, Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    final checkAvailability = ref.watch(checkRoomAvailabilityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Book Room')),
      body: Padding(
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
                      print('Date picker tapped');
                      setState(() {
                        isDatePickerOpen = true;
                      });
                      
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: Colors.blue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      setState(() {
                        isDatePickerOpen = false;
                      });
                      
                      print('Date picker result: $picked');
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          selectedTimeSlot = null; // Reset time selection when date changes
                        });
                        print('Date selected: $selectedDate');
                        
                        // Show feedback to user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Date selected: ${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                          Text(
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
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
                print('FutureBuilder state: ${snapshot.connectionState}');
                if (snapshot.hasError) {
                  print('FutureBuilder error: ${snapshot.error}');
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
                  print('FutureBuilder loading...');
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
                print('Available slots: ${slots.length}');
                
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
                    Text('Select a 30-minute time slot:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((slot) {
                        final startHour = slot.start.hour;
                        final startMinute = slot.start.minute;
                        final endHour = slot.end.hour;
                        final endMinute = slot.end.minute;
                        
                        // Format time labels
                        final startLabel = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
                        final endLabel = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
                        final label = '$startLabel - $endLabel';
                        
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: slot.isAvailable ? null : Colors.white,
                              fontWeight: selectedTimeSlot == slot.start ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: selectedTimeSlot == slot.start,
                          onSelected: slot.isAvailable
                              ? (selected) {
                                  setState(() {
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
                          disabledColor: Colors.grey.shade600, // Darker for taken slots
                          backgroundColor: Colors.grey.shade100,
                          avatar: slot.isAvailable ? null : Icon(Icons.block, color: Colors.white, size: 16),
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Date', '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                      _buildSummaryRow('Time', '${selectedTimeSlot!.hour.toString().padLeft(2, '0')}:${selectedTimeSlot!.minute.toString().padLeft(2, '0')} - ${selectedTimeSlot!.add(const Duration(minutes: 30)).hour.toString().padLeft(2, '0')}:${selectedTimeSlot!.add(const Duration(minutes: 30)).minute.toString().padLeft(2, '0')}'),
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
                        setState(() {
                          isSubmitting = true;
                          feedback = null;
                        });
                        final start = selectedTimeSlot!;
                        final end = start.add(const Duration(minutes: 30));
                        final booking = BookingEntity(
                          id: '', // Firestore will auto-generate
                          userId: widget.userId,
                          venueId: widget.venueId,
                          roomId: widget.roomId,
                          startTime: Timestamp.fromDate(start),
                          endTime: Timestamp.fromDate(end),
                          durationHours: 0, // We'll calculate the actual duration in minutes
                          roomFee: widget.hourlyPrice * 0.5, // Half hour price
                          reservationFee: 0,
                          totalAmount: widget.hourlyPrice * 0.5,
                          paymentStatus: 'pending',
                          bookingStatus: 'pending',
                          paymentIntentId: null,
                          createdAt: Timestamp.now(),
                          updatedAt: Timestamp.now(),
                        );
                        try {
                          await ref.read(createBookingProvider).call(booking);
                          setState(() {
                            feedback = 'Booking successful!';
                            isSubmitting = false;
                          });
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigate back or to booking history
                          Navigator.of(context).pop();
                        } catch (e) {
                          print('Booking error: $e');
                          setState(() {
                            feedback = 'Booking failed: $e';
                            isSubmitting = false;
                          });
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm Booking'),
                    ),
            if (feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(feedback!, style: TextStyle(color: feedback!.contains('success') ? Colors.green : Colors.red)),
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