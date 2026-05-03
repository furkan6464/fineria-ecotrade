import 'package:flutter/foundation.dart';

/// Backend tabanı. Örnek: `flutter run --dart-define=API_BASE_URL=https://sunucu`
///
/// **Android emülatör (varsayılan):** Ağda `10.0.2.2` = geliştirme bilgisayarının
/// `localhost` eşleniği. C# **5159**, Python YZ **8001** bu host’ta dinliyorsa ek
/// tanım gerekmez: `http://10.0.2.2:5159` ve `http://10.0.2.2:8001`.
///
/// **Android gerçek cihaz:** Aynı Wi‑Fi’de bilgisayarın LAN IP’si veya USB ile
/// `adb reverse tcp:5159 tcp:5159` + `adb reverse tcp:8001 tcp:8001` sonrası
/// `http://127.0.0.1:...` veya `--dart-define=API_BASE_URL=http://192.168.x.x:5159`.
///
/// Masaüstü / iOS simülatör / Chrome: `API_BASE_URL` yoksa **`http://127.0.0.1:5159`**.
///
/// **YZ sohbet (Python):** `PYTHON_AI_BASE_URL` veya Android’de varsayılan
/// emülatör **`http://10.0.2.2:8001`**; masaüstü **`127.0.0.1:8001`**.
abstract final class ApiConfig {
  /// Açıkça verildiğinde her ortamda bu adres kullanılır (öncelik).
  static const String _explicitBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _explicitPythonAiBaseUrl = String.fromEnvironment(
    'PYTHON_AI_BASE_URL',
    defaultValue: '',
  );

  /// `EcoTrade.Api` HTTP profili: port **5159**.
  static String get baseUrl {
    final explicit = _explicitBaseUrl.trim();
    if (explicit.isNotEmpty) {
      return explicit.endsWith('/') ? explicit.substring(0, explicit.length - 1) : explicit;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5159';
    }
    return 'http://127.0.0.1:5159';
  }

  /// `python_mvp` uvicorn — `POST /ai/chat` (Groq). C# bypass.
  static String get pythonAiBaseUrl {
    final explicit = _explicitPythonAiBaseUrl.trim();
    if (explicit.isNotEmpty) {
      return explicit.endsWith('/')
          ? explicit.substring(0, explicit.length - 1)
          : explicit;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001';
    }
    return 'http://127.0.0.1:8001';
  }

  /// `false` yapınca tüm auth istekleri gerçek sunucuya gider.
  static const bool mockAuth = bool.fromEnvironment(
    'MOCK_AUTH',
    defaultValue: true,
  );

  /// `/api/predictions/ai-recommendations` için üretici kullanıcı kimliği.
  /// Boşsa [hackathonAiRecommendationsUserId] kullanılır (PostgreSQL demo satırı gerekmez).
  static const String aiRecommendationsUserId = String.fromEnvironment(
    'AI_RECOMMENDATIONS_USER_ID',
    defaultValue: '',
  );

  /// Varsayılan Guid — C# tarafı DB'de panel yoksa demo panel ile analyze çağırır.
  static const String hackathonAiRecommendationsUserId =
      '00000000-0000-0000-0000-000000000001';
}
