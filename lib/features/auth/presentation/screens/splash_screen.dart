import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/splash_painters.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 2000);

  late final AnimationController _controller;

  // Stage timings follow the storyboard (fractions of the 2.0s timeline).
  late final Animation<double> _stadium; // 0.0 - 0.3s  fade in
  late final Animation<double> _pitch; //   0.3 - 0.8s  pitch lines draw
  late final Animation<double> _logo; //    0.8 - 1.2s  logo reveal
  late final Animation<double> _text; //    1.2 - 1.8s  name + tagline
  late final Animation<double> _exit; //    1.8 - 2.0s  shrink / hand-off

  Animation<double> _stage(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    _stadium = _stage(0.0, 0.15, Curves.easeIn);
    _pitch = _stage(0.15, 0.4, Curves.easeInOut);
    _logo = _stage(0.4, 0.6, Curves.easeOutBack);
    _text = _stage(0.6, 0.9, Curves.easeOutCubic);
    _exit = _stage(0.9, 1.0, Curves.easeInCubic);

    _runAndNavigate();
  }

  Future<void> _runAndNavigate() async {
    await _controller.forward();
    if (!mounted) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final exit = _exit.value;
          final fade = 1.0 - exit;

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: StadiumBackgroundPainter(
                  opacity: _stadium.value * (1.0 - 0.85 * exit),
                ),
              ),
              CustomPaint(
                painter: PitchLinesPainter(progress: _pitch.value, opacity: fade),
              ),
              Align(
                alignment: const Alignment(0, -0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(exit),
                    const SizedBox(height: 20),
                    _buildTitle(fade),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo(double exit) {
    final reveal = _logo.value;
    final scale = (0.4 + 0.6 * reveal) * (1.0 - 0.4 * exit);

    return Opacity(
      opacity: reveal.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 96,
          height: 120,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: LogoPinPainter(glow: reveal)),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 22),
                child: Icon(
                  Icons.sports_soccer_rounded,
                  size: 46,
                  color: AppColors.lime,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double fade) {
    final t = _text.value;

    return Opacity(
      opacity: (t * fade).clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 16 * (1.0 - t)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Turf',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Spot',
                    style: TextStyle(color: AppColors.lime),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.appTagline,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
