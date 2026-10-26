class TurfModel {
  final String id;
  final String name;
  final String nameLowercase;
  final List<String> searchKeywords;
  final String address;
  final String area;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> sports; // 'cricket', 'football'
  final List<String> formats; // 'Box Cricket', '5-a-side', etc.
  final String surface; // 'Artificial Grass', 'Natural Grass'
  final String? turfType; // e.g. 'Artificial Grass' (surface may be more specific)
  final int pricePerHour;
  final int? weekdayRate;
  final int? weekendRate;
  final int? peakRate;
  final String? peakHours; // e.g. '6 PM – 11 PM'
  final Map<String, String> priceDetails; // 'Weekday', 'Weekend', 'Peak Hours'
  final Map<String, String> openingHours; // 'Mon-Fri': '6:00 AM - 12:00 AM', etc.
  final List<String> amenities; // 'floodlights', 'parking', 'washroom', etc.
  final List<String> photos;
  final String phone;
  final bool isActive;
  final DateTime updatedAt;
  final double? rating;
  final int? reviewCount;
  double? calculatedDistanceKm;

  TurfModel({
    required this.id,
    required this.name,
    required this.nameLowercase,
    required this.searchKeywords,
    required this.address,
    required this.area,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.sports,
    required this.formats,
    required this.surface,
    this.turfType,
    this.weekdayRate,
    this.weekendRate,
    this.peakRate,
    this.peakHours,
    required this.pricePerHour,
    required this.priceDetails,
    required this.openingHours,
    required this.amenities,
    required this.photos,
    required this.phone,
    required this.isActive,
    required this.updatedAt,
    this.rating,
    this.reviewCount,
    this.calculatedDistanceKm,
  });

  String get coverPhoto =>
      photos.isNotEmpty ? photos.first : 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800';

  /// Highly rated and widely reviewed turfs get the 'Popular' badge.
  bool get isPopular => (rating ?? 0) >= 4.5 && (reviewCount ?? 0) >= 100;

  bool get hasRates =>
      weekdayRate != null || weekendRate != null || peakRate != null;

  bool get supportsCricket =>
      sports.any((s) => s.toLowerCase() == 'cricket');

  bool get supportsFootball =>
      sports.any((s) => s.toLowerCase() == 'football');

  TurfModel copyWith({
    double? calculatedDistanceKm,
  }) {
    return TurfModel(
      id: id,
      name: name,
      nameLowercase: nameLowercase,
      searchKeywords: searchKeywords,
      address: address,
      area: area,
      city: city,
      latitude: latitude,
      longitude: longitude,
      sports: sports,
      formats: formats,
      surface: surface,
      turfType: turfType,
      weekdayRate: weekdayRate,
      weekendRate: weekendRate,
      peakRate: peakRate,
      peakHours: peakHours,
      pricePerHour: pricePerHour,
      priceDetails: priceDetails,
      openingHours: openingHours,
      amenities: amenities,
      photos: photos,
      phone: phone,
      isActive: isActive,
      updatedAt: updatedAt,
      rating: rating,
      reviewCount: reviewCount,
      calculatedDistanceKm: calculatedDistanceKm ?? this.calculatedDistanceKm,
    );
  }

  factory TurfModel.fromMap(Map<String, dynamic> map, String id) {
    return TurfModel(
      id: id,
      name: map['name'] ?? '',
      nameLowercase: (map['nameLowercase'] ?? (map['name'] as String? ?? '').toLowerCase()),
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      city: map['city'] ?? 'Mumbai',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 19.0760,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 72.8777,
      sports: List<String>.from(map['sports'] ?? []),
      formats: List<String>.from(map['formats'] ?? []),
      surface: map['surface'] ?? 'Artificial Grass',
      turfType: map['turfType'],
      weekdayRate: (map['weekdayRate'] as num?)?.toInt(),
      weekendRate: (map['weekendRate'] as num?)?.toInt(),
      peakRate: (map['peakRate'] as num?)?.toInt(),
      peakHours: map['peakHours'],
      pricePerHour: (map['pricePerHour'] as num?)?.toInt() ?? 1000,
      priceDetails: Map<String, String>.from(map['priceDetails'] ?? {}),
      openingHours: Map<String, String>.from(map['openingHours'] ?? {}),
      amenities: List<String>.from(map['amenities'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
      phone: map['phone'] ?? '+919876543210',
      isActive: map['isActive'] ?? true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: (map['reviewCount'] as num?)?.toInt(),
    );
  }
}
