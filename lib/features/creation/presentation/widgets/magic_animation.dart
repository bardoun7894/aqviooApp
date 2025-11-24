import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MagicAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const MagicAnimation({
    super.key,
    this.size = 200,
    this.color = AppColors.primaryPurple,
  });

  @override
  State<MagicAnimation> createState() => _MagicAnimationState();
}

class _MagicAnimationState extends State<MagicAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PulsingCirclesPainter(
              animationValue: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _PulsingCirclesPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _PulsingCirclesPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 pulsing circles with different phases
    for (int i = 0; i < 3; i++) {
      final phase = (animationValue + i * 0.33) % 1.0;
      final radius = maxRadius * phase;
      final opacity = (1.0 - phase) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw central glowing core
    final coreSize = 12.0 + (math.sin(animationValue * 2 * math.pi) * 4.0);
    final corePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, coreSize, corePaint);

    // Draw solid core
    final solidCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, coreSize * 0.7, solidCorePaint);
  }

  @override
  bool shouldRepaint(covariant _PulsingCirclesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
