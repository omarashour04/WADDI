// Profile page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/features/users/presentation/providers/user_providers.dart';
import 'package:waddi_platform/features/users/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final user = authState.user;
    final userId = authState.user?.id ?? '';
    return MainScaffold(
      currentIndex: 2,
      userId: userId,
      child: Scaffold(
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
                        await showDialog(
                          context: context,
                          builder: (context) => _EditProfileDialog(
                            user: user,
                            onSave: (name, phone) async {
                              final userRepo = ref.read(userRepositoryProvider);
                              final updatedUser = UserEntity(
                                id: user.id,
                                email: user.email,
                                name: name,
                                role: user.role,
                                phoneNumber: phone,
                                createdAt: user.createdAt,
                                updatedAt: Timestamp.now(),
                                points: user.points,
                                venueId: user.venueId,
                                fcmTokens: user.fcmTokens,
                              );
                              await userRepo.updateUser(updatedUser);
                              ref.refresh(userProvider(user.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated!')),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await authNotifier.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/bookings/${user.id}');
                      },
                      child: const Text('My Bookings'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/support/${user.id}');
                      },
                      child: const Text('Support Tickets'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/reviews/${user.id}');
                      },
                      child: const Text('My Reviews'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final dynamic user;
  final Future<void> Function(String name, String phone) onSave;
  const _EditProfileDialog({required this.user, required this.onSave});
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.onSave(_nameController.text.trim(), _phoneController.text.trim());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 