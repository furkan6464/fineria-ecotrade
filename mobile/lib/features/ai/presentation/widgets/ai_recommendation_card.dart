import 'package:flutter/material.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';

class AiRecommendationCard extends StatelessWidget {
  const AiRecommendationCard({super.key, required this.model});

  final RecommendationModel model;

  (Color fill, Color border, Color text, IconData icon) get _style {
    switch (model.kind) {
      case RecommendationVisualKind.productionWeather:
        return (
          AiTheme.orangeFill,
          AiTheme.orangeBorder,
          AiTheme.orangeText,
          Icons.wb_sunny_outlined,
        );
      case RecommendationVisualKind.consumptionDemand:
        return (
          AiTheme.blueFill,
          AiTheme.blueBorder,
          AiTheme.blueText,
          Icons.schedule_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (fill, border, textColor, icon) = _style;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  model.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.35,
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
