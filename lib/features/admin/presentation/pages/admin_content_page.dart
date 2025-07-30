import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminContentPage extends ConsumerStatefulWidget {
  const AdminContentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends ConsumerState<AdminContentPage> {
  bool _isLoading = false;
  String? _error;

  Future<void> _editContent(String contentType) async {
    // Get current content
    String currentContent = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('content')
          .doc(contentType)
          .get();
      
      if (doc.exists) {
        currentContent = doc.data()?['content'] ?? '';
      }
    } catch (e) {
      print('Error loading content: $e');
    }

    // Show edit dialog
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ContentEditDialog(
        contentType: contentType,
        initialContent: currentContent,
      ),
    );

    if (result != null) {
      await _saveContent(contentType, result);
    }
  }

  Future<void> _saveContent(String contentType, String content) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('content')
          .doc(contentType)
          .set({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$contentType updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save content: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3, // Profile tab
      userId: '',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Content Management'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Manage Platform Content',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Edit FAQ, Terms & Conditions, and Privacy Policy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error message
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Content items
                _buildContentCard(
                  context,
                  icon: Icons.question_answer,
                  title: 'FAQ',
                  subtitle: 'Frequently Asked Questions',
                  onEdit: () => _editContent('faq'),
                ),
                
                _buildContentCard(
                  context,
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  subtitle: 'Platform terms and conditions',
                  onEdit: () => _editContent('terms'),
                ),
                
                _buildContentCard(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'User privacy and data protection',
                  onEdit: () => _editContent('privacy'),
                ),
                
                const SizedBox(height: 32),
                
                // Recent content updates
                Text(
                  'Recent Content Updates',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('content')
                      .orderBy('updatedAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('No content updates yet'),
                      );
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final contentType = doc.id;
                        final updatedAt = data['updatedAt'] as Timestamp?;
                        final content = data['content'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                _getContentIcon(contentType),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(_getContentTitle(contentType)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.length > 50 
                                    ? '${content.substring(0, 50)}...' 
                                    : content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (updatedAt != null)
                                  Text(
                                    'Updated: ${_formatDate(updatedAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editContent(contentType),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getContentIcon(String contentType) {
    switch (contentType) {
      case 'faq':
        return Icons.question_answer;
      case 'terms':
        return Icons.description;
      case 'privacy':
        return Icons.privacy_tip;
      default:
        return Icons.edit;
    }
  }

  String _getContentTitle(String contentType) {
    switch (contentType) {
      case 'faq':
        return 'FAQ';
      case 'terms':
        return 'Terms & Conditions';
      case 'privacy':
        return 'Privacy Policy';
      default:
        return contentType;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ContentEditDialog extends StatefulWidget {
  final String contentType;
  final String initialContent;

  const _ContentEditDialog({
    required this.contentType,
    required this.initialContent,
  });

  @override
  State<_ContentEditDialog> createState() => _ContentEditDialogState();
}

class _ContentEditDialogState extends State<_ContentEditDialog> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${_getContentTitle(widget.contentType)}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            hintText: 'Enter content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : () {
            Navigator.of(context).pop(_controller.text);
          },
          child: _isSaving 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
        ),
      ],
    );
  }

  String _getContentTitle(String contentType) {
    switch (contentType) {
      case 'faq':
        return 'FAQ';
      case 'terms':
        return 'Terms & Conditions';
      case 'privacy':
        return 'Privacy Policy';
      default:
        return contentType;
    }
  }
} 