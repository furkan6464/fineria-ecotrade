import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_home/presentation/consumer_dashboard_formatters.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';

/// Sol: EcoTrade Fiyatı (T/kWh) - sag: Anlik Tuketim (kWh).
class ConsumerTopCards extends StatelessWidget {
  const ConsumerTopCards({
    super.key,
    required this.poolPriceTitle,
    required this.poolPriceTryPerKwh,
    required this.instantConsumptionTitle,
    required this.instantConsumptionKwh,
  });

  final String poolPriceTitle;
  final double poolPriceTryPerKwh;
  final String instantConsumptionTitle;
  final double instantConsumptionKwh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ValueCard(
            icon: Icons.schedule_rounded,
            title: poolPriceTitle,
            valueText: ConsumerDashboardFormatters.tryPriceTag(
              poolPriceTryPerKwh,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ValueCard(
            icon: Icons.home_outlined,
            title: instantConsumptionTitle,
            valueText: ConsumerDashboardFormatters.kwh(instantConsumptionKwh),
            valueIsKwh: true,
          ),
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.valueText,
    this.valueIsKwh = false,
  });

  final IconData icon;
  final String title;
  final String valueText;
  final bool valueIsKwh;

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
          _ValueText(text: valueText, kwh: valueIsKwh),
        ],
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText({required this.text, required this.kwh});

  final String text;
  final bool kwh;

  @override
  Widget build(BuildContext context) {
    if (!kwh) {
      return Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Color(0xFF000000),
          height: 1.1,
        ),
      );
    }
    final i = text.lastIndexOf(' ');
    final main = i > 0 ? text.substring(0, i) : text;
    final unit = i > 0 ? text.substring(i + 1) : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          main,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF000000),
            height: 1.1,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              unit,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: ProducerDashboardColors.cardLabelGray,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
