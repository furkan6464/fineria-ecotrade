import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/config/api_config.dart';

/// Doğrudan Python `POST /ai/chat` — Postman ile aynı servis ([ApiConfig.pythonAiBaseUrl]).
///
/// Ayrı bir [Dio] kullanılır: ana API ile paylaşılan istemci Groq gibi uzun yanıtlarda ve
/// ilk bağlantıda daha geniş zaman aşımı ister; üstelik Python adresi farklı tabandır.
class AiChatRepository {
  AiChatRepository({Dio? dio}) : _dio = dio ?? _createDedicatedClient();

  final Dio _dio;

  static Dio _createDedicatedClient() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 45),
        validateStatus: (code) => code != null && code < 500,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
    return dio;
  }

  String get _chatUrl => '${ApiConfig.pythonAiBaseUrl}/ai/chat';

  static String? _extractReply(dynamic data) {
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final r = m['reply'] ?? m['Reply'];
      if (r is String && r.trim().isNotEmpty) return r.trim();
      if (r != null) return r.toString().trim();
    }
    return null;
  }

  Future<String?> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;
    try {
      final response = await _dio.post<dynamic>(
        _chatUrl,
        data: <String, dynamic>{'message': trimmed},
      );

      final code = response.statusCode ?? 0;
      final ok = code >= 200 && code < 300;
      final text = _extractReply(response.data);

      if (ok && text != null) {
        return text;
      }

      if (kDebugMode) {
        debugPrint(
          '[AiChatRepository] Yanıt uygun değil: HTTP $code '
          'body=${response.data}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AiChatRepository] DioException ${e.type} '
          '${e.response?.statusCode} ${e.message}',
        );
        debugPrint('[AiChatRepository] response data: ${e.response?.data}');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AiChatRepository] $e\n$st');
      }
    }
    return null;
  }
}
