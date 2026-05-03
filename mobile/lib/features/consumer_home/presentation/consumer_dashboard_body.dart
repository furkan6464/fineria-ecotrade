import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_home/domain/consumer_dashboard_model.dart';
import 'package:mobile/features/consumer_home/presentation/widgets/consumer_consumption_chart.dart';
import 'package:mobile/features/consumer_home/presentation/widgets/consumer_hero_section.dart';
import 'package:mobile/features/consumer_home/presentation/widgets/consumer_top_cards.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';

class ConsumerDashboardBody extends StatelessWidget {
  const ConsumerDashboardBody({super.key, required this.model});

  final ConsumerDashboardModel model;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ProducerDashboardColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsumerHeroSection(model: model),
            const SizedBox(height: 20),
            ConsumerTopCards(
              poolPriceTitle: model.poolPriceTitle,
              poolPriceTryPerKwh: model.poolPriceTryPerKwh,
              instantConsumptionTitle: model.instantConsumptionTitle,
              instantConsumptionKwh: model.instantConsumptionKwh,
            ),
            const SizedBox(height: 28),
            ConsumerConsumptionChart(model: model),
          ],
        ),
      ),
    );
  }
}
