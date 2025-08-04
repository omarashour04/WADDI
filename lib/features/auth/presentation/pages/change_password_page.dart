import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/smart_back_button.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool isSubmitting = false;
  String? error;
  bool isFirstLogin = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        if (userData != null && userData['isFirstLogin'] == true) {
          setState(() {
            isFirstLogin = true;
          });
        }
      }
    } catch (e) {
      print('Error checking first login: $e');
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => error = 'No user is signed in');
        return;
      }

      // If it's first login, we don't need to verify current password
      if (!isFirstLogin) {
        // Re-authenticate user with current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Change password
      await user.updatePassword(_newPasswordController.text);

      // Update Firestore to mark first login as completed
      if (isFirstLogin) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isFirstLogin': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Redirect based on user role
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        final role = userData?['role'] ?? 'user';
        
        if (role == 'venue_owner') {
          context.go('/venue-owner?ownerId=${user.uid}');
        } else if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to change password';
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Please log in again to change your password';
      }
      setState(() => error = errorMessage);
    } catch (e) {
      setState(() => error = 'Failed to change password: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isFirstLogin ? 'Set New Password' : 'Change Password'),
        leading: isFirstLogin ? null : SmartBackButton(),
        automaticallyImplyLeading: !isFirstLogin,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isFirstLogin) ...[
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please set a new password for your account. This is required for security purposes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              if (!isFirstLogin) ...[
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: isSubmitting ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Changing Password...'),
                        ],
                      )
                    : Text(isFirstLogin ? 'Set Password' : 'Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
