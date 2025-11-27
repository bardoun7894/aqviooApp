import 'package:flutter/material.dart';

/// Device categories based on screen width
enum DeviceCategory {
  smallPhone, // < 360dp
  mediumPhone, // 360-400dp
  largePhone, // 400-600dp
  tablet, // >= 600dp
}

/// Comprehensive responsive utilities for automatic UI adaptation
class ResponsiveUtils {
  // Screen breakpoints (in logical pixels)
  static const double smallPhoneWidth = 360;
  static const double mediumPhoneWidth = 400;
  static const double largePhoneWidth = 600;

  // Reference design dimensions (Design was for iPhone 11 Pro)
  static const double designWidth = 375;
  static const double designHeight = 812;

  /// Get the device category based on screen width
  static DeviceCategory getDeviceCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < smallPhoneWidth) {
      return DeviceCategory.smallPhone;
    } else if (width < mediumPhoneWidth) {
      return DeviceCategory.mediumPhone;
    } else if (width < largePhoneWidth) {
      return DeviceCategory.largePhone;
    } else {
      return DeviceCategory.tablet;
    }
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe width (excluding system padding)
  static double safeWidth(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return screenWidth(context) - padding.left - padding.right;
  }

  /// Get safe height (excluding system padding)
  static double safeHeight(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return screenHeight(context) - padding.top - padding.bottom;
  }

  /// Calculate width as percentage of screen width (0-100)
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Calculate height as percentage of screen height (0-100)
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Get a responsive value based on device category
  ///
  /// Example:
  /// ```dart
  /// final padding = ResponsiveUtils.responsiveValue(
  ///   context,
  ///   smallPhone: 12.0,
  ///   mediumPhone: 16.0,
  ///   largePhone: 20.0,
  ///   tablet: 24.0,
  /// );
  /// ```
  static T responsiveValue<T>({
    required BuildContext context,
    required T smallPhone,
    T? mediumPhone,
    T? largePhone,
    T? tablet,
  }) {
    final category = getDeviceCategory(context);

    switch (category) {
      case DeviceCategory.smallPhone:
        return smallPhone;
      case DeviceCategory.mediumPhone:
        return mediumPhone ?? smallPhone;
      case DeviceCategory.largePhone:
        return largePhone ?? mediumPhone ?? smallPhone;
      case DeviceCategory.tablet:
        return tablet ?? largePhone ?? mediumPhone ?? smallPhone;
    }
  }

  /// Scale a value based on screen width relative to design width
  static double scaleWidth(BuildContext context, double value) {
    return value * (screenWidth(context) / designWidth);
  }

  /// Scale a value based on screen height relative to design height
  static double scaleHeight(BuildContext context, double value) {
    return value * (screenHeight(context) / designHeight);
  }

  /// Scale font size based on screen width with min/max constraints
  static double scaleFontSize(BuildContext context, double fontSize) {
    final scaledSize = fontSize * (screenWidth(context) / designWidth);

    // Constrain font size to reasonable limits
    final category = getDeviceCategory(context);
    switch (category) {
      case DeviceCategory.smallPhone:
        return scaledSize.clamp(fontSize * 0.85, fontSize * 1.0);
      case DeviceCategory.mediumPhone:
        return scaledSize.clamp(fontSize * 0.9, fontSize * 1.05);
      case DeviceCategory.largePhone:
        return scaledSize.clamp(fontSize * 0.95, fontSize * 1.1);
      case DeviceCategory.tablet:
        return scaledSize.clamp(fontSize * 1.0, fontSize * 1.2);
    }
  }

  /// Get responsive horizontal padding
  static double responsiveHorizontalPadding(BuildContext context) {
    return responsiveValue<double>(
      context: context,
      smallPhone: 16.0,
      mediumPhone: 20.0,
      largePhone: 24.0,
      tablet: 32.0,
    );
  }

  /// Get responsive vertical padding
  static double responsiveVerticalPadding(BuildContext context) {
    return responsiveValue<double>(
      context: context,
      smallPhone: 12.0,
      mediumPhone: 16.0,
      largePhone: 20.0,
      tablet: 24.0,
    );
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(
      BuildContext context, double baseRadius) {
    return responsiveValue<double>(
      context: context,
      smallPhone: baseRadius * 0.85,
      mediumPhone: baseRadius * 0.9,
      largePhone: baseRadius,
      tablet: baseRadius * 1.1,
    );
  }

  /// Check if device is a small phone
  static bool isSmallPhone(BuildContext context) {
    return getDeviceCategory(context) == DeviceCategory.smallPhone;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return getDeviceCategory(context) == DeviceCategory.tablet;
  }

  /// Get minimum touch target size (accessibility)
  static double get minTouchTarget => 48.0;

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSize) {
    return responsiveValue<double>(
      context: context,
      smallPhone: baseSize * 0.9,
      mediumPhone: baseSize,
      largePhone: baseSize * 1.05,
      tablet: baseSize * 1.15,
    );
  }
}
