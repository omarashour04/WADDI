import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_users_provider.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: usersAsync.when(
        data: (snapshot) {
          final users = snapshot.docs;
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final data = users[i].data() as Map<String, dynamic>;
              final userId = users[i].id;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['name'] ?? userId),
                subtitle: Text('Role: ${data['role'] ?? 'user'} | Email: ${data['email'] ?? ''}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // TODO: Call Cloud Functions for edit, delete, promote, admin
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    const PopupMenuItem(value: 'promote', child: Text('Promote to Owner')),
                    const PopupMenuItem(value: 'admin', child: Text('Make Admin')),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
} 