import 'package:flutter/material.dart';
import '../../domain/entities/booking_entity.dart';

class ReviewDialog extends StatefulWidget {
  final BookingEntity booking;

  const ReviewDialog({
    super.key,
    required this.booking,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Experience'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.booking.venueName} - ${widget.booking.roomName}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('How would you rate your experience?'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 32,
                  color: index < _rating ? Colors.amber : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Share your experience (optional):'),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tell us about your experience...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0
              ? () {
                  Navigator.of(context).pop({
                    'rating': _rating,
                    'review': _reviewController.text.trim(),
                  });
                }
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
} 