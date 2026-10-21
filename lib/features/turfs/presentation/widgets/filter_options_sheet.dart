import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Placeholder filter menu; the options are listed but not wired up yet.
class FilterOptionsSheet extends StatelessWidget {
  const FilterOptionsSheet({super.key});

  static const _options = [
    (Icons.payments_outlined, 'Price range'),
    (Icons.checklist_rounded, 'Amenities'),
    (Icons.star_outline_rounded, 'Rating'),
    (Icons.near_me_outlined, 'Distance'),
  ];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.authSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const FilterOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.authFieldBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filters',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.authText,
              ),
            ),
            const SizedBox(height: 8),
            for (final (icon, label) in _options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: AppColors.authForest),
                title: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.authText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Coming soon',
                  style: TextStyle(color: AppColors.authMuted, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.authMuted),
              ),
          ],
        ),
      ),
    );
  }
}
