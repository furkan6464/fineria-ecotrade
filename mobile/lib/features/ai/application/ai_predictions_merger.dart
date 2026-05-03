import 'package:intl/intl.dart';
import 'package:mobile/features/ai/domain/ai_assistant_model.dart';
import 'package:mobile/features/predictions/data/ai_recommendations_dto.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

abstract final class AiPredictionsMerger {
  static final NumberFormat _dec = NumberFormat.decimalPattern('tr_TR');

  static RecommendationVisualKind kindFromApi(String? k) {
    if (k == 'consumptionDemand') {
      return RecommendationVisualKind.consumptionDemand;
    }
    return RecommendationVisualKind.productionWeather;
  }

  /// C# tavsiye listesi varsa öncelik; yoksa canlı + forecast’tan üret.
  static List<RecommendationModel> buildRecommendations({
    required LiveProductionDto live,
    required ProducerForecastDto forecast,
    AiRecommendationsDto? fromApi,
  }) {
    if (fromApi != null &&
        fromApi.recommendations.isNotEmpty &&
        fromApi.recommendations.any((e) => e.body.trim().isNotEmpty)) {
      return fromApi.recommendations
          .where((e) => e.body.trim().isNotEmpty)
          .map(
            (e) => RecommendationModel(
              kind: kindFromApi(e.kind),
              title: e.title.trim().isEmpty ? 'Tavsiye' : e.title.trim(),
              body: e.body.trim(),
            ),
          )
          .take(6)
          .toList();
    }

    final out = <RecommendationModel>[];

    final region = live.region?.trim();
    final regionBit = region != null && region.isNotEmpty
        ? '$region pilot: '
        : 'Düzce pilot: ';

    final w = live.weatherSummaryTr?.trim();
    if (w != null && w.isNotEmpty) {
      out.add(
        RecommendationModel(
          kind: RecommendationVisualKind.productionWeather,
          title: 'Hava ve üretim özeti',
          body:
              '$regionBit$w Anlık tahmini üretim: ${_dec.format(live.liveProductionKwh)} kWh.',
        ),
      );
    }

    final r = live.recommendationTr?.trim();
    if (r != null && r.isNotEmpty) {
      out.add(
        RecommendationModel(
          kind: RecommendationVisualKind.consumptionDemand,
          title: 'Kişiselleştirilmiş öneri',
          body: r,
        ),
      );
    }

    final best = forecast.bestSellHour?.trim();
    if (best != null && best.isNotEmpty) {
      out.add(
        RecommendationModel(
          kind: RecommendationVisualKind.productionWeather,
          title: 'Satış saati',
          body:
              'Tahmini en iyi satış penceresi: $best. Fiyat ipucu: ${_dec.format(live.priceHintTryPerKwh)} ₺/kWh.',
        ),
      );
    }

    if (out.isEmpty) {
      return const [
        RecommendationModel(
          kind: RecommendationVisualKind.productionWeather,
          title: 'Pilot bölge',
          body:
              'Düzce meteoroloji simülasyonu bağlandığında burada günlük öneriler görünecek.',
        ),
      ];
    }

    return out;
  }

  static String welcomeBodyFromLive(LiveProductionDto live) {
    final w = live.weatherSummaryTr?.trim();
    final base = w != null && w.isNotEmpty
        ? w
        : 'Pilot bölge verilerini senin için özetliyorum.';
    return '$base Anlık üretim: ${_dec.format(live.liveProductionKwh)} kWh · ${_dec.format(live.priceHintTryPerKwh)} ₺/kWh.';
  }

  static List<ChatMessageModel> seedChatAfterHydrate(LiveProductionDto live) {
    final rec = live.recommendationTr?.trim();
    final kwh = _dec.format(live.liveProductionKwh);
    final text = rec != null && rec.isNotEmpty
        ? '$rec (Anlık üretim: $kwh kWh.)'
        : 'Öne çıkan tavsiyeler kartları güncellendi. Anlık üretim tahmini: $kwh kWh. Sorularını aşağıdan yazabilirsin.';
    return [ChatMessageModel(isUser: false, text: text)];
  }
}
