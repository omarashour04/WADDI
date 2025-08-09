import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waddi_platform/features/auth/auth_injection.dart';

class ReviewsPage extends ConsumerWidget {
  final String venueId;
  const ReviewsPage({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('venueId', isEqualTo: venueId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews found.'));
          }
          final reviews = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, i) {
              final review = reviews[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text('Rating: ${review['rating'] ?? ''}'),
                  subtitle: Text(review['comment'] ?? ''),
                  trailing: Text(review['userId'] ?? ''),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _NewReviewDialog(venueId: venueId, userId: userId),
          );
        },
        tooltip: 'Write Review',
        child: const Icon(Icons.rate_review),
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
            // Show review details dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Review Details'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Rating: '),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Comment:'),
                    const SizedBox(height: 4),
                    Text(review.comment),
                    if (review.response != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Venue Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(review.response!),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
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
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
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
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
          ),
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

class _NewReviewDialog extends StatefulWidget {
  final String venueId;
  final String userId;
  const _NewReviewDialog({required this.venueId, required this.userId});
  @override
  State<_NewReviewDialog> createState() => _NewReviewDialogState();
}

class _NewReviewDialogState extends State<_NewReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Write a Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: _rating.toString(),
            onChanged: (val) => setState(() => _rating = val),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comment'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('reviews').add({
              'userId': widget.userId,
              'venueId': widget.venueId,
              'rating': _rating,
              'comment': _commentController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
