import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/review_dialog.dart';
import '../../domain/entities/booking_entity.dart';

class UserBookingsPage extends ConsumerStatefulWidget {
  const UserBookingsPage({super.key});

  @override
  ConsumerState<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends ConsumerState<UserBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    final user = ref.read(authProvider).user;
    if (user != null && !user.isGuestUser) {
      ref.read(bookingStateProvider.notifier).loadUserBookings(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bookingState = ref.watch(bookingStateProvider);

    if (authState.user?.isGuestUser == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          leading: const SmartBackButton(),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your bookings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadBookings(),
        child: bookingState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(bookingState.bookings),
                  _buildBookingsList(bookingState.upcomingBookings),
                  _buildBookingsList(bookingState.pastBookings),
                ],
              ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring venues to make your first booking!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/venues'),
              child: const Text('Browse Venues'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookingCard(
            booking: booking,
            onCancel: () => _cancelBooking(booking.id),
            onReview: () => _showReviewDialog(booking),
          ),
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bookingStateProvider.notifier).cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showReviewDialog(BookingEntity booking) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReviewDialog(booking: booking),
    );

    if (result != null) {
      await ref.read(bookingStateProvider.notifier).addReview(
        booking.id,
        result['rating'] as int,
        result['review'] as String,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
} 