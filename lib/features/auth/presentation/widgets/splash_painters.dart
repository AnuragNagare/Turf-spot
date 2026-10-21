import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Fraction of the screen height where the grass meets the night sky.
const double _horizonFactor = 0.5;

/// Night-time stadium: dark sky, two floodlights and a grass field.
class StadiumBackgroundPainter extends CustomPainter {
  final double opacity;
  final double horizonFactor;

  const StadiumBackgroundPainter({
    required this.opacity,
    this.horizonFactor = _horizonFactor,
  });

  Color _fade(Color color, [double scale = 1.0]) =>
      color.withOpacity((opacity * scale).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * horizonFactor;

    final sky = Rect.fromLTWH(0, 0, size.width, horizon);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_fade(const Color(0xFF010504)), _fade(AppColors.deepGreen)],
        ).createShader(sky),
    );

    final field = Rect.fromLTWH(0, horizon, size.width, size.height - horizon);
    canvas.drawRect(
      field,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _fade(const Color(0xFF0F3D1C)),
            _fade(const Color(0xFF031009)),
          ],
        ).createShader(field),
    );

    // Soft pool of light cast over the pitch by the floodlights.
    final pool = Rect.fromCircle(
      center: Offset(size.width / 2, horizon + size.height * 0.12),
      radius: size.width * 0.8,
    );
    canvas.drawRect(
      field,
      Paint()
        ..shader = RadialGradient(
          colors: [_fade(AppColors.lime, 0.14), _fade(AppColors.lime, 0)],
        ).createShader(pool),
    );

    for (final x in const [0.17, 0.83]) {
      _drawFloodlight(
        canvas,
        size,
        Offset(size.width * x, size.height * horizonFactor * 0.72),
      );
    }
  }

  void _drawFloodlight(Canvas canvas, Size size, Offset lamp) {
    final glow = Rect.fromCircle(center: lamp, radius: size.width * 0.3);
    canvas.drawCircle(
      lamp,
      glow.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [_fade(Colors.white, 0.45), _fade(Colors.white, 0)],
        ).createShader(glow),
    );

    canvas.drawLine(
      lamp,
      Offset(lamp.dx, size.height * horizonFactor),
      Paint()
        ..color = _fade(Colors.black, 0.7)
        ..strokeWidth = 2,
    );

    final bulb = Paint()..color = _fade(Colors.white);
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: lamp + Offset((col - 1) * 9.0, (row - 0.5) * 8.0),
              width: 7,
              height: 5,
            ),
            const Radius.circular(1.5),
          ),
          bulb,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StadiumBackgroundPainter old) =>
      old.opacity != opacity || old.horizonFactor != horizonFactor;
}

/// Glowing perspective pitch markings that are drawn in as [progress] goes 0 -> 1.
class PitchLinesPainter extends CustomPainter {
  final double progress;
  final double opacity;

  const PitchLinesPainter({required this.progress, required this.opacity});

  List<Path> _buildPaths(Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * _horizonFactor;

    final centerLine = Path()
      ..moveTo(w / 2, horizon)
      ..lineTo(w / 2, h);

    final centerCircle = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w / 2, h * 0.68),
        width: w * 0.62,
        height: h * 0.09,
      ));

    final leftBox = Path()
      ..moveTo(0, h * 0.6)
      ..lineTo(w * 0.28, h * 0.545)
      ..lineTo(w * 0.4, h * 0.545);

    final rightBox = Path()
      ..moveTo(w, h * 0.6)
      ..lineTo(w * 0.72, h * 0.545)
      ..lineTo(w * 0.6, h * 0.545);

    return [centerLine, centerCircle, leftBox, rightBox];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || opacity <= 0) return;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = AppColors.lime.withOpacity(0.55 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD9F99D).withOpacity(opacity);

    for (final path in _buildPaths(size)) {
      for (final metric in path.computeMetrics()) {
        final drawn = metric.extractPath(0, metric.length * progress);
        canvas.drawPath(drawn, glow);
        canvas.drawPath(drawn, core);
      }
    }
  }

  @override
  bool shouldRepaint(PitchLinesPainter old) =>
      old.progress != progress || old.opacity != opacity;
}

/// Location-pin outline used as the TurfSpot logo mark, with an animated glow.
class LogoPinPainter extends CustomPainter {
  final double glow;

  const LogoPinPainter({required this.glow});

  Path _pinPath(Size size) {
    final r = size.width / 2;
    return Path()
      ..moveTo(r, size.height)
      ..cubicTo(r * 0.25, size.height * 0.72, 0, r * 1.35, 0, r)
      ..arcTo(Rect.fromCircle(center: Offset(r, r), radius: r), math.pi, math.pi, false)
      ..cubicTo(size.width, r * 1.35, r * 1.75, size.height * 0.72, r, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _pinPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = AppColors.lime.withOpacity(0.6 * glow.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawPath(path, Paint()..color = AppColors.deepGreen.withOpacity(0.85));

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lime, AppColors.primary],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(LogoPinPainter old) => old.glow != glow;
}

/// Pin logo with a football inside; shared by the splash and the auth hero.
class TurfSpotLogoMark extends StatelessWidget {
  final double width;
  final double glow;

  const TurfSpotLogoMark({super.key, this.width = 96, this.glow = 1.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 1.25,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: LogoPinPainter(glow: glow)),
          ),
          Padding(
            padding: EdgeInsets.only(top: width * 0.23),
            child: Icon(
              Icons.sports_soccer_rounded,
              size: width * 0.48,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }
}
