import 'package:cloud_firestore/cloud_firestore.dart';

class BookingEntity {
  final String id;
  final String userId;
  final String venueId;
  final String roomId;
  final String venueName;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final int? rating;
  final String? review;
  final int numberOfPeople;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String? checkedInBy; // userId of who checked them in
  final String? qrCode; // Unique QR code for this booking
  final DateTime? autoCancellationTime; // When booking will be auto-cancelled if not checked in
  final bool? reminder24hSent;
  final bool? reminder1hSent;
  final bool? reminder15mSent;

  BookingEntity({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.roomId,
    required this.venueName,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.notes,
    required this.numberOfPeople,
    required this.createdAt,
    required this.updatedAt,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.checkedInBy,
    this.qrCode,
    this.autoCancellationTime,
    this.rating,
    this.review,
    this.reminder24hSent,
    this.reminder1hSent,
    this.reminder15mSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'venueId': venueId,
      'roomId': roomId,
      'venueName': venueName,
      'roomName': roomName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'rating': rating,
      'review': review,
      'numberOfPeople': numberOfPeople,
      'isCheckedIn': isCheckedIn,
      'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'checkedInBy': checkedInBy,
      'qrCode': qrCode,
      'reminder24hSent': reminder24hSent ?? false,
      'reminder1hSent': reminder1hSent ?? false,
      'reminder15mSent': reminder15mSent ?? false,
    };
  }

  /// Convert to map for offline storage (JSON serializable)
  Map<String, dynamic> toMapForOffline() {
    return {
      'userId': userId,
      'venueId': venueId,
      'roomId': roomId,
      'venueName': venueName,
      'roomName': roomName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'review': review,
      'numberOfPeople': numberOfPeople,
      'isCheckedIn': isCheckedIn,
      'checkedInAt': checkedInAt?.toIso8601String(),
      'checkedInBy': checkedInBy,
      'qrCode': qrCode,
      'reminder24hSent': reminder24hSent ?? false,
      'reminder1hSent': reminder1hSent ?? false,
      'reminder15mSent': reminder15mSent ?? false,
    };
  }

  /// Create from offline map (JSON deserializable)
  factory BookingEntity.fromOfflineMap(Map<String, dynamic> map, String id) {
    return BookingEntity(
      id: id,
      userId: map['userId'] ?? '',
      venueId: map['venueId'] ?? '',
      roomId: map['roomId'] ?? '',
      venueName: map['venueName'] ?? '',
      roomName: map['roomName'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationHours: map['durationHours'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      notes: map['notes'],
      numberOfPeople: map['numberOfPeople'] ?? 1,
      isCheckedIn: map['isCheckedIn'] ?? false,
      checkedInAt: map['checkedInAt'] != null ? DateTime.parse(map['checkedInAt']) : null,
      checkedInBy: map['checkedInBy'],
      qrCode: map['qrCode'],
      rating: map['rating'],
      review: map['review'],
      reminder24hSent: map['reminder24hSent'],
      reminder1hSent: map['reminder1hSent'],
      reminder15mSent: map['reminder15mSent'],
    );
  }

  factory BookingEntity.fromMap(Map<String, dynamic> map, String id) {
    return BookingEntity(
      id: id,
      userId: map['userId'] ?? '',
      venueId: map['venueId'] ?? '',
      roomId: map['roomId'] ?? '',
      venueName: map['venueName'] ?? '',
      roomName: map['roomName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      durationHours: map['durationHours'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      notes: map['notes'],
      rating: map['rating'],
      review: map['review'],
      numberOfPeople: map['numberOfPeople'] ?? 1,
      isCheckedIn: map['isCheckedIn'] ?? false,
      checkedInAt: map['checkedInAt'] != null ? (map['checkedInAt'] as Timestamp).toDate() : null,
      checkedInBy: map['checkedInBy'],
      qrCode: map['qrCode'],
      reminder24hSent: map['reminder24hSent'] ?? false,
      reminder1hSent: map['reminder1hSent'] ?? false,
      reminder15mSent: map['reminder15mSent'] ?? false,
    );
  }

  BookingEntity copyWith({
    String? id,
    String? userId,
    String? venueId,
    String? roomId,
    String? venueName,
    String? roomName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    int? rating,
    String? review,
    int? numberOfPeople,
    bool? isCheckedIn,
    DateTime? checkedInAt,
    String? checkedInBy,
    String? qrCode,
    bool? reminder24hSent,
    bool? reminder1hSent,
    bool? reminder15mSent,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      venueId: venueId ?? this.venueId,
      roomId: roomId ?? this.roomId,
      venueName: venueName ?? this.venueName,
      roomName: roomName ?? this.roomName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
      qrCode: qrCode ?? this.qrCode,
      reminder24hSent: reminder24hSent ?? this.reminder24hSent,
      reminder1hSent: reminder1hSent ?? this.reminder1hSent,
      reminder15mSent: reminder15mSent ?? this.reminder15mSent,
    );
  }

  // Calculate the actual status based on time and current status
  String get actualStatus {
    final now = DateTime.now();
    
    // If already cancelled, return cancelled
    if (status == 'cancelled') return 'cancelled';
    
    // Check if booking should be auto-cancelled (10 minutes late for cash payments)
    if (!isCheckedIn && status == 'confirmed' && totalPrice == 0.0) {
      final checkInDeadline = startTime.add(const Duration(minutes: 10));
      if (now.isAfter(checkInDeadline)) return 'cancelled';
    }
    
    // If booking time has passed, mark as completed
    if (endTime.isBefore(now)) return 'completed';
    
    // If booking is in progress (started but not ended)
    if (startTime.isBefore(now) && endTime.isAfter(now)) return 'in_progress';
    
    // If booking is in the future, return the original status
    return status;
  }

  // Check if booking is upcoming (future booking)
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now()) && status != 'cancelled';
  }

  // Check if booking is past (completed)
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  // Check if booking is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now) && status != 'cancelled';
  }

  bool get canCancel => isUpcoming && status == 'confirmed';
  bool get canReview => isPast && status == 'completed' && rating == null;
  
  // Check-in related getters (15-minute window)
  bool get needsCheckIn => status == 'confirmed' && !isCheckedIn && startTime.isBefore(DateTime.now().add(const Duration(minutes: 15)));
  bool get isOverdueForCheckIn => status == 'confirmed' && !isCheckedIn && DateTime.now().isAfter(startTime.add(const Duration(minutes: 15)));
  bool get isCashPayment => totalPrice == 0.0;
  bool get canCheckIn => status == 'confirmed' && !isCheckedIn && !isOverdueForCheckIn;
} 