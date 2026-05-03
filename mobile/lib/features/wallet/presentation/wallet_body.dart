import 'package:flutter/material.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';
import 'package:mobile/features/wallet/presentation/widgets/wallet_ai_summary_card.dart';
import 'package:mobile/features/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:mobile/features/wallet/presentation/widgets/wallet_metrics_row.dart';
import 'package:mobile/features/wallet/presentation/widgets/wallet_transactions_section.dart';

class WalletBody extends StatelessWidget {
  const WalletBody({super.key, required this.model});

  final WalletModel model;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WalletTheme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WalletBalanceCard(model: model),
                  if (model.liveDuzceFootnote != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      model.liveDuzceFootnote!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WalletTheme.labelGray,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  WalletMetricsRow(model: model),
                  const SizedBox(height: 16),
                  WalletAiSummaryCard(summary: model.aiSummary),
                  const SizedBox(height: 16),
                  WalletTransactionsSection(model: model),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
