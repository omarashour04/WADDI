class SearchFilters {
  final double? minPrice;
  final double? maxPrice;
  final int? minCapacity;
  final int? maxCapacity;
  final List<String> amenities;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? radius; // in kilometers
  final String sortBy; // 'price', 'rating', 'distance', 'availability'
  final bool sortAscending;
  final bool showOnlyAvailable;

  SearchFilters({
    this.minPrice,
    this.maxPrice,
    this.minCapacity,
    this.maxCapacity,
    this.amenities = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.radius,
    this.sortBy = 'rating',
    this.sortAscending = false,
    this.showOnlyAvailable = false,
  });

  SearchFilters copyWith({
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    int? maxCapacity,
    List<String>? amenities,
    String? location,
    double? latitude,
    double? longitude,
    double? radius,
    String? sortBy,
    bool? sortAscending,
    bool? showOnlyAvailable,
  }) {
    return SearchFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      amenities: amenities ?? this.amenities,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
    );
  }

  bool get hasFilters {
    return minPrice != null ||
        maxPrice != null ||
        minCapacity != null ||
        maxCapacity != null ||
        amenities.isNotEmpty ||
        location != null ||
        latitude != null ||
        longitude != null ||
        radius != null ||
        showOnlyAvailable;
  }

  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minCapacity': minCapacity,
      'maxCapacity': maxCapacity,
      'amenities': amenities,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
      'showOnlyAvailable': showOnlyAvailable,
    };
  }

  factory SearchFilters.fromMap(Map<String, dynamic> map) {
    return SearchFilters(
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      minCapacity: map['minCapacity']?.toInt(),
      maxCapacity: map['maxCapacity']?.toInt(),
      amenities: List<String>.from(map['amenities'] ?? []),
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      radius: map['radius']?.toDouble(),
      sortBy: map['sortBy'] ?? 'rating',
      sortAscending: map['sortAscending'] ?? false,
      showOnlyAvailable: map['showOnlyAvailable'] ?? false,
    );
  }
} 