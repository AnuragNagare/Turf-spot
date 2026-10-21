import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/user_model.dart';
import '../../data/turf_repository.dart';
import '../../domain/turf_model.dart';

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

// Favourite turfs (local to the session for now)
class FavouriteTurfsNotifier extends StateNotifier<Set<String>> {
  FavouriteTurfsNotifier() : super(const {});

  void toggle(String turfId) {
    state = state.contains(turfId)
        ? (Set<String>.of(state)..remove(turfId))
        : {...state, turfId};
  }
}

final favouriteTurfsProvider =
    StateNotifierProvider<FavouriteTurfsNotifier, Set<String>>(
  (ref) => FavouriteTurfsNotifier(),
);

// Recently viewed turf ids, newest first (last 10, session only)
class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  static const _maxItems = 10;

  RecentlyViewedNotifier() : super(const []);

  void add(String turfId) {
    state = [turfId, ...state.where((id) => id != turfId)].take(_maxItems).toList();
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<String>>(
  (ref) => RecentlyViewedNotifier(),
);

// Resolves comma-separated turf ids to turfs, keeping the given order.
// (A String key, not a List, so the family can compare keys by value.)
final turfsByIdsProvider =
    FutureProvider.family<List<TurfModel>, String>((ref, idsKey) async {
  if (idsKey.isEmpty) return const [];
  final ids = idsKey.split(',');

  final repo = ref.watch(turfRepositoryProvider);
  final lat = ref.watch(userLatitudeProvider);
  final lon = ref.watch(userLongitudeProvider);
  final all = await repo.getTurfs(userLatitude: lat, userLongitude: lon);
  final byId = {for (final turf in all) turf.id: turf};

  return [for (final id in ids) if (byId[id] != null) byId[id]!];
});
