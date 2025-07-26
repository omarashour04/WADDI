import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore firestore;
  BookingRepositoryImpl({required this.firestore});

  @override
  Future<BookingEntity?> getBookingById(String id) async {
    final doc = await firestore.collection('bookings').doc(id).get();
    if (!doc.exists) return null;
    return BookingEntity.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<BookingEntity>> getBookingsForUser(String userId) async {
    final snapshot = await firestore.collection('bookings').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => BookingEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsForVenue(String venueId) async {
    final snapshot = await firestore.collection('bookings').where('venueId', isEqualTo: venueId).get();
    return snapshot.docs.map((doc) => BookingEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsForRoomOnDate(String roomId, DateTime date) async {
    final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0));
    final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
    final snapshot = await firestore.collection('bookings')
      .where('roomId', isEqualTo: roomId)
      .where('startTime', isLessThanOrEqualTo: endOfDay)
      .where('endTime', isGreaterThanOrEqualTo: startOfDay)
      .get();
    return snapshot.docs.map((doc) => BookingEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> createBooking(BookingEntity booking) async {
    // Generate a new document ID if the booking ID is empty
    final docId = booking.id.isEmpty ? null : booking.id;
    final docRef = docId != null 
        ? firestore.collection('bookings').doc(docId)
        : firestore.collection('bookings').doc();
    
    // Create a new booking entity with the generated ID
    final bookingWithId = BookingEntity(
      id: docRef.id,
      userId: booking.userId,
      venueId: booking.venueId,
      roomId: booking.roomId,
      startTime: booking.startTime,
      endTime: booking.endTime,
      durationHours: booking.durationHours,
      roomFee: booking.roomFee,
      reservationFee: booking.reservationFee,
      totalAmount: booking.totalAmount,
      paymentStatus: booking.paymentStatus,
      bookingStatus: booking.bookingStatus,
      paymentIntentId: booking.paymentIntentId,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
    
    await docRef.set(bookingWithId.toMap());
  }

  @override
  Future<void> updateBooking(BookingEntity booking) async {
    await firestore.collection('bookings').doc(booking.id).update(booking.toMap());
  }

  @override
  Future<void> deleteBooking(String id) async {
    await firestore.collection('bookings').doc(id).delete();
  }
} 