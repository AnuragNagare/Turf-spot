import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Soft green scene with a batsman and a footballer, plus the app slogan.
class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _ScenePainter())),
          Align(
            alignment: const Alignment(0, -0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAY MORE.\nSEARCH LESS.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                    height: 1.5,
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 30, height: 3, color: AppColors.lime),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter();

  static const _tint = Color(0xFF4E7F5A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Misty green wash that fades up into the sheet.
    final area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authSheet,
            _tint.withOpacity(0.25),
            _tint.withOpacity(0.5),
          ],
        ).createShader(area),
    );

    // Tree line.
    final trees = Paint()..color = _tint.withOpacity(0.28);
    for (var x = -10.0; x < w + 30; x += 34) {
      canvas.drawCircle(Offset(x, h * 0.55), 26 + (x % 4) * 4, trees);
    }

    // Pitch strip at the bottom.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.86, w, h * 0.14),
      Paint()..color = _tint.withOpacity(0.6),
    );

    _batsman(canvas, Offset(w * 0.17, h * 0.86), h * 0.5);
    _footballer(canvas, Offset(w * 0.83, h * 0.86), h * 0.5);
  }

  Paint _limb(double width) => Paint()
    ..color = const Color(0xFF2F5D3C)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width;

  /// [feet] is the point between the feet; [height] the figure's height.
  void _batsman(Canvas canvas, Offset feet, double height) {
    final p = _limb(height * 0.09);
    final hip = feet + Offset(0, -height * 0.45);
    final shoulder = feet + Offset(height * 0.02, -height * 0.78);

    canvas.drawLine(hip, feet + Offset(-height * 0.14, 0), p);
    canvas.drawLine(hip, feet + Offset(height * 0.14, 0), p);
    canvas.drawLine(hip, shoulder, p);
    canvas.drawCircle(
      shoulder + Offset(0, -height * 0.1),
      height * 0.08,
      Paint()..color = const Color(0xFF2F5D3C),
    );

    // Arms and a raised bat.
    final hands = shoulder + Offset(height * 0.14, -height * 0.02);
    canvas.drawLine(shoulder, hands, p);
    canvas.drawLine(
      hands + Offset(-height * 0.08, height * 0.08),
      hands + Offset(height * 0.3, -height * 0.2),
      _limb(height * 0.07)..color = const Color(0xFF3F7A4F),
    );
  }

  void _footballer(Canvas canvas, Offset feet, double height) {
    final p = _limb(height * 0.09);
    final hip = feet + Offset(0, -height * 0.45);
    final shoulder = feet + Offset(-height * 0.04, -height * 0.78);

    // Standing leg and kicking leg.
    canvas.drawLine(hip, feet + Offset(height * 0.06, 0), p);
    canvas.drawLine(hip, feet + Offset(-height * 0.28, -height * 0.08), p);
    canvas.drawLine(hip, shoulder, p);
    canvas.drawCircle(
      shoulder + Offset(0, -height * 0.1),
      height * 0.08,
      Paint()..color = const Color(0xFF2F5D3C),
    );

    // Arms out for balance.
    canvas.drawLine(shoulder, shoulder + Offset(height * 0.24, -height * 0.06), p);
    canvas.drawLine(shoulder, shoulder + Offset(-height * 0.2, height * 0.12), p);

    // Ball.
    final ball = feet + Offset(-height * 0.42, -height * 0.05);
    canvas.drawCircle(ball, height * 0.07, Paint()..color = const Color(0xFF1F3F29));
  }

  @override
  bool shouldRepaint(_ScenePainter old) => false;
}
