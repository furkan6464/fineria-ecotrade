import 'package:flutter/material.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';

class AiWelcomeCard extends StatelessWidget {
  const AiWelcomeCard({super.key, required this.welcome});

  final AiWelcomeCardModel welcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AiTheme.greenFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AiTheme.greenBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AiTheme.welcomeBadgeRing,
              border: Border.all(color: AiTheme.greenBorder, width: 0.5),
            ),
            child: Icon(Icons.star_rounded, color: AiTheme.greenStar, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  welcome.greetingLine,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AiTheme.greenBodyText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  welcome.bodyText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AiTheme.greenBodyText,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
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
