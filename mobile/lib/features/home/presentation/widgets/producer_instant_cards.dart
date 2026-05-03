import 'package:flutter/material.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';

class ProducerInstantCards extends StatelessWidget {
  const ProducerInstantCards({
    super.key,
    required this.productionTitle,
    required this.productionValueText,
    required this.consumptionTitle,
    required this.consumptionValueText,
  });

  final String productionTitle;
  final String productionValueText;
  final String consumptionTitle;
  final String consumptionValueText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Card(
            icon: Icons.schedule_rounded,
            title: productionTitle,
            valueText: productionValueText,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _Card(
            icon: Icons.home_outlined,
            title: consumptionTitle,
            valueText: consumptionValueText,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.title,
    required this.valueText,
  });

  final IconData icon;
  final String title;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: ProducerDashboardColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ProducerDashboardColors.iconCircleFill,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: ProducerDashboardColors.darkGreen.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: ProducerDashboardColors.cardLabelGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valueText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF000000),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
