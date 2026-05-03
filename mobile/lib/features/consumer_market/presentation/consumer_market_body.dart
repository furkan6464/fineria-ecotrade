import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/application/consumer_market_controller.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';
import 'package:mobile/features/consumer_market/presentation/widgets/pool_rate_card.dart';
import 'package:mobile/features/consumer_market/presentation/widgets/pool_status_card.dart';
import 'package:mobile/features/consumer_market/presentation/widgets/settlements_list.dart';
import 'package:mobile/features/consumer_market/presentation/widgets/strategy_section.dart';
import 'package:provider/provider.dart';

class ConsumerMarketBody extends StatelessWidget {
  const ConsumerMarketBody({super.key, required this.model});

  final ConsumerMarketModel model;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ConsumerMarketController>();

    return ColoredBox(
      color: ConsumerMarketTheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PoolRateCard(model: model),
            const SizedBox(height: 20),
            _SectionLabel(text: model.poolStatusSectionTitle),
            const SizedBox(height: 8),
            PoolStatusCard(model: model),
            const SizedBox(height: 20),
            _SectionLabel(text: model.strategySectionTitle),
            const SizedBox(height: 8),
            StrategySection(
              model: model,
              onSelectAuto: controller.selectAutoStrategy,
              onSelectGridOnly: controller.selectGridOnlyStrategy,
            ),
            const SizedBox(height: 20),
            _SectionLabel(text: model.recentSettlementsSectionTitle),
            const SizedBox(height: 8),
            SettlementsList(rows: model.recentSettlements),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 1.0,
        color: ConsumerMarketTheme.sectionLabelGray,
      ),
    );
  }
}
