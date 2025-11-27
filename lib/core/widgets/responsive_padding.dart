import 'package:flutter/material.dart';
import '../utils/responsive_extensions.dart';

/// A padding widget that automatically scales based on screen size
///
/// Usage:
/// ```dart
/// ResponsivePadding(
///   horizontal: 24,
///   vertical: 16,
///   child: Text('Hello'),
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.all,
    this.horizontal,
    this.vertical,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final Widget child;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;

    if (all != null) {
      padding = EdgeInsets.all(all!);
    } else {
      padding = EdgeInsets.only(
        left: left ?? horizontal ?? 0,
        top: top ?? vertical ?? 0,
        right: right ?? horizontal ?? 0,
        bottom: bottom ?? vertical ?? 0,
      );
    }

    // Apply responsive scaling
    final responsivePadding = padding.responsive(context);

    return Padding(
      padding: responsivePadding,
      child: child,
    );
  }
}

/// A SizedBox that scales its dimensions based on screen size
class ResponsiveSizedBox extends StatelessWidget {
  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.scaleW(context),
      height: height?.scaleH(context),
      child: child,
    );
  }
}

/// A gap widget for spacing in Flex widgets (Row/Column)
class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap(
    this.size, {
    super.key,
    this.axis = Axis.vertical,
  });

  final double size;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final scaledSize =
        axis == Axis.vertical ? size.scaleH(context) : size.scaleW(context);

    return SizedBox(
      width: axis == Axis.horizontal ? scaledSize : null,
      height: axis == Axis.vertical ? scaledSize : null,
    );
  }
}
