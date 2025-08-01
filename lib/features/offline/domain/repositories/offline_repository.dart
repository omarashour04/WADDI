abstract class OfflineRepository {
  Future<void> cacheVenues(List<Map<String, dynamic>> venues);
  Future<List<Map<String, dynamic>>> getCachedVenues();
  Future<void> cacheUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getCachedUserData();
  Future<void> cacheFavorites(List<Map<String, dynamic>> favorites);
  Future<List<Map<String, dynamic>>> getCachedFavorites();
  Future<void> cacheBookings(List<Map<String, dynamic>> bookings);
  Future<List<Map<String, dynamic>>> getCachedBookings();
  Future<DateTime?> getLastSyncTime();
  Future<bool> isDataStale(Duration maxAge);
  Future<void> clearAllCache();
  Future<void> cacheImage(String url, String fileName);
  Future<String?> getCachedImagePath(String fileName);
  Future<void> clearImageCache();
} 