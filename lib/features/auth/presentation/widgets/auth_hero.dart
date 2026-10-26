import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'splash_painters.dart';

/// Where the grass starts inside the hero, as a fraction of its height.
const double _heroHorizon = 0.78;

/// Colour at the bottom of the hero; the sheet sits on top of it.
const Color authHeroBase = Color(0xFF031009);

/// Night-stadium header with the TurfSpot logo, wordmark and tagline.
class AuthHero extends StatelessWidget {
  final double height;

  const AuthHero({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const StadiumPhoto(horizonFactor: _heroHorizon),
          // Darkens the photo so the white wordmark stays readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66010504), Color(0x99010504)],
              ),
            ),
          ),
          const CustomPaint(painter: _RibbonPainter()),
          Padding(
            padding: EdgeInsets.only(top: topInset + 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TurfSpotLogoMark(width: 76),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Turf',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Spot',
                        style: TextStyle(color: AppColors.lime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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

/// Bright green ribbons that sweep in from the top-right and left edges.
class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topRight = Path()
      ..moveTo(w * 0.64, 0)
      ..quadraticBezierTo(w * 0.82, h * 0.2, w, h * 0.27)
      ..lineTo(w, h * 0.42)
      ..quadraticBezierTo(w * 0.78, h * 0.22, w * 0.7, 0)
      ..close();

    final left = Path()
      ..moveTo(0, h * 0.63)
      ..quadraticBezierTo(w * 0.18, h * 0.7, w * 0.27, h * _heroHorizon)
      ..lineTo(w * 0.24, h * _heroHorizon)
      ..quadraticBezierTo(w * 0.1, h * 0.76, 0, h * 0.7)
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.lime, AppColors.primaryDark],
      ).createShader(Offset.zero & size);

    for (final path in [topRight, left]) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.lime.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawPath(path, fill);
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => false;
}
