import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/home/domain/producer_dashboard_model.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_formatters.dart';
import 'package:mobile/features/home/presentation/widgets/producer_hero_arrow_painter.dart';
import 'package:mobile/features/home/presentation/widgets/producer_metric_row.dart';

class ProducerHeroSection extends StatelessWidget {
  const ProducerHeroSection({super.key, required this.model});

  final ProducerDashboardModel model;

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
                      model.totalProductionSectionLabel,
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
                      ProducerDashboardFormatters.kwh(model.totalProductionKwh),
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
                      title: model.sharedEnergyTitle,
                      valueText: ProducerDashboardFormatters.kwh(
                        model.sharedEnergyKwh,
                      ),
                      iconAssetPath: model.sharedEnergyIconAssetPath,
                    ),
                    ProducerMetricRow(
                      title: model.blockedCo2Title,
                      valueText: ProducerDashboardFormatters.kg(
                        model.blockedCo2Kg,
                      ),
                      iconAssetPath: model.blockedCo2IconAssetPath,
                    ),
                    ProducerMetricRow(
                      title: model.totalEarningsTitle,
                      valueText: ProducerDashboardFormatters.tryLira(
                        model.totalEarningsTry,
                      ),
                      iconAssetPath: model.totalEarningsIconAssetPath,
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
                        child: _HouseImage(
                          assetPath: model.houseImageAssetPath,
                        ),
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

class _HouseImage extends StatelessWidget {
  const _HouseImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final low = assetPath.toLowerCase();
    if (low.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: 220,
        height: 210,
        fit: BoxFit.contain,
        allowDrawingOutsideViewBox: true,
        errorBuilder: (context, error, stack) => Icon(
          Icons.home_work_outlined,
          size: 120,
          color: ProducerDashboardColors.darkGreen.withValues(alpha: 0.35),
        ),
      );
    }
    return Image.asset(
      assetPath,
      width: 220,
      height: 210,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => Icon(
        Icons.home_work_outlined,
        size: 120,
        color: ProducerDashboardColors.darkGreen.withValues(alpha: 0.35),
      ),
    );
  }
}
