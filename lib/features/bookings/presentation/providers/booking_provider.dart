import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../../../shared/services/offline_mode_service.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(FirebaseFirestore.instance);
});

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});

final bookingProvider = FutureProvider.family<BookingEntity?, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getBooking(bookingId);
});

class BookingState {
  final List<BookingEntity> allBookings;
  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> pastBookings;
  final bool isLoading;
  final String? errorMessage;

  BookingState({
    required this.allBookings,
    required this.upcomingBookings,
    required this.pastBookings,
    required this.isLoading,
    this.errorMessage,
  });

  BookingState copyWith({
    List<BookingEntity>? allBookings,
    List<BookingEntity>? upcomingBookings,
    List<BookingEntity>? pastBookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingState(
      allBookings: allBookings ?? this.allBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingNotifier(this._repository)
      : super(BookingState(
          allBookings: [],
          upcomingBookings: [],
          pastBookings: [],
          isLoading: false,
        ));

  Future<void> loadUserBookings(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bookings = await _repository.getUserBookings(userId);
      
      // Store bookings for offline access
      final bookingsData = bookings.map((booking) => booking.toMap()).toList();
      await OfflineModeService.instance.storeUserBookingsForOffline(bookingsData);

      final now = DateTime.now();
      final upcoming = bookings.where((booking) => booking.startTime.isAfter(now)).toList();
      final past = bookings.where((booking) => booking.startTime.isBefore(now)).toList();

      state = state.copyWith(
        allBookings: bookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createBooking(BookingEntity booking) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bookingId = await _repository.createBooking(booking);
      final newBooking = booking.copyWith(id: bookingId);

      // Refresh the bookings from the database to get the latest state
      final updatedBookings = await _repository.getUserBookings(newBooking.userId);
      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        allBookings: updatedBookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.cancelBooking(bookingId);

      // Refresh the bookings from the database to get the latest state
      final updatedBookings = await _repository.getUserBookings(state.allBookings.first.userId);
      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        allBookings: updatedBookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addReview(String bookingId, int rating, String review) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.addReview(bookingId, rating, review);

      final updatedBookings = state.allBookings.map((booking) {
        if (booking.id == bookingId) {
          return booking.copyWith(rating: rating, review: review);
        }
        return booking;
      }).toList();

      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        allBookings: updatedBookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<DateTime>> getRoomAvailability(String venueId, String roomId, DateTime date) async {
    try {
      return await _repository.getRoomAvailability(venueId, roomId, date);
    } catch (e) {
      throw Exception('Failed to get room availability: $e');
    }
  }

  Future<bool> isRoomAvailable(String venueId, String roomId, DateTime startTime, DateTime endTime) async {
    try {
      return await _repository.isRoomAvailable(venueId, roomId, startTime, endTime);
    } catch (e) {
      throw Exception('Failed to check room availability: $e');
    }
  }

  Future<bool> isRoomAvailableForOpenEndedBooking(String venueId, String roomId, DateTime startTime) async {
    try {
      return await _repository.isRoomAvailableForOpenEndedBooking(venueId, roomId, startTime);
    } catch (e) {
      throw Exception('Failed to check room availability for open-ended booking: $e');
    }
  }

  Future<Map<String, dynamic>?> findBestAvailableRoom({
    required String venueId,
    required int numberOfPeople,
    required DateTime startTime,
    required DateTime endTime,
    required bool isOpenEnded,
  }) async {
    try {
      return await _repository.findBestAvailableRoom(
        venueId: venueId,
        numberOfPeople: numberOfPeople,
        startTime: startTime,
        endTime: endTime,
        isOpenEnded: isOpenEnded,
      );
    } catch (e) {
      throw Exception('Failed to find best available room: $e');
    }
  }

  Future<Map<String, dynamic>> getVenueAvailabilityData({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      return await _repository.getVenueAvailabilityData(
        venueId: venueId,
        date: date,
      );
    } catch (e) {
      throw Exception('Failed to get venue availability data: $e');
    }
  }

  Future<Map<DateTime, Map<String, dynamic>>> batchGetVenueAvailabilityData({
    required String venueId,
    required List<DateTime> dates,
  }) async {
    try {
      return await _repository.batchGetVenueAvailabilityData(
        venueId: venueId,
        dates: dates,
      );
    } catch (e) {
      throw Exception('Failed to batch get venue availability data: $e');
    }
  }
}

// Provider for specific user bookings
final bookingsForUserProvider = FutureProvider.family<List<BookingEntity>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getUserBookings(userId);
}); 