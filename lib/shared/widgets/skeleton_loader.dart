import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final double? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.width,
    this.height,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget skeletonChild = child;
    
    if (width != null || height != null) {
      skeletonChild = SizedBox(
        width: width,
        height: height,
        child: child,
      );
    }
    
    if (margin != null) {
      skeletonChild = Padding(
        padding: margin!,
        child: skeletonChild,
      );
    }
    
    if (borderRadius != null) {
      skeletonChild = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: skeletonChild,
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: skeletonChild,
    );
  }
}

class VenueCardSkeleton extends StatelessWidget {
  final bool isGrid;
  
  const VenueCardSkeleton({super.key, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SkeletonLoader(
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
              // Content skeleton
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        child: Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        child: Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: SkeletonLoader(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          title: SkeletonLoader(
            child: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          subtitle: SkeletonLoader(
            child: Container(
              height: 12,
              width: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class RoomCardSkeleton extends StatelessWidget {
  const RoomCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image skeleton
          SkeletonLoader(
            width: 120,
            height: 120,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            child: Container(color: Colors.white),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name skeleton
                  SkeletonLoader(
                    height: 20, 
                    width: 150, 
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(color: Colors.white),
                  ),
                  // Description skeleton
                  SkeletonLoader(
                    height: 14, 
                    width: 200, 
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(color: Colors.white),
                  ),
                  // Price skeleton
                  SkeletonLoader(
                    height: 18, 
                    width: 80,
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(),
            const SizedBox(height: 4),
            _buildInfoRow(),
            const SizedBox(height: 4),
            _buildInfoRow(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class SearchBarSkeleton extends StatelessWidget {
  const SearchBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SkeletonLoader(
        height: 50, 
        borderRadius: 8,
        child: Container(color: Colors.white),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar skeleton
        Container(
          margin: const EdgeInsets.all(16),
          child: SkeletonLoader(
            width: 100, 
            height: 100, 
            borderRadius: 50,
            child: Container(color: Colors.white),
          ),
        ),
        // Name skeleton
        SkeletonLoader(
          height: 24, 
          width: 150, 
          margin: const EdgeInsets.only(bottom: 8),
          child: Container(color: Colors.white),
        ),
        // Email skeleton
        SkeletonLoader(
          height: 16, 
          width: 200, 
          margin: const EdgeInsets.only(bottom: 32),
          child: Container(color: Colors.white),
        ),
        // Menu items skeleton
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLoader(
              height: 60, 
              borderRadius: 12,
              child: Container(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class VenueDetailsSkeleton extends StatelessWidget {
  const VenueDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App bar skeleton
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: SkeletonLoader(
              height: 300, 
              borderRadius: 0,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        // Content skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                SkeletonLoader(
                  height: 32, 
                  width: 250, 
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Container(color: Colors.white),
                ),
                // Address skeleton
                SkeletonLoader(
                  height: 16, 
                  width: 200, 
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Container(color: Colors.white),
                ),
                // Amenities skeleton
                ...List.generate(
                  6,
                  (index) => SkeletonLoader(
                    height: 40, 
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar skeleton
        Container(
          margin: const EdgeInsets.all(16),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Filter chips skeleton
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Results skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VenueCardSkeleton(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
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
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
