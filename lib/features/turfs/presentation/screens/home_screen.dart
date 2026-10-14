import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../providers/turf_provider.dart';
import '../widgets/area_picker_dialog.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/sport_filter_chips.dart';
import '../widgets/turf_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final sortOption = ref.watch(turfSortOptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(turfsListProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Top Location & Profile Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location selector button
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => AreaPickerDialog.show(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppConstants.defaultCity,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedArea,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // User Profile Avatar
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: ClipOval(
                            child: user?.photoUrl != null
                                ? Image.network(
                                    user!.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky Search Bar & Filter Controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search by turf name or area...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.textSecondary, size: 22),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        color: AppColors.textSecondary, size: 18),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Filter Chips & Sort Button Row
                      Row(
                        children: [
                          const Expanded(child: SportFilterChips()),
                          const SizedBox(width: 8),
                          // Sort Trigger Button
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => SortBottomSheet.show(context),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sort_rounded,
                                    size: 18,
                                    color: AppColors.primaryLight,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sortOption.label.split(':').first,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Section Header: Available Turfs Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchQuery.isNotEmpty ? 'Search Results' : 'Nearby Turfs',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      turfsAsync.when(
                        data: (list) => Text(
                          '${list.length} available',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // Turf List / Skeletons / Empty State
              turfsAsync.when(
                data: (turfs) {
                  if (turfs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyStateWidget(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TurfCard(turf: turfs[index]),
                        childCount: turfs.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const TurfCardSkeleton(),
                      childCount: 4,
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    description: err.toString(),
                    actionText: 'Retry',
                    onAction: () => ref.invalidate(turfsListProvider),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
