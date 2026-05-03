import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/features/predictions/data/ai_recommendations_dto.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

/// C# EcoTrade.Api tahmin uçları (`/api/predictions/*`).
class PredictionRepository {
  PredictionRepository(this._dio);

  final Dio _dio;

  static const _livePath = '/api/predictions/live';
  static const _forecastPath = '/api/predictions/producer-forecast';
  static const _aiRecPath = '/api/predictions/ai-recommendations';

  static void _log(String msg) {
    if (kDebugMode) {
      debugPrint('[PredictionRepository] $msg');
    }
  }

  Future<LiveProductionDto> fetchLive() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _livePath,
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        try {
          final dto = LiveProductionDto.fromJson(data);
          _log(
            'live OK → degraded=${dto.degraded} '
            '${dto.liveProductionKwh} kWh (sunucudan)',
          );
          return dto;
        } catch (e, st) {
          _log('live JSON/parse hatası: $e');
          _log('$st');
          _log('live ham gövde: $data');
        }
      } else {
        _log(
          'live beklenmeyen yanıt: status=${response.statusCode} '
          'data=${data == null}',
        );
      }
    } on DioException catch (e) {
      _log(
        'live DioException → ${e.type} '
        '${e.response?.statusCode} ${e.message}',
      );
    } catch (e, st) {
      _log('live error: $e');
      _log('$st');
    }
    _log('live → fallback() kullanılıyor');
    return LiveProductionDto.fallback();
  }

  Future<ProducerForecastDto> fetchProducerForecast() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _forecastPath,
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 18),
        ),
      );
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        try {
          final dto = ProducerForecastDto.fromJson(data);
          _log(
            'forecast OK → degraded=${dto.degraded} '
            'n=${dto.next6Hours.length} saat',
          );
          return dto;
        } catch (e, st) {
          _log('forecast JSON/parse hatası: $e');
          _log('$st');
          _log('forecast ham gövde: $data');
        }
      } else {
        _log(
          'forecast beklenmeyen yanıt: status=${response.statusCode} '
          'data=${data == null}',
        );
      }
    } on DioException catch (e) {
      _log(
        'forecast DioException → ${e.type} '
        '${e.response?.statusCode} ${e.message}',
      );
    } catch (e, st) {
      _log('forecast error: $e');
      _log('$st');
    }
    _log('forecast → empty() kullanılıyor');
    return ProducerForecastDto.empty();
  }

  /// [userId] boşsa null döner (çağrılmaz).
  Future<AiRecommendationsDto?> fetchAiRecommendations(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _aiRecPath,
        queryParameters: {'userId': id},
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        try {
          final dto = AiRecommendationsDto.fromJson(data);
          _log('ai-recommendations OK → ${dto.recommendations.length} öğe');
          return dto;
        } catch (e, st) {
          _log('ai JSON/parse hatası: $e');
          _log('$st');
        }
      }
    } on DioException catch (e) {
      _log(
        'ai DioException → ${e.type} '
        '${e.response?.statusCode} ${e.message}',
      );
    } catch (e, st) {
      _log('ai error: $e');
      _log('$st');
    }
    _log('ai-recommendations → null');
    return null;
  }
}
