import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/turf_provider.dart';

class SportFilterChips extends ConsumerWidget {
  const SportFilterChips({super.key});

  static const _sports = [
    (label: 'All Sports', value: 'All', icon: Icons.grid_view_rounded),
    (label: 'Cricket', value: 'Cricket', icon: Icons.sports_cricket_rounded),
    (label: 'Football', value: 'Football', icon: Icons.sports_soccer_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSport = ref.watch(selectedSportFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sports.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _sports[index];
          final isSelected = selectedSport == item.value;
          final foreground = isSelected ? Colors.white : AppColors.authText;

          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => ref.read(selectedSportFilterProvider.notifier).state = item.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.authForest : AppColors.authField,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.authForest : AppColors.authFieldBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: foreground),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: foreground,
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
