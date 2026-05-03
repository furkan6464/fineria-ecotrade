import 'package:flutter/material.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/exchange_formatters.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';

class ExchangePriceChartCard extends StatelessWidget {
  const ExchangePriceChartCard({super.key, required this.model});

  final ProducerExchangeModel model;

  @override
  Widget build(BuildContext context) {
    final chart = model.priceChart;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: ExchangeTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ExchangeTheme.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.instantProductionSectionLabel,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: ExchangeTheme.subtitleGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ExchangeFormatters.kwh(model.instantProductionKwh),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: ExchangeTheme.darkGreen,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ComparePriceColumn(
                  label: model.dedasTariffLabel,
                  tryPerKwh: model.dedasTariffTryPerKwh,
                  emphasized: false,
                ),
              ),
              Expanded(
                child: _ComparePriceColumn(
                  label: model.instantPriceSectionLabel,
                  tryPerKwh: model.instantPriceTryPerKwh,
                  emphasized: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _AdvantageBadge(
              text: model.priceAdvantageBadgeText,
              positive: model.priceAdvantagePositive,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            model.valuePropositionLine,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.35,
              color: ExchangeTheme.subtitleGray,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 188,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                const topPad = 36.0;
                const bottomPad = 28.0;
                final stackH = constraints.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(w, stackH),
                      painter: _ChartPainter(
                        points: chart.linePointsNormalized,
                        peakX: chart.peakNormalizedX,
                        lineColor: ExchangeTheme.khaki,
                        baselineColor: ExchangeTheme.subtitleGray.withValues(
                          alpha: 0.35,
                        ),
                        topPadding: topPad,
                        bottomPadding: bottomPad,
                      ),
                    ),
                    _PeakTooltipLayer(
                      chart: chart,
                      width: w,
                      stackHeight: stackH,
                      topPad: topPad,
                      bottomPad: bottomPad,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: bottomPad,
                      child: _XAxisLabels(ticks: chart.xAxisTicks),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparePriceColumn extends StatelessWidget {
  const _ComparePriceColumn({
    required this.label,
    required this.tryPerKwh,
    required this.emphasized,
  });

  final String label;
  final double tryPerKwh;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: emphasized ? 13 : 12,
            color: ExchangeTheme.subtitleGray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ExchangeFormatters.tryPerKwh(tryPerKwh),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: emphasized ? 28 : 22,
            color: ExchangeTheme.darkGreen,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _AdvantageBadge extends StatelessWidget {
  const _AdvantageBadge({required this.text, required this.positive});

  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ExchangeTheme.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 18,
            color: ExchangeTheme.darkGreen,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: ExchangeTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
    required this.peakX,
    required this.lineColor,
    required this.baselineColor,
    required this.topPadding,
    required this.bottomPadding,
  });

  final List<ExchangeChartPoint> points;
  final double peakX;
  final Color lineColor;
  final Color baselineColor;
  final double topPadding;
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final baselineY = size.height - bottomPadding;
    final chartTop = topPadding;
    final chartH = baselineY - chartTop;

    final dashPaint = Paint()
      ..color = baselineColor
      ..strokeWidth = 1;

    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, baselineY),
        Offset((x + dash).clamp(0.0, size.width), baselineY),
        dashPaint,
      );
      x += dash + gap;
    }

    if (points.length < 2) return;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final px = p.x * size.width;
      final py = baselineY - p.y * chartH;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final peakXN = peakX * size.width;
    double peakY = baselineY;
    ExchangeChartPoint? nearest;
    var bestDx = double.infinity;
    for (final p in points) {
      final dx = (p.x - peakX).abs();
      if (dx < bestDx) {
        bestDx = dx;
        nearest = p;
      }
    }
    if (nearest != null) {
      peakY = baselineY - nearest.y * chartH;
    }

    canvas.drawCircle(
      Offset(peakXN, peakY),
      5,
      Paint()..color = ExchangeTheme.darkGreen,
    );
    canvas.drawCircle(
      Offset(peakXN, peakY),
      5,
      Paint()
        ..color = ExchangeTheme.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.peakX != peakX ||
      oldDelegate.lineColor != lineColor;
}

class _PeakTooltipLayer extends StatelessWidget {
  const _PeakTooltipLayer({
    required this.chart,
    required this.width,
    required this.stackHeight,
    required this.topPad,
    required this.bottomPad,
  });

  final ExchangePriceChartModel chart;
  final double width;
  final double stackHeight;
  final double topPad;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    final peakX = chart.peakNormalizedX * width;
    ExchangeChartPoint? nearest;
    var bestDx = double.infinity;
    for (final p in chart.linePointsNormalized) {
      final dx = (p.x - chart.peakNormalizedX).abs();
      if (dx < bestDx) {
        bestDx = dx;
        nearest = p;
      }
    }
    final yNorm = nearest?.y ?? 0;
    final baselineY = stackHeight - bottomPad;
    final chartInnerH = baselineY - topPad;
    final peakY = baselineY - yNorm * chartInnerH;

    const bubbleW = 168.0;
    const bubbleH = 34.0;
    var left = peakX - bubbleW / 2;
    left = left.clamp(4.0, width - bubbleW - 4);

    return Positioned(
      left: left,
      top: (peakY - bubbleH - 14).clamp(topPad - 8, topPad + 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          chart.peakTooltipText,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: ExchangeTheme.white,
          ),
        ),
      ),
    );
  }
}

class _XAxisLabels extends StatelessWidget {
  const _XAxisLabels({required this.ticks});

  final List<ExchangeChartXTick> ticks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final t in ticks)
              Positioned(
                left: (t.positionNormalizedX * w).clamp(0.0, w) - 22,
                right: null,
                top: 0,
                child: SizedBox(
                  width: 44,
                  child: Text(
                    t.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: t.emphasized
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 12,
                      color: ExchangeTheme.darkGreen,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
