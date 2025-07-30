import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

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
  
  // New controllers for additional fields
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minCapacityController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  
  List<String> imageUrls = [];
  List<String> selectedAmenities = [];
  bool isSubmitting = false;
  String? error;

  // Available amenities options
  final List<String> availableAmenities = [
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Heating',
    'Kitchen',
    'Bathroom',
    'Sound System',
    'Projector',
    'Whiteboard',
    'Coffee/Tea',
    'Catering',
    'Security',
    'Accessibility',
    'Outdoor Space',
    'Gaming Equipment',
    'Meeting Rooms',
    'Conference Facilities',
    'Storage Space',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.venueId != null) _loadVenue();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minCapacityController.dispose();
    _maxCapacityController.dispose();
    super.dispose();
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
      
      // Load price range
      final hourlyPriceRange = data['hourlyPriceRange'] as Map<String, dynamic>? ?? {};
      _minPriceController.text = (hourlyPriceRange['min'] ?? 0).toString();
      _maxPriceController.text = (hourlyPriceRange['max'] ?? 0).toString();
      
      // Load capacity range
      final capacityRange = data['capacityRange'] as Map<String, dynamic>? ?? {};
      _minCapacityController.text = (capacityRange['min'] ?? 0).toString();
      _maxCapacityController.text = (capacityRange['max'] ?? 0).toString();
      
      // Load amenities
      selectedAmenities = List<String>.from(data['amenities'] ?? []);
      
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
      // Set status based on who is creating the venue
      final status = widget.ownerId == 'admin' ? 'approved' : 'pending';
      
      // Parse price and capacity values
      final minPrice = double.tryParse(_minPriceController.text) ?? 0.0;
      final maxPrice = double.tryParse(_maxPriceController.text) ?? 0.0;
      final minCapacity = int.tryParse(_minCapacityController.text) ?? 0;
      final maxCapacity = int.tryParse(_maxCapacityController.text) ?? 0;
      
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'address': _addressController.text.trim(),
        'contactPhone': _contactPhoneController.text.trim(),
        'contactEmail': _contactEmailController.text.trim(),
        'images': imageUrls,
        'ownerId': widget.ownerId,
        'status': status, // 'approved' for admin, 'pending' for venue owners
        'averageRating': 0.0,
        'totalReviews': 0,
        'hourlyPriceRange': {
          'min': minPrice,
          'max': maxPrice,
        },
        'capacityRange': {
          'min': minCapacity,
          'max': maxCapacity,
        },
        'operatingHours': {},
        'blockedDates': [],
        'amenities': selectedAmenities,
        'location': GeoPoint(0, 0), // Default location
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (widget.venueId == null) {
        await FirebaseFirestore.instance.collection('venues').add(data);
      } else {
        await FirebaseFirestore.instance.collection('venues').doc(widget.venueId).update(data);
      }
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.venueId == null ? 'Venue added successfully!' : 'Venue updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            GoRouter.of(context).pop();
          }
        });
      }
    } catch (e) {
      setState(() => error = 'Failed to save venue: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venueId == null ? 'Add Venue' : 'Edit Venue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.mounted) {
              // Navigate back to the appropriate page based on owner
              if (widget.ownerId == 'admin') {
                context.go('/admin/venues');
              } else {
                // For venue owners, go back to their dashboard
                context.go('/venue-owner?ownerId=${widget.ownerId}');
              }
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Basic Information Section
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Venue Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              // Contact Information Section
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Pricing Section
              Text(
                'Pricing (per hour)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Capacity Section
              Text(
                'Capacity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Min Capacity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxCapacityController,
                      decoration: const InputDecoration(
                        labelText: 'Max Capacity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Amenities Section
              Text(
                'Amenities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableAmenities.map((amenity) {
                  final isSelected = selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAmenities.add(amenity);
                        } else {
                          selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Images Section
              Text(
                'Images',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...imageUrls.map((url) => Stack(
                    children: [
                      Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imageUrls.remove(url);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.venueId == null ? 'Add Venue' : 'Save Changes',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 