import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RoomFormPage extends StatefulWidget {
  final String venueId;
  final String? roomId; // null for add, not null for edit
  const RoomFormPage({required this.venueId, this.roomId, Key? key}) : super(key: key);

  @override
  State<RoomFormPage> createState() => _RoomFormPageState();
}

class _RoomFormPageState extends State<RoomFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController();
  final _hourlyPriceController = TextEditingController();
  final _equipmentController = TextEditingController();
  List<String> imageUrls = [];
  bool isSubmitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null) _loadRoom();
  }

  Future<void> _loadRoom() async {
    final doc = await FirebaseFirestore.instance.collection('venues').doc(widget.venueId).collection('rooms').doc(widget.roomId).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _descController.text = data['description'] ?? '';
      _capacityController.text = data['capacity']?.toString() ?? '';
      _hourlyPriceController.text = data['hourlyPrice']?.toString() ?? '';
      _equipmentController.text = (data['amenities'] as List?)?.join(', ') ?? '';
      imageUrls = List<String>.from(data['images'] ?? []);
      setState(() {});
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref().child('room_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() => imageUrls.add(url));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isSubmitting = true;
      error = null;
    });
    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'capacity': int.tryParse(_capacityController.text.trim()) ?? 0,
        'hourlyPrice': double.tryParse(_hourlyPriceController.text.trim()) ?? 0.0,
        'images': imageUrls,
        'amenities': _equipmentController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'venueId': widget.venueId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final roomsRef = FirebaseFirestore.instance.collection('venues').doc(widget.venueId).collection('rooms');
      if (widget.roomId == null) {
        await roomsRef.add(data);
      } else {
        await roomsRef.doc(widget.roomId).update(data);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => error = 'Failed to save room: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomId == null ? 'Add Room' : 'Edit Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hourlyPriceController,
                decoration: const InputDecoration(labelText: 'Hourly Price (EGP)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipment/Amenities (comma separated)'),
              ),
              const SizedBox(height: 16),
              Text('Images:', style: Theme.of(context).textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: [
                  ...imageUrls.map((url) => Image.network(url, width: 80, height: 80, fit: BoxFit.cover)),
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: _pickAndUploadImage,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(widget.roomId == null ? 'Add Room' : 'Save Changes'),
                    ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 