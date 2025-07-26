import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';

    return MainScaffold(
      currentIndex: 3,
      userId: userId,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Profile'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              try {
                context.pop();
              } catch (e) {
                context.go('/venues');
              }
            },
          ),
        ),
        body: Container(
          color: AppColors.backgroundLight,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Information Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
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
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        authState.user?.name ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Email
                      Text(
                        authState.user?.email ?? 'user@email.com',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Account Options Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      // Account Section Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Account',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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
                      _ProfileOption(
                        title: 'Settings',
                        icon: Icons.settings,
                        onTap: () {
                          // Navigate to settings page
                          context.go('/settings');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Support Tickets Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      // Support Section Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Support',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
