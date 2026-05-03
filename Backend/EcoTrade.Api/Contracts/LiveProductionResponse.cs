namespace EcoTrade.Api.Contracts;

/// <summary>Python <c>/predict/live</c> yanıtının C# karşılığı (Flutter’a açılır).</summary>
public sealed class LiveProductionResponse
{
    public bool Degraded { get; set; }
    public string? Warning { get; set; }

    public string Region { get; set; } = "Düzce";

    public double LiveProductionKwh { get; set; }

    public double PriceHintTryPerKwh { get; set; }

    public string? WeatherSummaryTr { get; set; }

    public string? RecommendationTr { get; set; }
}
