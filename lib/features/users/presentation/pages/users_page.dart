import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_providers.dart';
import '../../domain/entities/user_entity.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) => _UserCard(user: users[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Text(user.role),
        onTap: () {
          // TODO: Navigate to user details
        },
      ),
    );
  }
} 