import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

/// Sticky Call / Directions / Share bar.
class DetailActionBar extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback onShare;

  const DetailActionBar({
    super.key,
    required this.onCall,
    required this.onDirections,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Call',
                icon: Icons.phone_rounded,
                background: Colors.white,
                foreground: AppColors.authForest,
                borderColor: AppColors.authForest,
                onTap: onCall,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 13,
              child: _ActionButton(
                label: 'Directions',
                icon: Icons.near_me_outlined,
                background: AppColors.authForest,
                foreground: Colors.white,
                onTap: onDirections,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Share',
                icon: Icons.ios_share_rounded,
                background: AppColors.limeTint,
                foreground: AppColors.authForest,
                onTap: onShare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 24, color: foreground),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: foreground,
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
