import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color darkPurple = Color(0xFF6D28D9);
  static const Color deepBackground = Color(0xFF2E1065); // For dark mode background

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color darkGray = Color(0xFF1F2937); // For text, NOT background

  // Glassmorphism Colors
  static Color glassWhite = Colors.white.withOpacity(0.2);
  static Color glassBorder = Colors.white.withOpacity(0.5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
