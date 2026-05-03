import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Toplam üretim metninden eve giden L şekilli ok (#A8B082).
class ProducerHeroArrowPainter extends CustomPainter {
  ProducerHeroArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final start = Offset(size.width * 0.02, size.height * 0.22);
    final elbow = Offset(size.width * 0.52, size.height * 0.22);
    final end = Offset(size.width * 0.78, size.height * 0.48);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(elbow.dx, end.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, paint);

    const headLen = 7.0;
    final dir = Offset(end.dx - elbow.dx, end.dy - elbow.dy);
    final len = math.max(1.0, dir.distance);
    final u = Offset(dir.dx / len, dir.dy / len);
    final perp = Offset(-u.dy, u.dx);
    final tip = end;
    final left = tip - u * headLen + perp * (headLen * 0.45);
    final right = tip - u * headLen - perp * (headLen * 0.45);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(head, fill);
  }

  @override
  bool shouldRepaint(covariant ProducerHeroArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
