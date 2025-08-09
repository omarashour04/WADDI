import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailTestPage extends ConsumerStatefulWidget {
  const EmailTestPage({super.key});

  @override
  ConsumerState<EmailTestPage> createState() => _EmailTestPageState();
}

class _EmailTestPageState extends ConsumerState<EmailTestPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _result;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Email Functionality',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Test Email Address',
                hintText: 'Enter email to send test to',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Test User Name',
                hintText: 'Enter test user name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testConfirmationEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Confirmation Email'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testCancellationEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Cancellation Email'),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testReminderEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Reminder Email'),
            ),
            const SizedBox(height: 24),
            
            if (_result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.contains('success') ? Colors.green[50] : Colors.red[50],
                  border: Border.all(
                    color: _result!.contains('success') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!,
                  style: TextStyle(
                    color: _result!.contains('success') ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConfirmationEmail() async {
    await _testEmail('confirmation');
  }

  Future<void> _testCancellationEmail() async {
    await _testEmail('cancellation');
  }

  Future<void> _testReminderEmail() async {
    await _testEmail('reminder');
  }

  Future<void> _testEmail(String type) async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _result = 'Please enter both email and name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // Email service temporarily removed
      bool success = false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email feature is temporarily disabled'),
          backgroundColor: Colors.orange,
        ),
      );

      setState(() {
        _result = success 
            ? '✅ $type email sent successfully! Check your inbox.'
            : '❌ Failed to send $type email. Check console for details.';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error sending $type email: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 