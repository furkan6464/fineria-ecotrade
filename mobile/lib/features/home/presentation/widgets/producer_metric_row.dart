import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';

class ProducerMetricRow extends StatelessWidget {
  const ProducerMetricRow({
    super.key,
    required this.title,
    required this.valueText,
    required this.iconAssetPath,
    this.bottomSpacing = 14,
  });

  final String title;
  final String valueText;
  final String iconAssetPath;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ProducerDashboardColors.khaki.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              iconAssetPath,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                ProducerDashboardColors.darkGreen,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: ProducerDashboardColors.darkGreen,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: ProducerDashboardColors.darkGreen,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
