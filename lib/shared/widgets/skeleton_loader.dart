import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class VenueCardSkeleton extends StatelessWidget {
  const VenueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 4 / 3, // Match VenueCard aspect ratio
                child: SkeletonLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 16,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    height: 16,
                    width: cardWidth * 0.6,
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  SkeletonLoader(height: 12, width: cardWidth * 0.4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name skeleton
                  SkeletonLoader(height: 20, width: 150, margin: const EdgeInsets.only(bottom: 8)),
                  // Description skeleton
                  SkeletonLoader(height: 14, width: 200, margin: const EdgeInsets.only(bottom: 12)),
                  // Price skeleton
                  SkeletonLoader(height: 18, width: 80),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue name skeleton
            SkeletonLoader(height: 20, width: 180, margin: const EdgeInsets.only(bottom: 8)),
            // Room name skeleton
            SkeletonLoader(height: 16, width: 140, margin: const EdgeInsets.only(bottom: 12)),
            Row(
              children: [
                // Date skeleton
                SkeletonLoader(height: 16, width: 100),
                const Spacer(),
                // Status skeleton
                SkeletonLoader(height: 16, width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarSkeleton extends StatelessWidget {
  const SearchBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SkeletonLoader(height: 50, borderRadius: 8),
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
          child: SkeletonLoader(width: 100, height: 100, borderRadius: 50),
        ),
        // Name skeleton
        SkeletonLoader(height: 24, width: 150, margin: const EdgeInsets.only(bottom: 8)),
        // Email skeleton
        SkeletonLoader(height: 16, width: 200, margin: const EdgeInsets.only(bottom: 32)),
        // Menu items skeleton
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLoader(height: 60, borderRadius: 12),
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
          flexibleSpace: FlexibleSpaceBar(background: SkeletonLoader(height: 300, borderRadius: 0)),
        ),
        // Content skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                SkeletonLoader(height: 32, width: 250, margin: const EdgeInsets.only(bottom: 16)),
                // Address skeleton
                SkeletonLoader(height: 16, width: 200, margin: const EdgeInsets.only(bottom: 24)),
                // Amenities skeleton
                ...List.generate(
                  6,
                  (index) => SkeletonLoader(height: 40, margin: const EdgeInsets.only(bottom: 8)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
