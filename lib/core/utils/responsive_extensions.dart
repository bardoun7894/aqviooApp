import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// Extension on [num] for responsive sizing
///
/// Usage examples:
/// ```dart
/// SizedBox(height: 20.h)  // 20% of screen height
/// SizedBox(width: 50.w)   // 50% of screen width
/// Text('Hello', style: TextStyle(fontSize: 16.sp)) // Scaled font
/// ```
extension ResponsiveNum on num {
  /// Get width as percentage of screen width
  /// Note: Requires BuildContext via .w(context) or use in widget tree
  double w(BuildContext context) {
    return ResponsiveUtils.screenWidth(context) * (this / 100);
  }

  /// Get height as percentage of screen height
  double h(BuildContext context) {
    return ResponsiveUtils.screenHeight(context) * (this / 100);
  }

  /// Get safe width (excluding padding) as percentage
  double sw(BuildContext context) {
    return ResponsiveUtils.safeWidth(context) * (this / 100);
  }

  /// Get safe height (excluding padding) as percentage
  double sh(BuildContext context) {
    return ResponsiveUtils.safeHeight(context) * (this / 100);
  }

  /// Scale font size responsively
  double sp(BuildContext context) {
    return ResponsiveUtils.scaleFontSize(context, toDouble());
  }

  /// Scale width value responsively
  double scaleW(BuildContext context) {
    return ResponsiveUtils.scaleWidth(context, toDouble());
  }

  /// Scale height value responsively
  double scaleH(BuildContext context) {
    return ResponsiveUtils.scaleHeight(context, toDouble());
  }
}

/// Extension on [BuildContext] for quick access to responsive properties
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => ResponsiveUtils.screenWidth(this);

  /// Get screen height
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  /// Get safe width (excluding padding)
  double get safeWidth => ResponsiveUtils.safeWidth(this);

  /// Get safe height (excluding padding)
  double get safeHeight => ResponsiveUtils.safeHeight(this);

  /// Get device category
  DeviceCategory get deviceCategory => ResponsiveUtils.getDeviceCategory(this);

  /// Check if device is a small phone
  bool get isSmallPhone => ResponsiveUtils.isSmallPhone(this);

  /// Check if device is a medium phone
  bool get isMediumPhone => deviceCategory == DeviceCategory.mediumPhone;

  /// Check if device is a large phone
  bool get isLargePhone => deviceCategory == DeviceCategory.largePhone;

  /// Check if device is a tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Get responsive horizontal padding
  double get responsiveHPadding =>
      ResponsiveUtils.responsiveHorizontalPadding(this);

  /// Get responsive vertical padding
  double get responsiveVPadding =>
      ResponsiveUtils.responsiveVerticalPadding(this);

  /// Get a responsive value based on device category
  T responsive<T>({
    required T smallPhone,
    T? mediumPhone,
    T? largePhone,
    T? tablet,
  }) {
    return ResponsiveUtils.responsiveValue<T>(
      context: this,
      smallPhone: smallPhone,
      mediumPhone: mediumPhone,
      largePhone: largePhone,
      tablet: tablet,
    );
  }
}

/// Extension on [EdgeInsets] for responsive padding
extension ResponsiveEdgeInsets on EdgeInsets {
  /// Scale EdgeInsets based on screen size
  EdgeInsets responsive(BuildContext context) {
    final category = context.deviceCategory;
    final scale = switch (category) {
      DeviceCategory.smallPhone => 0.85,
      DeviceCategory.mediumPhone => 0.9,
      DeviceCategory.largePhone => 1.0,
      DeviceCategory.tablet => 1.15,
    };

    return EdgeInsets.only(
      left: left * scale,
      top: top * scale,
      right: right * scale,
      bottom: bottom * scale,
    );
  }
}

/// Extension on [BorderRadius] for responsive border radius
extension ResponsiveBorderRadius on BorderRadius {
  /// Scale BorderRadius based on screen size
  BorderRadius responsive(BuildContext context) {
    final category = context.deviceCategory;
    final scale = switch (category) {
      DeviceCategory.smallPhone => 0.85,
      DeviceCategory.mediumPhone => 0.9,
      DeviceCategory.largePhone => 1.0,
      DeviceCategory.tablet => 1.1,
    };

    return BorderRadius.only(
      topLeft: topLeft * scale,
      topRight: topRight * scale,
      bottomLeft: bottomLeft * scale,
      bottomRight: bottomRight * scale,
    );
  }
}
