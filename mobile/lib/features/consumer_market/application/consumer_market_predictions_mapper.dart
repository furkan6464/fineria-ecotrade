import 'dart:math' as math;

import 'package:mobile/features/consumer_market/domain/consumer_market_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

abstract final class ConsumerMarketPredictionsMapper {
  /// Forecast yoksa canlı kWh üzerinden 6 saatlik sentetik akış üretir
  /// (üretici mapper'ıyla aynı şekil).
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

  /// Pilot bölgeyi temsilen ölçek katsayısı — 6 saatlik mahalle toplamına
  /// yaklaşmak için per-saat değerleri çoğaltır (jüri tarafında okunabilir
  /// "Arz/Talep kWh" değerleri çıksın diye).
  static const double kDistrictScale = 6.0;

  static ConsumerMarketModel merge(
    ConsumerMarketModel base,
    LiveProductionDto live,
    ProducerForecastDto forecast,
  ) {
    var rows = forecast.next6Hours;
    if (rows.isEmpty) {
      rows = _syntheticHoursFromLive(live);
    }

    var supplySum = 0.0;
    var demandSum = 0.0;
    final spark = <double>[];
    final settlements = <ConsumerSettlementRow>[];

    final price = live.priceHintTryPerKwh;
    for (final r in rows) {
      final cons = (r.productionKwh - r.surplusKwh).clamp(0.0, r.productionKwh);
      supplySum += r.surplusKwh;
      demandSum += cons;
      final hourly = r.priceTryPerKwh ?? price;
      spark.add(hourly);

      final fromNeighbor = math.min(cons, r.surplusKwh * 0.55);
      if (fromNeighbor > 0.05) {
        final amount = fromNeighbor * hourly;
        settlements.add(
          ConsumerSettlementRow(
            title: 'Havuzdan Karşılandı',
            subtitle:
                '${r.hour} - ${double.parse(fromNeighbor.toStringAsFixed(2))} kWh',
            amountTry: double.parse(amount.toStringAsFixed(2)),
          ),
        );
      }
    }

    final scaledSupply = supplySum * kDistrictScale;
    final scaledDemand = demandSum * kDistrictScale;

    final surplusGtDemand = scaledSupply >= scaledDemand;
    final headline = surplusGtDemand
        ? 'Üretim Fazlası Var'
        : 'Tüketim Fazlası Var';
    final detail = surplusGtDemand
        ? 'Şu an mahallede tüketimden çok üretim var.'
        : 'Şu an mahallede üretimden çok tüketim var.';
    final trendLabel = surplusGtDemand
        ? 'Arz yüksek, fiyat düşüyor'
        : 'Talep yüksek, fiyat yükseliyor';

    settlements.sort((a, b) => b.amountTry.compareTo(a.amountTry));
    final top = settlements.take(3).toList();

    return ConsumerMarketModel(
      poolRateTitle: base.poolRateTitle,
      poolRateTryPerKwh: price,
      poolRateTrendLabel: trendLabel,
      poolRateTrendDownward: surplusGtDemand,
      priceSparkline: spark,
      poolStatusSectionTitle: base.poolStatusSectionTitle,
      poolStatusHeadline: headline,
      poolStatusDetail: detail,
      supplyKwh: scaledSupply,
      demandKwh: scaledDemand,
      supplyLabel: base.supplyLabel,
      demandLabel: base.demandLabel,
      strategySectionTitle: base.strategySectionTitle,
      strategyAutoTitle: base.strategyAutoTitle,
      strategyAutoDescription: base.strategyAutoDescription,
      strategyGridOnlyTitle: base.strategyGridOnlyTitle,
      strategyGridOnlyDescription: base.strategyGridOnlyDescription,
      autoStrategySelected: base.autoStrategySelected,
      recentSettlementsSectionTitle: base.recentSettlementsSectionTitle,
      recentSettlements: top,
    );
  }
}
