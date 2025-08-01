import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../data/repositories/booking_repository_impl.dart';

final bookingRepositoryProvider = Provider<BookingRepositoryImpl>((ref) {
  return BookingRepositoryImpl();
});

class BookingState {
  final List<BookingEntity> bookings;
  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> pastBookings;
  final bool isLoading;
  final String? errorMessage;

  BookingState({
    this.bookings = const [],
    this.upcomingBookings = const [],
    this.pastBookings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BookingState copyWith({
    List<BookingEntity>? bookings,
    List<BookingEntity>? upcomingBookings,
    List<BookingEntity>? pastBookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pastBookings: pastBookings ?? this.pastBookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepositoryImpl _repository;

  BookingNotifier(this._repository) : super(BookingState());

  Future<void> loadUserBookings(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bookings = await _repository.getUserBookings(userId);
      final upcoming = bookings.where((b) => b.isUpcoming).toList();
      final past = bookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        bookings: bookings,
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

      final updatedBookings = [newBooking, ...state.bookings];
      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        bookings: updatedBookings,
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
      final updatedBookings = await _repository.getUserBookings(state.bookings.first.userId);
      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        bookings: updatedBookings,
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

      final updatedBookings = state.bookings.map((booking) {
        if (booking.id == bookingId) {
          return booking.copyWith(rating: rating, review: review);
        }
        return booking;
      }).toList();

      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();

      state = state.copyWith(
        bookings: updatedBookings,
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
}

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});

// Provider for specific user bookings
final bookingsForUserProvider = FutureProvider.family<List<BookingEntity>, String>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getUserBookings(userId);
});

// Provider for specific booking
final bookingProvider = FutureProvider.family<BookingEntity?, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return await repository.getBooking(bookingId);
}); 