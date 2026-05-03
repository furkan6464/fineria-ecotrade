import 'package:flutter/material.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_formatters.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';

class WalletMetricsRow extends StatelessWidget {
  const WalletMetricsRow({super.key, required this.model});

  final WalletModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _MetricTile(card: model.pendingCard, theme: theme),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(card: model.upcomingBillCard, theme: theme),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.card, required this.theme});

  final WalletMetricCardModel card;
  final ThemeData theme;

  (Color fill, Color fg, IconData icon) _style() {
    switch (card.visualKind) {
      case WalletMetricVisualKind.pendingOrange:
        return (
          WalletTheme.accentFill,
          WalletTheme.accentFg,
          Icons.add_rounded,
        );
      case WalletMetricVisualKind.billBlue:
        return (
          WalletTheme.expenseFill,
          WalletTheme.expenseFg,
          Icons.info_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fill, fg, icon) = _style();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WalletTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WalletTheme.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: fg, width: 0.5),
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: WalletTheme.labelGray,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WalletFormatters.tryAmount(card.amountTry),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: WalletTheme.titleDark,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
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
