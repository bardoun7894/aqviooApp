import 'package:flutter/material.dart';

/// A widget that displays an animated gradient blob with a pulsing effect
/// Used for decorative background elements in the new Aqvioo design system
class AnimatedGradientBlob extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final double minOpacity;
  final double maxOpacity;
  final double blurRadius;

  const AnimatedGradientBlob({
    super.key,
    this.size = 256,
    required this.colors,
    this.duration = const Duration(seconds: 4),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.minOpacity = 0.7,
    this.maxOpacity = 1.0,
    this.blurRadius = 48,
  });

  @override
  State<AnimatedGradientBlob> createState() => _AnimatedGradientBlobState();
}

class _AnimatedGradientBlobState extends State<AnimatedGradientBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Repeat the animation infinitely
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.first.withOpacity(0.3),
                    blurRadius: widget.blurRadius,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
