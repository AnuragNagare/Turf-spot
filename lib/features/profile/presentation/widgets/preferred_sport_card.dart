import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/user_model.dart';

/// Preferred sport selector. The pills are locked until "Edit" is tapped.
class PreferredSportCard extends StatefulWidget {
  final PreferredSport selected;
  final ValueChanged<PreferredSport> onChanged;

  const PreferredSportCard({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<PreferredSportCard> createState() => _PreferredSportCardState();
}

class _PreferredSportCardState extends State<PreferredSportCard> {
  static const _options = [
    (PreferredSport.both, 'All Sports', Icons.grid_view_rounded),
    (PreferredSport.cricket, 'Cricket', Icons.sports_cricket_rounded),
    (PreferredSport.football, 'Football', Icons.sports_soccer_rounded),
  ];

  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.limeTint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferred Sport',
                        style: GoogleFonts.outfit(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.authForest,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'This will be your default filter on Home',
                        style: TextStyle(fontSize: 14, color: AppColors.authMuted),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.authText,
                  minimumSize: const Size(48, 48),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _editing ? 'Done' : 'Edit',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Icon(_editing ? Icons.check_rounded : Icons.edit_outlined, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _pill(_options[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill((PreferredSport, String, IconData) option) {
    final (sport, label, icon) = option;
    final isSelected = widget.selected == sport;
    final foreground = isSelected ? Colors.white : AppColors.authText;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: _editing,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _editing ? () => widget.onChanged(sport) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.authForest : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: foreground),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
