import 'package:flutter/foundation.dart';
import 'package:mobile/features/consumer_market/application/consumer_market_predictions_mapper.dart';
import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';

class ConsumerMarketController extends ChangeNotifier {
  ConsumerMarketModel? _model;
  ConsumerMarketModel? get model => _model;

  /// Sıfır değerli iskelet — etiketler sabit, sayılar tahmin akışından dolar.
  void primeBaseline() {
    _model = const ConsumerMarketModel(
      poolRateTitle: 'EcoTrade Havuz Kuru',
      poolRateTryPerKwh: 0.0,
      poolRateTrendLabel: 'Arz/talep dengesi yükleniyor',
      poolRateTrendDownward: true,
      priceSparkline: [],
      poolStatusSectionTitle: 'ANLIK HAVUZ DURUMU',
      poolStatusHeadline: 'Veriler yükleniyor',
      poolStatusDetail: 'Tahmin servisinden 6 saatlik özet hesaplanıyor.',
      supplyKwh: 0.0,
      demandKwh: 0.0,
      supplyLabel: 'Arz',
      demandLabel: 'Talep',
      strategySectionTitle: 'TÜKETİM STRATEJİN',
      strategyAutoTitle: 'Havuzdan Otomatik Karşıla',
      strategyAutoDescription:
          'Tüketimini arka planda en ucuz fiyattan havuz eşleşmeleriyle otomatik düşürür.',
      strategyGridOnlyTitle: 'Sadece Şebekeyi Kullan',
      strategyGridOnlyDescription:
          'EcoTrade havuzuna katılmaz, DEDAŞ tarifesinden standart faturalandırılırsın.',
      autoStrategySelected: true,
      recentSettlementsSectionTitle: 'SON MAHSUPLAŞMALAR',
      recentSettlements: [],
    );
    notifyListeners();
  }

  void applyModel(ConsumerMarketModel next) {
    _model = next;
    notifyListeners();
  }

  void selectAutoStrategy() => _patchStrategy(true);
  void selectGridOnlyStrategy() => _patchStrategy(false);

  void _patchStrategy(bool auto) {
    final m = _model;
    if (m == null || m.autoStrategySelected == auto) return;
    _model = ConsumerMarketModel(
      poolRateTitle: m.poolRateTitle,
      poolRateTryPerKwh: m.poolRateTryPerKwh,
      poolRateTrendLabel: m.poolRateTrendLabel,
      poolRateTrendDownward: m.poolRateTrendDownward,
      priceSparkline: m.priceSparkline,
      poolStatusSectionTitle: m.poolStatusSectionTitle,
      poolStatusHeadline: m.poolStatusHeadline,
      poolStatusDetail: m.poolStatusDetail,
      supplyKwh: m.supplyKwh,
      demandKwh: m.demandKwh,
      supplyLabel: m.supplyLabel,
      demandLabel: m.demandLabel,
      strategySectionTitle: m.strategySectionTitle,
      strategyAutoTitle: m.strategyAutoTitle,
      strategyAutoDescription: m.strategyAutoDescription,
      strategyGridOnlyTitle: m.strategyGridOnlyTitle,
      strategyGridOnlyDescription: m.strategyGridOnlyDescription,
      autoStrategySelected: auto,
      recentSettlementsSectionTitle: m.recentSettlementsSectionTitle,
      recentSettlements: m.recentSettlements,
    );
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
      final base = _model;
      if (base == null) return;
      applyModel(ConsumerMarketPredictionsMapper.merge(base, live, forecast));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('ConsumerMarketController.hydrate: $e');
        debugPrint('$st');
      }
    }
  }
}
