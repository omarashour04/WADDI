import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/app_colors.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({super.key});

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Logo scale and rotation animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Wave animation
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Bounce animation
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start fade in
    await _fadeController.forward();
    
    // Start logo animation
    await _logoController.forward();
    
    // Start bounce animation
    await _bounceController.forward();
    
    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: Stack(
            children: [
              // Animated background waves
              ...List.generate(4, (index) {
                return Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WavePainter(
                          animation: _waveAnimation.value + (index * math.pi / 4),
                          color: AppColors.accentExtraLight.withValues(alpha: 0.4 - (index * 0.08)),
                          waveHeight: 25 + (index * 8),
                          waveSpeed: 1.2 + (index * 0.3),
                        ),
                      );
                    },
                  ),
                );
              }),
              
              // Floating particles
              ...List.generate(8, (index) {
                return Positioned(
                  top: 100 + (index * 80),
                  left: 50 + (index * 40),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value * (0.6 + (index * 0.05)),
                        child: Container(
                          width: 6 + (index * 2),
                          height: 6 + (index * 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentExtraLight.withValues(alpha: 0.7 - (index * 0.08)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animations
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoController, _pulseController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value * _pulseAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icons/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to text logo if image fails
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: AppColors.primaryGradient,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'W',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 56,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // App name with bounce animation
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bounceAnimation.value,
                          child: const Text(
                            'WADDI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tagline with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Your Venue, Your Way',
                        style: TextStyle(
                          color: AppColors.accentExtraLight.withValues(alpha: 0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Loading indicator with custom design
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            // Outer ring
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentExtraLight.withValues(alpha: 0.3),
                              ),
                              strokeWidth: 4,
                            ),
                            // Inner ring
                            Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Loading text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppColors.accentExtraLight.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom decorative elements
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value * (0.7 + (index * 0.08)),
                            child: Container(
                              width: 10 + (index * 2),
                              height: 10 + (index * 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentExtraLight.withValues(alpha: 0.7 - (index * 0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentExtraLight.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for animated waves
class WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  final double waveHeight;
  final double waveSpeed;

  WavePainter({
    required this.animation,
    required this.color,
    required this.waveHeight,
    required this.waveSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.75 + 
                math.sin((x / size.width * 2 * math.pi * waveSpeed) + animation) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
