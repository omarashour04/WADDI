import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/review_dialog.dart';
import '../../domain/entities/booking_entity.dart';
import '../../../../shared/providers/connectivity_provider.dart';

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
    
    // Listen to connectivity changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(connectivityProvider, (previous, next) {
        next.when(
          data: (isOnline) {
            if (isOnline && previous?.value == false) {
              // User came back online, synchronize data
              final authState = ref.read(authProvider);
              if (authState.user != null && !authState.user!.isGuestUser) {
                ref.read(bookingStateProvider.notifier).synchronizeOfflineData(authState.user!.id);
              }
            }
          },
          loading: () {},
          error: (_, __) {},
        );
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we have a valid user and the state is not already loading
    final user = ref.read(authProvider).user;
    final bookingState = ref.read(bookingStateProvider);
    if (user != null && !user.isGuestUser && !bookingState.isLoading) {
      _loadBookings();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    try {
      final user = ref.read(authProvider).user;
      if (user != null && !user.isGuestUser && user.id.isNotEmpty) {
        ref.read(bookingStateProvider.notifier).loadUserBookings(user.id);
      }
    } catch (e) {
      print('Error in _loadBookings: $e');
      // Don't let errors in this method crash the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingStateProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOnline = connectivityAsync.when(
      data: (isOnline) => isOnline,
      loading: () => true, // Assume online while loading
      error: (_, __) => false, // Assume offline on error
    );

    // Load bookings if empty
    if (bookingState.allBookings.isEmpty && !bookingState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
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
      body: Column(
        children: [
          // Connectivity Status Indicator
          if (!isOnline && bookingState.allBookings.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode - Showing cached data',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _loadBookings(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: _buildBody(bookingState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BookingState bookingState) {
    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingState.errorMessage != null
              ? _buildErrorState()
              : _tabController.length > 0
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(bookingState.allBookings),
                        _buildBookingsList(bookingState.upcomingBookings),
                        _buildBookingsList(bookingState.pastBookings),
                      ],
                    )
                  : const Center(child: Text('Loading tabs...')),
    );
  }

  Widget _buildBookingsList(List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        if (booking == null) return const SizedBox.shrink();
        
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings Found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t made any bookings yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Browse Venues'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final errorMessage = ref.read(bookingStateProvider).errorMessage;
    
    // Determine if this is an offline data message
    final isOfflineData = errorMessage?.contains('offline data') == true;
    final isNetworkError = errorMessage?.contains('network') == true || 
                          errorMessage?.contains('connection') == true;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOfflineData ? Icons.cloud_off : Icons.error_outline, 
            size: 64, 
            color: isOfflineData ? Colors.orange[400] : Colors.red[400]
          ),
          const SizedBox(height: 16),
          Text(
            isOfflineData ? 'Offline Mode' : 'Error Loading Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isOfflineData ? Colors.orange[600] : Colors.red[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOfflineData ? Colors.orange[600] : Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (isOfflineData) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                'You\'re viewing cached data. Some information may be outdated. '
                'Connect to the internet to get the latest updates.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: () => _loadBookings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOfflineData ? Colors.orange[600] : Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(isOfflineData ? 'Try to Refresh' : 'Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Clear error state and try to reload
              ref.read(bookingStateProvider.notifier).clearError();
              _loadBookings();
            },
            child: const Text('Clear Error & Retry'),
          ),
          if (isNetworkError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Connection Tips:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Check your internet connection\n'
                    '• Try switching between WiFi and mobile data\n'
                    '• Restart the app if the problem persists',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await ref.read(bookingStateProvider.notifier).cancelBooking(bookingId);
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReviewDialog(BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        booking: booking,
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final rating = result['rating'] as int;
        final review = result['review'] as String;
        // Handle review submission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
} 