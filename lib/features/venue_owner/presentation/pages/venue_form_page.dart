import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/storage_utils.dart';

// Room data model
class RoomData {
  String? id;
  String name;
  String description;
  int capacity;
  double hourlyPrice;
  List<String> images;
  List<String> amenities;
  bool isClosedForMaintenance;
  String? error;

  RoomData({
    this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.hourlyPrice,
    required this.images,
    required this.amenities,
    this.isClosedForMaintenance = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'hourlyPrice': hourlyPrice,
      'images': images,
      'amenities': amenities,
      'isClosedForMaintenance': isClosedForMaintenance,
      'venueId': '', // Will be set when saving
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory RoomData.fromMap(Map<String, dynamic> map, String roomId) {
    return RoomData(
      id: roomId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      capacity: map['capacity'] ?? 0,
      hourlyPrice: (map['hourlyPrice'] ?? 0.0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      isClosedForMaintenance: map['isClosedForMaintenance'] ?? false,
    );
  }

  RoomData copyWith({
    String? id,
    String? name,
    String? description,
    int? capacity,
    double? hourlyPrice,
    List<String>? images,
    List<String>? amenities,
    bool? isClosedForMaintenance,
    String? error,
  }) {
    return RoomData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      isClosedForMaintenance: isClosedForMaintenance ?? this.isClosedForMaintenance,
    );
  }
}

class VenueFormPage extends StatefulWidget {
  final String ownerId;
  final String? venueId; // null for add, not null for edit
  const VenueFormPage({required this.ownerId, this.venueId, super.key});

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _timeSlotDurationController = TextEditingController();

  List<String> imageUrls = [];
  List<String> selectedAmenities = [];
  List<RoomData> rooms = [];
  bool isSubmitting = false;
  bool isClosedForMaintenance = false;
  bool allowOpenEndedBookings = false; // New field for open-ended bookings
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
    try {
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

        // Load maintenance status
        isClosedForMaintenance = data['isClosedForMaintenance'] ?? false;

        // Load open-ended bookings status
        allowOpenEndedBookings = data['allowOpenEndedBookings'] ?? false;

        // Load rooms
        await _loadRooms();

        setState(() {});
      }
    } catch (e) {
      setState(() => error = 'Failed to load venue: $e');
    }
  }

