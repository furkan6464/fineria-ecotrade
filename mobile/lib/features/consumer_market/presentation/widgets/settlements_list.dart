import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_formatters.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';

class SettlementsList extends StatelessWidget {
  const SettlementsList({super.key, required this.rows});

  final List<ConsumerSettlementRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: ConsumerMarketTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
        ),
        child: Text(
          'Henuz mahsuplasma yok - havuz eslesmesi olunca burada gorunur.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: ConsumerMarketTheme.subtitleGray,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ConsumerMarketTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final r = rows[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: ConsumerMarketTheme.border,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ConsumerMarketTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ConsumerMarketTheme.border,
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 20,
                        color: ConsumerMarketTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: ConsumerMarketTheme.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.subtitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: ConsumerMarketTheme.subtitleGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ConsumerMarketFormatters.tryAmount(r.amountTry),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: ConsumerMarketTheme.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
