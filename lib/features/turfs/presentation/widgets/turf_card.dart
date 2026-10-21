import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/turf_model.dart';
import '../providers/turf_provider.dart';
import 'amenity_icon.dart';

class TurfCard extends ConsumerWidget {
  final TurfModel turf;

  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/turf/${turf.id}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 4, child: _buildPhoto(ref)),
                  const SizedBox(width: 12),
                  Expanded(flex: 6, child: _buildDetails()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(WidgetRef ref) {
    final isFavourite = ref.watch(favouriteTurfsProvider).contains(turf.id);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 170),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: turf.coverPhoto,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.authField),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.authField,
                child: const Icon(Icons.sports, size: 36, color: AppColors.authMuted),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Semantics(
                button: true,
                label: isFavourite ? 'Remove from favourites' : 'Add to favourites',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ref.read(favouriteTurfsProvider.notifier).toggle(turf.id),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black38,
                    ),
                    child: Icon(
                      isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 22,
                      color: isFavourite ? AppColors.error : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${turf.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final distance = turf.calculatedDistanceKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                turf.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authText,
                ),
              ),
            ),
            if (distance != null) ...[
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(Icons.location_on_outlined, size: 15, color: AppColors.authMuted),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  AppFormatters.formatDistance(distance),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.authMuted),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${turf.area}, ${turf.city}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, color: AppColors.authMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final sport in turf.sports) _sportPill(sport)],
        ),
        if (turf.rating != null) ...[
          const SizedBox(height: 8),
          _buildRating(),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            for (final amenity in turf.amenities.take(3)) _amenity(amenity),
          ],
        ),
        const Spacer(),
        const SizedBox(height: 8),
        _buildPriceStrip(),
      ],
    );
  }

  Widget _sportPill(String sport) {
    final isCricket = sport.toLowerCase() == 'cricket';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.authField,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCricket ? Icons.sports_cricket_rounded : Icons.sports_soccer_rounded,
            size: 14,
            color: AppColors.authText,
          ),
          const SizedBox(width: 4),
          Text(
            sport,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.authText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
        const SizedBox(width: 3),
        Text(
          turf.rating!.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
        if (turf.reviewCount != null) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '(${turf.reviewCount} reviews)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.authMuted),
            ),
          ),
        ],
      ],
    );
  }

  Widget _amenity(String amenity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(amenityIcon(amenity), size: 15, color: AppColors.authMuted),
        const SizedBox(width: 4),
        Text(
          amenityShortLabel(amenity),
          style: const TextStyle(fontSize: 12, color: AppColors.authMuted),
        ),
      ],
    );
  }

  Widget _buildPriceStrip() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.limeTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${AppFormatters.formatCurrency(turf.pricePerHour)} / hour',
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authText,
                ),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.authForest,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
