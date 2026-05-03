import 'package:flutter/foundation.dart';

/// LLM / C# backend’den beslenen asistan ekranı kök modeli.
@immutable
class AiAssistantModel {
  const AiAssistantModel({
    required this.welcome,
    required this.recommendationsSectionTitle,
    required this.recommendations,
    required this.chatSectionTitle,
    required this.messages,
    required this.isAssistantTyping,
    required this.quickPrompts,
    required this.inputPlaceholder,
  });

  final AiWelcomeCardModel welcome;
  final String recommendationsSectionTitle;
  final List<RecommendationModel> recommendations;
  final String chatSectionTitle;
  final List<ChatMessageModel> messages;
  final bool isAssistantTyping;
  final List<QuickPromptModel> quickPrompts;
  final String inputPlaceholder;

  AiAssistantModel copyWith({
    AiWelcomeCardModel? welcome,
    String? recommendationsSectionTitle,
    List<RecommendationModel>? recommendations,
    String? chatSectionTitle,
    List<ChatMessageModel>? messages,
    bool? isAssistantTyping,
    List<QuickPromptModel>? quickPrompts,
    String? inputPlaceholder,
  }) {
    return AiAssistantModel(
      welcome: welcome ?? this.welcome,
      recommendationsSectionTitle:
          recommendationsSectionTitle ?? this.recommendationsSectionTitle,
      recommendations: recommendations ?? this.recommendations,
      chatSectionTitle: chatSectionTitle ?? this.chatSectionTitle,
      messages: messages ?? this.messages,
      isAssistantTyping: isAssistantTyping ?? this.isAssistantTyping,
      quickPrompts: quickPrompts ?? this.quickPrompts,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
    );
  }
}

@immutable
class AiWelcomeCardModel {
  const AiWelcomeCardModel({
    required this.greetingLine,
    required this.bodyText,
  });

  final String greetingLine;
  final String bodyText;
}

enum RecommendationVisualKind { productionWeather, consumptionDemand }

@immutable
class RecommendationModel {
  const RecommendationModel({
    required this.kind,
    required this.title,
    required this.body,
  });

  final RecommendationVisualKind kind;
  final String title;
  final String body;
}

@immutable
class ChatMessageModel {
  const ChatMessageModel({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

@immutable
class QuickPromptModel {
  const QuickPromptModel({
    required this.id,
    required this.label,
    required this.messageToSend,
  });

  final String id;
  final String label;

  /// Çipe basılınca kullanıcı mesajı olarak gönderilecek metin (backend / model).
  final String messageToSend;
}
