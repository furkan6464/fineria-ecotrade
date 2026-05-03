import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/producer_exchange_chart_builder.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';

class ProducerExchangeController extends ChangeNotifier {
  ProducerExchangeModel? _model;
  ProducerExchangeModel? get model => _model;

  /// Referans şebeke tarifesi (₺/kWh) — demo / jüri karşılaştırması.
  static const double kDedasRefTlKwh = 2.65;

  /// Havuz anlık fiyat varsayılanı (₺/kWh); API geldiğinde `priceHint` ile güncellenir.
  static const double kDefaultPoolTlKwh = 2.10;

  static String advantageBadgeText(double dedasTlKwh, double poolTlKwh) {
    if (dedasTlKwh <= 0) return 'EcoTrade havuz fiyatı';
    final pct = ((dedasTlKwh - poolTlKwh) / dedasTlKwh * 100).floor().clamp(0, 99);
    if (pct <= 0) return 'DEDAŞ ile yakın';
    return 'DEDAŞ\'tan %$pct daha ucuz';
  }

  static bool advantagePositive(double dedasTlKwh, double poolTlKwh) =>
      poolTlKwh < dedasTlKwh;

  static String valuePropositionLineFor(double dedasTlKwh, double poolTlKwh) {
    final d = dedasTlKwh.toStringAsFixed(2).replaceAll('.', ',');
    final p = poolTlKwh.toStringAsFixed(2).replaceAll('.', ',');
    return 'Şebekeden (DEDAŞ) alırlarsa $d ₺/kWh öderler; bizim havuz sistemimizden alırlarsa $p ₺/kWh. Aradaki ~%20 fark değer önerimiz (value proposition).';
  }

  void loadDemo() {
    _model = ProducerExchangeModel(
      instantProductionSectionLabel: 'Anlık üretim (Düzce pilot)',
      instantProductionKwh: 4.2,
      dedasTariffLabel: 'Güncel DEDAŞ tarifesi',
      dedasTariffTryPerKwh: kDedasRefTlKwh,
      instantPriceSectionLabel: 'EcoTrade anlık havuz fiyatı',
      instantPriceTryPerKwh: kDefaultPoolTlKwh,
      valuePropositionLine: valuePropositionLineFor(
        kDedasRefTlKwh,
        kDefaultPoolTlKwh,
      ),
      priceAdvantageBadgeText: advantageBadgeText(
        kDedasRefTlKwh,
        kDefaultPoolTlKwh,
      ),
      priceAdvantagePositive: advantagePositive(
        kDedasRefTlKwh,
        kDefaultPoolTlKwh,
      ),
      priceChart: staticIntradayHavuzCurve(),
      salesSectionTitle: 'Satışını yönet',
      sellableEnergyLabel: 'Satılabilir enerjin:',
      sellableEnergyKwh: 2.4,
      automaticSellButtonLabel: '✨ Otomatik sat',
      manualSellButtonLabel: 'Manuel sat',
      automaticSellSelected: true,
      activeOfferSectionTitle: 'Aktif teklifin',
      activeOffer: ExchangeActiveOfferModel(
        energyKwh: 2.4,
        priceTryPerKwh: kDefaultPoolTlKwh,
        statusMessage: 'Alıcı bekleniyor...',
      ),
      recentTransactionsSectionTitle: 'Son işlemlerin',
      recentTransactions: const [
        ExchangeTransactionRow(
          counterpartyName: 'Ahmet',
          timeLabel: '13:42',
          energyKwh: 2.1,
          amountTry: 4.41,
          avatarInitial: 'A',
          avatarBackgroundArgb: 0xFFD4E4C4,
        ),
        ExchangeTransactionRow(
          counterpartyName: 'Fatma',
          timeLabel: '11:20',
          energyKwh: 1.0,
          amountTry: 2.10,
          avatarInitial: 'F',
          avatarBackgroundArgb: 0xFFE8E2D4,
        ),
      ],
    );
    notifyListeners();
  }

  void applyModel(ProducerExchangeModel next) {
    _model = next;
    notifyListeners();
  }

