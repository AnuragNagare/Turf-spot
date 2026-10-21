import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../amenity_icon.dart';

/// Amenity tiles: 5 per row on normal phones, 4 on very narrow ones.
class AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;

  const AmenitiesGrid({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, size: 26, color: AppColors.authText),
            const SizedBox(width: 10),
            Text(
              'Amenities',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.authText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 340 ? 4 : 5;
            const gap = 10.0;
            final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final amenity in amenities)
                  SizedBox(
                    width: tileWidth,
                    height: tileWidth * 1.1,
                    child: _AmenityTile(amenity: amenity),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AmenityTile extends StatelessWidget {
  final String amenity;

  const _AmenityTile({required this.amenity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(amenityIcon(amenity), size: 28, color: AppColors.authForest),
          const SizedBox(height: 6),
          Text(
            amenity,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: AppColors.authText,
            ),
          ),
        ],
      ),
    );
  }
}
