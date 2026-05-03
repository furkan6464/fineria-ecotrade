import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/producer_dashboard_model.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_formatters.dart';

class ProducerDailyProductionChart extends StatelessWidget {
  const ProducerDailyProductionChart({super.key, required this.model});

  final ProducerDashboardModel model;

  @override
  Widget build(BuildContext context) {
    final maxY = model.chartYAxisTicksKwh.isEmpty
        ? 1.0
        : model.chartYAxisTicksKwh.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.chartTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: ProducerDashboardColors.darkGreen,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            const yAxisW = 52.0;
            const chartH = 168.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: chartH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: yAxisW,
                        height: chartH,
                        child: CustomPaint(
                          painter: _YAxisLabelsPainter(
                            ticks: model.chartYAxisTicksKwh,
                            maxY: maxY,
                            chartHeight: chartH,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: chartH,
                          child: LayoutBuilder(
                            builder: (context, b) {
                              final w = b.maxWidth;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CustomPaint(
                                    painter: _DashedGridPainter(
                                      ticks: model.chartYAxisTicksKwh,
                                      maxY: maxY,
                                      chartHeight: chartH,
                                      width: w,
                                    ),
                                    child: SizedBox.expand(),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (final slot in model.chartSlots)
                                        Expanded(
                                          child: _BarPair(
                                            slot: slot,
                                            maxY: maxY,
                                            chartHeight: chartH,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final slot in model.chartSlots)
                      Expanded(
                        child: Text(
                          slot.timeLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: slot.timeLabelBold
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 13,
                            color: ProducerDashboardColors.darkGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _Legend(
                  productionLabel: model.chartLegendProductionLabel,
                  consumptionLabel: model.chartLegendConsumptionLabel,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BarPair extends StatelessWidget {
  const _BarPair({
    required this.slot,
    required this.maxY,
    required this.chartHeight,
  });

  final ProducerChartSlot slot;
  final double maxY;
  final double chartHeight;

  static const _barW = 18.0;
  static const _gap = 6.0;
  static const _radius = 4.0;

  @override
  Widget build(BuildContext context) {
    final hProd = (slot.productionKwh / maxY) * chartHeight;
    final hCons = (slot.consumptionKwh / maxY) * chartHeight;
    final hp = hProd.clamp(2.0, chartHeight);
    final hc = hCons.clamp(2.0, chartHeight);

    return SizedBox(
      height: chartHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RoundedTopBar(
                  width: _barW,
                  height: hp,
                  color: ProducerDashboardColors.brown,
                  radius: _radius,
                ),
                const SizedBox(width: _gap),
                _RoundedTopBar(
                  width: _barW,
                  height: hc,
                  color: ProducerDashboardColors.darkGreen,
                  radius: _radius,
                ),
              ],
            ),
          ),
          if (slot.productionTooltipKwh != null)
            Positioned(
              bottom: hp + 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ProducerDashboardColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: ProducerDashboardColors.darkGreen,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  ProducerDashboardFormatters.kwh(slot.productionTooltipKwh!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: ProducerDashboardColors.darkGreen,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundedTopBar extends StatelessWidget {
  const _RoundedTopBar({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: Container(width: width, height: height, color: color),
    );
  }
}

class _DashedGridPainter extends CustomPainter {
  _DashedGridPainter({
    required this.ticks,
    required this.maxY,
    required this.chartHeight,
    required this.width,
  });

  final List<double> ticks;
  final double maxY;
  final double chartHeight;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProducerDashboardColors.darkGreen.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;

    for (final t in ticks) {
      final y = chartHeight - (t / maxY) * chartHeight;
      _drawDashedLine(canvas, Offset(0, y), Offset(width, y), paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    final d = b - a;
    final len = d.distance;
    if (len == 0) return;
    final dir = Offset(d.dx / len, d.dy / len);
    var pos = 0.0;
    while (pos < len) {
      final p0 = a + dir * pos;
      final seg = (pos + dash > len) ? len - pos : dash;
      final p1 = a + dir * (pos + seg);
      canvas.drawLine(p0, p1, paint);
      pos += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedGridPainter oldDelegate) =>
      oldDelegate.ticks != ticks ||
      oldDelegate.maxY != maxY ||
      oldDelegate.chartHeight != chartHeight ||
      oldDelegate.width != width;
}

class _YAxisLabelsPainter extends CustomPainter {
  _YAxisLabelsPainter({
    required this.ticks,
    required this.maxY,
    required this.chartHeight,
  });

  final List<double> ticks;
  final double maxY;
  final double chartHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (final t in ticks) {
      final y = chartHeight - (t / maxY) * chartHeight - 6;
      tp.text = TextSpan(
        text: '${ProducerDashboardFormatters.decimal1(t)} kWh',
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: ProducerDashboardColors.darkGreen.withValues(alpha: 0.75),
        ),
      );
      tp.layout(maxWidth: size.width);
      tp.paint(
        canvas,
        Offset(size.width - tp.width, y.clamp(0.0, size.height - 16)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _YAxisLabelsPainter oldDelegate) =>
      oldDelegate.ticks != ticks ||
      oldDelegate.maxY != maxY ||
      oldDelegate.chartHeight != chartHeight;
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.productionLabel,
    required this.consumptionLabel,
  });

  final String productionLabel;
  final String consumptionLabel;

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: ProducerDashboardColors.darkGreen,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        item(ProducerDashboardColors.brown, productionLabel),
        const SizedBox(width: 22),
        item(ProducerDashboardColors.darkGreen, consumptionLabel),
      ],
    );
  }
}
