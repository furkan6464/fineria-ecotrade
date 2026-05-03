import 'package:flutter/foundation.dart';

/// Üretici ana sayfa için API / controller’dan beslenen veri.
@immutable
class ProducerDashboardModel {
  const ProducerDashboardModel({
    required this.totalProductionSectionLabel,
    required this.sharedEnergyTitle,
    required this.blockedCo2Title,
    required this.totalEarningsTitle,
    required this.instantProductionTitle,
    required this.instantConsumptionTitle,
    required this.totalProductionKwh,
    required this.sharedEnergyKwh,
    required this.blockedCo2Kg,
    required this.totalEarningsTry,
    required this.sharedEnergyIconAssetPath,
    required this.blockedCo2IconAssetPath,
    required this.totalEarningsIconAssetPath,
    required this.instantProductionKwh,
    required this.instantConsumptionKwh,
    required this.chartTitle,
    required this.chartYAxisTicksKwh,
    required this.chartSlots,
    required this.chartLegendProductionLabel,
    required this.chartLegendConsumptionLabel,
    required this.houseImageAssetPath,
  });

  final String totalProductionSectionLabel;
  final String sharedEnergyTitle;
  final String blockedCo2Title;
  final String totalEarningsTitle;
  final String instantProductionTitle;
  final String instantConsumptionTitle;

  final double totalProductionKwh;

  final double sharedEnergyKwh;
  final double blockedCo2Kg;
  final double totalEarningsTry;
  final String sharedEnergyIconAssetPath;
  final String blockedCo2IconAssetPath;
  final String totalEarningsIconAssetPath;

  final double instantProductionKwh;
  final double instantConsumptionKwh;

  final String chartTitle;
  final List<double> chartYAxisTicksKwh;
  final List<ProducerChartSlot> chartSlots;

  final String chartLegendProductionLabel;
  final String chartLegendConsumptionLabel;

  final String houseImageAssetPath;

  /// Etiket ve görseller — kWh alanları [ProducerDashboardPredictionsMapper.merge] ile dolar.
  /// Jüri öncesi: ekran açılır açılmaz sahte anlık değer göstermemek için başlangıç modeli.
  static const ProducerDashboardModel shellLayout = ProducerDashboardModel(
    totalProductionSectionLabel: 'Toplam üretim',
    sharedEnergyTitle: 'Paylaşılan enerji',
    blockedCo2Title: 'Engellen CO2',
    totalEarningsTitle: 'Toplam kazanç',
    instantProductionTitle: 'Anlık üretim',
    instantConsumptionTitle: 'Anlık tüketim',
    totalProductionKwh: 0,
    sharedEnergyKwh: 0,
    blockedCo2Kg: 0,
    totalEarningsTry: 0,
    sharedEnergyIconAssetPath: 'assets/dashboard/icon1.svg',
    blockedCo2IconAssetPath: 'assets/dashboard/icon2.svg',
    totalEarningsIconAssetPath: 'assets/dashboard/icon3.svg',
    instantProductionKwh: 0,
    instantConsumptionKwh: 0,
    chartTitle: 'Bugünkü üretim grafiği',
    chartYAxisTicksKwh: [1.0, 0.5, 0.25],
    chartSlots: [],
    chartLegendProductionLabel: 'Anlık üretim',
    chartLegendConsumptionLabel: 'Anlık tüketim',
    // PNG: eski loadDemo ile aynı; devasa ev.svg bazı cihazlarda görünmez olabiliyor.
    houseImageAssetPath: 'assets/dashboard/ev_house.png',
  );
}

@immutable
class ProducerChartSlot {
  const ProducerChartSlot({
    required this.timeLabel,
    required this.timeLabelBold,
    required this.productionKwh,
    required this.consumptionKwh,
    this.productionTooltipKwh,
  });

  final String timeLabel;
  final bool timeLabelBold;
  final double productionKwh;
  final double consumptionKwh;

  /// Üretim sütununun üstünde balon için değer (kWh).
  final double? productionTooltipKwh;
}
