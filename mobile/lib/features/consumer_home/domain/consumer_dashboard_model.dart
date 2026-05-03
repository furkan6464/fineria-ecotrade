import 'package:flutter/foundation.dart';

/// Tüketici ana sayfa modeli — fiyat, anlık tüketim, paylaşılan komşu enerjisi,
/// bloke edilen CO2 ve toplam tasarruf (DEDAŞ ile fark).
@immutable
class ConsumerDashboardModel {
  const ConsumerDashboardModel({
    required this.totalConsumptionSectionLabel,
    required this.totalConsumptionKwh,
    required this.neighborSourcedTitle,
    required this.neighborSourcedKwh,
    required this.blockedCo2Title,
    required this.blockedCo2Kg,
    required this.totalSavingsTitle,
    required this.totalSavingsTry,
    required this.neighborSourcedIconAssetPath,
    required this.blockedCo2IconAssetPath,
    required this.totalSavingsIconAssetPath,
    required this.poolPriceTitle,
    required this.poolPriceTryPerKwh,
    required this.instantConsumptionTitle,
    required this.instantConsumptionKwh,
    required this.chartTitle,
    required this.chartYAxisTicksKwh,
    required this.chartSlots,
    required this.chartLegendGridLabel,
    required this.chartLegendNeighborLabel,
    required this.heroImageAssetPath,
  });

  final String totalConsumptionSectionLabel;
  final double totalConsumptionKwh;

  final String neighborSourcedTitle;
  final double neighborSourcedKwh;
  final String blockedCo2Title;
  final double blockedCo2Kg;
  final String totalSavingsTitle;
  final double totalSavingsTry;

  final String neighborSourcedIconAssetPath;
  final String blockedCo2IconAssetPath;
  final String totalSavingsIconAssetPath;

  final String poolPriceTitle;
  final double poolPriceTryPerKwh;
  final String instantConsumptionTitle;
  final double instantConsumptionKwh;

  final String chartTitle;
  final List<double> chartYAxisTicksKwh;
  final List<ConsumerChartSlot> chartSlots;
  final String chartLegendGridLabel;
  final String chartLegendNeighborLabel;

  final String heroImageAssetPath;

  /// Sadece metin/ikon yolları; kWh [ConsumerDashboardPredictionsMapper.merge] ile dolar.
  static const ConsumerDashboardModel shellLayout = ConsumerDashboardModel(
    totalConsumptionSectionLabel: 'Toplam Tüketim',
    totalConsumptionKwh: 0,
    neighborSourcedTitle: 'Komşudan Alınan',
    neighborSourcedKwh: 0,
    blockedCo2Title: 'Engellen CO2',
    blockedCo2Kg: 0,
    totalSavingsTitle: 'Toplam Kazanç',
    totalSavingsTry: 0,
    neighborSourcedIconAssetPath: 'assets/dashboard/icon1.svg',
    blockedCo2IconAssetPath: 'assets/dashboard/icon2.svg',
    totalSavingsIconAssetPath: 'assets/dashboard/icon3.svg',
    poolPriceTitle: 'EcoTrade Fiyatı',
    poolPriceTryPerKwh: 0,
    instantConsumptionTitle: 'Anlık Tüketim',
    instantConsumptionKwh: 0,
    chartTitle: 'Bugünkü Tüketim Grafiği',
    chartYAxisTicksKwh: [1.0, 0.5, 0.25],
    chartSlots: [],
    chartLegendGridLabel: 'Şebekeden Tüketim',
    chartLegendNeighborLabel: 'Komşudan Tüketim',
    heroImageAssetPath: 'assets/dashboard/ev_charging.png',
  );
}

@immutable
class ConsumerChartSlot {
  const ConsumerChartSlot({
    required this.timeLabel,
    required this.timeLabelBold,
    required this.gridConsumptionKwh,
    required this.neighborConsumptionKwh,
    this.tooltipKwh,
  });

  final String timeLabel;
  final bool timeLabelBold;

  /// Şebekeden çekilen (kahverengi sütun).
  final double gridConsumptionKwh;

  /// Havuzdan / komşudan karşılanan (yeşil sütun).
  final double neighborConsumptionKwh;

  /// Sütun üstünde balon (varsa).
  final double? tooltipKwh;
}
