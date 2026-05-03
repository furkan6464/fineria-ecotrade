namespace EcoTrade.Api.Options;

public sealed class MlServiceOptions
{
    public const string SectionName = "MlService";

    /// <summary>Örn. http://127.0.0.1:8001 (uvicorn)</summary>
    public string BaseUrl { get; set; } = "http://127.0.0.1:8001";

    public int TimeoutSeconds { get; set; } = 20;

    /// <summary>GET — anlık üretim simülasyonu.</summary>
    public string LivePath { get; set; } = "/predict/live";

    /// <summary>GET — gelecek 6 saat üretim + fiyat serisi.</summary>
    public string ForecastPath { get; set; } = "/predict/forecast";

    /// <summary>Eski tam analiz (opsiyonel, AI tavsiyeleri için).</summary>
    public string AnalyzePath { get; set; } = "/analyze";

    /// <summary>POST — Groq sohbet (Flutter).</summary>
    public string ChatPath { get; set; } = "/ai/chat";
}
