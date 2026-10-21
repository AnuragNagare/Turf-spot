import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Emerald & Sports Green)
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color accent = Color(0xFFF59E0B); // Amber / Gold accent
  static const Color lime = Color(0xFFA3E635); // Glow / pitch-line highlight
  static const Color deepGreen = Color(0xFF052E16); // Stadium grass shadow

  // Light auth sheet
  static const Color authSheet = Color(0xFFF7F8F4);
  static const Color authField = Color(0xFFEEF0EB);
  static const Color authFieldBorder = Color(0xFFDDE1D8);
  static const Color authForest = Color(0xFF14412B);
  static const Color authText = Color(0xFF0F1F17);
  static const Color authMuted = Color(0xFF6B7280);
  static const Color limeTint = Color(0xFFEEF8D6); // Price strip on turf cards

  // Neutral & Slate (Dark mode & Card styles)
  static const Color background = Color(0xFF0F172A); // Dark Slate
  static const Color surface = Color(0xFF1E293B); // Elevated Card Surface
  static const Color surfaceLight = Color(0xFF334155);
  static const Color border = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
