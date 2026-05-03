import 'package:flutter/foundation.dart';
import 'package:mobile/features/consumer_home/application/consumer_dashboard_predictions_mapper.dart';
import 'package:mobile/features/consumer_home/domain/consumer_dashboard_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';

/// Tüketici ana sayfa: ilk frame model yok (yükleniyor); tahmin gelince tek seferde dolar.
class ConsumerDashboardController extends ChangeNotifier {
  ConsumerDashboardModel? _model;
  ConsumerDashboardModel? get model => _model;

  void applyModel(ConsumerDashboardModel next) {
    _model = next;
    notifyListeners();
  }

  Future<void> hydrateFromPredictions(PredictionRepository repo) async {
    try {
      final results = await Future.wait([
        repo.fetchLive(),
        repo.fetchProducerForecast(),
      ]);
      final live = results[0] as LiveProductionDto;
      final forecast = results[1] as ProducerForecastDto;
      applyModel(
        ConsumerDashboardPredictionsMapper.merge(
          ConsumerDashboardModel.shellLayout,
          live,
          forecast,
        ),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('ConsumerDashboardController.hydrate: $e');
        debugPrint('$st');
      }
      applyModel(
        ConsumerDashboardPredictionsMapper.merge(
          ConsumerDashboardModel.shellLayout,
          LiveProductionDto.fallback(),
          ProducerForecastDto.empty(),
        ),
      );
    }
  }
}
