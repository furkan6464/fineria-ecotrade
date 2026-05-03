import 'package:flutter/material.dart';
import 'package:mobile/features/ai/application/ai_assistant_controller.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_chat_bubble.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_message_input_bar.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_quick_prompts_row.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_recommendation_card.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:mobile/features/ai/presentation/widgets/ai_welcome_card.dart';
import 'package:provider/provider.dart';

class AiBody extends StatelessWidget {
  const AiBody({super.key, required this.model});

  final AiAssistantModel model;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AiAssistantController>();
    final maxBubbleW = MediaQuery.sizeOf(context).width * 0.82;
    final theme = Theme.of(context);

    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      color: AiTheme.sectionTitle,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );

    return ColoredBox(
      color: AiTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: AiWelcomeCard(welcome: model.welcome),
                  ),
                ),
                if (model.recommendations.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        model.recommendationsSectionTitle,
                        style: sectionStyle,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final isLast =
                            index == model.recommendations.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: AiRecommendationCard(
                            model: model.recommendations[index],
                          ),
                        );
                      }, childCount: model.recommendations.length),
                    ),
                  ),
                ],
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(model.chatSectionTitle, style: sectionStyle),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AiChatBubble(
                          message: model.messages[index],
                          maxWidth: maxBubbleW,
                        ),
                      );
                    }, childCount: model.messages.length),
                  ),
                ),
                if (model.isAssistantTyping)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: AiTypingIndicator(maxWidth: maxBubbleW * 0.5),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),
          AiQuickPromptsRow(prompts: model.quickPrompts),
          const SizedBox(height: 4),
          AiMessageInputBar(
            hint: model.inputPlaceholder,
            onSend: controller.sendUserMessage,
          ),
        ],
      ),
    );
  }
}
