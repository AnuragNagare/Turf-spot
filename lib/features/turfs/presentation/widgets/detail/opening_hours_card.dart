import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/opening_hours.dart';

/// Today's opening hours with a live Open Now / Closed chip.
class OpeningHoursCard extends StatelessWidget {
  final Map<String, String> openingHours;

  const OpeningHoursCard({super.key, required this.openingHours});

  @override
  Widget build(BuildContext context) {
    final info = OpeningHours.forToday(openingHours, DateTime.now());
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, size: 34, color: AppColors.authText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opening Hours',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.label.replaceAll(' - ', ' – '),
                  style: const TextStyle(fontSize: 16, color: AppColors.authMuted),
                ),
              ],
            ),
          ),
          if (info.isOpen != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: info.isOpen! ? const Color(0xFFD7F5C8) : const Color(0xFFFDE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                info.isOpen! ? 'Open Now' : 'Closed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: info.isOpen! ? AppColors.authForest : AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
