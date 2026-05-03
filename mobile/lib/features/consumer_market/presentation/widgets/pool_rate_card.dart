import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_formatters.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';

class PoolRateCard extends StatelessWidget {
  const PoolRateCard({super.key, required this.model});

  final ConsumerMarketModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: ConsumerMarketTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.poolRateTitle,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: ConsumerMarketTheme.subtitleGray,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  ConsumerMarketFormatters.tryPerKwh(model.poolRateTryPerKwh),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: ConsumerMarketTheme.darkGreen,
                    height: 1.1,
                  ),
                ),
              ),
              _TrendChip(
                label: model.poolRateTrendLabel,
                downward: model.poolRateTrendDownward,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: model.priceSparkline,
                color: ConsumerMarketTheme.khaki,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.label, required this.downward});

  final String label;
  final bool downward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ConsumerMarketTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            downward
                ? Icons.arrow_drop_down_rounded
                : Icons.arrow_drop_up_rounded,
            size: 18,
            color: ConsumerMarketTheme.darkGreen,
          ),
          const SizedBox(width: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: ConsumerMarketTheme.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      // Belli bir orta yükseklikte düz bir çizgi (veri gelmemişse).
      final p = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final y = size.height * 0.55;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      return;
    }
    var minV = values.first;
    var maxV = values.first;
    for (final v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    if ((maxV - minV).abs() < 0.0001) {
      maxV = minV + 0.01;
    }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final t = i / (values.length - 1);
      final x = t * size.width;
      final norm = (values[i] - minV) / (maxV - minV);
      final y = size.height * (1.0 - norm) * 0.85 + size.height * 0.075;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
