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
      duration: const Duration(seconds: 10),
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
            painter: _MagicPainter(
              animationValue: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _MagicPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _MagicPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw rotating outer circle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animationValue * 2 * math.pi);
    canvas.drawCircle(Offset.zero, radius * 0.8, paint);

    // Draw inner star/polygon
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.4;
    final double outerRadius = radius * 0.8;

    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? outerRadius : innerRadius;
      final double angle = (i * math.pi) / points;
      if (i == 0) {
        path.moveTo(r * math.cos(angle), r * math.sin(angle));
      } else {
        path.lineTo(r * math.cos(angle), r * math.sin(angle));
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw pulsing center
    final pulseRadius =
        radius * 0.2 * (0.8 + 0.2 * math.sin(animationValue * 4 * math.pi));
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pulseRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _MagicPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
