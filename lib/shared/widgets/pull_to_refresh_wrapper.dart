import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull_to_refresh;
import '../themes/app_colors.dart';

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoading;
  final bool enablePullDown;
  final bool enablePullUp;
  final pull_to_refresh.RefreshController? controller;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final refreshController = controller ?? pull_to_refresh.RefreshController();

    return pull_to_refresh.SmartRefresher(
      controller: refreshController,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      header: const CustomRefreshHeader(),
      footer: const CustomRefreshFooter(),
      onRefresh: onRefresh != null
          ? () async {
              try {
                await onRefresh!();
                refreshController.refreshCompleted();
              } catch (e) {
                refreshController.refreshFailed();
              }
            }
          : null,
      onLoading: onLoading != null
          ? () async {
              try {
                await onLoading!();
                refreshController.loadComplete();
              } catch (e) {
                refreshController.loadFailed();
              }
            }
          : null,
      child: child,
    );
  }
}

class CustomRefreshHeader extends StatelessWidget {
  const CustomRefreshHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const pull_to_refresh.WaterDropHeader(
      waterDropColor: AppColors.primary,
      complete: Icon(Icons.check_circle, color: AppColors.primary, size: 24),
    );
  }
}

class CustomRefreshFooter extends StatelessWidget {
  const CustomRefreshFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const pull_to_refresh.ClassicFooter(
      loadingText: 'Loading more...',
      noDataText: 'No more data',
      failedText: 'Failed to load',
      canLoadingText: 'Release to load more',
      idleText: 'Pull up to load more',
    );
  }
}

// Custom refresh indicator for specific use cases
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final Color? color;

  const CustomRefreshIndicator({super.key, required this.child, this.onRefresh, this.color});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: color ?? AppColors.primary,
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      child: child,
    );
  }
}

// Animated refresh indicator
class AnimatedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  const AnimatedRefreshIndicator({
    super.key,
    required this.child,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<AnimatedRefreshIndicator> createState() => _AnimatedRefreshIndicatorState();
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
