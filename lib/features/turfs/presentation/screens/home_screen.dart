import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/turf_provider.dart';
import '../widgets/area_picker_dialog.dart';
import '../widgets/filter_options_sheet.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/sort_chips_row.dart';
import '../widgets/sport_filter_chips.dart';
import '../widgets/turf_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _searchBarHeight = 56.0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final selectedArea = ref.watch(selectedAreaProvider);
    final turfsAsync = ref.watch(turfsListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final heroHeight = MediaQuery.paddingOf(context).top + 220;

    return Scaffold(
      backgroundColor: AppColors.authSheet,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        items: const [
          AppBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
          AppBottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) context.push('/profile');
        },
      ),
      body: RefreshIndicator(
        color: AppColors.authForest,
        backgroundColor: Colors.white,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () async {
          ref.invalidate(turfsListProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Hero with the search bar floating over its bottom edge
            SliverToBoxAdapter(
              child: SizedBox(
                height: heroHeight + _searchBarHeight / 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: HomeHero(
                        height: heroHeight,
                        area: selectedArea,
                        photoUrl: user?.photoUrl,
                        onLocationTap: () => AreaPickerDialog.show(context),
                        onProfileTap: () => context.push('/profile'),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      top: heroHeight - _searchBarHeight / 2,
                      child: HomeSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: _clearSearch,
                        showClear: searchQuery.isNotEmpty,
                        onFilterTap: () => FilterOptionsSheet.show(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: SportFilterChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: SortChipsRow()),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Turf List / Skeletons / Empty State
            turfsAsync.when(
              data: (turfs) {
                if (turfs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      light: true,
                      icon: Icons.search_off_rounded,
                      title: 'No turfs found',
                      description: searchQuery.isNotEmpty
                          ? 'We couldn\'t find any turf matching "$searchQuery". Try checking for spelling or resetting filters.'
                          : 'No turfs match the selected filters.',
                      actionText: 'Clear Filters',
                      onAction: () {
                        _clearSearch();
                        ref.read(selectedSportFilterProvider.notifier).state = 'All';
                        ref.read(selectedAreaProvider.notifier).state = 'All Areas';
                      },
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TurfCard(turf: turfs[index]),
                      childCount: turfs.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const TurfCardSkeleton(),
                    childCount: 4,
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: EmptyStateWidget(
                  light: true,
                  icon: Icons.error_outline_rounded,
                  title: 'Something went wrong',
                  description: err.toString(),
                  actionText: 'Retry',
                  onAction: () => ref.invalidate(turfsListProvider),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
