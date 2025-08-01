import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BookNowButton extends ConsumerWidget {
  final String venueId;
  final String venueName;
  final String roomId;
  final String roomName;
  final double hourlyPrice;

  const BookNowButton({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.roomId,
    required this.roomName,
    required this.hourlyPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isGuest = authState.user?.isGuestUser == true;

    return ElevatedButton(
      onPressed: () {
        if (isGuest) {
          _showLoginDialog(context);
        } else {
          _navigateToBooking(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Book Now',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to book this room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
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
  }

  void _navigateToBooking(BuildContext context) {
    final queryParams = {
      'venueId': venueId,
      'venueName': venueName,
      'roomId': roomId,
      'roomName': roomName,
      'hourlyPrice': hourlyPrice.toString(),
    };
    
    final uri = Uri(path: '/book-room', queryParameters: queryParams);
    context.push(uri.toString());
  }
} 