  void cancelActiveOffer() {
    final m = _model;
    if (m == null) return;
    _model = ProducerExchangeModel(
      instantProductionSectionLabel: m.instantProductionSectionLabel,
      instantProductionKwh: m.instantProductionKwh,
      dedasTariffLabel: m.dedasTariffLabel,
      dedasTariffTryPerKwh: m.dedasTariffTryPerKwh,
      instantPriceSectionLabel: m.instantPriceSectionLabel,
      instantPriceTryPerKwh: m.instantPriceTryPerKwh,
      valuePropositionLine: m.valuePropositionLine,
      priceAdvantageBadgeText: m.priceAdvantageBadgeText,
      priceAdvantagePositive: m.priceAdvantagePositive,
      priceChart: m.priceChart,
      salesSectionTitle: m.salesSectionTitle,
      sellableEnergyLabel: m.sellableEnergyLabel,
      sellableEnergyKwh: m.sellableEnergyKwh,
      automaticSellButtonLabel: m.automaticSellButtonLabel,
      manualSellButtonLabel: m.manualSellButtonLabel,
      automaticSellSelected: m.automaticSellSelected,
      activeOfferSectionTitle: m.activeOfferSectionTitle,
      activeOffer: null,
      recentTransactionsSectionTitle: m.recentTransactionsSectionTitle,
      recentTransactions: m.recentTransactions,
    );
    notifyListeners();
  }

  Future<void> hydrateFromApi(PredictionRepository repo) async {
    try {
      final live = await repo.fetchLive();
      final forecast = await repo.fetchProducerForecast();
      final m = _model;
      if (m == null) return;

      final chart = producerExchangeChartFromForecast(forecast);

      final sellable = math.max(0.2, live.liveProductionKwh * 0.52);
      final offer = m.activeOffer;

      final poolPrice = live.priceHintTryPerKwh;
      final dedas = m.dedasTariffTryPerKwh;

      _model = ProducerExchangeModel(
        instantProductionSectionLabel: m.instantProductionSectionLabel,
        instantProductionKwh: live.liveProductionKwh,
        dedasTariffLabel: m.dedasTariffLabel,
        dedasTariffTryPerKwh: dedas,
        instantPriceSectionLabel: m.instantPriceSectionLabel,
        instantPriceTryPerKwh: poolPrice,
        valuePropositionLine: valuePropositionLineFor(dedas, poolPrice),
        priceAdvantageBadgeText: advantageBadgeText(dedas, poolPrice),
        priceAdvantagePositive: advantagePositive(dedas, poolPrice),
        priceChart: chart,
        salesSectionTitle: m.salesSectionTitle,
        sellableEnergyLabel: m.sellableEnergyLabel,
        sellableEnergyKwh: sellable,
        automaticSellButtonLabel: m.automaticSellButtonLabel,
        manualSellButtonLabel: m.manualSellButtonLabel,
        automaticSellSelected: m.automaticSellSelected,
        activeOfferSectionTitle: m.activeOfferSectionTitle,
        activeOffer: offer == null
            ? null
            : ExchangeActiveOfferModel(
                energyKwh: sellable,
                priceTryPerKwh: live.priceHintTryPerKwh,
                statusMessage: offer.statusMessage,
              ),
        recentTransactionsSectionTitle: m.recentTransactionsSectionTitle,
        recentTransactions: m.recentTransactions,
      );
      notifyListeners();
    } catch (_) {
      // Ağ / parse: ilk paint’teki demo verisi kalır.
    }
  }

  void selectAutomaticSell() {
    _patchSalesMode(true);
  }

  void selectManualSell() {
    _patchSalesMode(false);
  }

  void _patchSalesMode(bool automatic) {
    final m = _model;
    if (m == null || m.automaticSellSelected == automatic) return;
    _model = ProducerExchangeModel(
      instantProductionSectionLabel: m.instantProductionSectionLabel,
      instantProductionKwh: m.instantProductionKwh,
      dedasTariffLabel: m.dedasTariffLabel,
      dedasTariffTryPerKwh: m.dedasTariffTryPerKwh,
      instantPriceSectionLabel: m.instantPriceSectionLabel,
      instantPriceTryPerKwh: m.instantPriceTryPerKwh,
      valuePropositionLine: m.valuePropositionLine,
      priceAdvantageBadgeText: m.priceAdvantageBadgeText,
      priceAdvantagePositive: m.priceAdvantagePositive,
      priceChart: m.priceChart,
      salesSectionTitle: m.salesSectionTitle,
      sellableEnergyLabel: m.sellableEnergyLabel,
      sellableEnergyKwh: m.sellableEnergyKwh,
      automaticSellButtonLabel: m.automaticSellButtonLabel,
      manualSellButtonLabel: m.manualSellButtonLabel,
      automaticSellSelected: automatic,
      activeOfferSectionTitle: m.activeOfferSectionTitle,
      activeOffer: m.activeOffer,
      recentTransactionsSectionTitle: m.recentTransactionsSectionTitle,
      recentTransactions: m.recentTransactions,
    );
    notifyListeners();
  }
}
