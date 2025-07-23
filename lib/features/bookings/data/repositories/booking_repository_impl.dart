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
    await firestore.collection('bookings').doc(booking.id).set(booking.toMap());
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