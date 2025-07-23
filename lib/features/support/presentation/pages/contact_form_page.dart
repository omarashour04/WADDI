import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactFormPage extends StatefulWidget {
  final String userId;
  const ContactFormPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  bool isSubmitting = false;
  String? error;

  Future<void> _submitTicket() async {
    setState(() {
      isSubmitting = true;
      error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('supportTickets').add({
        'userId': widget.userId,
        'subject': _subjectController.text.trim(),
        'description': _descController.text.trim(),
        'category': 'General',
        'status': 'open',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => error = 'Failed to submit ticket: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitTicket,
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