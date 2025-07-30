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
import 'package:waddi_platform/shared/providers/shared_providers.dart';
import '../../../../core/services/app_state_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';

    // Update navigation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationStateProvider.notifier).updateCurrentRoute('/profile');
    });

    return MainScaffold(
      currentIndex: 3,
      userId: userId,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).bottomNavigationBarTheme.backgroundColor
              : AppColors.primary,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.textOnPrimary,
          title: const Text('Profile'),
          elevation: 0,
          leading: SmartBackButton(),
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Check if user is authenticated or guest
                if (authState.status == AuthStatus.authenticated && authState.user != null) ...[
                  // Profile Information Section for authenticated users
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).bottomNavigationBarTheme.backgroundColor
                              : AppColors.primaryLight,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          authState.user?.name ?? 'User',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // User Email
                        Text(
                          authState.user?.email ?? 'user@email.com',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // User Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(authState.user?.role ?? 'user'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getRoleDisplayName(authState.user?.role ?? 'user'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Guest User Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Guest Icon
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person_outline, size: 50, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        // Guest Title
                        Text(
                          'Welcome Guest!',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to access your account',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go('/register'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Account Options Section - Only show for authenticated users
                if (authState.status == AuthStatus.authenticated && authState.user != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Section Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Account',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Account Options
                        _ProfileOption(
                          title: 'Edit Profile',
                          icon: Icons.edit,
                          onTap: () {
                            // Navigate to edit profile page
                            context.go('/profile/edit');
                          },
                        ),
                        _ProfileOption(
                          title: 'Change Password',
                          icon: Icons.lock,
                          onTap: () {
                            // Navigate to change password page
                            context.go('/reset-password');
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Role-Specific Navigation Section
                // Admin section moved to admin dashboard
                // if (authState.user?.role == 'admin') _buildAdminSection(context, ref),
                if (authState.user?.role == 'admin') _buildAdminAccessSection(context, ref),
                if (authState.user?.role == 'venue_owner') _buildVenueOwnerSection(context, ref),

                const SizedBox(height: 16),

                // Support Tickets Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Support Section Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Support',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Support Options
                      _ProfileOption(
                        title: 'Support Tickets',
                        icon: Icons.support_agent,
                        onTap: () {
                          // Navigate to support tickets page
                          context.go('/support/$userId');
                        },
                      ),
                      _ProfileOption(
                        title: 'Contact Support',
                        icon: Icons.contact_support,
                        onTap: () {
                          // Navigate to contact support page
                          context.go('/contact-support');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Notifications Section (for authenticated users)
                if (authState.status == AuthStatus.authenticated)
                  _buildNotificationsSection(context, ref),

                const SizedBox(height: 16),

                // Role Management Section (for testing)
                if (authState.user?.role == 'user' && authState.status == AuthStatus.authenticated)
                  _buildRolePromotionSection(context, ref),

                // Guest User Conversion Section
                if (authState.status == AuthStatus.unauthenticated)
                  _buildGuestConversionSection(context, ref),

                // Settings Section (for all users including guests)
                _buildSettingsSection(context, ref),

                const SizedBox(height: 24),

                // Log Out Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.textOnSecondary,
                              ),
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        // Log out the user
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for role management
  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'venue_owner':
        return Colors.orange;
      case 'user':
        return Colors.blue;
      case 'guest':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'venue_owner':
        return 'Venue Owner';
      case 'user':
        return 'User';
      case 'guest':
        return 'Guest';
      default:
        return 'User';
    }
  }

  Widget _buildAdminAccessSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Admin Panel',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          _ProfileOption(
            title: 'Admin Dashboard',
            icon: Icons.dashboard,
            onTap: () => context.go('/admin'),
          ),

          // Role Switching Section
          const Padding(padding: EdgeInsets.all(16), child: Divider()),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Switch Role (Testing)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Switch to User Role
          _ProfileOption(
            title: 'Switch to User Role',
            icon: Icons.person,
            onTap: () async {
              final shouldSwitch = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Switch to User Role'),
                  content: const Text(
                    'Are you sure you want to switch to user role? You will lose admin privileges.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Switch to User'),
                    ),
                  ],
                ),
              );

              if (shouldSwitch == true) {
                try {
                  await ref.read(authProvider.notifier).updateUserRole('user');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully switched to User role!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.go('/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to switch role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),

          // Switch to Venue Owner Role
          _ProfileOption(
            title: 'Switch to Venue Owner Role',
            icon: Icons.business,
            onTap: () async {
              final shouldSwitch = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Switch to Venue Owner Role'),
                  content: const Text(
                    'Are you sure you want to switch to venue owner role? You will lose admin privileges.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Switch to Venue Owner'),
                    ),
                  ],
                ),
              );

              if (shouldSwitch == true) {
                try {
                  await ref.read(authProvider.notifier).updateUserRole('venue_owner');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully switched to Venue Owner role!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.go('/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to switch role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Admin Panel',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          _ProfileOption(
            title: 'Dashboard',
            icon: Icons.dashboard,
            onTap: () => context.go('/admin'),
          ),
          _ProfileOption(
            title: 'Manage Users',
            icon: Icons.people,
            onTap: () => context.go('/admin/users'),
          ),
          _ProfileOption(
            title: 'Manage Venues',
            icon: Icons.business,
            onTap: () => context.go('/admin/venues'),
          ),
          _ProfileOption(
            title: 'Manage Bookings',
            icon: Icons.book_online,
            onTap: () => context.go('/admin/bookings'),
          ),
          _ProfileOption(
            title: 'Analytics',
            icon: Icons.analytics,
            onTap: () => context.go('/admin/analytics'),
          ),
          _ProfileOption(
            title: 'Content Management',
            icon: Icons.content_copy,
            onTap: () => context.go('/admin/content'),
          ),
          _ProfileOption(
            title: 'Notifications',
            icon: Icons.notifications,
            onTap: () => context.go('/admin/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueOwnerSection(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Venue Management',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
          _ProfileOption(
            title: 'My Venues',
            icon: Icons.business,
            onTap: () => context.go('/venue-owner?ownerId=$userId'),
          ),
          _ProfileOption(
            title: 'Add New Venue',
            icon: Icons.add_business,
            onTap: () => context.go('/venue-owner/venue-form?ownerId=$userId'),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePromotionSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Role Management (Testing)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          _ProfileOption(
            title: 'Promote to Admin',
            icon: Icons.admin_panel_settings,
            onTap: () async {
              await ref.read(authProvider.notifier).promoteToAdmin();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Promoted to Admin!')));
              }
            },
          ),
          _ProfileOption(
            title: 'Promote to Venue Owner',
            icon: Icons.business,
            onTap: () async {
              await ref.read(authProvider.notifier).promoteToVenueOwner();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Promoted to Venue Owner!')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestConversionSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Guest User',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'You are currently using the app as a guest. Create an account to save your preferences and access all features.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          _ProfileOption(
            title: 'View Notifications',
            icon: Icons.notifications,
            onTap: () => context.go('/notifications'),
          ),
          _ProfileOption(
            title: 'Manage Notification Settings',
            icon: Icons.settings,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ),
          _ProfileOption(
            title: 'General Settings',
            icon: Icons.settings,
            onTap: () => context.go('/settings'),
          ),
          _ProfileOption(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip,
            onTap: () => context.go('/privacy-policy'),
          ),
          _ProfileOption(
            title: 'Terms of Service',
            icon: Icons.description,
            onTap: () => context.go('/terms-of-service'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color, size: 16),
          ],
        ),
      ),
    );
  }
}
