import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/domain/user_model.dart';
import '../data/turf_repository.dart';
import '../domain/turf_model.dart';

final turfRepositoryProvider = Provider<TurfRepository>((ref) {
  return InMemoryTurfRepository();
});

// Search bar query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filter by Sport: 'All', 'Cricket', 'Football'
final selectedSportFilterProvider = StateProvider<String>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    if (user.preferredSport == PreferredSport.cricket) return 'Cricket';
    if (user.preferredSport == PreferredSport.football) return 'Football';
  }
  return 'All';
});

// Filter by Area: 'All Areas', 'Andheri West', etc.
final selectedAreaProvider = StateProvider<String>((ref) => 'All Areas');

// Sorting
final turfSortOptionProvider = StateProvider<TurfSortOption>((ref) => TurfSortOption.nearest);

// User Coordinates (Default Mumbai center)
final userLatitudeProvider = StateProvider<double>((ref) => 19.1136);
final userLongitudeProvider = StateProvider<double>((ref) => 72.8697);

// Main Turfs List Provider
final turfsListProvider = FutureProvider<List<TurfModel>>((ref) async {
  final repo = ref.watch(turfRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final sport = ref.watch(selectedSportFilterProvider);
  final area = ref.watch(selectedAreaProvider);
  final sort = ref.watch(turfSortOptionProvider);
  final lat = ref.watch(userLatitudeProvider);
  final lon = ref.watch(userLongitudeProvider);

  return repo.getTurfs(
    query: query,
    sportFilter: sport,
    areaFilter: area,
    sortOption: sort,
    userLatitude: lat,
    userLongitude: lon,
  );
});

// Single Turf Detail Provider
final turfDetailProvider = FutureProvider.family<TurfModel?, String>((ref, id) async {
  final repo = ref.watch(turfRepositoryProvider);
  final lat = ref.watch(userLatitudeProvider);
  final lon = ref.watch(userLongitudeProvider);

  final turf = await repo.getTurfById(id);
  if (turf != null) {
    final list = await repo.getTurfs(userLatitude: lat, userLongitude: lon);
    try {
      return list.firstWhere((t) => t.id == id);
    } catch (_) {
      return turf;
    }
  }
  return null;
});
