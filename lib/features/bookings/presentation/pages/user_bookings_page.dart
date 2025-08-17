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

class UserBookingsPage extends ConsumerStatefulWidget {
  const UserBookingsPage({super.key});

  @override
  ConsumerState<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends ConsumerState<UserBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedBookings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load bookings automatically when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load bookings if not already loading and no bookings exist
    final bookingState = ref.read(bookingStateProvider);
    if (!bookingState.isLoading && 
        bookingState.allBookings.isEmpty && 
        !_hasLoadedBookings) {
      print('DEBUG: didChangeDependencies - loading bookings');
      _loadBookings();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    print('DEBUG: _loadBookings called');
    
    final user = ref.read(authProvider).user;
    if (user == null || user.isGuestUser) {
      print('DEBUG: No user or guest user, skipping load');
      return;
    }

    print('DEBUG: User: ${user.id}, isGuest: ${user.isGuestUser}');
    print('DEBUG: Calling loadUserBookings for user: ${user.id}');
    
    try {
      await ref.read(bookingStateProvider.notifier).loadUserBookings(user.id);
      _hasLoadedBookings = true; // Mark as loaded
      print('DEBUG: Bookings loaded successfully');
    } catch (e) {
      print('DEBUG: Error loading bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingStateProvider);
    final user = ref.read(authProvider).user;
    final theme = Theme.of(context);
    
    print('DEBUG: Build called - isLoading: ${bookingState.isLoading}, allBookings: ${bookingState.allBookings.length}, error: ${bookingState.errorMessage}');
    
    // Auto-clear error if we have data and no loading
    if (bookingState.allBookings.isNotEmpty && 
        !bookingState.isLoading && 
        bookingState.errorMessage != null) {
      print('DEBUG: Auto-clearing error since we have data');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bookingStateProvider.notifier).clearError();
      });
    }

    return MainScaffold(
      currentIndex: 3, // Bookings tab index
      userId: user?.id ?? '', // Provide user ID
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'My Bookings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            // Beautiful refresh button with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  print('DEBUG: Manual refresh pressed');
                  // Clear any existing error before refreshing
                  ref.read(bookingStateProvider.notifier).clearError();
                  _loadBookings();
                },
                tooltip: 'Refresh Bookings',
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ],
            ),
          ),
          child: _buildBody(bookingState),
        ),
      ),
    );
  }

  Widget _buildBody(BookingState bookingState) {
    final theme = Theme.of(context);
    print('DEBUG: _buildBody called - isLoading: ${bookingState.isLoading}, error: ${bookingState.errorMessage}');
    
    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      strokeWidth: 3,
      child: bookingState.isLoading
          ? _buildBeautifulLoadingState()
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
                  : _buildBeautifulLoadingState(),
    );
  }

  Widget _buildBeautifulLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful animated loading container
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loading your bookings...',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we fetch your latest information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Beautiful empty state icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Empty state title
            Text(
              'No Bookings Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Empty state description
            Text(
              'You haven\'t made any bookings yet.\nStart exploring venues and book your first space!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Action button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/home'),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Browse Venues',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bookings will appear here once you make your first reservation',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final errorMessage = ref.read(bookingStateProvider).errorMessage;
    
    // Determine if this is an offline data message
    final isOfflineData = errorMessage?.contains('offline data') == true;
    final isNetworkError = errorMessage?.contains('network') == true || 
                          errorMessage?.contains('connection') == true;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with background
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isOfflineData ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error title
            Text(
              isOfflineData ? 'Offline Mode' : 'Error Loading Bookings',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Error message
            Text(
              errorMessage ?? 'An unexpected error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  'Retry',
                  Icons.refresh_rounded,
                  theme.colorScheme.primary,
                  () => _loadBookings(),
                ),
                _buildActionButton(
                  context,
                  'Clear Error',
                  Icons.clear_rounded,
                  theme.colorScheme.secondary,
                  () {
                    ref.read(bookingStateProvider.notifier).clearError();
                    _loadBookings();
                  },
                ),
              ],
            ),
            
            // Additional info for offline mode
            if (isOfflineData) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline Information',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re viewing cached data. Some information may be outdated. '
                      'Connect to the internet to get the latest updates.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            // Connection tips for network errors
            if (isNetworkError) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: theme.colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Tips',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your internet connection\n'
                      '• Try switching between WiFi and mobile data\n'
                      '• Restart the app if the problem persists',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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