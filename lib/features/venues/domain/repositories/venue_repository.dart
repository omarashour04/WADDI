import '../entities/venue_entity.dart';
import '../entities/room_entity.dart';
import '../../presentation/providers/venue_providers.dart';

abstract class VenueRepository {
  Future<VenueEntity?> getVenueById(String id);
  Future<List<VenueEntity>> getAllVenues();
  Future<void> createVenue(VenueEntity venue);
  Future<void> updateVenue(VenueEntity venue);
  Future<void> deleteVenue(String id);

  // Rooms subcollection
  Future<List<RoomEntity>> getRoomsForVenue(String venueId);
  Future<void> createRoom(String venueId, RoomEntity room);
  Future<void> updateRoom(String venueId, RoomEntity room);
  Future<void> deleteRoom(String venueId, String roomId);

  // Search and filter
  Future<List<VenueEntity>> searchAndFilterVenues({String? query, VenueFilter? filter});
} 