import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/widgets/splash_painters.dart';

/// Stadium header with a wavy bottom edge, the user's avatar and identity.
class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onCameraTap;

  const ProfileHeader({super.key, required this.user, required this.onCameraTap});

  static const _avatarSize = 108.0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final height = topInset + 190;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: const _WaveClipper(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(
                  painter: StadiumBackgroundPainter(opacity: 1, horizonFactor: 0.55),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xCC052E16), Color(0x33052E16)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const CustomPaint(painter: _WaveRibbonPainter()),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topInset + 16, 20, 36),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 18),
                Expanded(child: _buildIdentity()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final photoUrl = user?.photoUrl;

    return SizedBox(
      width: _avatarSize + 8,
      height: _avatarSize + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 54,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person, size: 54, color: Colors.white),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: 'Change profile photo',
              child: Material(
                color: AppColors.limeTint,
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCameraTap,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 22,
                      color: AppColors.authForest,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity() {
    final email = user?.email;
    final contact = (email != null && email.isNotEmpty) ? email : (user?.phone ?? '');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.name ?? 'Player',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        if (contact.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            contact,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              AppConstants.defaultCity,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

Path _wavePath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..lineTo(0, h * 0.82)
    ..cubicTo(w * 0.2, h * 1.0, w * 0.45, h * 0.78, w * 0.7, h * 0.88)
    ..cubicTo(w * 0.85, h * 0.94, w * 0.95, h * 0.9, w, h * 0.82)
    ..lineTo(w, 0)
    ..close();
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) => _wavePath(size);

  @override
  bool shouldReclip(_WaveClipper old) => false;
}

/// Bright green ribbon that follows the wave at both ends of the header.
class _WaveRibbonPainter extends CustomPainter {
  const _WaveRibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final left = Path()
      ..moveTo(0, h * 0.74)
      ..cubicTo(w * 0.1, h * 0.86, w * 0.2, h * 0.97, w * 0.3, h * 0.96)
      ..cubicTo(w * 0.2, h * 0.93, w * 0.08, h * 0.88, 0, h * 0.82)
      ..close();

    final right = Path()
      ..moveTo(w, h * 0.74)
      ..cubicTo(w * 0.95, h * 0.84, w * 0.88, h * 0.95, w * 0.76, h * 0.92)
      ..cubicTo(w * 0.9, h * 0.92, w * 0.96, h * 0.88, w, h * 0.82)
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.lime, AppColors.primaryDark],
      ).createShader(Offset.zero & size);

    canvas.drawPath(left, fill);
    canvas.drawPath(right, fill);
  }

  @override
  bool shouldRepaint(_WaveRibbonPainter old) => false;
}
