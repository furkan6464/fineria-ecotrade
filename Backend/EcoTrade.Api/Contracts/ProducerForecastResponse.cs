namespace EcoTrade.Api.Contracts;

public sealed class ProducerForecastResponse
{
    public bool Degraded { get; set; }
    public string? Warning { get; set; }

    /// <summary>Fazla enerji (satılabilir) en yüksek olan saat (HH:mm).</summary>
    public string? BestSellHour { get; set; }

    public double? BestSellHourSurplusKwh { get; set; }

    public IReadOnlyList<HourlyForecastPoint> Next6Hours { get; set; } =
        Array.Empty<HourlyForecastPoint>();
}

public sealed class HourlyForecastPoint
{
    public string Hour { get; set; } = "";
    public double ProductionKwh { get; set; }
    public double ConsumptionKwh { get; set; }
    public double SurplusKwh { get; set; }
    public int CloudCoverPercent { get; set; }

    /// <summary>Mahalle / P2P fiyat ipucu (Python serisinden).</summary>
    public double? PriceTryPerKwh { get; set; }
}
