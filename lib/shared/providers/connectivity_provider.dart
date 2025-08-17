import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider that tracks the current connectivity status
final connectivityProvider = StreamProvider<bool>((ref) async* {
  // First check current connectivity
  final currentResult = await Connectivity().checkConnectivity();
  yield currentResult != ConnectivityResult.none;
  
  // Then listen to changes
  yield* Connectivity().onConnectivityChanged.map((result) {
    return result != ConnectivityResult.none;
  });
});

/// Provider that provides the current connectivity status as a boolean
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online while loading
    error: (_, __) => false, // Assume offline on error
  );
});

/// Simple boolean provider for connectivity status
final connectivityStatusProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(connectivityProvider);
});
