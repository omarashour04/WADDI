// Login page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/widgets/custom_text_field.dart';
// import 'package:waddi_platform/shared/widgets/loading_button.dart'; // Uncomment if implemented

class LoginPage extends ConsumerWidget {
  LoginPage({Key? key}) : super(key: key);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    // Listen for state changes to show snackbars or navigate
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (current.status == AuthStatus.authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );
        // Navigate to home page
        // Navigator.of(context).pushReplacementNamed('/home');
      } else if (current.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.errorMessage ?? 'An error occurred')),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Email',
              controller: _emailController,
              // labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              hintText: 'Password',
              controller: _passwordController,
              // labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            // LoadingButton(
            //   isLoading: authState.status == AuthStatus.loading,
            //   onPressed: () {
            //     ref.read(authProvider.notifier).login(
            //       _emailController.text,
            //       _passwordController.text,
            //     );
            //   },
            //   text: 'Login',
            // ),
            ElevatedButton(
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () {
                      ref.read(authProvider.notifier).login(
                            _emailController.text,
                            _passwordController.text,
                          );
                    },
              child: authState.status == AuthStatus.loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                // Navigator.of(context).pushNamed('/register');
              },
              child: const Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
} 