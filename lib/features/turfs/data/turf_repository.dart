import 'dart:math';
import '../domain/turf_model.dart';
import 'mock_turfs_data.dart';

enum TurfSortOption {
  nearest,
  priceLowToHigh,
  priceHighToLow;

  String get label {
    switch (this) {
      case TurfSortOption.nearest:
        return 'Nearest First';
      case TurfSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case TurfSortOption.priceHighToLow:
        return 'Price: High to Low';
    }
  }
}

abstract class TurfRepository {
  Future<List<TurfModel>> getTurfs({
    String? query,
    String? sportFilter, // 'All', 'Cricket', 'Football'
    String? areaFilter,
    TurfSortOption sortOption = TurfSortOption.nearest,
    double? userLatitude,
    double? userLongitude,
  });

  Future<TurfModel?> getTurfById(String id);
}

class InMemoryTurfRepository implements TurfRepository {
  final List<TurfModel> _turfs = List.from(mockTurfs);

  // Haversine formula to compute great-circle distance between two points in km
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Future<List<TurfModel>> getTurfs({
    String? query,
    String? sportFilter,
    String? areaFilter,
    TurfSortOption sortOption = TurfSortOption.nearest,
    double? userLatitude,
    double? userLongitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate fast 300ms fetch

    final userLat = userLatitude ?? 19.1136; // Default to Mumbai center
    final userLon = userLongitude ?? 72.8697;

    var results = _turfs.where((t) => t.isActive).map((turf) {
      final dist = _calculateDistance(userLat, userLon, turf.latitude, turf.longitude);
      return turf.copyWith(calculatedDistanceKm: dist);
    }).toList();

    // 1. Sport Filter
    if (sportFilter != null && sportFilter != 'All' && sportFilter != 'Both') {
      results = results.where((t) {
        return t.sports.any((s) => s.toLowerCase() == sportFilter.toLowerCase());
      }).toList();
    }

    // 2. Area Filter
    if (areaFilter != null && areaFilter != 'All Areas') {
      results = results.where((t) => t.area.toLowerCase() == areaFilter.toLowerCase()).toList();
    }

    // 3. Search Query (Typo-tolerant, case-insensitive prefix and keyword match)
    if (query != null && query.trim().length >= 2) {
      final q = query.trim().toLowerCase();
      results = results.where((t) {
        final matchesName = t.nameLowercase.contains(q);
        final matchesArea = t.area.toLowerCase().contains(q);
        final matchesKeywords = t.searchKeywords.any((k) => k.contains(q));
        return matchesName || matchesArea || matchesKeywords;
      }).toList();
    }

    // 4. Sorting
    switch (sortOption) {
      case TurfSortOption.nearest:
        results.sort((a, b) =>
            (a.calculatedDistanceKm ?? 0).compareTo(b.calculatedDistanceKm ?? 0));
        break;
      case TurfSortOption.priceLowToHigh:
        results.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case TurfSortOption.priceHighToLow:
        results.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
    }

    return results;
  }

  @override
  Future<TurfModel?> getTurfById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      final turf = _turfs.firstWhere((t) => t.id == id);
      return turf;
    } catch (_) {
      return null;
    }
  }
}
