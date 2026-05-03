class AiRecommendationsDto {
  const AiRecommendationsDto({
    required this.degraded,
    required this.recommendations,
    this.warning,
  });

  final bool degraded;
  final String? warning;
  final List<AiRecommendationItemDto> recommendations;

  factory AiRecommendationsDto.fromJson(Map<String, dynamic> json) {
    final raw = json['recommendations'] as List<dynamic>? ?? [];
    return AiRecommendationsDto(
      degraded: json['degraded'] as bool? ?? false,
      warning: json['warning'] as String?,
      recommendations: raw
          .map(
            (e) => AiRecommendationItemDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class AiRecommendationItemDto {
  const AiRecommendationItemDto({
    required this.kind,
    required this.title,
    required this.body,
    this.relatedHour,
  });

  final String kind;
  final String title;
  final String body;
  final String? relatedHour;

  factory AiRecommendationItemDto.fromJson(Map<String, dynamic> json) {
    return AiRecommendationItemDto(
      kind: json['kind'] as String? ?? 'productionWeather',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      relatedHour: json['relatedHour'] as String?,
    );
  }
}
