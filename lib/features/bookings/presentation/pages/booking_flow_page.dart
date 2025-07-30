import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/shared/widgets/smart_back_button.dart';
import 'package:waddi_platform/shared/widgets/custom_button.dart';
import 'package:waddi_platform/shared/widgets/custom_text_field.dart';
import 'package:waddi_platform/shared/widgets/loading_indicator.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/shared/themes/app_typography.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/bookings/presentation/providers/booking_providers.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';

class BookingFlowPage extends ConsumerStatefulWidget {
  final String venueId;
  final String? roomId;

  const BookingFlowPage({super.key, required this.venueId, this.roomId});

  @override
  ConsumerState<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends ConsumerState<BookingFlowPage> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String _selectedTime = '09:00';
  String _selectedDuration = '1 hour';
  int _guestCount = 1;
  String _specialRequests = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _createBooking() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please complete all booking details')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please log in to create a booking')));
        }
        return;
      }

      // For now, just navigate to confirmation
      if (mounted) {
        context.go('/booking-confirmation/demo-booking-id');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (_isLoading) {
      return Scaffold(body: Center(child: LoadingIndicator()));
    }

    return MainScaffold(
      currentIndex: 1,
      userId: authState.user?.id ?? '',
      child: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step content
          Expanded(child: _buildStepContent()),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(onPressed: _previousStep, label: 'Previous'),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _currentStep == 3 ? _createBooking : _nextStep,
                    label: _currentStep == 3 ? 'Confirm Booking' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDateTimeSelectionStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDateTimeSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date & Time', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Date selection
          Text('Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select a date',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time selection
          Text('Time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTime,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              '09:00',
              '10:00',
              '11:00',
              '12:00',
              '13:00',
              '14:00',
              '15:00',
              '16:00',
              '17:00',
              '18:00',
              '19:00',
              '20:00',
            ].map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
            onChanged: (value) => setState(() => _selectedTime = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Duration selection
          Text('Duration', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDuration,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              '1 hour',
              '2 hours',
              '3 hours',
              '4 hours',
              '5 hours',
              '6 hours',
            ].map((duration) => DropdownMenuItem(value: duration, child: Text(duration))).toList(),
            onChanged: (value) => setState(() => _selectedDuration = value!),
          ),

          const SizedBox(height: 24),

          // Guest count
          Text('Number of Guests', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_guestCount > 1) {
                    setState(() => _guestCount--);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Center(
                  child: Text('$_guestCount', style: Theme.of(context).textTheme.headlineMedium),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_guestCount < 10) {
                    setState(() => _guestCount++);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Special requests
          Text('Special Requests (Optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CustomTextField(
            controller: TextEditingController(text: _specialRequests),
            hintText: 'Any special requirements...',
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final totalHours = int.parse(_selectedDuration.split(' ')[0]);
    final totalPrice = 50.0 * totalHours; // Fixed price for demo

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Booking', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),

                  _buildSummaryRow('Venue', 'Demo Venue'),
                  _buildSummaryRow('Room', 'Demo Room'),
                  _buildSummaryRow(
                    'Date',
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                  _buildSummaryRow('Time', _selectedTime),
                  _buildSummaryRow('Duration', _selectedDuration),
                  _buildSummaryRow('Guests', '$_guestCount'),
                  _buildSummaryRow('Price per hour', '\$50.00'),
                  const Divider(),
                  _buildSummaryRow(
                    'Total Price',
                    '\$${totalPrice.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),

          if (_specialRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Special Requests', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(_specialRequests),
                  ],
                ),
              ),
            ),
          ],
        ],
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
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
