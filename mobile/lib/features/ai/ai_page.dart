import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/ai/application/ai_assistant_controller.dart';
import 'package:mobile/features/ai/data/ai_chat_repository.dart';
import 'package:mobile/features/ai/presentation/ai_body.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:provider/provider.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final dio = context.read<Dio>();
        final chatRepo = AiChatRepository();
        final c = AiAssistantController(
          chatBridge: chatRepo.sendMessage,
        )..loadDemo();
        unawaited(c.hydrateFromPredictions(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<AiAssistantController>(
        builder: (context, controller, _) {
          final model = controller.viewModel;
          if (model == null) {
            return const ColoredBox(
              color: AiTheme.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AiTheme.greenBorder,
                  ),
                ),
              ),
            );
          }
          return AiBody(model: model);
        },
      ),
    );
  }
}
