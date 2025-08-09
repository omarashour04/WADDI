import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/booking_entity.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to booking details page
          context.go('/booking-details/${booking.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.venueName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.roomName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildStatusChip(),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.startTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _isOpenEndedBooking()
                      ? '${_formatTime(booking.startTime)} - Open-ended'
                      : '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _isOpenEndedBooking()
                      ? 'Duration: To be determined'
                      : '${booking.durationHours} hour${booking.durationHours != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _isOpenEndedBooking()
                      ? 'Price: To be determined (Cash only)'
                      : '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isOpenEndedBooking() ? Colors.orange[700] : Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${booking.numberOfPeople} person${booking.numberOfPeople != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (booking.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (booking.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.rating}/5',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (booking.review?.isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.review!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking.canCancel && onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (booking.canCheckIn)
                  ...[
                    if (booking.canCancel || booking.canReview) const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to a simple scanner page that reads room QR
                          // The scanner page will call the provider to check in by room scan
                          context.go('/check-in');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Scan to Check In'),
                      ),
                    ),
                  ],
                if (booking.canReview && onReview != null) ...[
                  if (booking.canCancel) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Review'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (booking.actualStatus) {
      case 'confirmed':
        color = Colors.green;
        text = 'Confirmed';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Completed';
        break;
      case 'in_progress':
        color = Colors.purple;
        text = 'In Progress';
        break;
      default:
        color = Colors.grey;
        text = booking.actualStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _isOpenEndedBooking() {
    // Check if it's an open-ended booking based on duration and price
    return booking.durationHours == 0 && booking.totalPrice == 0.0;
  }
} 