import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final double blurIntensity;
  final Duration animationDuration;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? cursorColor;
  final Color? focusedBorderColor;
  final Color? unfocusedBorderColor;
  final double borderWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enableAnimation;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final String? errorText;
  final bool filled;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.hintStyle,
    this.labelStyle,
    this.textStyle,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.autofocus = false,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.opacity = 0.2,
    this.blurIntensity = 10.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.cursorColor,
    this.focusedBorderColor,
    this.unfocusedBorderColor,
    this.borderWidth = 1.5,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enableAnimation = true,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.errorText,
    this.filled = true,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;
  bool _isHovered = false;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

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

    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _internalFocusNode!.dispose();
    } else {
      _effectiveFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_effectiveFocusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
      if (_isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableAnimation && isHovered != _isHovered) {
      setState(() {
        _isHovered = isHovered;
      });
      if (isHovered && !_isFocused) {
        _controller.forward();
      } else if (!isHovered && !_isFocused) {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = widget.enableAnimation
        ? _isFocused || _isHovered
            ? _opacityAnimation.value
            : widget.opacity
        : widget.opacity;

    final effectiveBorderWidth = widget.enableAnimation
        ? _isFocused
            ? _borderAnimation.value
            : widget.borderWidth
        : widget.borderWidth;

    final effectiveBorderColor = _isFocused
        ? widget.focusedBorderColor ?? AppColors.primaryPurple
        : widget.unfocusedBorderColor ?? AppColors.white.withOpacity(0.5);

    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                widget.labelText!,
                style: widget.labelStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.labelColor ?? AppColors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
              ),
            ),
          ],
          MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: effectiveBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                  if (_isFocused)
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
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
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.white.withOpacity(effectiveOpacity),
                          AppColors.white.withOpacity(effectiveOpacity * 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _effectiveFocusNode,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      onTap: widget.onTap,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      autofocus: widget.autofocus,
                      cursorColor: widget.cursorColor ?? AppColors.primaryPurple,
                      style: widget.textStyle ??
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: widget.textColor ?? AppColors.darkGray,
                              ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: widget.hintStyle ??
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: widget.hintColor ?? AppColors.darkGray.withOpacity(0.6),
                                ),
                        prefixIcon: widget.prefixIcon,
                        suffixIcon: widget.suffixIcon,
                        border: widget.border ?? InputBorder.none,
                        focusedBorder: widget.focusedBorder ?? InputBorder.none,
                        errorBorder: widget.errorBorder ?? InputBorder.none,
                        enabledBorder: widget.border ?? InputBorder.none,
                        disabledBorder: widget.border ?? InputBorder.none,
                        filled: widget.filled,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        errorText: widget.errorText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
