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
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        _showEditUserDialog(context, userId, data);
                        break;
                      case 'delete':
                        _showDeleteUserDialog(context, userId, data['name'] ?? userId);
                        break;
                      case 'promote':
                        _showPromoteUserDialog(context, userId, data['name'] ?? userId, 'owner');
                        break;
                      case 'admin':
                        _showPromoteUserDialog(context, userId, data['name'] ?? userId, 'admin');
                        break;
                    }
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

  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${userData['name'] ?? userId}'),
            const SizedBox(height: 8),
            Text('Email: ${userData['email'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Role: ${userData['role'] ?? 'user'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit user functionality coming soon!')),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "$userName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete user functionality coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPromoteUserDialog(BuildContext context, String userId, String userName, String newRole) {
    final roleDisplay = newRole == 'owner' ? 'Venue Owner' : 'Admin';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Promote to $roleDisplay'),
        content: Text('Are you sure you want to promote "$userName" to $roleDisplay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Promote to $roleDisplay functionality coming soon!')),
              );
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }
}
