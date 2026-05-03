class LiveProductionDto {
  const LiveProductionDto({
    required this.degraded,
    required this.liveProductionKwh,
    required this.priceHintTryPerKwh,
    this.warning,
    this.region,
    this.weatherSummaryTr,
    this.recommendationTr,
  });

  final bool degraded;
  final double liveProductionKwh;
  final double priceHintTryPerKwh;
  final String? warning;
  final String? region;
  final String? weatherSummaryTr;
  final String? recommendationTr;

  static LiveProductionDto fallback() => const LiveProductionDto(
    degraded: true,
    liveProductionKwh: 3.8,
    priceHintTryPerKwh: 2.10,
  );

  factory LiveProductionDto.fromJson(Map<String, dynamic> json) {
    return LiveProductionDto(
      degraded: json['degraded'] as bool? ?? false,
      liveProductionKwh: (json['liveProductionKwh'] as num?)?.toDouble() ?? 3.8,
      priceHintTryPerKwh:
          (json['priceHintTryPerKwh'] as num?)?.toDouble() ?? 2.10,
      warning: json['warning'] as String?,
      region: json['region'] as String?,
      weatherSummaryTr: json['weatherSummaryTr'] as String?,
      recommendationTr: json['recommendationTr'] as String?,
    );
  }
}

class ForecastHourPointDto {
  const ForecastHourPointDto({
    required this.hour,
    required this.productionKwh,
    required this.surplusKwh,
    this.priceTryPerKwh,
  });

  final String hour;
  final double productionKwh;
  final double surplusKwh;
  final double? priceTryPerKwh;

  factory ForecastHourPointDto.fromJson(Map<String, dynamic> json) {
    return ForecastHourPointDto(
      hour: json['hour'] as String? ?? '',
      productionKwh: (json['productionKwh'] as num?)?.toDouble() ?? 0,
      surplusKwh: (json['surplusKwh'] as num?)?.toDouble() ?? 0,
      priceTryPerKwh: (json['priceTryPerKwh'] as num?)?.toDouble(),
    );
  }
}

class ProducerForecastDto {
  const ProducerForecastDto({
    required this.degraded,
    required this.next6Hours,
    this.warning,
    this.bestSellHour,
    this.bestSellHourSurplusKwh,
  });

  final bool degraded;
  final String? warning;
  final String? bestSellHour;
  final double? bestSellHourSurplusKwh;
  final List<ForecastHourPointDto> next6Hours;

  static ProducerForecastDto empty() =>
      const ProducerForecastDto(degraded: true, next6Hours: []);

  factory ProducerForecastDto.fromJson(Map<String, dynamic> json) {
    final raw = json['next6Hours'] as List<dynamic>? ?? [];
    return ProducerForecastDto(
      degraded: json['degraded'] as bool? ?? false,
      warning: json['warning'] as String?,
      bestSellHour: json['bestSellHour'] as String?,
      bestSellHourSurplusKwh: (json['bestSellHourSurplusKwh'] as num?)
          ?.toDouble(),
      next6Hours: raw
          .map(
            (e) => ForecastHourPointDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}
