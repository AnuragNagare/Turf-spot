import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Row of up to 5 thumbnails. The selected one has a lime border; when there
/// are more photos, the last tile shows "+N" and jumps to the first hidden one.
class PhotoThumbnailStrip extends StatelessWidget {
  static const _maxTiles = 5;

  final List<String> photos;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const PhotoThumbnailStrip({
    super.key,
    required this.photos,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.length < 2) return const SizedBox.shrink();

    final hasMore = photos.length > _maxTiles;
    final tileCount = hasMore ? _maxTiles : photos.length;
    final hiddenCount = photos.length - (_maxTiles - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < tileCount; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _Thumbnail(
                url: photos[i],
                selected: currentIndex == i,
                overlayLabel: hasMore && i == tileCount - 1 ? '+$hiddenCount' : null,
                onTap: () => onSelect(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  final bool selected;
  final String? overlayLabel;
  final VoidCallback onTap;

  const _Thumbnail({
    required this.url,
    required this.selected,
    required this.overlayLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: overlayLabel != null ? 'Show more photos' : 'Show photo',
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1.25,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.lime : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.authField),
                    errorWidget: (_, __, ___) => Container(color: AppColors.authField),
                  ),
                  if (overlayLabel != null)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        overlayLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
