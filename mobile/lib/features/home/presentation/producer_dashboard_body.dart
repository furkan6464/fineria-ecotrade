import 'package:flutter/material.dart';
import 'package:mobile/features/home/domain/producer_dashboard_model.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_formatters.dart';
import 'package:mobile/features/home/presentation/widgets/producer_daily_production_chart.dart';
import 'package:mobile/features/home/presentation/widgets/producer_hero_section.dart';
import 'package:mobile/features/home/presentation/widgets/producer_instant_cards.dart';

/// Sadece gövde: AppBar ve alt navigasyon [EcoTradeShell] içinde kalır.
class ProducerDashboardBody extends StatelessWidget {
  const ProducerDashboardBody({super.key, required this.model});

  final ProducerDashboardModel model;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ProducerDashboardColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProducerHeroSection(model: model),
            const SizedBox(height: 20),
            ProducerInstantCards(
              productionTitle: model.instantProductionTitle,
              productionValueText: ProducerDashboardFormatters.kwh(
                model.instantProductionKwh,
              ),
              consumptionTitle: model.instantConsumptionTitle,
              consumptionValueText: ProducerDashboardFormatters.kwh(
                model.instantConsumptionKwh,
              ),
            ),
            const SizedBox(height: 28),
            ProducerDailyProductionChart(model: model),
          ],
        ),
      ),
    );
  }
}
