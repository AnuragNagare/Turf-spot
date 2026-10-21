import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/turf_repository.dart';
import '../providers/turf_provider.dart';

/// "Sort by" label followed by horizontally scrolling sort chips.
class SortChipsRow extends ConsumerWidget {
  const SortChipsRow({super.key});

  static const _options = [
    (TurfSortOption.nearest, 'Nearest', Icons.location_on_rounded),
    (TurfSortOption.priceLowToHigh, 'Price: Low to High', Icons.swap_vert_rounded),
    (TurfSortOption.priceHighToLow, 'Price: High to Low', Icons.swap_vert_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(turfSortOptionProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _options.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Text(
                'Sort by',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authText,
                ),
              ),
            );
          }

          final (option, label, icon) = _options[index - 1];
          final isSelected = option == selected;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => ref.read(turfSortOptionProvider.notifier).state = option,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lime : AppColors.authField,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.lime : AppColors.authFieldBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.authText),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.authText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
