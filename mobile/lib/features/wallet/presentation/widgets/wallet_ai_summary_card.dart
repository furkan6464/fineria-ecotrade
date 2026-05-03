import 'package:flutter/material.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';

class WalletAiSummaryCard extends StatelessWidget {
  const WalletAiSummaryCard({super.key, required this.summary});

  final WalletAiSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: WalletTheme.titleDark,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.35,
    );
    final highlightStyle = baseStyle?.copyWith(
      color: WalletTheme.incomeFg,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: WalletTheme.aiCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WalletTheme.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.star_rounded,
              color: WalletTheme.aiStar,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  for (final p in summary.parts)
                    TextSpan(
                      text: p.text,
                      style: p.emphasizeSavings ? highlightStyle : baseStyle,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
