import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
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
  int? selectedHour;
  bool isSubmitting = false;
  String? feedback;

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
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      child: Text('${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
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
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final slots = snapshot.data as List<TimeSlot>;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((slot) {
                    final hour = slot.start.hour;
                    final label = '${slot.start.hour.toString().padLeft(2, '0')}:00 - ${slot.end.hour.toString().padLeft(2, '0')}:00';
                    return ChoiceChip(
                      label: Text(label),
                      selected: selectedHour == hour,
                      onSelected: slot.isAvailable
                          ? (selected) => setState(() => selectedHour = selected ? hour : null)
                          : null,
                      selectedColor: Colors.green,
                      disabledColor: Colors.grey.shade300,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            if (selectedHour != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: const Text('Booking Summary'),
                  subtitle: Text('Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}\nTime: ${selectedHour!.toString().padLeft(2, '0')}:00 - ${(selectedHour! + 1).toString().padLeft(2, '0')}:00\nRoom: ${widget.roomId}\nVenue: ${widget.venueId}\nTotal: ${widget.hourlyPrice} SAR'),
                ),
              ),
            if (selectedHour != null)
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSubmitting = true;
                          feedback = null;
                        });
                        final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedHour!);
                        final end = start.add(const Duration(hours: 1));
                        final booking = BookingEntity(
                          id: '', // Firestore will auto-generate
                          userId: widget.userId,
                          venueId: widget.venueId,
                          roomId: widget.roomId,
                          startTime: Timestamp.fromDate(start),
                          endTime: Timestamp.fromDate(end),
                          durationHours: 1,
                          roomFee: widget.hourlyPrice,
                          reservationFee: 0,
                          totalAmount: widget.hourlyPrice,
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
                        } catch (e) {
                          setState(() {
                            feedback = 'Booking failed: $e';
                            isSubmitting = false;
                          });
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
} 