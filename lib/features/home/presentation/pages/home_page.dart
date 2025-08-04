import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasCheckedNotifications = false;

  @override
  void initState() {
    super.initState();
    // Check for notifications after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    if (_hasCheckedNotifications) return;

    final authState = ref.read(authProvider);
    // Only check notifications for authenticated users (not guests)
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      await NotificationService.checkAndShowNotifications(context);
      setState(() {
        _hasCheckedNotifications = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;
    final isAdmin = authState.user?.role == 'admin';
    final isVenueOwner = authState.user?.role == 'venue_owner';

    // If user is admin or venue owner, redirect to appropriate dashboard
    if (isAdmin || isVenueOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (isAdmin) {
            context.go('/admin');
          } else if (isVenueOwner) {
            context.go('/venue-owner');
          }
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainScaffold(
      currentIndex: 0,
      userId: authState.user?.id ?? '',
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? 'Welcome to WADDI!'
                          : 'Welcome back, ${authState.user?.name ?? 'User'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGuest
                          ? 'Discover amazing venues and book your next adventure'
                          : 'Ready to explore more venues?',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.search,
                    title: 'Find Venues',
                    subtitle: 'Discover amazing places',
                    color: Colors.blue,
                    onTap: () => context.go('/venues'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.book_online,
                    title: 'My Bookings',
                    subtitle: 'View your reservations',
                    color: Colors.green,
                    onTap: () {
                      if (isGuest) {
                        // Show login prompt for guests
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text('Please log in to view your bookings.'),
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
                      } else {
                        context.go('/bookings');
                      }
                    },
                  ),
                  if (!isGuest) ...[
                    _buildActionCard(
                      context,
                      icon: Icons.favorite,
                      title: 'Favorites',
                      subtitle: 'Your saved venues',
                      color: Colors.red,
                      onTap: () => context.go('/favorites'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'Past bookings',
                      color: Colors.orange,
                      onTap: () => context.go('/history'),
                    ),
                  ],
                  if (isGuest) ...[
                    _buildActionCard(
                      context,
                      icon: Icons.login,
                      title: 'Sign In',
                      subtitle: 'Access your account',
                      color: Colors.purple,
                      onTap: () => context.go('/login'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.person_add,
                      title: 'Sign Up',
                      subtitle: 'Create new account',
                      color: Colors.teal,
                      onTap: () => context.go('/register'),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Featured Venues
              Text(
                'Featured Venues',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Placeholder for featured venues
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Featured venues coming soon',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Search and Discovery Section
              _buildSectionHeader('Search & Discovery'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.search, color: Colors.blue),
                      title: const Text('Advanced Search'),
                      subtitle: const Text('Filter by price, capacity, amenities'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/search'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.map, color: Colors.green),
                      title: const Text('Venues Map'),
                      subtitle: const Text('Find venues near you'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/venues-map'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title: const Text('My Favorites'),
                      subtitle: const Text('Your saved venues'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        if (authState.user?.isGuestUser == true) {
                          _showLoginPrompt(context);
                        } else {
                          context.go('/favorites');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2, // Increased padding for more space
      child: IntrinsicHeight(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 11),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to view your favorites.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
