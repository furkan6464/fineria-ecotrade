import 'package:flutter/material.dart';
import 'package:mobile/features/ai/application/ai_assistant_controller.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';
import 'package:provider/provider.dart';

class AiQuickPromptsRow extends StatelessWidget {
  const AiQuickPromptsRow({super.key, required this.prompts});

  final List<QuickPromptModel> prompts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<AiAssistantController>();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = prompts[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.sendQuickPrompt(p),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AiTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AiTheme.chipBorder, width: 0.5),
                ),
                child: Text(
                  p.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AiTheme.userText,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
