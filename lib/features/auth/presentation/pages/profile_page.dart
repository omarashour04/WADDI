// Profile page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final user = authState.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Email: ${user.email}'),
                  const SizedBox(height: 8),
                  Text('Role: ${user.role}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // TODO: Implement update profile logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Update profile not implemented.')),
                      );
                    },
                    child: const Text('Update Profile'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await authNotifier.logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
} 