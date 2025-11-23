import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final double blurIntensity;
  final Duration animationDuration;
  final Gradient? gradient;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final bool enableAnimation;
  final VoidCallback? onTap;
  final bool enableHoverEffect;
  final bool enableBorderAnimation;
  final Alignment? alignment;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.opacity = 0.2,
    this.blurIntensity = 10.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.gradient,
    this.gradientBegin,
    this.gradientEnd,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.enableAnimation = true,
    this.onTap,
    this.enableHoverEffect = true,
    this.enableBorderAnimation = true,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _borderAnimation;
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

    _borderAnimation = Tween<double>(
      begin: widget.borderWidth,
      end: widget.borderWidth + 0.5,
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
    if (widget.enableAnimation && widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableAnimation && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.enableAnimation && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableAnimation && widget.enableHoverEffect) {
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
        ? _isPressed || _isHovered
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

    final effectiveBorderWidth = widget.enableAnimation && widget.enableBorderAnimation
        ? _isPressed || _isHovered
            ? _borderAnimation.value
            : widget.borderWidth
        : widget.borderWidth;

    final effectiveBorderColor = widget.borderColor ?? AppColors.white.withOpacity(0.5);

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      child: Transform.scale(
        scale: effectiveScale,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? _onTapDown : null,
          onTapUp: widget.onTap != null ? _onTapUp : null,
          onTapCancel: widget.onTap != null ? _onTapCancel : null,
          child: MouseRegion(
            onEnter: widget.enableHoverEffect && widget.onTap != null ? (_) => _onHover(true) : null,
            onExit: widget.enableHoverEffect && widget.onTap != null ? (_) => _onHover(false) : null,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              clipBehavior: widget.clipBehavior,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: effectiveBorderWidth,
                ),
                boxShadow: widget.boxShadow ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurIntensity,
                    sigmaY: widget.blurIntensity,
                  ),
                  child: Container(
                    padding: widget.padding,
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
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
