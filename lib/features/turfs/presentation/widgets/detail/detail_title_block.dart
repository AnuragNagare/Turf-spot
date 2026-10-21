import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/turf_model.dart';

/// Name, location, rating, "Popular" badge, freshness text and sport pills.
class DetailTitleBlock extends StatelessWidget {
  final TurfModel turf;

  const DetailTitleBlock({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    final distance = turf.calculatedDistanceKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          turf.name,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppColors.authText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 24, color: AppColors.authText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${turf.area}, ${turf.city}',
                style: const TextStyle(fontSize: 16, color: AppColors.authText),
              ),
            ),
            if (distance != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.map_outlined, size: 24, color: AppColors.authText),
              const SizedBox(width: 6),
              Text(
                AppFormatters.formatDistance(distance),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authText,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            if (turf.rating != null) _buildRating(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 20, color: AppColors.authMuted),
                const SizedBox(width: 6),
                Text(
                  'Info updated on ${AppFormatters.formatDateShort(turf.updatedAt)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.authMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [for (final sport in turf.sports) _SportPill(sport: sport)],
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 28, color: AppColors.accent),
        const SizedBox(width: 4),
        Text(
          turf.rating!.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
        if (turf.reviewCount != null) ...[
          const SizedBox(width: 6),
          Text(
            '(${turf.reviewCount} reviews)',
            style: const TextStyle(fontSize: 16, color: AppColors.authMuted),
          ),
        ],
        if (turf.isPopular) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD7F5C8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 16, color: AppColors.authForest),
                SizedBox(width: 4),
                Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authForest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SportPill extends StatelessWidget {
  final String sport;

  const _SportPill({required this.sport});

  @override
  Widget build(BuildContext context) {
    final isCricket = sport.toLowerCase() == 'cricket';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.authField,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCricket ? Icons.sports_cricket_rounded : Icons.sports_soccer_rounded,
            size: 22,
            color: AppColors.authText,
          ),
          const SizedBox(width: 8),
          Text(
            sport,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.authText,
            ),
          ),
        ],
      ),
    );
  }
}
