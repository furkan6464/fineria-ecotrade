import 'package:flutter/foundation.dart';

/// Borsa (üretici) ekranı — C# API yanıtına karşılık gelen taslak model.
@immutable
class ProducerExchangeModel {
  const ProducerExchangeModel({
    required this.instantProductionSectionLabel,
    required this.instantProductionKwh,
    required this.dedasTariffLabel,
    required this.dedasTariffTryPerKwh,
    required this.instantPriceSectionLabel,
    required this.instantPriceTryPerKwh,
    required this.valuePropositionLine,
    required this.priceAdvantageBadgeText,
    required this.priceAdvantagePositive,
    required this.priceChart,
    required this.salesSectionTitle,
    required this.sellableEnergyLabel,
    required this.sellableEnergyKwh,
    required this.automaticSellButtonLabel,
    required this.manualSellButtonLabel,
    required this.automaticSellSelected,
    required this.activeOfferSectionTitle,
    required this.activeOffer,
    required this.recentTransactionsSectionTitle,
    required this.recentTransactions,
  });

  final String instantProductionSectionLabel;
  final double instantProductionKwh;

  /// Şebeke referansı (ör. güncel DEDAŞ tarifesi).
  final String dedasTariffLabel;
  final double dedasTariffTryPerKwh;

  final String instantPriceSectionLabel;
  final double instantPriceTryPerKwh;

  /// Jüri / kullanıcı için kısa değer önerisi metni.
  final String valuePropositionLine;

  /// Örn. "DEDAŞ'tan %20 daha ucuz"
  final String priceAdvantageBadgeText;
  final bool priceAdvantagePositive;

  final ExchangePriceChartModel priceChart;

  final String salesSectionTitle;
  final String sellableEnergyLabel;
  final double sellableEnergyKwh;

  final String automaticSellButtonLabel;
  final String manualSellButtonLabel;
  final bool automaticSellSelected;

  final String activeOfferSectionTitle;
  final ExchangeActiveOfferModel? activeOffer;

  final String recentTransactionsSectionTitle;
  final List<ExchangeTransactionRow> recentTransactions;
}

@immutable
class ExchangePriceChartModel {
  const ExchangePriceChartModel({
    required this.linePointsNormalized,
    required this.xAxisTicks,
    required this.peakNormalizedX,
    required this.peakTooltipText,
  });

  /// Grafik alanı içinde 0–1 normalize çizgi noktaları (x soldan sağa, y alttan üste).
  final List<ExchangeChartPoint> linePointsNormalized;

  final List<ExchangeChartXTick> xAxisTicks;

  /// Tepe noktasının x konumu (0–1).
  final double peakNormalizedX;

  final String peakTooltipText;
}

@immutable
class ExchangeChartPoint {
  const ExchangeChartPoint(this.x, this.y);

  final double x;
  final double y;
}

@immutable
class ExchangeChartXTick {
  const ExchangeChartXTick({
    required this.label,
    required this.positionNormalizedX,
    required this.emphasized,
  });

  final String label;
  final double positionNormalizedX;
  final bool emphasized;
}

@immutable
class ExchangeActiveOfferModel {
  const ExchangeActiveOfferModel({
    required this.energyKwh,
    required this.priceTryPerKwh,
    required this.statusMessage,
  });

  final double energyKwh;
  final double priceTryPerKwh;
  final String statusMessage;
}

@immutable
class ExchangeTransactionRow {
  const ExchangeTransactionRow({
    required this.counterpartyName,
    required this.timeLabel,
    required this.energyKwh,
    required this.amountTry,
    required this.avatarInitial,
    required this.avatarBackgroundArgb,
  });

  final String counterpartyName;
  final String timeLabel;
  final double energyKwh;
  final double amountTry;
  final String avatarInitial;

  /// `Color(avatarBackgroundArgb)` — API veya sunucu atanır.
  final int avatarBackgroundArgb;
}
