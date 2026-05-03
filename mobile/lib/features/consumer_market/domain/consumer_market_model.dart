import 'package:flutter/foundation.dart';

@immutable
class ConsumerMarketModel {
  const ConsumerMarketModel({
    required this.poolRateTitle,
    required this.poolRateTryPerKwh,
    required this.poolRateTrendLabel,
    required this.poolRateTrendDownward,
    required this.priceSparkline,
    required this.poolStatusSectionTitle,
    required this.poolStatusHeadline,
    required this.poolStatusDetail,
    required this.supplyKwh,
    required this.demandKwh,
    required this.supplyLabel,
    required this.demandLabel,
    required this.strategySectionTitle,
    required this.strategyAutoTitle,
    required this.strategyAutoDescription,
    required this.strategyGridOnlyTitle,
    required this.strategyGridOnlyDescription,
    required this.autoStrategySelected,
    required this.recentSettlementsSectionTitle,
    required this.recentSettlements,
  });

  final String poolRateTitle;
  final double poolRateTryPerKwh;
  final String poolRateTrendLabel;
  final bool poolRateTrendDownward;

  /// Fiyat eğrisi (tahmin saatlerinin priceTryPerKwh).
  final List<double> priceSparkline;

  final String poolStatusSectionTitle;
  final String poolStatusHeadline;
  final String poolStatusDetail;
  final double supplyKwh;
  final double demandKwh;
  final String supplyLabel;
  final String demandLabel;

  final String strategySectionTitle;
  final String strategyAutoTitle;
  final String strategyAutoDescription;
  final String strategyGridOnlyTitle;
  final String strategyGridOnlyDescription;
  final bool autoStrategySelected;

  final String recentSettlementsSectionTitle;
  final List<ConsumerSettlementRow> recentSettlements;
}

@immutable
class ConsumerSettlementRow {
  const ConsumerSettlementRow({
    required this.title,
    required this.subtitle,
    required this.amountTry,
  });

  final String title;
  final String subtitle;
  final double amountTry;
}
