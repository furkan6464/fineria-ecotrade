import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';

class StrategySection extends StatelessWidget {
  const StrategySection({
    super.key,
    required this.model,
    required this.onSelectAuto,
    required this.onSelectGridOnly,
  });

  final ConsumerMarketModel model;
  final VoidCallback onSelectAuto;
  final VoidCallback onSelectGridOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ConsumerMarketTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerMarketTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          _Option(
            selected: model.autoStrategySelected,
            title: model.strategyAutoTitle,
            description: model.strategyAutoDescription,
            onTap: onSelectAuto,
          ),
          Divider(height: 1, thickness: 0.5, color: ConsumerMarketTheme.border),
          _Option(
            selected: !model.autoStrategySelected,
            title: model.strategyGridOnlyTitle,
            description: model.strategyGridOnlyDescription,
            onTap: onSelectGridOnly,
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 14,
                        color: ConsumerMarketTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.35,
                        color: ConsumerMarketTheme.subtitleGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? ConsumerMarketTheme.darkGreen
              : ConsumerMarketTheme.border,
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ConsumerMarketTheme.darkGreen,
              ),
            )
          : null,
    );
  }
}
