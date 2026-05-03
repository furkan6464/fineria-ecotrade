import 'package:flutter/material.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';

class AiTypingIndicator extends StatelessWidget {
  const AiTypingIndicator({super.key, required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AiTheme.greenFill,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: AiTheme.greenBorder, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0),
              const SizedBox(width: 5),
              _dot(1),
              const SizedBox(width: 5),
              _dot(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(int index) {
    final a = 0.35 + index * 0.2;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AiTheme.greenBodyText.withValues(alpha: a.clamp(0.0, 1.0)),
      ),
    );
  }
}
