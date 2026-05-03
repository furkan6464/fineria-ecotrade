import 'package:flutter/material.dart';
import 'package:mobile/features/wallet/application/wallet_controller.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_amount_page.dart';
import 'package:mobile/features/wallet/presentation/wallet_formatters.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';
import 'package:provider/provider.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key, required this.model});

  final WalletModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<WalletController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalletTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WalletTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.totalBalanceLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: WalletTheme.labelGray,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WalletFormatters.tryAmount(model.totalBalanceTry),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: WalletTheme.titleDark,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WalletActionButton(
                  label: model.withdrawButtonLabel,
                  background: WalletTheme.incomeFill,
                  foreground: WalletTheme.incomeFg,
                  borderColor: WalletTheme.incomeFg,
                  icon: Icons.arrow_upward_rounded,
                  onTap: () => WalletAmountPage.open(
                    context,
                    controller,
                    isWithdraw: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletActionButton(
                  label: model.depositButtonLabel,
                  background: WalletTheme.neutralFill,
                  foreground: WalletTheme.neutralFg,
                  borderColor: WalletTheme.neutralFg,
                  icon: Icons.arrow_downward_rounded,
                  onTap: () => WalletAmountPage.open(
                    context,
                    controller,
                    isWithdraw: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  const _WalletActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
