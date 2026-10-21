import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Pill-shaped Login / Sign Up switch driven by a two-tab [TabController].
class AuthModeToggle extends StatelessWidget {
  final TabController controller;

  const AuthModeToggle({super.key, required this.controller});

  static const _labels = ['Login', 'Sign Up'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.authField,
        borderRadius: BorderRadius.circular(28),
      ),
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, _) {
          final t = controller.animation!.value.clamp(0.0, 1.0);

          return Stack(
            children: [
              Align(
                alignment: Alignment(-1 + 2 * t, 0),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.authForest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.authForest.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _labels.length; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: controller.index == i,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => controller.animateTo(i),
                          child: Center(
                            child: Text(
                              _labels[i],
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color.lerp(
                                  Colors.white,
                                  AppColors.authText,
                                  (t - i).abs().clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
