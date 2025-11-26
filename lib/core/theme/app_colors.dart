import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Logo Theme (Vibrant Purple & Iridescent)
  static const Color primaryPurple = Color(0xFF8B5CF6); // Vivid Violet
  static const Color darkPurple = Color(0xFF6D28D9); // Deep Purple
  static const Color lightPurple = Color(0xFFA78BFA); // Light Violet
  static const Color accentPink = Color(0xFFEC4899); // Pink for iridescence
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan for iridescence

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Cool White/Grey
  static const Color backgroundDark =
      Color(0xFF0F172A); // Slate 900 (unused for now)

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF1F5F9); // Slate 100
  static const Color mediumGray = Color(0xFF94A3B8); // Slate 400
  static const Color darkGray = Color(0xFF334155); // Slate 700
  static const Color black = Color(0xFF000000);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0x99FFFFFF); // 60% White
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% White

  // Neumorphism Colors (Light Mode)
  static const Color neuBackground = backgroundLight;
  static const Color neuShadowLight = Color(0xFFFFFFFF);
  static const Color neuShadowDark = Color(0xFFCBD5E1); // Slate 300

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFF7C3BED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient iridescentGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFF06B6D4), // Cyan
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xCCFFFFFF), // 80%
      Color(0x99FFFFFF), // 60%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Animated Gradient Blob Colors
  static const Color gradientBlobPurple = Color(0xFFC4B5FD); // Violet 300
  static const Color gradientBlobPink = Color(0xFFFBCFE8); // Pink 200
  static const Color gradientBlobBlue = Color(0xFFBAE6FD); // Sky 200

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
}
