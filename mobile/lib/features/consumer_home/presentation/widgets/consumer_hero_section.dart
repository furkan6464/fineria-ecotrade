import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/consumer_home/domain/consumer_dashboard_model.dart';
import 'package:mobile/features/consumer_home/presentation/consumer_dashboard_formatters.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/home/presentation/widgets/producer_hero_arrow_painter.dart';
import 'package:mobile/features/home/presentation/widgets/producer_metric_row.dart';

/// Tüketici hero — toplam tüketim + 3 satır (komşudan alınan / CO₂ / kazanç) + görsel.
class ConsumerHeroSection extends StatelessWidget {
  const ConsumerHeroSection({super.key, required this.model});

  final ConsumerDashboardModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ProducerHeroArrowPainter(
                color: ProducerDashboardColors.khaki,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.totalConsumptionSectionLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: ProducerDashboardColors.darkGreen.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ConsumerDashboardFormatters.kwh(
                        model.totalConsumptionKwh,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        color: ProducerDashboardColors.darkGreen,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    ProducerMetricRow(
                      title: model.neighborSourcedTitle,
                      valueText: ConsumerDashboardFormatters.kwh(
                        model.neighborSourcedKwh,
                      ),
                      iconAssetPath: model.neighborSourcedIconAssetPath,
                    ),
                    ProducerMetricRow(
                      title: model.blockedCo2Title,
                      valueText: ConsumerDashboardFormatters.kg(
                        model.blockedCo2Kg,
                      ),
                      iconAssetPath: model.blockedCo2IconAssetPath,
                    ),
                    ProducerMetricRow(
                      title: model.totalSavingsTitle,
                      valueText: ConsumerDashboardFormatters.tryLira(
                        model.totalSavingsTry,
                      ),
                      iconAssetPath: model.totalSavingsIconAssetPath,
                      bottomSpacing: 0,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomRight,
                  children: [
                    Positioned(
                      right: -28,
                      bottom: -8,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                        child: _HeroImage(assetPath: model.heroImageAssetPath),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final low = assetPath.toLowerCase();
    final fallback = Icon(
      Icons.electric_car_rounded,
      size: 120,
      color: ProducerDashboardColors.darkGreen.withValues(alpha: 0.35),
    );
    if (low.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        height: 210,
        fit: BoxFit.contain,
        allowDrawingOutsideViewBox: true,
        placeholderBuilder: (_) => fallback,
      );
    }
    return Image.asset(
      assetPath,
      height: 210,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}
