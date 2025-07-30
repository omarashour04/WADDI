import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3, // Profile tab
      userId: '',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('User Management'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Users', 'user'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Venue Owners', 'venue_owner'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Admins', 'admin'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter users based on search and role
                  final allUsers = snapshot.data!.docs;
                  print('DEBUG: Total users in database: ${allUsers.length}');
                  
                  // Use a Set to track unique user IDs to prevent duplicates
                  final seenUserIds = <String>{};
                  final filteredUsers = allUsers.where((doc) {
                    final userId = doc.id;
                    
                    // Check for duplicates
                    if (seenUserIds.contains(userId)) {
                      print('DEBUG: Duplicate user found: $userId');
                      return false;
                    }
                    seenUserIds.add(userId);
                    
                    final data = doc.data() as Map<String, dynamic>;
                    final role = data['role'] as String? ?? 'user';
                    final searchLower = _searchQuery.toLowerCase();
                    
                    // Role filter
                    if (_roleFilter != 'all' && role != _roleFilter) {
                      return false;
                    }
                    
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final name = (data['name'] as String? ?? '').toLowerCase();
                      final email = (data['email'] as String? ?? '').toLowerCase();
                      
                      return name.contains(searchLower) ||
                             email.contains(searchLower);
                    }
                    
                    return true;
                  }).toList();
                  
                  print('DEBUG: Filtered users count: ${filteredUsers.length}');
                  print('DEBUG: Unique user IDs: ${seenUserIds.length}');
                  
                  // Debug: Print user details
                  for (final doc in filteredUsers) {
                    final data = doc.data() as Map<String, dynamic>;
                    print('DEBUG: User ${doc.id} - Name: ${data['name']}, Email: ${data['email']}, Role: ${data['role']}');
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final doc = filteredUsers[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final userId = doc.id;
                      final name = data['name'] as String? ?? 'Unknown User';
                      final email = data['email'] as String? ?? 'No email';
                      final role = data['role'] as String? ?? 'user';
                      final points = (data['points'] as num?)?.toInt() ?? 0;
                      final createdAt = data['createdAt'] as Timestamp?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(role).withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: _getRoleColor(role),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(role),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Points: $points'),
                                ],
                              ),
                              if (createdAt != null) ...[
                                Text('Joined: ${_formatDate(createdAt)}'),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(value, userId, data),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              if (role != 'admin') ...[
                                const PopupMenuItem(
                                  value: 'promote_admin',
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Promote to Admin'),
                                    ],
                                  ),
                                ),
                              ],
                              if (role == 'user') ...[
                                const PopupMenuItem(
                                  value: 'promote_venue_owner',
                                  child: Row(
                                    children: [
                                      Icon(Icons.store, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Promote to Venue Owner'),
                                    ],
                                  ),
                                ),
                              ],
                              if (role == 'venue_owner') ...[
                                const PopupMenuItem(
                                  value: 'demote_user',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Demote to User'),
                                    ],
                                  ),
                                ),
                              ],
                              if (role == 'admin') ...[
                                const PopupMenuItem(
                                  value: 'demote_user',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Demote to User'),
                                    ],
                                  ),
                                ),
                              ],
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete User'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _roleFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _roleFilter = selected ? value : 'all';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'venue_owner':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, String userId, Map<String, dynamic> data) {
    switch (action) {
      case 'view':
        // Show user details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('User Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: $userId'),
                Text('Name: ${data['name'] ?? 'N/A'}'),
                Text('Email: ${data['email'] ?? 'N/A'}'),
                Text('Role: ${data['role'] ?? 'N/A'}'),
                Text('Points: ${data['points'] ?? 0}'),
                if (data['phoneNumber'] != null)
                  Text('Phone: ${data['phoneNumber']}'),
                if (data['createdAt'] != null)
                  Text('Joined: ${_formatDate(data['createdAt'])}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
        break;
      case 'promote_admin':
        _updateUserRole(userId, 'admin');
        break;
      case 'promote_venue_owner':
        _updateUserRole(userId, 'venue_owner');
        break;
      case 'demote_user':
        _updateUserRole(userId, 'user');
        break;
      case 'delete':
        _deleteUser(userId);
        break;
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'role': newRole,
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated to: $newRole')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user role: $e')),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
}
