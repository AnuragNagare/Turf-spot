import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/turf_provider.dart';

/// Full-width photo carousel with back, favourite and share buttons and a
/// "n / total" counter.
class DetailPhotoHeader extends ConsumerWidget {
  final String turfId;
  final List<String> photos;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const DetailPhotoHeader({
    super.key,
    required this.turfId,
    required this.photos,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.paddingOf(context).top;
    final isFavourite = ref.watch(favouriteTurfsProvider).contains(turfId);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller,
          itemCount: photos.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) => CachedNetworkImage(
            imageUrl: photos[index],
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => Container(
              color: AppColors.authField,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.authForest),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.authField,
              child: const Icon(Icons.sports, size: 48, color: AppColors.authMuted),
            ),
          ),
        ),
        // Keeps the buttons readable on bright photos.
        IgnorePointer(
          child: Container(
            height: topInset + 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
        Positioned(
          top: topInset + 8,
          left: 16,
          child: _CircleButton(
            tooltip: 'Back',
            background: AppColors.authForest,
            icon: Icons.arrow_back_rounded,
            iconColor: Colors.white,
            onTap: onBack,
          ),
        ),
        Positioned(
          top: topInset + 8,
          right: 16,
          child: Row(
            children: [
              _CircleButton(
                tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
                background: Colors.white,
                icon: isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: isFavourite ? AppColors.error : AppColors.authText,
                onTap: () => ref.read(favouriteTurfsProvider.notifier).toggle(turfId),
              ),
              const SizedBox(width: 10),
              _CircleButton(
                tooltip: 'Share',
                background: Colors.white,
                icon: Icons.share_rounded,
                iconColor: AppColors.authText,
                onTap: onShare,
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_camera_outlined, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${currentIndex + 1} / ${photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String tooltip;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.tooltip,
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 24, color: iconColor),
          ),
        ),
      ),
    );
  }
}
