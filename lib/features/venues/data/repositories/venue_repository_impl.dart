import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/venue_repository.dart';
import '../../presentation/providers/venue_providers.dart';

class VenueRepositoryImpl implements VenueRepository {
  final FirebaseFirestore firestore;
  VenueRepositoryImpl({required this.firestore});

  @override
  Future<VenueEntity?> getVenueById(String id) async {
    final doc = await firestore.collection('venues').doc(id).get();
    if (!doc.exists) return null;
    return VenueEntity.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<VenueEntity>> getAllVenues({bool includePending = false}) async {
    try {
      print('Fetching venues from Firestore...');
      Query query = firestore.collection('venues');
      
      // Only return approved venues unless specifically requested to include pending
      if (!includePending) {
        query = query.where('status', isEqualTo: 'approved');
      }
      
      final snapshot = await query.get();
      print('Found ${snapshot.docs.length} venues');
      final venues = snapshot.docs.map((doc) => VenueEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      print('Successfully loaded ${venues.length} venues');
      return venues;
    } catch (e, stackTrace) {
      print('Error in getAllVenues: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> createVenue(VenueEntity venue) async {
    await firestore.collection('venues').doc(venue.id).set(venue.toMap());
  }

  @override
  Future<void> updateVenue(VenueEntity venue) async {
    await firestore.collection('venues').doc(venue.id).update(venue.toMap());
  }

  @override
  Future<void> deleteVenue(String id) async {
    await firestore.collection('venues').doc(id).delete();
  }

  // Admin methods for venue approval
  @override
  Future<void> approveVenue(String id) async {
    await firestore.collection('venues').doc(id).update({
      'status': 'approved',
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> rejectVenue(String id) async {
    await firestore.collection('venues').doc(id).update({
      'status': 'rejected',
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<List<VenueEntity>> getPendingVenues() async {
    try {
      final snapshot = await firestore
          .collection('venues')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.map((doc) => VenueEntity.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting pending venues: $e');
      rethrow;
    }
  }

  // Rooms subcollection
  @override
  Future<List<RoomEntity>> getRoomsForVenue(String venueId) async {
    final snapshot = await firestore.collection('venues').doc(venueId).collection('rooms').get();
    return snapshot.docs.map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<RoomEntity?> getRoomById(String roomId) async {
    // Search for the room across all venues
    final venues = await getAllVenues();
    for (final venue in venues) {
      final rooms = await getRoomsForVenue(venue.id);
      final room = rooms.where((room) => room.id == roomId).firstOrNull;
      if (room != null) {
        return room;
      }
    }
    return null;
  }

  @override
  Future<void> createRoom(String venueId, RoomEntity room) async {
    await firestore
        .collection('venues')
        .doc(venueId)
        .collection('rooms')
        .doc(room.id)
        .set(room.toMap());
  }

  @override
  Future<void> updateRoom(String venueId, RoomEntity room) async {
    await firestore
        .collection('venues')
        .doc(venueId)
        .collection('rooms')
        .doc(room.id)
        .update(room.toMap());
  }

  @override
  Future<void> deleteRoom(String venueId, String roomId) async {
    await firestore.collection('venues').doc(venueId).collection('rooms').doc(roomId).delete();
  }

  @override
  Future<List<VenueEntity>> searchAndFilterVenues({String? query, VenueFilter? filter, bool includePending = false}) async {
    var collection = firestore.collection('venues');
    Query venuesQuery = collection;
    
    // Only return approved venues unless specifically requested to include pending
    if (!includePending) {
      venuesQuery = venuesQuery.where('status', isEqualTo: 'approved');
    }
    
    if (filter != null) {
      if (filter.minRating != null) {
        venuesQuery = venuesQuery.where('averageRating', isGreaterThanOrEqualTo: filter.minRating);
      }
      if (filter.priceRange != null) {
        venuesQuery = venuesQuery.where(
          'hourlyPriceRange.min',
          isLessThanOrEqualTo: filter.priceRange,
        );
        venuesQuery = venuesQuery.where(
          'hourlyPriceRange.max',
          isGreaterThanOrEqualTo: filter.priceRange,
        );
      }
      if (filter.amenities != null && filter.amenities!.isNotEmpty) {
        for (final amenity in filter.amenities!) {
          venuesQuery = venuesQuery.where('amenities', arrayContains: amenity);
        }
      }
      if (filter.gameTypes != null && filter.gameTypes!.isNotEmpty) {
        for (final gameType in filter.gameTypes!) {
          venuesQuery = venuesQuery.where('gameTypes', arrayContains: gameType);
        }
      }
    }
    final snapshot = await venuesQuery.get();
    var venues = snapshot.docs
        .map((doc) => VenueEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    if (query != null && query.isNotEmpty) {
      venues = venues
          .where(
            (venue) =>
        venue.name.toLowerCase().contains(query.toLowerCase()) ||
                venue.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    return venues;
  }
} 
