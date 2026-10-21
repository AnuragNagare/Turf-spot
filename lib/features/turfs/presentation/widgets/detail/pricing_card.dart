import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/turf_model.dart';

/// Weekday / Weekend / Peak Hours rates. Falls back to the free-text
/// `priceDetails` rows when structured rates are not available.
class PricingCard extends StatelessWidget {
  final TurfModel turf;

  const PricingCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    final columns = <_Rate>[
      if (turf.weekdayRate != null)
        _Rate(Icons.calendar_month_outlined, 'Weekday', 'Mon – Fri', turf.weekdayRate!),
      if (turf.weekendRate != null)
        _Rate(Icons.calendar_month_outlined, 'Weekend', 'Sat – Sun', turf.weekendRate!),
      if (turf.peakRate != null)
        _Rate(Icons.bolt_rounded, 'Peak Hours', turf.peakHours ?? '', turf.peakRate!),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.limeTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_rupee_rounded, size: 24, color: AppColors.authText),
              const SizedBox(width: 8),
              Text(
                'Pricing',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authText,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '(Per Hour)',
                style: TextStyle(fontSize: 18, color: AppColors.authText),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (columns.isNotEmpty)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < columns.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: AppColors.authFieldBorder,
                      ),
                    Expanded(child: _RateColumn(rate: columns[i])),
                  ],
                ],
              ),
            )
          else
            _buildFallbackRows(),
        ],
      ),
    );
  }

  Widget _buildFallbackRows() {
    if (turf.priceDetails.isEmpty) {
      return Text(
        '${AppFormatters.formatCurrency(turf.pricePerHour)} / hour',
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.authText,
        ),
      );
    }

    return Column(
      children: [
        for (final entry in turf.priceDetails.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14, color: AppColors.authMuted),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.authText,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Rate {
  final IconData icon;
  final String label;
  final String subLabel;
  final int amount;

  const _Rate(this.icon, this.label, this.subLabel, this.amount);
}

class _RateColumn extends StatelessWidget {
  final _Rate rate;

  const _RateColumn({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(rate.icon, size: 26, color: AppColors.authForest),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authText,
                    ),
                  ),
                  if (rate.subLabel.isNotEmpty)
                    Text(
                      rate.subLabel,
                      style: const TextStyle(fontSize: 12, color: AppColors.authMuted),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: AppFormatters.formatCurrency(rate.amount),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authText,
                  ),
                ),
                const TextSpan(
                  text: ' / hour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authText,
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
