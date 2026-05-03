import 'package:flutter/material.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/exchange_formatters.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';

class ExchangeSalesSection extends StatelessWidget {
  const ExchangeSalesSection({
    super.key,
    required this.model,
    required this.onAutomaticTap,
    required this.onManualTap,
  });

  final ProducerExchangeModel model;
  final VoidCallback onAutomaticTap;
  final VoidCallback onManualTap;

  @override
  Widget build(BuildContext context) {
    final auto = model.automaticSellSelected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.salesSectionTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ExchangeTheme.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: ExchangeTheme.darkGreen,
            ),
            children: [
              TextSpan(text: '${model.sellableEnergyLabel} '),
              TextSpan(
                text: ExchangeFormatters.kwh(model.sellableEnergyKwh),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SellModeButton(
                label: model.automaticSellButtonLabel,
                selected: auto,
                onTap: onAutomaticTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SellModeButton(
                label: model.manualSellButtonLabel,
                selected: !auto,
                onTap: onManualTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SellModeButton extends StatelessWidget {
  const _SellModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? ExchangeTheme.darkGreen
                : ExchangeTheme.badgeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? ExchangeTheme.darkGreen
                  : ExchangeTheme.cardBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? ExchangeTheme.white : ExchangeTheme.darkGreen,
            ),
          ),
        ),
      ),
    );
  }
}
