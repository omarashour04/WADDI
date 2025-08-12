import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../../../shared/services/offline_mode_service.dart';
import 'package:flutter/foundation.dart';

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
    if (userId.isEmpty) {
      state = state.copyWith(
        allBookings: [],
        upcomingBookings: [],
        pastBookings: [],
        isLoading: false,
        errorMessage: 'Invalid user ID',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bookings = await _repository.getUserBookings(userId);

      // Store bookings for offline access
      try {
        final bookingsData = bookings.map((booking) => booking.toMapForOffline()).toList();
        await OfflineModeService.instance.storeUserBookingsForOffline(bookingsData);
      } catch (e) {
        // Don't fail if offline storage fails
        print('Warning: Failed to store bookings offline: $e');
      }

      final now = DateTime.now();
      final upcoming = bookings.where((booking) => booking.isUpcoming).toList();
      final past = bookings.where((booking) => booking.isPast).toList();

      state = state.copyWith(
        allBookings: bookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      print('Error loading user bookings: $e');
      
      // Try to load offline data as fallback
      if (OfflineModeService.instance.isOnline == false) {
        await loadOfflineBookings(userId);
        return;
      }
      
      // Provide more user-friendly error messages
      String errorMessage;
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Access denied. Please check your permissions.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Service temporarily unavailable. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Failed to load bookings. Please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      
      // Try to load offline data as fallback for network errors
      if (e.toString().contains('network') || e.toString().contains('unavailable')) {
        await loadOfflineBookings(userId);
      }
    }
  }

  /// Load offline bookings when online loading fails
  Future<void> loadOfflineBookings(String userId) async {
    try {
      // First validate offline data
      final isValid = await OfflineModeService.instance.validateAndRepairOfflineData();
      
      if (!isValid) {
        // Data was corrupted and cleared, show appropriate message
        state = state.copyWith(
          allBookings: [],
          upcomingBookings: [],
          pastBookings: [],
          isLoading: false,
          errorMessage: 'Offline data was corrupted and has been cleared. Please check your connection and try again.',
        );
        return;
      }
      
      final offlineBookings = await OfflineModeService.instance.getOfflineUserBookings();
      if (offlineBookings.isNotEmpty) {
        // Convert offline data back to BookingEntity objects
        final bookings = offlineBookings.map((map) {
          try {
            return BookingEntity.fromOfflineMap(map, map['id'] ?? '');
          } catch (e) {
            print('Error converting offline booking: $e');
            return null;
          }
        }).where((booking) => booking != null).cast<BookingEntity>().toList();

        final upcoming = bookings.where((booking) => booking.isUpcoming).toList();
        final past = bookings.where((booking) => booking.isPast).toList();

        state = state.copyWith(
          allBookings: bookings,
          upcomingBookings: upcoming,
          pastBookings: past,
          isLoading: false,
          errorMessage: 'Showing offline data. Some information may be outdated.',
        );
      } else {
        state = state.copyWith(
          allBookings: [],
          upcomingBookings: [],
          pastBookings: [],
          isLoading: false,
          errorMessage: 'No offline data available. Please check your connection.',
        );
      }
    } catch (e) {
      print('Error loading offline bookings: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load offline data. Please try again later.',
      );
    }
  }

  /// Synchronize offline data when user comes back online
  Future<void> synchronizeOfflineData(String userId) async {
    if (userId.isEmpty) return;
    
    try {
      // Load fresh data from the server
      await loadUserBookings(userId);
    } catch (e) {
      print('Error synchronizing offline data: $e');
      // Don't update error state for sync failures
    }
  }

  /// Clear offline data (useful for logout or data corruption)
  Future<void> clearOfflineData() async {
    try {
      await OfflineModeService.instance.clearAllOfflineData();
      
      if (kDebugMode) {
        print('Offline data cleared successfully');
      }
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  /// Get offline data statistics for debugging
  Future<Map<String, dynamic>> getOfflineDataStats() async {
    try {
      return await OfflineModeService.instance.getOfflineDataStats();
    } catch (e) {
      print('Error getting offline data stats: $e');
      return {};
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
      print('Error creating booking: $e');
      
      // Provide more user-friendly error messages
      String errorMessage;
      if (e.toString().contains('room-not-available')) {
        errorMessage = 'This room is not available for the selected time. Please choose another time or room.';
      } else if (e.toString().contains('past-time')) {
        errorMessage = 'Cannot book for past times. Please select a future time.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Access denied. Please check your permissions.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Service temporarily unavailable. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Failed to create booking. Please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
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
      print('Error cancelling booking: $e');
      
      // Provide more user-friendly error messages
      String errorMessage;
      if (e.toString().contains('booking-not-found')) {
        errorMessage = 'Booking not found. It may have been already cancelled.';
      } else if (e.toString().contains('cannot-cancel')) {
        errorMessage = 'This booking cannot be cancelled. Please check the cancellation policy.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Access denied. Please check your permissions.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Service temporarily unavailable. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Failed to cancel booking. Please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> checkInByRoomScan({
    required String userId,
    required String venueId,
    required String roomId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.checkInByRoomScan(userId: userId, venueId: venueId, roomId: roomId);
      // Refresh list for that user
      final updatedBookings = await _repository.getUserBookings(userId);
      final upcoming = updatedBookings.where((b) => b.isUpcoming).toList();
      final past = updatedBookings.where((b) => b.isPast).toList();
      state = state.copyWith(
        allBookings: updatedBookings,
        upcomingBookings: upcoming,
        pastBookings: past,
        isLoading: false,
      );
    } catch (e) {
      print('Error during room scan check-in: $e');
      
      // Provide more user-friendly error messages
      String errorMessage;
      if (e.toString().contains('booking-not-found')) {
        errorMessage = 'No active booking found for this room. Please check your booking details.';
      } else if (e.toString().contains('already-checked-in')) {
        errorMessage = 'You are already checked in for this booking.';
      } else if (e.toString().contains('wrong-room')) {
        errorMessage = 'This QR code is for a different room. Please scan the correct room QR code.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Access denied. Please check your permissions.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Service temporarily unavailable. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Failed to check in. Please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> ownerCheckIn({
    required String bookingId,
    required String ownerUserId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.ownerCheckIn(bookingId: bookingId, ownerUserId: ownerUserId);
      // Refresh list for that user
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
      print('Error during owner check-in: $e');
      
      // Provide more user-friendly error messages
      String errorMessage;
      if (e.toString().contains('booking-not-found')) {
        errorMessage = 'Booking not found. It may have been cancelled or completed.';
      } else if (e.toString().contains('already-checked-in')) {
        errorMessage = 'This customer is already checked in.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Access denied. Only venue owners can check in customers.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Service temporarily unavailable. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Failed to check in customer. Please try again.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<int> enforceNoShowCancellations({String? userId, String? venueId}) async {
    try {
      return await _repository.enforceNoShowCancellations(userId: userId, venueId: venueId);
    } catch (e) {
      return 0;
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
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Method to clear error state and reset
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      isLoading: false,
    );
  }

  // Method to reset state to initial values
  void resetState() {
    state = BookingState(
      allBookings: [],
      upcomingBookings: [],
      pastBookings: [],
      isLoading: false,
      errorMessage: null,
    );
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