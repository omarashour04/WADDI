import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailController = TextEditingController();
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF43E9FF), Color(0xFF38C6F4), Color(0xFF3A8DFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () {
                      try {
                        context.pop();
                      } catch (e) {
                        // If pop fails, navigate to venues page
                        context.go('/venues');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
            TextField(
              controller: _emailController,
                  style: const TextStyle(fontFamily: null),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.black54, fontFamily: null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: null,
                      ),
                      elevation: 0,
                    ),
              onPressed: () async {
                final email = _emailController.text.trim();
                await authNotifier.resetPassword(email);
                setState(() {
                  _feedback = 'Password reset email sent (if account exists).';
                });
              },
              child: const Text('Send Reset Email'),
                  ),
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _feedback!,
                      style: const TextStyle(color: Colors.green, fontFamily: null),
                    ),
              ),
          ],
            ),
          ),
        ),
      ),
    );
  }
} 
