import 'package:flutter/material.dart';

class MapConnectionsPainter extends CustomPainter {
  MapConnectionsPainter({required this.segments});

  final List<({Offset from, Offset to, Color color})> segments;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in segments) {
      _dashedLine(canvas, s.from, s.to, s.color);
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final d = b - a;
    final len = d.distance;
    if (len < 1) return;
    final dir = Offset(d.dx / len, d.dy / len);
    const dash = 6.0;
    const gap = 4.0;
    var pos = 0.0;
    while (pos < len) {
      final seg = (pos + dash > len) ? len - pos : dash;
      canvas.drawLine(a + dir * pos, a + dir * (pos + seg), paint);
      pos += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant MapConnectionsPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final o = oldDelegate.segments[i];
      final n = segments[i];
      if (o.from != n.from || o.to != n.to || o.color != n.color) {
        return true;
      }
    }
    return false;
  }
}
