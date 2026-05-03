import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/config/api_config.dart';
import 'package:mobile/features/ai/application/ai_predictions_merger.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';

class AiAssistantController extends ChangeNotifier {
  AiAssistantController({Future<String?> Function(String message)? chatBridge})
      : _chatBridge = chatBridge;

  /// C# `/api/ai/chat` → Python Groq.
  final Future<String?> Function(String message)? _chatBridge;

  AiAssistantModel? _model;

  AiAssistantModel? get viewModel => _model;

  void applyModel(AiAssistantModel next) {
    _model = next;
    notifyListeners();
  }

  /// İlk çizim: boş sohbet; karşılama metni hydrate ile dolar.
  void loadDemo() {
    applyModel(
      const AiAssistantModel(
        welcome: AiWelcomeCardModel(
          greetingLine: 'Merhaba,',
          bodyText: 'Düzce pilot tahminleri yükleniyor…',
        ),
        recommendationsSectionTitle: 'Öne çıkan tavsiyeler',
        recommendations: [],
        chatSectionTitle: 'Sohbet',
        messages: [],
        isAssistantTyping: false,
        quickPrompts: [
          QuickPromptModel(
            id: 'monthly_report',
            label: 'Aylık rapor',
            messageToSend: 'Aylık raporumu özetle.',
          ),
          QuickPromptModel(
            id: 'savings_tips',
            label: 'Tasarruf ipuçları',
            messageToSend: 'Bana tasarruf ipuçları ver.',
          ),
          QuickPromptModel(
            id: 'price_alert',
            label: 'Fiyat alarmı kur',
            messageToSend: 'Fiyat alarmı kurmak istiyorum.',
          ),
        ],
        inputPlaceholder: 'EcoTrade asistanına bir şey sor...',
      ),
    );
  }

  Future<void> hydrateFromPredictions(PredictionRepository repo) async {
    try {
      final results = await Future.wait([
        repo.fetchLive(),
        repo.fetchProducerForecast(),
      ]);
      final live = results[0] as LiveProductionDto;
      final forecast = results[1] as ProducerForecastDto;

      final uidRaw = ApiConfig.aiRecommendationsUserId.trim();
      final uid = uidRaw.isNotEmpty
          ? uidRaw
          : ApiConfig.hackathonAiRecommendationsUserId;
      final aiApi = await repo.fetchAiRecommendations(uid);

      final m = _model;
      if (m == null) return;

      final recs = AiPredictionsMerger.buildRecommendations(
        live: live,
        forecast: forecast,
        fromApi: aiApi,
      );

      final welcome = AiWelcomeCardModel(
        greetingLine: m.welcome.greetingLine,
        bodyText: AiPredictionsMerger.welcomeBodyFromLive(live),
      );

      applyModel(
        m.copyWith(
          welcome: welcome,
          recommendations: recs,
          messages: AiPredictionsMerger.seedChatAfterHydrate(live),
          isAssistantTyping: false,
        ),
      );
    } catch (_) {
      final m = _model;
      if (m == null) return;
      applyModel(
        m.copyWith(
          welcome: const AiWelcomeCardModel(
            greetingLine: 'Merhaba,',
            bodyText:
                'Şu an tahmin servisine ulaşılamadı; tavsiyeler yüklenemedi. Ağı kontrol edip tekrar dene.',
          ),
          recommendations: AiPredictionsMerger.buildRecommendations(
            live: LiveProductionDto.fallback(),
            forecast: ProducerForecastDto.empty(),
            fromApi: null,
          ),
          messages: const [
            ChatMessageModel(
              isUser: false,
              text:
                  'Sunucuya ulaşılamadı; aşağıdaki kartlar yedek metindir. Bağlantı gelince otomatik yenilenecek.',
            ),
          ],
          isAssistantTyping: false,
        ),
      );
    }
  }

  void sendUserMessage(String text) {
    final m = _model;
    if (m == null) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    applyModel(
      m.copyWith(
        messages: [
          ...m.messages,
          ChatMessageModel(isUser: true, text: trimmed),
        ],
        isAssistantTyping: true,
      ),
    );
    unawaited(_replyPlaceholder());
  }

  Future<void> _replyPlaceholder() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final m = _model;
    if (m == null || !m.isAssistantTyping) return;
    final msgs = m.messages;
    if (msgs.isEmpty) return;
    final last = msgs.last;
    if (!last.isUser) return;

    late final String reply;
    if (_chatBridge != null) {
      try {
        reply =
            await _chatBridge(last.text) ??
            'Sohbet yanıtı alınamadı.\n'
            '• Python: uvicorn --host 0.0.0.0 — bilgisayarda 8001 dinlemeli.\n'
            '• Emülatör: http://10.0.2.2:8001/ai/chat (varsayılan ApiConfig).\n'
            '• Gerçek cihaz: LAN IP veya adb reverse tcp:8001 — güvenlik duvarı TCP 8001.\n'
            '• Tahminler için C# hâlâ 5159.';
      } catch (e) {
        reply = kDebugMode ? 'Sohbet hatası: $e' : 'Şu an yanıt verilemedi.';
      }
    } else {
      reply =
          'Sohbet köprüsü bağlı değil; üstteki kartlar canlı tahminlerden geliyor.';
    }

    applyModel(
      m.copyWith(
        messages: [
          ...m.messages,
          ChatMessageModel(isUser: false, text: reply),
        ],
        isAssistantTyping: false,
      ),
    );
  }

  void sendQuickPrompt(QuickPromptModel prompt) {
    sendUserMessage(prompt.messageToSend);
  }

  void setTyping(bool typing) {
    final m = _model;
    if (m == null) return;
    applyModel(m.copyWith(isAssistantTyping: typing));
  }

  void appendAssistantMessage(String text) {
    final m = _model;
    if (m == null) return;
    applyModel(
      m.copyWith(
        messages: [
          ...m.messages,
          ChatMessageModel(isUser: false, text: text),
        ],
        isAssistantTyping: false,
      ),
    );
  }
}
