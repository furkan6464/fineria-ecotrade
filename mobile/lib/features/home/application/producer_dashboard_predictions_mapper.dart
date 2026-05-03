import 'dart:math' as math;

import 'package:mobile/features/home/domain/producer_dashboard_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

/// Canlı + 6 saatlik forecast → dashboard. Forecast boşsa canlı kWh’ye göre 6 saat üretilir (grafik her zaman modele bağlı).
abstract final class ProducerDashboardPredictionsMapper {
  static double _instantConsumptionFromProduction(double productionKwh) {
    return (productionKwh * 0.35).clamp(0.05, productionKwh);
  }

  static List<double> _yTicks(double maxBar) {
    if (maxBar <= 0) return const [1.0, 0.5, 0.25];
    final m = math.max(1.0, (maxBar * 1.12).ceilToDouble());
    return [m, (m / 2).clamp(0.5, m), (m / 4).clamp(0.25, m)];
  }

  /// C# forecast boş gelse bile Python’dan gelen anlık kWh ile 6 sütun üretir.
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

  static ProducerDashboardModel merge(
    ProducerDashboardModel base,
    LiveProductionDto live,
    ProducerForecastDto forecast,
  ) {
    var rows = forecast.next6Hours;
    if (rows.isEmpty) {
      rows = _syntheticHoursFromLive(live);
    }

    final instantProd = live.liveProductionKwh;
    final instantCons = _instantConsumptionFromProduction(instantProd);

    final sumProduction = rows.fold<double>(0, (a, r) => a + r.productionKwh);
    final price = live.priceHintTryPerKwh;
    final shared = (sumProduction * 0.55).clamp(0.0, sumProduction);
    final co2 = (shared * 0.42).clamp(0.0, 999.0);
    final earnings = (shared * price * 0.92).clamp(0.0, 999999.0);

    final slots = <ProducerChartSlot>[];
    var maxBar = 1.0;
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final cons = (r.productionKwh - r.surplusKwh).clamp(0.0, r.productionKwh);
      maxBar = math.max(maxBar, math.max(r.productionKwh, cons));
      final isLast = i == rows.length - 1;
      slots.add(
        ProducerChartSlot(
          timeLabel: r.hour,
          timeLabelBold: isLast,
          productionKwh: r.productionKwh,
          consumptionKwh: cons,
          productionTooltipKwh: isLast ? instantProd : null,
        ),
      );
    }

    final fromApi = forecast.next6Hours.isNotEmpty;
    final chartTitle = fromApi
        ? 'Sonraki ${rows.length} saat tahmini (Düzce pilot)'
        : 'Tahmine dayalı üretim (canlı kWh ile ölçeklendi)';

    return ProducerDashboardModel(
      totalProductionSectionLabel: base.totalProductionSectionLabel,
      sharedEnergyTitle: base.sharedEnergyTitle,
      blockedCo2Title: base.blockedCo2Title,
      totalEarningsTitle: base.totalEarningsTitle,
      instantProductionTitle: base.instantProductionTitle,
      instantConsumptionTitle: base.instantConsumptionTitle,
      totalProductionKwh: sumProduction,
      sharedEnergyKwh: shared,
      blockedCo2Kg: co2,
      totalEarningsTry: earnings,
      sharedEnergyIconAssetPath: base.sharedEnergyIconAssetPath,
      blockedCo2IconAssetPath: base.blockedCo2IconAssetPath,
      totalEarningsIconAssetPath: base.totalEarningsIconAssetPath,
      instantProductionKwh: instantProd,
      instantConsumptionKwh: instantCons,
      chartTitle: chartTitle,
      chartYAxisTicksKwh: _yTicks(maxBar),
      chartSlots: slots,
      chartLegendProductionLabel: base.chartLegendProductionLabel,
      chartLegendConsumptionLabel: base.chartLegendConsumptionLabel,
      houseImageAssetPath: base.houseImageAssetPath,
    );
  }
}
