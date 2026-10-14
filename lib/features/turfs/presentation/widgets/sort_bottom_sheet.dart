import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/turf_repository.dart';
import '../providers/turf_provider.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SortBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(turfSortOptionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sort Turfs By',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSortTile(
            context,
            ref,
            option: TurfSortOption.nearest,
            icon: Icons.near_me_outlined,
            title: 'Nearest First',
            subtitle: 'Sorted by distance from your current location',
            isSelected: currentSort == TurfSortOption.nearest,
          ),
          const SizedBox(height: 8),
          _buildSortTile(
            context,
            ref,
            option: TurfSortOption.priceLowToHigh,
            icon: Icons.trending_down_rounded,
            title: 'Price: Low to High',
            subtitle: 'Most economical turfs first',
            isSelected: currentSort == TurfSortOption.priceLowToHigh,
          ),
          const SizedBox(height: 8),
          _buildSortTile(
            context,
            ref,
            option: TurfSortOption.priceHighToLow,
            icon: Icons.trending_up_rounded,
            title: 'Price: High to Low',
            subtitle: 'Premium venues first',
            isSelected: currentSort == TurfSortOption.priceHighToLow,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortTile(
    BuildContext context,
    WidgetRef ref, {
    required TurfSortOption option,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ref.read(turfSortOptionProvider.notifier).state = option;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
