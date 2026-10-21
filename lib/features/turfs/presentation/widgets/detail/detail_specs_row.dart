import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/turf_model.dart';

/// Turf Type, Formats and Surface as three icon + label + value columns.
class DetailSpecsRow extends StatelessWidget {
  final TurfModel turf;

  const DetailSpecsRow({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    final specs = <_Spec>[
      if (turf.turfType != null)
        _Spec(Icons.grass_rounded, 'Turf Type', turf.turfType!),
      if (turf.formats.isNotEmpty)
        _Spec(Icons.sports_soccer_outlined, 'Formats', turf.formats.join(', ')),
      _Spec(Icons.layers_outlined, 'Surface', turf.surface),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.authFieldBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final spec in specs)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(spec.icon, size: 30, color: AppColors.authForest),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spec.label,
                          style: const TextStyle(fontSize: 13, color: AppColors.authMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spec.value,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.authText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Spec {
  final IconData icon;
  final String label;
  final String value;

  const _Spec(this.icon, this.label, this.value);
}
