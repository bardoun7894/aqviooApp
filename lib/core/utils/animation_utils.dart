import 'dart:math';
import 'package:flutter/material.dart';

class AnimationUtils {
  // Page transition animations
  static Widget slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Curve curve = Curves.easeInOut,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }

  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    Curve curve = Curves.easeInOut,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return FadeTransition(opacity: curvedAnimation, child: child);
  }

  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    double beginScale = 0.8,
    Curve curve = Curves.elasticOut,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: 1.0,
      ).animate(curvedAnimation),
      child: child,
    );
  }

  static Widget rotationTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    double turns = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return RotationTransition(
      turns: Tween<double>(begin: turns, end: 0.0).animate(curvedAnimation),
      child: child,
    );
  }

  // Combined transitions
  static Widget slideAndFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Curve curve = Curves.easeInOut,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  }

  // Widget animation builders
  static Widget animatedBuilder({
    required Widget child,
    required AnimationController controller,
    required Tween<double> tween,
    Curve curve = Curves.linear,
    required Widget Function(BuildContext, Widget?) builder,
  }) {
    final curvedAnimation = CurvedAnimation(parent: controller, curve: curve);

    return AnimatedBuilder(
      animation: tween.animate(curvedAnimation),
      builder: builder,
      child: child,
    );
  }

  // Staggered animation helpers
  static List<Interval> createStaggeredIntervals({
    required int count,
    double startInterval = 0.0,
    double intervalGap = 0.1,
  }) {
    final List<Interval> intervals = [];
    final double intervalLength =
        (1.0 - startInterval) / count - intervalGap * (count - 1) / count;

    for (int i = 0; i < count; i++) {
      final double start = startInterval + (i * (intervalLength + intervalGap));
      final double end = start + intervalLength;
      intervals.add(Interval(start, end, curve: Curves.easeOut));
    }

    return intervals;
  }

  // Common animation controllers
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  // Repeating animation controller
  static AnimationController createRepeatingController({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
  }) {
    return AnimationController(duration: duration, vsync: vsync)..repeat();
  }

  // Pulse animation
  static Animation<double> createPulseAnimation({
    required AnimationController controller,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return Tween<double>(
      begin: minScale,
      end: maxScale,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  // Shake animation
  static Animation<double> createShakeAnimation({
    required AnimationController controller,
    double displacement = 10.0,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: ShakeCurve()));
  }

  // Bounce animation
  static Animation<double> createBounceAnimation({
    required AnimationController controller,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));
  }

  // Elastic animation
  static Animation<double> createElasticAnimation({
    required AnimationController controller,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
  }
}

enum SlideDirection { rightToLeft, leftToRight, topToBottom, bottomToTop }

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    return sin(t * 2 * 3.14159265359);
  }
}

// Custom page transitions
class GlassPageTransition extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;

  GlassPageTransition({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return AnimationUtils.slideAndFadeTransition(
             context,
             animation,
             secondaryAnimation,
             child,
             direction: direction,
           );
         },
       );
}

class GlassScalePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  GlassScalePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return AnimationUtils.scaleTransition(
             context,
             animation,
             secondaryAnimation,
             child,
           );
         },
       );
}

// Animated widgets
class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final VoidCallback? onComplete;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.onComplete,
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

class AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final Curve curve;
  final VoidCallback? onComplete;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.direction = SlideDirection.bottomToTop,
    this.curve = Curves.easeOut,
    this.onComplete,
  });

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    Offset begin;
    switch (widget.direction) {
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    _animation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}
