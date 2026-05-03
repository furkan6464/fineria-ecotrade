import 'package:flutter/foundation.dart';
import 'package:mobile/features/home/application/producer_dashboard_predictions_mapper.dart';
import 'package:mobile/features/home/domain/producer_dashboard_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';

/// Ana sayfa: ilk frame’de [model] yok (yükleniyor); API/tahmin gelince tek seferde dolar
/// — açılışta 4,2 kWh gibi sahte anlık değer gösterilmez.
class ProducerDashboardController extends ChangeNotifier {
  ProducerDashboardModel? _model;
  ProducerDashboardModel? get model => _model;

  void applyModel(ProducerDashboardModel next) {
    _model = next;
    notifyListeners();
  }

  /// C# canlı + 6 saatlik forecast; hata olursa canlı fallback + boş forecast ile yine model üretir.
  Future<void> hydrateFromPredictions(PredictionRepository repo) async {
    try {
      final results = await Future.wait([
        repo.fetchLive(),
        repo.fetchProducerForecast(),
      ]);
      final live = results[0] as LiveProductionDto;
      final forecast = results[1] as ProducerForecastDto;
      applyModel(
        ProducerDashboardPredictionsMapper.merge(
          ProducerDashboardModel.shellLayout,
          live,
          forecast,
        ),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('hydrateFromPredictions: $e');
        debugPrint('$st');
      }
      applyModel(
        ProducerDashboardPredictionsMapper.merge(
          ProducerDashboardModel.shellLayout,
          LiveProductionDto.fallback(),
          ProducerForecastDto.empty(),
        ),
      );
    }
  }
}
