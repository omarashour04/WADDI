// Register page UI
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/venues');
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
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
              ),
                const SizedBox(height: 8),
              Text(
                  'Sign Up',
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
                controller: _nameController,
                  style: const TextStyle(fontFamily: null),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.black54, fontFamily: null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                  style: const TextStyle(fontFamily: null),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.black54, fontFamily: null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                keyboardType: TextInputType.phone,
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
                              final name = _nameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              final phoneNumber = _phoneController.text.trim();
                              
                              // Check if current user is a guest user
                              final authState = ref.read(authProvider);
                              if (authState.status == AuthStatus.unauthenticated && authState.user?.isGuestUser == true) {
                                // Convert guest user to registered user
                                await authNotifier.convertGuestToUser(
                                  email: email,
                                  password: password,
                                  name: name,
                                  phoneNumber: phoneNumber,
                                );
                              } else {
                                // Regular registration
                                await authNotifier.register(name, email, password);
                              }
                            },
                            child: const Text('Register'),
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
                            label: const Text('Sign up with Google'),
                            onPressed: () async {
                              await authNotifier.signInWithGoogle();
                            },
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      "Already have an account? ",
                      style: const TextStyle(color: Colors.white, fontFamily: null),
                    ),
                    GestureDetector(
                      onTap: () {
                      context.go('/login');
                    },
                      child: const Text(
                        'Login',
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
