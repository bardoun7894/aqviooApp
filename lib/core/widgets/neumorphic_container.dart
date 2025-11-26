import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double depth;
  final double intensity;
  final bool isConcave;
  final BoxShape shape;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.color,
    this.depth = 4.0,
    this.intensity = 0.7,
    this.isConcave = false,
    this.shape = BoxShape.rectangle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.neuBackground;

    // Calculate shadow colors based on base color
    // For a true neumorphic effect, we need a lighter and a darker shadow
    final lightShadow = AppColors.neuShadowLight.withOpacity(intensity);
    final darkShadow = AppColors.neuShadowDark.withOpacity(intensity);

    final boxDecoration = BoxDecoration(
      color: baseColor,
      borderRadius:
          shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      shape: shape,
      boxShadow: [
        // Top Left Shadow (Light)
        BoxShadow(
          color: isConcave ? darkShadow : lightShadow,
          offset:
              Offset(isConcave ? depth : -depth, isConcave ? depth : -depth),
          blurRadius: depth * 2,
          spreadRadius: 0.0,
        ),
        // Bottom Right Shadow (Dark)
        BoxShadow(
          color: isConcave ? lightShadow : darkShadow,
          offset:
              Offset(isConcave ? -depth : depth, isConcave ? -depth : depth),
          blurRadius: depth * 2,
          spreadRadius: 0.0,
        ),
      ],
      gradient: isConcave
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkShadow.withOpacity(0.1),
                lightShadow.withOpacity(0.1),
              ],
              stops: const [0.1, 0.9],
            )
          : null,
    );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: boxDecoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return Container(
      margin: margin,
      child: content,
    );
  }
}
