import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Placeholder page for legal documents until the real ones are published.
class InfoPageScreen extends StatelessWidget {
  final String title;

  const InfoPageScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authSheet,
      appBar: AppBar(
        backgroundColor: AppColors.authSheet,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.authText),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.authText,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This document will be published before TurfSpot launches.',
          style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.authMuted),
        ),
      ),
    );
  }
}
