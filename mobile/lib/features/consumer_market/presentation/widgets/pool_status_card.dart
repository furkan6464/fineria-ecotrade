import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_formatters.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';

class PoolStatusCard extends StatelessWidget {
  const PoolStatusCard({super.key, required this.model});

  final ConsumerMarketModel model;

  @override
  Widget build(BuildContext context) {
    final supply = model.supplyKwh;
    final demand = model.demandKwh;
    final totalRaw = supply + demand;
    final total = totalRaw > 0 ? totalRaw : 1.0;
    final pivot = (supply / total).clamp(0.05, 0.95);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: ConsumerMarketTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.poolStatusHeadline,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: ConsumerMarketTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            model.poolStatusDetail,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.35,
              color: ConsumerMarketTheme.subtitleGray,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return SizedBox(
                height: 14,
                width: w,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ConsumerMarketTheme.background,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pivot,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ConsumerMarketTheme.khaki,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    Positioned(
                      left: pivot * w - 1,
                      top: -3,
                      child: Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          color: ConsumerMarketTheme.darkGreen,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${model.supplyLabel}: ${ConsumerMarketFormatters.kwh(supply)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: ConsumerMarketTheme.darkGreen,
                  ),
                ),
              ),
              Text(
                '${model.demandLabel}: ${ConsumerMarketFormatters.kwh(demand)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: ConsumerMarketTheme.darkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
