import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../themes/app_colors.dart';

class LottieLoadingAnimation extends StatelessWidget {
  final double size;
  final String? animationPath;

  const LottieLoadingAnimation({super.key, this.size = 100, this.animationPath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(animationPath ?? 'assets/animations/loading.json', fit: BoxFit.contain),
      ),
    );
  }
}

class LottieSuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const LottieSuccessAnimation({super.key, this.size = 100, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/success.json',
          fit: BoxFit.contain,
          onLoaded: (composition) {
            if (onComplete != null) {
              Future.delayed(composition.duration, onComplete!);
            }
          },
        ),
      ),
    );
  }
}

class LottieErrorAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const LottieErrorAnimation({super.key, this.size = 100, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/error.json',
          fit: BoxFit.contain,
          onLoaded: (composition) {
            if (onComplete != null) {
              Future.delayed(composition.duration, onComplete!);
            }
          },
        ),
      ),
    );
  }
}

class LottieEmptyStateAnimation extends StatelessWidget {
  final String title;
  final String subtitle;
  final double size;

  const LottieEmptyStateAnimation({
    super.key,
    required this.title,
    required this.subtitle,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset('assets/animations/empty_state.json', fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LottieBookingAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const LottieBookingAnimation({super.key, this.size = 150, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/booking.json',
          fit: BoxFit.contain,
          onLoaded: (composition) {
            if (onComplete != null) {
              Future.delayed(composition.duration, onComplete!);
            }
          },
        ),
      ),
    );
  }
}

class LottieSearchAnimation extends StatelessWidget {
  final double size;

  const LottieSearchAnimation({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset('assets/animations/search.json', fit: BoxFit.contain),
      ),
    );
  }
}

class LottieNoResultsAnimation extends StatelessWidget {
  final String message;
  final double size;

  const LottieNoResultsAnimation({super.key, required this.message, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset('assets/animations/no_results.json', fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LottieNetworkErrorAnimation extends StatelessWidget {
  final VoidCallback? onRetry;
  final double size;

  const LottieNetworkErrorAnimation({super.key, this.onRetry, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset('assets/animations/network_error.json', fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

// Loading overlay with Lottie animation
class LottieLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LottieLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LottieLoadingAnimation(size: 80),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
