import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/bookings/domain/entities/booking_entity.dart';
import 'package:waddi_platform/features/venues/domain/entities/venue_entity.dart';
import 'package:waddi_platform/features/venues/domain/entities/room_entity.dart';
import '../providers/booking_providers.dart';
import '../../../venues/presentation/providers/venue_providers.dart';

class BookingDetailsPage extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingProvider(bookingId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Booking Details'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.pop();
            } catch (e) {
              context.go('/bookings/${authState.user?.id}');
            }
          },
        ),
      ),
      body: bookingAsync.when(
        data: (booking) {
          return _BookingDetailsContent(booking: booking);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading booking details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(bookingProvider(bookingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDetailsContent extends ConsumerWidget {
  final BookingEntity booking;

  const _BookingDetailsContent({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueProvider(booking.venueId));
    final roomAsync = ref.watch(roomProvider(booking.roomId));

    return Container(
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Section
            _buildSection(
              context,
              title: 'Venue',
              child: venueAsync.when(
                data: (venue) => _buildVenueInfo(context, venue),
                loading: () => _buildVenueSkeleton(),
                error: (_, __) => _buildVenueInfo(context, null),
              ),
            ),

            const SizedBox(height: 24),

            // Room Details Section
            _buildSection(
              context,
              title: 'Room Details',
              child: roomAsync.when(
                data: (room) => _buildRoomInfo(context, room),
                loading: () => _buildRoomSkeleton(),
                error: (_, __) => _buildRoomInfo(context, null),
              ),
            ),

            const SizedBox(height: 24),

            // Booking Information Section
            _buildSection(context, title: 'Booking Information', child: _buildBookingInfo(context)),

            const SizedBox(height: 24),

            // Cancellation Policy Section
            _buildSection(
              context,
              title: 'Cancellation Policy',
              child: _buildCancellationPolicy(context),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildVenueInfo(BuildContext context, VenueEntity? venue) {
    return Row(
      children: [
        // Venue Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: venue?.images.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    venue!.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.business, color: AppColors.primary, size: 30);
                    },
                  ),
                )
              : Icon(Icons.business, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 12),
        // Venue Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venue?.name ?? 'Game Haven',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                venue?.address ?? '123 Elm Street, Anytown',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueSkeleton() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, color: Colors.grey[300]),
              const SizedBox(height: 4),
              Container(height: 12, width: 150, color: Colors.grey[300]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInfo(BuildContext context, RoomEntity? room) {
    return Row(
      children: [
        // Room Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.play_arrow, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 12),
        // Room Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room?.name ?? 'Private Gaming Room',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Room ${room?.id ?? '1'}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSkeleton() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 140, color: Colors.grey[300]),
              const SizedBox(height: 4),
              Container(height: 12, width: 80, color: Colors.grey[300]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingInfo(BuildContext context) {
    final startTime = booking.startTime.toDate();
    final endTime = booking.endTime.toDate();
    final duration = endTime.difference(startTime).inHours;
    final dateFormat = '${_getMonthName(startTime.month)} ${startTime.day}, ${startTime.year}';
    final timeFormat =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        _buildInfoRow('Date', dateFormat),
        _buildInfoRow('Time', timeFormat),
        _buildInfoRow('Duration', '$duration hour${duration > 1 ? 's' : ''}'),
        _buildInfoRow('Total Cost', 'SAR ${booking.totalAmount.toStringAsFixed(2)}'),
        _buildInfoRow('Status', booking.bookingStatus, isStatus: true),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isStatus ? _getStatusColor(value) : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textPrimary;
    }
  }

  Widget _buildCancellationPolicy(BuildContext context) {
    return Text(
      'Cancellations must be made at least 24 hours in advance for a full refund.',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Contact Venue Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Contact venue functionality
              ref
                  .read(venueProvider(booking.venueId))
                  .when(
                    data: (venue) {
                      if (venue?.contactPhone != null && venue!.contactPhone!.isNotEmpty) {
                        // Show contact options dialog
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Contact Venue'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Venue: ${venue.name}'),
                                const SizedBox(height: 8),
                                Text('Phone: ${venue.contactPhone}'),
                                if (venue.contactEmail != null && venue.contactEmail!.isNotEmpty)
                                  Text('Email: ${venue.contactEmail}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Close'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  // Launch phone call
                                  _launchPhoneCall(context, venue.contactPhone!);
                                },
                                child: const Text('Call'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact information not available for this venue.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    loading: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Loading venue information...'))),
                    error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to load venue contact information.'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textOnSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Contact Venue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Get Directions Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Get directions functionality
              ref
                  .read(venueProvider(booking.venueId))
                  .when(
                    data: (venue) {
                      if (venue?.address != null && venue!.address!.isNotEmpty) {
                        // Launch maps with venue address
                        _launchDirections(context, venue.address!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address not available for this venue.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    loading: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Loading venue information...'))),
                    error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to load venue address.'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Get Directions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Manage Booking Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Manage booking functionality
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Manage Booking'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking ID: ${booking.id}'),
                      const SizedBox(height: 8),
                      Text('Status: ${booking.bookingStatus}'),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${_formatDateTime(booking.startTime.toDate(), booking.durationHours)}',
                      ),
                      const SizedBox(height: 16),
                      const Text('What would you like to do?'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _cancelBooking(context, booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Manage Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<void> _launchPhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone app.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _launchDirections(BuildContext context, String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse('https://maps.google.com/maps?q=$encodedAddress');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch maps app.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime date, int durationHours) {
    final startTime = date;
    final endTime = date.add(Duration(hours: durationHours));

    final dateFormat = '${_getMonthName(startTime.month)} ${startTime.day}, ${startTime.year}';
    final startTimeFormat =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeFormat =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$dateFormat, $startTimeFormat - $endTimeFormat';
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Update booking status in Firestore
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'bookingStatus': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to bookings page
          context.pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling booking: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
 