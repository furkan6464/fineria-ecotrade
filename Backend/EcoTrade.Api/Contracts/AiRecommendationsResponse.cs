namespace EcoTrade.Api.Contracts;

public sealed class AiRecommendationsResponse
{
    public bool Degraded { get; set; }
    public string? Warning { get; set; }

    /// <summary>Flutter <c>RecommendationModel</c> ile uyumlu öğeler.</summary>
    public IReadOnlyList<AiRecommendationItem> Recommendations { get; set; } =
        Array.Empty<AiRecommendationItem>();
}

public sealed class AiRecommendationItem
{
    /// <summary>productionWeather | consumptionDemand</summary>
    public string Kind { get; set; } = "productionWeather";

    public string Title { get; set; } = "";
    public string Body { get; set; } = "";

    /// <summary>Kaynak saat (ML tavsiye satırından), isteğe bağlı.</summary>
    public string? RelatedHour { get; set; }
}
