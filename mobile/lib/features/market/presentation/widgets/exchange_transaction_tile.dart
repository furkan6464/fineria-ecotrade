import 'package:flutter/material.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/exchange_formatters.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';

class ExchangeTransactionTile extends StatelessWidget {
  const ExchangeTransactionTile({super.key, required this.row});

  final ExchangeTransactionRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ExchangeTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExchangeTheme.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(row.avatarBackgroundArgb),
            child: Text(
              row.avatarInitial,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ExchangeTheme.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.counterpartyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: ExchangeTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ExchangeFormatters.timeAndKwh(row.timeLabel, row.energyKwh),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: ExchangeTheme.subtitleGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ExchangeFormatters.plusTry(row.amountTry),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: ExchangeTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
