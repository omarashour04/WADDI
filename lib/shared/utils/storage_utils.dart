/// Utility class for Firebase Storage path management and sanitization.
///
/// This class provides methods to:
/// - Sanitize venue and room names for use in Firebase Storage paths
/// - Generate proper storage paths for venue and room images
/// - Create unique filenames for uploaded images
///
/// Storage Structure:
/// - Venue images: venues/{sanitizedVenueName}/
/// - Room images: venues/{sanitizedVenueName}/{sanitizedRoomName}/
class StorageUtils {
  /// Sanitizes a string to be used as a Firebase Storage path
  /// Replaces spaces and special characters with underscores
  static String sanitizePath(String input) {
    if (input.isEmpty) return 'unnamed';

    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters except spaces and hyphens
        .replaceAll(RegExp(r'[\s-]+'), '_') // Replace spaces and hyphens with underscores
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single underscore
        .replaceAll(RegExp(r'^_+|_+$'), ''); // Remove leading/trailing underscores
  }

  /// Generates a Firebase Storage path for venue images
  /// Format: venues/{sanitizedVenueName}/
  static String getVenueImagePath(String venueName) {
    final sanitizedName = sanitizePath(venueName);
    return 'venues/$sanitizedName/';
  }

  /// Generates a Firebase Storage path for room images
  /// Format: venues/{sanitizedVenueName}/{sanitizedRoomName}/
  static String getRoomImagePath(String venueName, String roomName) {
    final sanitizedVenueName = sanitizePath(venueName);
    final sanitizedRoomName = sanitizePath(roomName);
    return 'venues/$sanitizedVenueName/$sanitizedRoomName/';
  }

  /// Generates a unique filename for an image
  static String generateImageFilename(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    return '${timestamp}_${sanitizePath(originalName.split('.').first)}.$extension';
  }
}
