import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../shared/widgets/smart_back_button.dart';

class AdminDatabaseSetupPage extends ConsumerStatefulWidget {
  const AdminDatabaseSetupPage({super.key});

  @override
  ConsumerState<AdminDatabaseSetupPage> createState() => _AdminDatabaseSetupPageState();
}

class _AdminDatabaseSetupPageState extends ConsumerState<AdminDatabaseSetupPage> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Setup'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Maintenance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use these tools to update the database structure for new features.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Add Maintenance Fields Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.engineering, color: Colors.orange),
                title: const Text('Add Maintenance Fields'),
                subtitle: const Text('Add isClosedForMaintenance field to venues and rooms'),
                trailing: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.arrow_forward_ios),
                onTap: _isLoading ? null : _addMaintenanceFields,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Add Status Fields Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Add Status Fields'),
                subtitle: const Text('Add status field to existing venues'),
                trailing: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.arrow_forward_ios),
                onTap: _isLoading ? null : _addStatusFields,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cleanup Guest Users Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.cleaning_services, color: Colors.blue),
                title: const Text('Cleanup Guest Users'),
                subtitle: const Text('Remove guest users from database'),
                trailing: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.arrow_forward_ios),
                onTap: _isLoading ? null : _cleanupGuestUsers,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Success') 
                    ? Colors.green[50] 
                    : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('Success') 
                      ? Colors.green 
                      : Colors.red,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Success') 
                      ? Colors.green[800] 
                      : Colors.red[800],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMaintenanceFields() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding maintenance fields...';
    });

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('addMaintenanceFields');
      
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;
      
      setState(() {
        _statusMessage = '✅ ${data['message']}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addStatusFields() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding status fields...';
    });

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('updateVenuesWithStatus');
      
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;
      
      setState(() {
        _statusMessage = '✅ ${data['message']}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupGuestUsers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cleaning up guest users...';
    });

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('cleanupGuestUsers');
      
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;
      
      setState(() {
        _statusMessage = '✅ ${data['message']}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 