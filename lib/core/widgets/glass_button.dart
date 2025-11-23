import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double blurIntensity;
  final Duration animationDuration;
  final Color? textColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final double iconSize;
  final Gradient? gradient;
  final bool enableAnimation;
  final bool enableRippleEffect;
  final double borderWidth;
  final Color? borderColor;

  const GlassButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.padding,
    this.opacity = 0.2,
    this.blurIntensity = 10.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.textColor,
    this.textStyle,
    this.icon,
    this.iconSize = 20.0,
    this.gradient,
    this.enableAnimation = true,
    this.enableRippleEffect = true,
    this.borderWidth = 1.0,
    this.borderColor,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
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
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: widget.opacity + 0.2,
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
    widget.onPressed?.call();
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

    final buttonChild = widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.textColor ?? Colors.white,
                size: widget.iconSize,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: widget.textStyle ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.textColor ?? Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
            ),
          ],
        );

    return Transform.scale(
      scale: effectiveScale,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        child: MouseRegion(
          onEnter: widget.onPressed != null ? (_) => _onHover(true) : null,
          onExit: widget.onPressed != null ? (_) => _onHover(false) : null,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.borderColor ??
                    AppColors.white.withOpacity(0.5),
                width: widget.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.2),
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
                  decoration: BoxDecoration(
                    gradient: widget.gradient ??
                        LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.white.withOpacity(effectiveOpacity),
                            AppColors.white.withOpacity(effectiveOpacity * 0.7),
                          ],
                        ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: Center(
                    child: widget.enableRippleEffect
                        ? Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onPressed,
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: buttonChild,
                            ),
                          )
                        : buttonChild,
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
