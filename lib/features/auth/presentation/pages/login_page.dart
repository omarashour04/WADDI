// Login page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/users');
        });
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              authState.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            await authNotifier.login(email, password);
                          },
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('Login with Google'),
                          onPressed: () async {
                            await authNotifier.signInWithGoogle();
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          child: const Text('Continue as Guest'),
                          onPressed: () async {
                            await authNotifier.signInAnonymously();
                          },
                        ),
                      ],
                    ),
              TextButton(
                onPressed: () {
                  context.push('/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
              TextButton(
                onPressed: () {
                  context.push('/reset-password');
                },
                child: const Text('Forgot password?'),
              ),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
