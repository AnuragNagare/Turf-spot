import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'google_logo.dart';

/// Email / Google tab row driven by a two-tab [TabController].
class AuthMethodTabs extends StatelessWidget {
  final TabController controller;

  const AuthMethodTabs({super.key, required this.controller});

  Widget _icon(int i, bool selected) {
    final color = selected ? AppColors.authText : AppColors.authMuted;
    switch (i) {
      case 0:
        return Icon(Icons.mail_outline_rounded, size: 24, color: color);
      default:
        return const GoogleLogo(size: 22);
    }
  }

  static const _labels = ['Email', 'Google'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, _) {
          final t = controller.animation!.value.clamp(0.0, 1.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(height: 1, color: AppColors.authFieldBorder),
                ),
              ),
              Align(
                alignment: Alignment(t * 2 - 1, 1),
                child: FractionallySizedBox(
                  widthFactor: 1 / 2,
                  child: Container(height: 3, color: AppColors.lime),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _labels.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 28,
                        margin: const EdgeInsets.only(bottom: 4),
                        color: AppColors.authFieldBorder,
                      ),
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: controller.index == i,
                        child: InkWell(
                          onTap: () => controller.animateTo(i),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _icon(i, controller.index == i),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                    _labels[i],
                                    maxLines: 1,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: controller.index == i
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: controller.index == i
                                          ? AppColors.authText
                                          : AppColors.authMuted,
                                    ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
