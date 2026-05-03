import 'package:flutter/material.dart';
import 'package:mobile/features/market/application/producer_exchange_controller.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';
import 'package:mobile/features/market/presentation/widgets/exchange_active_offer_card.dart';
import 'package:mobile/features/market/presentation/widgets/exchange_price_chart_card.dart';
import 'package:mobile/features/market/presentation/widgets/exchange_sales_section.dart';
import 'package:mobile/features/market/presentation/widgets/exchange_transaction_tile.dart';
import 'package:provider/provider.dart';

/// Yalnızca gövde — AppBar ve alt navigasyon kabukta kalır.
class ProducerExchangeBody extends StatelessWidget {
  const ProducerExchangeBody({super.key, required this.model});

  final ProducerExchangeModel model;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProducerExchangeController>();

    return ColoredBox(
      color: ExchangeTheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExchangePriceChartCard(model: model),
            const SizedBox(height: 24),
            ExchangeSalesSection(
              model: model,
              onAutomaticTap: controller.selectAutomaticSell,
              onManualTap: controller.selectManualSell,
            ),
            if (model.activeOffer != null) ...[
              const SizedBox(height: 28),
              ExchangeActiveOfferBlock(
                sectionTitle: model.activeOfferSectionTitle,
                offer: model.activeOffer!,
                onCancel: controller.cancelActiveOffer,
              ),
            ],
            const SizedBox(height: 28),
            Text(
              model.recentTransactionsSectionTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: ExchangeTheme.darkGreen,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in model.recentTransactions)
              ExchangeTransactionTile(row: row),
          ],
        ),
      ),
    );
  }
}
