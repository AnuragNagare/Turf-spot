import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ComingSoonOption {
  final IconData icon;
  final String label;

  const ComingSoonOption(this.icon, this.label);
}

/// Placeholder sheet for features that are not built yet.
class ComingSoonSheet extends StatelessWidget {
  final String title;
  final String message;
  final List<ComingSoonOption> options;

  const ComingSoonSheet({
    super.key,
    required this.title,
    required this.message,
    this.options = const [],
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    List<ComingSoonOption> options = const [],
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.authSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ComingSoonSheet(title: title, message: message, options: options),
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
              title,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.authText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppColors.authMuted),
            ),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(option.icon, color: AppColors.authForest),
                title: Text(
                  option.label,
                  style: const TextStyle(
                    color: AppColors.authText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Coming soon',
                  style: TextStyle(color: AppColors.authMuted, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
