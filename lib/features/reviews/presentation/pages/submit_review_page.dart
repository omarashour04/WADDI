import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitReviewPage extends StatefulWidget {
  final String userId;
  final String venueId;
  const SubmitReviewPage({required this.userId, required this.venueId, Key? key}) : super(key: key);

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  double rating = 5.0;
  final _controller = TextEditingController();
  bool isSubmitting = false;
  String? error;

  Future<void> _submitReview() async {
    setState(() {
      isSubmitting = true;
      error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': widget.userId,
        'venueId': widget.venueId,
        'rating': rating,
        'comment': _controller.text.trim(),
        'createdAt': Timestamp.now(),
      });
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => error = 'Failed to submit review: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${rating.toStringAsFixed(1)}'),
            Slider(
              value: rating,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: rating.toStringAsFixed(1),
              onChanged: (val) => setState(() => rating = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('Submit'),
                  ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
} 