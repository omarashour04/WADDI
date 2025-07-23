import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VenueFormPage extends StatefulWidget {
  final String ownerId;
  final String? venueId; // null for add, not null for edit
  const VenueFormPage({required this.ownerId, this.venueId, Key? key}) : super(key: key);

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  List<String> imageUrls = [];
  bool isSubmitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.venueId != null) _loadVenue();
  }

  Future<void> _loadVenue() async {
    final doc = await FirebaseFirestore.instance.collection('venues').doc(widget.venueId).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _descController.text = data['description'] ?? '';
      _addressController.text = data['address'] ?? '';
      _contactPhoneController.text = data['contactPhone'] ?? '';
      _contactEmailController.text = data['contactEmail'] ?? '';
      imageUrls = List<String>.from(data['images'] ?? []);
      setState(() {});
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref().child('venue_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}');
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
        'address': _addressController.text.trim(),
        'contactPhone': _contactPhoneController.text.trim(),
        'contactEmail': _contactEmailController.text.trim(),
        'images': imageUrls,
        'ownerId': widget.ownerId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.venueId == null) {
        await FirebaseFirestore.instance.collection('venues').add(data);
      } else {
        await FirebaseFirestore.instance.collection('venues').doc(widget.venueId).update(data);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => error = 'Failed to save venue: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.venueId == null ? 'Add Venue' : 'Edit Venue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Venue Name'),
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
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(labelText: 'Contact Email'),
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
                      child: Text(widget.venueId == null ? 'Add Venue' : 'Save Changes'),
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