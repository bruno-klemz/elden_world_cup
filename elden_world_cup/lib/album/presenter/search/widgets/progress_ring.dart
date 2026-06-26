import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// A small gold ring filled proportionally to [progress] (0..1), with the
/// percentage in the center. Used as the leading "icon" of region tiles — the
/// progress is the icon.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 34});

  final double progress; // 0..1
  final double size;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress.clamp(0.0, 1.0)),
        child: Center(
          child: Text('$pct%',
              style: const TextStyle(
                  color: Color(0xFFC9B78F),
                  fontSize: 9,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = AppColors.surfaceAlt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
