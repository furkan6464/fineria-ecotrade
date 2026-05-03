import 'package:flutter/material.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';

class AiChatBubble extends StatelessWidget {
  const AiChatBubble({
    super.key,
    required this.message,
    required this.maxWidth,
  });

  final ChatMessageModel message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    final fill = isUser ? AiTheme.userFill : AiTheme.greenFill;
    final border = isUser ? AiTheme.userBorder : AiTheme.greenBorder;
    final textColor = isUser ? AiTheme.userText : AiTheme.greenBodyText;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: 0.5),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
