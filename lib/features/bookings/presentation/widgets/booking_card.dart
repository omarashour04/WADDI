import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_colors.dart';
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
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to booking details page
          context.go('/booking-details/${booking.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.roomName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildStatusChip(),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColors.grey400,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(booking.startTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _isOpenEndedBooking()
                          ? '${_formatTime(booking.startTime)} - Open-ended'
                          : '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _isOpenEndedBooking()
                          ? 'Duration: To be determined'
                          : '${booking.durationHours} hour${booking.durationHours != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _isOpenEndedBooking()
                          ? 'Price: To be determined (Cash only)'
                          : '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isOpenEndedBooking() ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      '${booking.numberOfPeople} person${booking.numberOfPeople != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (booking.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.note, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          booking.notes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (booking.rating != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, size: 18, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.rating}/5',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (booking.review?.isNotEmpty == true) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            booking.review!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (booking.canCancel && onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (booking.canCheckIn)
                      ...[
                        if (booking.canCancel || booking.canReview) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to a simple scanner page that reads room QR
                              // The scanner page will call the provider to check in by room scan
                              context.go('/check-in');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Scan to Check In'),
                          ),
                        ),
                      ],
                    if (booking.canReview && onReview != null) ...[
                      if (booking.canCancel) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textOnSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
        color = AppColors.success;
        text = 'Confirmed';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'Pending';
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'Cancelled';
        break;
      case 'completed':
        color = AppColors.info;
        text = 'Completed';
        break;
      case 'in_progress':
        color = AppColors.primary;
        text = 'In Progress';
        break;
      default:
        color = AppColors.grey500;
        text = booking.actualStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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