import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_providers.dart';
import '../../domain/entities/review_entity.dart';

class ReviewsPage extends ConsumerWidget {
  final String venueId;
  const ReviewsPage({required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsForVenueProvider(venueId));
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Reviews')),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const _EmptyState(message: 'No reviews yet. Be the first to review this venue!');
          }
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, i) => _ReviewCard(review: reviews[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorState(
          message: 'Something went wrong. Please try again.',
          onRetry: () => ref.refresh(reviewsForVenueProvider(venueId)),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Review card, rating ${review.rating}',
      button: false,
      child: Card(
        child: ListTile(
          title: Text(
            'Rating: ${review.rating}',
            style: Theme.of(context).textTheme.titleMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          subtitle: Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          trailing: review.response != null ? Icon(Icons.reply, color: Colors.green) : null,
          onTap: () {
            // TODO: Show review details or response
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  const _EmptyState({required this.message, this.onAction, this.actionLabel});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          if (onAction != null && actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_comment),
                label: Text(actionLabel!),
                onPressed: onAction,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700])),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    );
  }
} 