  Future<void> _loadRooms() async {
    try {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('rooms')
          .get();

      rooms = roomsSnapshot.docs.map((doc) {
        return RoomData.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  void _addRoom() {
    setState(() {
      rooms.add(
        RoomData(
          name: '',
          description: '',
          capacity: 0,
          hourlyPrice: 0.0,
          images: [],
          amenities: [],
          isClosedForMaintenance: false,
        ),
      );
    });
  }

  void _removeRoom(int index) {
    setState(() {
      rooms.removeAt(index);
    });
  }

  void _updateRoom(int index, RoomData room) {
    setState(() {
      rooms[index] = room;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);

      // Get venue name for path (use current input or default)
      final venueName = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'unnamed_venue';

      // Generate proper storage path
      final venuePath = StorageUtils.getVenueImagePath(venueName);
      final filename = StorageUtils.generateImageFilename(picked.name);
      final fullPath = '$venuePath$filename';

      final ref = FirebaseStorage.instance.ref().child(fullPath);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() => imageUrls.add(url));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate rooms
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      if (room.name.trim().isEmpty) {
        setState(() => error = 'Room ${i + 1}: Name is required');
        return;
      }
      if (room.capacity <= 0) {
        setState(() => error = 'Room ${i + 1}: Capacity must be greater than 0');
        return;
      }
      if (room.hourlyPrice <= 0) {
        setState(() => error = 'Room ${i + 1}: Hourly price must be greater than 0');
        return;
      }
    }

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
        'isClosedForMaintenance': isClosedForMaintenance,
        'allowOpenEndedBookings': allowOpenEndedBookings,
        'openTime': _openTimeController.text.trim(),
        'closeTime': _closeTimeController.text.trim(),
        'timeSlotDuration': int.tryParse(_timeSlotDurationController.text) ?? 30,
        'hourlyPriceRange': {'min': minPrice, 'max': maxPrice},
        'capacityRange': {'min': minCapacity, 'max': maxCapacity},
        'operatingHours':
            '${_openTimeController.text.trim()} - ${_closeTimeController.text.trim()}',
        'blockedDates': [],
        'amenities': selectedAmenities,
        'location': GeoPoint(0, 0), // Default location
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String venueId;
      if (widget.venueId == null) {
        // Create new venue
        final venueDoc = await FirebaseFirestore.instance.collection('venues').add(data);
        venueId = venueDoc.id;
      } else {
        // Update existing venue
        await FirebaseFirestore.instance.collection('venues').doc(widget.venueId).update(data);
        venueId = widget.venueId!;
      }

      // Save rooms
      await _saveRooms(venueId);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.venueId == null ? 'Venue added successfully!' : 'Venue updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            // Use GoRouter to navigate back to venue owner dashboard
            context.go('/venue-owner');
          }
        });
      }
    } catch (e) {
      setState(() => error = 'Failed to save venue: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _saveRooms(String venueId) async {
    final roomsRef = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('rooms');

    for (final room in rooms) {
      final roomData = room.toMap();
      roomData['venueId'] = venueId;

      if (room.id == null) {
        // Create new room
        await roomsRef.add(roomData);
      } else {
        // Update existing room
        await roomsRef.doc(room.id).update(roomData);
      }
    }
  }

  Widget _buildRoomCard(int index, RoomData room) {
    final nameController = TextEditingController(text: room.name);
    final descController = TextEditingController(text: room.description);
    final capacityController = TextEditingController(text: room.capacity.toString());
    final priceController = TextEditingController(text: room.hourlyPrice.toString());

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${index + 1}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeRoom(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _updateRoom(index, room.copyWith(name: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => _updateRoom(index, room.copyWith(description: value)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        _updateRoom(index, room.copyWith(capacity: int.tryParse(value) ?? 0)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Hourly Price *',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateRoom(
                      index,
                      room.copyWith(hourlyPrice: double.tryParse(value) ?? 0.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableAmenities.map((amenity) {
                final isSelected = room.amenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updatedRoom = room.copyWith(
                      amenities: selected
                          ? [...room.amenities, amenity]
                          : room.amenities.where((a) => a != amenity).toList(),
                    );
                    _updateRoom(index, updatedRoom);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Room Images',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...room.images.map(
                  (url) => Stack(
                    children: [
                      Image.network(
                        url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final updatedRoom = room.copyWith(
                              images: room.images.where((img) => img != url).toList(),
                            );
                            _updateRoom(index, updatedRoom);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickAndUploadRoomImage(index),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 24, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Room Maintenance Status
            SwitchListTile(
              title: const Text('Closed for Maintenance'),
              subtitle: const Text('Mark this room as temporarily closed'),
              value: room.isClosedForMaintenance,
              onChanged: (value) {
                final updatedRoom = room.copyWith(isClosedForMaintenance: value);
                _updateRoom(index, updatedRoom);
              },
              secondary: Icon(
                room.isClosedForMaintenance ? Icons.engineering : Icons.engineering_outlined,
                color: room.isClosedForMaintenance ? Colors.orange : Colors.grey,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (room.isClosedForMaintenance)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This room will be marked as closed for maintenance.',
                        style: TextStyle(color: Colors.orange[700], fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadRoomImage(int roomIndex) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);

        // Get venue name and room name for path
        final venueName = _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'unnamed_venue';
        final roomName = rooms[roomIndex].name.trim().isNotEmpty
            ? rooms[roomIndex].name.trim()
            : 'unnamed_room';

        // Generate proper storage path
        final roomPath = StorageUtils.getRoomImagePath(venueName, roomName);
        final filename = StorageUtils.generateImageFilename(picked.name);
        final fullPath = '$roomPath$filename';

        final ref = FirebaseStorage.instance.ref().child(fullPath);
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();

        final room = rooms[roomIndex];
        final updatedRoom = room.copyWith(images: [...room.images, url]);
        _updateRoom(roomIndex, updatedRoom);
      }
    } catch (e) {
      setState(() => error = 'Failed to upload image: $e');
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),

              // Maintenance Status Section
              Text(
                'Maintenance Status',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Mark your venue as closed for maintenance if needed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Closed for Maintenance'),
                        subtitle: const Text('Mark venue as temporarily closed'),
                        value: isClosedForMaintenance,
                        onChanged: (value) {
                          setState(() {
                            isClosedForMaintenance = value;
                          });
                        },
                        secondary: Icon(
                          isClosedForMaintenance ? Icons.engineering : Icons.engineering_outlined,
                          color: isClosedForMaintenance ? Colors.orange : Colors.grey,
                        ),
                      ),
                      if (isClosedForMaintenance)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Venue will be marked as closed for maintenance. Users will not be able to book during this time.',
                                  style: TextStyle(color: Colors.orange[700], fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Open-Ended Bookings Section
              Text(
                'Open-Ended Bookings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Allow users to book open-ended periods (e.g., for monthly rentals).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Allow Open-Ended Bookings'),
                        subtitle: const Text('Enable open-ended booking periods'),
                        value: allowOpenEndedBookings,
                        onChanged: (value) {
                          setState(() {
                            allowOpenEndedBookings = value;
                          });
                        },
                        secondary: Icon(
                          allowOpenEndedBookings ? Icons.calendar_today : Icons.calendar_today_outlined,
                          color: allowOpenEndedBookings ? Colors.green : Colors.grey,
                        ),
                      ),
                      if (allowOpenEndedBookings)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Users can book open-ended periods (e.g., monthly rentals).',
                                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Operating Hours Section
              Text(
                'Operating Hours',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operating Hours',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Open Time',
                                hintText: '09:00',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter open time';
                                }
                                // Validate time format (HH:MM)
                                if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                                  return 'Please enter time in HH:MM format';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _closeTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Close Time',
                                hintText: '22:00',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter close time';
                                }
                                // Validate time format (HH:MM)
                                if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                                  return 'Please enter time in HH:MM format';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeSlotDurationController,
                        decoration: const InputDecoration(
                          labelText: 'Time Slot Duration (minutes)',
                          hintText: '30',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter time slot duration';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Please enter a valid duration';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Room Management Section
              Text(
                'Room Management',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Add rooms to your venue. Each room will have its own ID and details.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Rooms List
              ...rooms.asMap().entries.map((entry) {
                final index = entry.key;
                final room = entry.value;
                return _buildRoomCard(index, room);
              }),

              // Add Room Button
              OutlinedButton.icon(
                onPressed: _addRoom,
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
              const SizedBox(height: 24),

              // Images Section
              Text(
                'Images',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...imageUrls.map(
                    (url) => Stack(
                      children: [
                        Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
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
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
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
