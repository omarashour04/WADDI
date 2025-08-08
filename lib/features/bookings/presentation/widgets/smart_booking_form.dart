import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import 'smart_time_slot_selector.dart';

class SmartBookingForm extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final String openTime;
  final String closeTime;
  final int timeSlotDuration;

  const SmartBookingForm({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.openTime,
    required this.closeTime,
    required this.timeSlotDuration,
  });

  @override
  ConsumerState<SmartBookingForm> createState() => _SmartBookingFormState();
}

class _SmartBookingFormState extends ConsumerState<SmartBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedTimeSlots = [];
  bool _isOpenEndedBooking = false;
  int _numberOfPeople = 1;
  bool _isLoading = false;
  Map<String, dynamic>? _selectedRoom;
  bool _isSearchingRoom = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlots.clear();
        _selectedRoom = null;
      });
    }
  }

  Future<void> _findBestRoom() async {
    if (_selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearchingRoom = true;
    });

    try {
      final startTime = _getStartTime();
      final endTime = _getEndTime();

      final bestRoom = await ref.read(bookingStateProvider.notifier).findBestAvailableRoom(
        venueId: widget.venueId,
        numberOfPeople: _numberOfPeople,
        startTime: startTime,
        endTime: endTime,
        isOpenEnded: _isOpenEndedBooking,
      );

      setState(() {
        _selectedRoom = bestRoom;
        _isSearchingRoom = false;
      });

      if (bestRoom == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No suitable room available for $_numberOfPeople people at the selected time. '
                'This might be due to a recent booking. Please try a different time.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Found available room: ${bestRoom['roomName']} (Capacity: ${bestRoom['capacity']} people)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSearchingRoom = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime _getStartTime() {
    if (_selectedTimeSlots.isEmpty) return DateTime.now();
    final timeSlot = _selectedTimeSlots.first;
    final parts = timeSlot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
  }

  DateTime _getEndTime() {
    if (_isOpenEndedBooking) {
      // For open-ended bookings, set end time to close time
      final parts = widget.closeTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );
    } else {
      // For regular bookings, calculate based on selected time slots
      if (_selectedTimeSlots.isEmpty) return DateTime.now();
      
      final lastTimeSlot = _selectedTimeSlots.last;
      final parts = lastTimeSlot.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      ).add(Duration(minutes: widget.timeSlotDuration));
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please find an available room first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startTime = _getStartTime();
      final endTime = _getEndTime();
      
      // Calculate duration and price
      int durationHours;
      double totalPrice;
      
      if (_isOpenEndedBooking) {
        durationHours = 0; // Open-ended
        totalPrice = 0.0; // To be determined
      } else {
        durationHours = _selectedTimeSlots.length;
        totalPrice = (durationHours * _selectedRoom!['hourlyPrice']).toDouble();
      }

      final booking = BookingEntity(
        id: '',
        userId: ref.read(authProvider).user?.id ?? '',
        venueId: widget.venueId,
        roomId: _selectedRoom!['roomId'],
        venueName: widget.venueName, // Added missing parameter
        roomName: _selectedRoom!['roomName'], // Added missing parameter
        startTime: startTime,
        endTime: endTime,
        durationHours: durationHours,
        totalPrice: totalPrice,
        status: _isOpenEndedBooking ? 'confirmed' : 'pending',
        notes: _notesController.text.trim(),
        numberOfPeople: _numberOfPeople,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(bookingStateProvider.notifier).createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isOpenEndedBooking 
                ? 'Open-ended booking created successfully! Payment: Cash only'
                : 'Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
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

  Future<Map<String, dynamic>> getVenueAvailabilityData({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      return await ref.read(bookingStateProvider.notifier).getVenueAvailabilityData(
        venueId: venueId,
        date: date,
      );
    } catch (e) {
      throw Exception('Failed to get venue availability data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getAvailableRoomsForCapacity() async {
    try {
      final availabilityData = await ref
          .read(bookingStateProvider.notifier)
          .getVenueAvailabilityData(
            venueId: widget.venueId,
            date: _selectedDate,
          );

      final rooms = List<Map<String, dynamic>>.from(availabilityData['rooms'] ?? []);
      
      // Filter rooms that can accommodate the group and are not under maintenance
      return rooms.where((room) => 
        (room['capacity'] ?? 0) >= _numberOfPeople && 
        (room['isClosedForMaintenance'] ?? false) == false
      ).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.venueName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of People
              Text(
                'Number of People',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _numberOfPeople > 1 
                        ? () => setState(() => _numberOfPeople--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Text(
                      '$_numberOfPeople',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _numberOfPeople++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Available time slots will update based on your group size',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Booking Type Selection
              Text(
                'Booking Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                        child: Text(
                          'Open-ended bookings are cash only and automatically confirmed',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Date Selection
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Time Slot Selection
              Text(
                _isOpenEndedBooking ? 'Select Start Time' : 'Select Time Slots',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SmartTimeSlotSelector(
                venueId: widget.venueId,
                openTime: widget.openTime,
                closeTime: widget.closeTime,
                slotDurationMinutes: widget.timeSlotDuration,
                selectedDate: _selectedDate,
                numberOfPeople: _numberOfPeople,
                isOpenEndedBooking: _isOpenEndedBooking,
                onTimeSlotsSelected: (slots) {
                  setState(() {
                    _selectedTimeSlots = slots;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Find Room Button
              if (_selectedTimeSlots.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSearchingRoom ? null : _findBestRoom,
                    icon: _isSearchingRoom 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearchingRoom ? 'Finding Room...' : 'Find Available Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Selected Room Display
              if (_selectedRoom != null) ...[
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Room Found!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Room: ${_selectedRoom!['roomName']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Capacity: ${_selectedRoom!['capacity']} people'),
                        Text('Rate: \$${_selectedRoom!['hourlyPrice']}/hour'),
                        if (_selectedRoom!['description']?.isNotEmpty == true)
                          Text('Description: ${_selectedRoom!['description']}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
              if (_selectedRoom != null && _selectedTimeSlots.isNotEmpty)
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
                            const Text('People:'),
                            Text('$_numberOfPeople'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Duration:'),
                            Text(_isOpenEndedBooking 
                                ? 'Open-ended'
                                : '${_selectedTimeSlots.length} hour${_selectedTimeSlots.length != 1 ? 's' : ''}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Rate:'),
                            Text('\$${_selectedRoom!['hourlyPrice']}/hour'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isOpenEndedBooking 
                                  ? 'To be determined (Cash only)'
                                  : '\$${(_selectedTimeSlots.length * _selectedRoom!['hourlyPrice']).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Create Booking Button
              if (_selectedRoom != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isOpenEndedBooking ? 'Book Open-Ended' : 'Create Booking'),
                  ),
                ),
              const SizedBox(height: 24),

              // Available Rooms for Capacity
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAvailableRoomsForCapacity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final availableRooms = snapshot.data ?? [];
                  
                  if (availableRooms.isEmpty) {
                    return Container(
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
                              'No rooms available for $_numberOfPeople people. Please reduce the number of people.',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Rooms for $_numberOfPeople People',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...availableRooms.map((room) => Card(
                        child: ListTile(
                          leading: Icon(Icons.meeting_room, color: Colors.blue[600]),
                          title: Text(room['name'] ?? 'Room'),
                          subtitle: Text('Capacity: ${room['capacity']} people • \$${room['hourlyPrice']}/hour'),
                          trailing: Icon(Icons.check_circle, color: Colors.green[600]),
                        ),
                      )).toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 