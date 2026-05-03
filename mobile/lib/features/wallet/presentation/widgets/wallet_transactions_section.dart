import 'package:flutter/material.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_formatters.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';

class WalletTransactionsSection extends StatelessWidget {
  const WalletTransactionsSection({super.key, required this.model});

  final WalletModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = model.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.historyTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: WalletTheme.titleDark,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: WalletTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WalletTheme.border, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: WalletTheme.border,
                    ),
                  _TransactionTile(item: item),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final TransactionItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = item.signedAmountTry > 0;
    final amountColor = isCredit
        ? WalletTheme.incomeFg
        : WalletTheme.amountNegative;
    final amountText = WalletFormatters.signedTryDisplay(item.signedAmountTry);

    final iconBox = _TransactionIcon(kind: item.kind);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBox,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: WalletTheme.titleDark,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detailLine,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: WalletTheme.labelGray,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.kind});

  final WalletTransactionKind kind;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color fill;
    late final Color fg;

    switch (kind) {
      case WalletTransactionKind.income:
        icon = Icons.north_east_rounded;
        fill = WalletTheme.incomeFill;
        fg = WalletTheme.incomeFg;
      case WalletTransactionKind.expense:
        icon = Icons.south_west_rounded;
        fill = WalletTheme.expenseFill;
        fg = WalletTheme.expenseFg;
      case WalletTransactionKind.support:
        icon = Icons.north_rounded;
        fill = WalletTheme.accentFill;
        fg = WalletTheme.accentFg;
      case WalletTransactionKind.fee:
        icon = Icons.remove_rounded;
        fill = WalletTheme.neutralFill;
        fg = WalletTheme.neutralFg;
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg, width: 0.5),
      ),
      child: Icon(icon, size: 20, color: fg),
    );
  }
}
