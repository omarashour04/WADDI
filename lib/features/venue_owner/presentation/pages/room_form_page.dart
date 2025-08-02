import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../domain/entities/room_entity.dart';

class RoomFormPage extends ConsumerStatefulWidget {
  final String venueId;
  final String? roomId;

  const RoomFormPage({super.key, required this.venueId, this.roomId});

  @override
  ConsumerState<RoomFormPage> createState() => _RoomFormPageState();
}

class _RoomFormPageState extends ConsumerState<RoomFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _hourlyPriceController = TextEditingController();
  final _equipmentController = TextEditingController();

  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isClosedForMaintenance = false;

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null) {
      _loadRoom();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _hourlyPriceController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _capacityController.text = data['capacity']?.toString() ?? '';
        _hourlyPriceController.text = data['hourlyPrice']?.toString() ?? '';
        _equipmentController.text = data['equipment'] ?? '';
        _isClosedForMaintenance = data['isClosedForMaintenance'] ?? false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading room: $e')));
      }
    }
  }

  Future<void> _pickImages() async {
    // Implementation for image picking
    // This would use image_picker package
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'capacity': int.parse(_capacityController.text),
        'hourlyPrice': double.parse(_hourlyPriceController.text),
        'equipment': _equipmentController.text.trim(),
        'isClosedForMaintenance': _isClosedForMaintenance,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.roomId == null) {
        roomData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('venues')
            .doc(widget.venueId)
            .collection('rooms')
            .add(roomData);
      } else {
        await FirebaseFirestore.instance
            .collection('venues')
            .doc(widget.venueId)
            .collection('rooms')
            .doc(widget.roomId)
            .update(roomData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.roomId == null ? 'Room added successfully!' : 'Room updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/venue-owner/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving room: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomId == null ? 'Add Room' : 'Edit Room'),
        leading: const SmartBackButton(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter room description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyPriceController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Price (EGP)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter hourly price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(
                  labelText: 'Equipment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Closed for Maintenance'),
                subtitle: const Text('Mark this room as unavailable'),
                value: _isClosedForMaintenance,
                onChanged: (value) {
                  setState(() {
                    _isClosedForMaintenance = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.roomId == null ? 'Add Room' : 'Update Room'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
