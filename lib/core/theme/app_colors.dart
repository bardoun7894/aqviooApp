import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - New Design System
  static const Color primaryPurple = Color(0xFF7C3BED); // #7c3bed
  static const Color darkPurple = Color(0xFF6D28D9);

  // Background Colors - New Design System
  static const Color backgroundLight = Color(0xFFF7F6F8); // #f7f6f8
  static const Color backgroundDark = Color(0xFF171121); // #171121
  static const Color deepBackground = Color(
    0xFF2E1065,
  ); // For dark mode accents

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color darkGray = Color(
    0xFF333333,
  ); // Updated to match #333 from design
  static const Color mediumGray = Color(0xFF888888); // #888 for secondary text

  // Glassmorphism Colors - Updated to match new design
  static Color glassWhite = Colors.white.withOpacity(
    0.4,
  ); // rgba(255,255,255,0.4)
  static Color glassBorder = Colors.white.withOpacity(
    0.2,
  ); // rgba(255,255,255,0.2)
  static Color glassWhiteDark = Colors.white.withOpacity(0.4);
  static Color glassBorderDark = Colors.white.withOpacity(0.2);

  // Glassmorphism Opacity Values - New Design System
  static const double glassOpacity = 0.4; // Updated from 0.2
  static const double glassOpacityDark = 0.4;
  static const double glassBorderOpacity = 0.2; // Updated from 0.5
  static const double glassBorderOpacityDark = 0.2;

  // Glassmorphism Blur Values - New Design System
  static const double glassBlur = 12.0; // Updated from 15.0
  static const double glassBlurLight = 10.0;
  static const double glassBlurHeavy = 20.0;

  // Animated Gradient Blob Colors
  static const Color gradientBlobPurple = Color(0xFFA076F9); // Purple blob
  static const Color gradientBlobPurpleLight = Color(
    0xFFF5F3FF,
  ); // Light purple
  static const Color gradientBlobBlue = Color(0xFF82C8F7); // Blue blob

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism Gradients - Updated
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x66FFFFFF), // White 40%
      Color(0x66FFFFFF), // White 40%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    colors: [
      Color(0x66FFFFFF), // White 40%
      Color(0x66FFFFFF), // White 40%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Gradients - New Design System
  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [
      backgroundLight,
      Color(0xFFFFFFFF), // White
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [
      backgroundDark,
      Color(0xFF2E1065), // Deep purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Button Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryPurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [
      Color(0xFF4568DC), // Blue
      Color(0xFFB06AB3), // Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors - Updated for new design
  static Color glassShadow = Colors.black.withOpacity(0.05);
  static Color glassShadowDark = Colors.black.withOpacity(0.2);
  static Color primaryShadow = primaryPurple.withOpacity(
    0.3,
  ); // For primary buttons
  static Color glassShadowHover = primaryPurple.withOpacity(0.1);
  static Color glassShadowHoverDark = primaryPurple.withOpacity(0.2);

  // Border Colors
  static Color glassBorderColor = Colors.white.withOpacity(0.2); // Updated
  static Color glassBorderColorDark = Colors.white.withOpacity(0.2);
  static Color glassBorderColorFocused = primaryPurple;
  static Color glassBorderColorUnfocused = Colors.white.withOpacity(0.2);

  // Text Colors - Updated for new design
  static const Color glassTextPrimary = darkGray; // #333
  static Color glassTextSecondary = mediumGray; // #888
  static Color glassTextPrimaryDark = Colors.white.withOpacity(0.9);
  static Color glassTextSecondaryDark = Colors.white.withOpacity(0.7);
  static Color glassTextHint = mediumGray; // #888
  static Color glassTextHintDark = Colors.white.withOpacity(0.5);
}
