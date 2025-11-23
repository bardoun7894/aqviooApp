import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blurIntensity;
  final double borderWidth;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final bool enableAnimation;
  final Duration animationDuration;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;

  const GlassCard({
    super.key,
    required this.child,
    this.opacity = 0.2,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.onTap,
    this.blurIntensity = 15.0,
    this.borderWidth = 1.5,
    this.borderColor,
    this.boxShadow,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.width,
    this.height,
    this.gradient,
    this.gradientBegin,
    this.gradientEnd,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity + 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableAnimation) {
      setState(() {
        _isHovered = isHovered;
      });
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = widget.enableAnimation
        ? _isPressed
            ? _opacityAnimation.value
            : _isHovered
                ? _opacityAnimation.value
                : widget.opacity
        : widget.opacity;

    final effectiveScale = widget.enableAnimation
        ? _isPressed
            ? _scaleAnimation.value
            : _isHovered
                ? _scaleAnimation.value
                : 1.0
        : 1.0;

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: Transform.scale(
        scale: effectiveScale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurIntensity,
              sigmaY: widget.blurIntensity,
            ),
            child: GestureDetector(
              onTapDown: widget.onTap != null ? _onTapDown : null,
              onTapUp: widget.onTap != null ? _onTapUp : null,
              onTapCancel: widget.onTap != null ? _onTapCancel : null,
              child: MouseRegion(
                onEnter: widget.onTap != null ? (_) => _onHover(true) : null,
                onExit: widget.onTap != null ? (_) => _onHover(false) : null,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: widget.gradient ??
                        LinearGradient(
                          begin: widget.gradientBegin ?? Alignment.topLeft,
                          end: widget.gradientEnd ?? Alignment.bottomRight,
                          colors: [
                            AppColors.white.withOpacity(effectiveOpacity),
                            AppColors.white.withOpacity(effectiveOpacity * 0.7),
                          ],
                        ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.borderColor ??
                          AppColors.white.withOpacity(0.5),
                      width: widget.borderWidth,
                    ),
                    boxShadow: widget.boxShadow ?? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      if (_isHovered)
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
