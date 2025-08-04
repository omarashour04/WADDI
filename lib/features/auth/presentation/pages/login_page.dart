// Login page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        // Use a microtask to avoid router assertion errors
        Future.microtask(() {
          if (context.mounted) {
            context.go('/home');
          }
        });
      } else if (next.status == AuthStatus.unauthenticated && next.user?.isGuestUser == true) {
        // Guest user signed in, redirect to home
        Future.microtask(() {
          if (context.mounted) {
            context.go('/home');
          }
        });
      }
    });
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF43E9FF), // Light teal
              Color(0xFF38C6F4), // Mid blue
              Color(0xFF3A8DFF), // Deeper blue
            ],
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
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: null, // Use native font
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
                    labelText: 'Email  or Username',
                    labelStyle: const TextStyle(color: Colors.black54, fontFamily: null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(fontFamily: null),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.black54, fontFamily: null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 24),
                authState.isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: null,
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();

                                // Basic validation
                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter both email and password'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Email format validation
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a valid email address'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Check if current user is a guest user
                                final authState = ref.read(authProvider);
                                if (authState.status == AuthStatus.unauthenticated &&
                                    authState.user?.isGuestUser == true) {
                                  // For guest users, we need to sign out first, then sign in
                                  await authNotifier.logout();
                                  await authNotifier.login(email, password);
                                } else {
                                  // Regular login
                                  await authNotifier.login(email, password);
                                }
                              },
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF009CA6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: null,
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.login),
                              label: const Text('Login with Google'),
                              onPressed: () async {
                                await authNotifier.signInWithGoogle();
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: null,
                      ),
                    ),
                    onPressed: () async {
                      await authNotifier.signInAnonymously();
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account? ",
                      style: const TextStyle(color: Colors.white, fontFamily: null),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/register');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontFamily: null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    context.push('/reset-password');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontFamily: null,
                    ),
                  ),
                ),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red, fontFamily: null),
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
