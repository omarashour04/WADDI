import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

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
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                await authNotifier.resetPassword(email);
                setState(() {
                  _feedback = 'Password reset email sent (if account exists).';
                });
              },
              child: const Text('Send Reset Email'),
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(_feedback!, style: const TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
} 