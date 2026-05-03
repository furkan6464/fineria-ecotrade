import 'dart:math' as math;

import 'package:mobile/features/consumer_home/domain/consumer_dashboard_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

/// Tahmin akışından (`/api/predictions/live` + `/api/predictions/producer-forecast`)
/// tüketici özetini üretir. Üretici mapper’ıyla tutarlı katsayılar kullanılır:
/// - cons (saatlik tüketim) = productionKwh − surplusKwh
/// - havuzdan karşılanan ≈ surplus × 0,55 (havuz katılım payı)
/// - şebekeden çekilen = cons − havuzdan karşılanan
/// - tasarruf = havuzdan karşılanan × (DEDAŞ − havuz)
abstract final class ConsumerDashboardPredictionsMapper {
  /// Demo / jüri için DEDAŞ referans tarifesi (₺/kWh).
  static const double kDedasRefTlKwh = 2.65;

  static double _instantConsumptionFromProduction(double productionKwh) {
    return (productionKwh * 0.35).clamp(0.05, productionKwh);
  }

  static List<double> _yTicks(double maxBar) {
    if (maxBar <= 0) return const [1.0, 0.5, 0.25];
    final m = math.max(1.0, (maxBar * 1.12).ceilToDouble());
    return [m, (m / 2).clamp(0.5, m), (m / 4).clamp(0.25, m)];
  }

  /// Forecast boş gelse bile canlı kWh ile 6 saatlik sentetik seri üretir.
  static List<ForecastHourPointDto> _syntheticHoursFromLive(
    LiveProductionDto live,
  ) {
    final peak = math.max(0.1, live.liveProductionKwh);
    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month, now.day, now.hour);
    return List.generate(6, (i) {
      final t = anchor.add(Duration(hours: i));
      final label = '${t.hour.toString().padLeft(2, '0')}:00';
      final phase = (i - 2.2) / 2.2;
      final bell = math.exp(-phase * phase);
      final p = (peak * (0.3 + 0.7 * bell)).clamp(0.05, peak * 1.2);
      final surplus = (p * 0.42).clamp(0.01, p);
      return ForecastHourPointDto(
        hour: label,
        productionKwh: double.parse(p.toStringAsFixed(2)),
        surplusKwh: double.parse(surplus.toStringAsFixed(2)),
        priceTryPerKwh: live.priceHintTryPerKwh,
      );
    });
  }

  static ConsumerDashboardModel merge(
    ConsumerDashboardModel base,
    LiveProductionDto live,
    ProducerForecastDto forecast,
  ) {
    var rows = forecast.next6Hours;
    if (rows.isEmpty) {
      rows = _syntheticHoursFromLive(live);
    }

    final price = live.priceHintTryPerKwh;
    final instantProd = live.liveProductionKwh;
    final instantCons = _instantConsumptionFromProduction(instantProd);

    var totalCons = 0.0;
    var totalNeighbor = 0.0;
    var maxBar = 1.0;

    final slots = <ConsumerChartSlot>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final cons = (r.productionKwh - r.surplusKwh).clamp(0.0, r.productionKwh);
      final fromNeighbor = math.min(cons, r.surplusKwh * 0.55);
      final fromGrid = (cons - fromNeighbor).clamp(0.0, cons);

      totalCons += cons;
      totalNeighbor += fromNeighbor;
      maxBar = math.max(maxBar, math.max(fromGrid, fromNeighbor));

      final isLast = i == rows.length - 1;
      slots.add(
        ConsumerChartSlot(
          timeLabel: r.hour,
          timeLabelBold: isLast,
          gridConsumptionKwh: fromGrid,
          neighborConsumptionKwh: fromNeighbor,
          tooltipKwh: isLast ? cons : null,
        ),
      );
    }

    final co2 = (totalNeighbor * 0.42).clamp(0.0, 999.0);
    final saving = (totalNeighbor * (kDedasRefTlKwh - price)).clamp(
      0.0,
      999999.0,
    );

    final fromApi = forecast.next6Hours.isNotEmpty;
    final chartTitle = fromApi
        ? 'Sonraki ${rows.length} saat tüketim tahmini (Düzce pilot)'
        : 'Tahmine dayalı tüketim (canlı kWh ile ölçeklendi)';

    return ConsumerDashboardModel(
      totalConsumptionSectionLabel: base.totalConsumptionSectionLabel,
      totalConsumptionKwh: totalCons,
      neighborSourcedTitle: base.neighborSourcedTitle,
      neighborSourcedKwh: totalNeighbor,
      blockedCo2Title: base.blockedCo2Title,
      blockedCo2Kg: co2,
      totalSavingsTitle: base.totalSavingsTitle,
      totalSavingsTry: saving,
      neighborSourcedIconAssetPath: base.neighborSourcedIconAssetPath,
      blockedCo2IconAssetPath: base.blockedCo2IconAssetPath,
      totalSavingsIconAssetPath: base.totalSavingsIconAssetPath,
      poolPriceTitle: base.poolPriceTitle,
      poolPriceTryPerKwh: price,
      instantConsumptionTitle: base.instantConsumptionTitle,
      instantConsumptionKwh: instantCons,
      chartTitle: chartTitle,
      chartYAxisTicksKwh: _yTicks(maxBar),
      chartSlots: slots,
      chartLegendGridLabel: base.chartLegendGridLabel,
      chartLegendNeighborLabel: base.chartLegendNeighborLabel,
      heroImageAssetPath: base.heroImageAssetPath,
    );
  }
}
