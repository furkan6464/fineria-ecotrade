using System.Text;
using System.Text.Json;
using EcoTrade.Api.Contracts;
using EcoTrade.Api.Options;
using EcoTrade.Api.Serialization;
using Microsoft.Extensions.Options;

namespace EcoTrade.Api.Services;

/// <summary>
/// Python FastAPI MVP ile konuşur. Ağ/JSON/timeout durumunda asla exception yüzeye çıkmaz;
/// jüri demosu için anlamlı statik fallback döner.
/// </summary>
public sealed class PredictionService : IPredictionService
{
    public const double FallbackLiveKwh = 3.8;
    public const double FallbackPriceHint = 2.10;

    private readonly HttpClient _http;
    private readonly IProducerPanelRepository _panels;
    private readonly MlServiceOptions _options;
    private readonly ILogger<PredictionService> _log;

    public PredictionService(
        HttpClient http,
        IProducerPanelRepository panels,
        IOptions<MlServiceOptions> options,
        ILogger<PredictionService> log)
    {
        _http = http;
        _panels = panels;
        _options = options.Value;
        _log = log;
    }

    public async Task<LiveProductionResponse> GetLiveProductionAsync(
        CancellationToken cancellationToken = default)
    {
        try
        {
            var path = _options.LivePath.TrimStart('/');
            using var response = await _http
                .GetAsync(path, cancellationToken)
                .ConfigureAwait(false);

            if (!response.IsSuccessStatusCode)
            {
                _log.LogWarning("ML live HTTP {Code}", (int)response.StatusCode);
                return BuildFallbackLive("Tahmin servisi geçici olarak yanıt vermedi.");
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken)
                .ConfigureAwait(false);
            var dto = await JsonSerializer
                .DeserializeAsync<PyLiveResponse>(stream, MlJsonSerializerOptions.Instance, cancellationToken)
                .ConfigureAwait(false);

            if (dto is null || dto.LiveProductionKwh <= 0)
            {
                return BuildFallbackLive("Tahmin yanıtı geçersiz.");
            }

            return new LiveProductionResponse
            {
                Degraded = false,
                Region = dto.Region ?? "Düzce",
                LiveProductionKwh = dto.LiveProductionKwh,
                PriceHintTryPerKwh = dto.PriceHintTlPerKwh > 0
                    ? dto.PriceHintTlPerKwh
                    : FallbackPriceHint,
                WeatherSummaryTr = dto.WeatherSummaryTr,
                RecommendationTr = dto.RecommendationTr,
            };
        }
        catch (OperationCanceledException ex)
        {
            _log.LogWarning(ex, "ML live iptal/zaman aşımı");
            return BuildFallbackLive("Tahmin servisi zaman aşımına uğradı.");
        }
        catch (HttpRequestException ex)
        {
            _log.LogWarning(ex, "ML live HTTP hatası");
            return BuildFallbackLive("Tahmin servisine ulaşılamadı.");
        }
        catch (JsonException ex)
        {
            _log.LogWarning(ex, "ML live JSON çözümleme");
            return BuildFallbackLive("Tahmin yanıtı okunamadı.");
        }
        catch (Exception ex)
        {
            _log.LogError(ex, "ML live beklenmeyen hata");
            return BuildFallbackLive("Tahmin alınamadı.");
        }
    }

    public async Task<ProducerForecastResponse> GetProducerForecastAsync(
        Guid producerUserId,
        CancellationToken cancellationToken = default)
    {
        _ = producerUserId;

        try
        {
            var path = _options.ForecastPath.TrimStart('/');
            using var response = await _http
                .GetAsync(path, cancellationToken)
                .ConfigureAwait(false);

            if (!response.IsSuccessStatusCode)
            {
                _log.LogWarning("ML forecast HTTP {Code}", (int)response.StatusCode);
                return BuildFallbackForecast("Tahmin servisi geçici olarak yanıt vermedi.");
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken)
                .ConfigureAwait(false);
            var dto = await JsonSerializer
                .DeserializeAsync<PyForecastResponse>(stream, MlJsonSerializerOptions.Instance, cancellationToken)
                .ConfigureAwait(false);

            if (dto?.Series is null || dto.Series.Count == 0)
            {
                return BuildFallbackForecast("Tahmin listesi boş.");
            }

            var points = new List<HourlyForecastPoint>();
            foreach (var row in dto.Series)
            {
                var prod = row.ProductionKwh;
                var cons = Math.Round(prod * 0.32, 3);
                points.Add(new HourlyForecastPoint
                {
                    Hour = row.Hour ?? "",
                    ProductionKwh = prod,
                    ConsumptionKwh = cons,
                    SurplusKwh = Math.Round(prod - cons, 3),
                    CloudCoverPercent = 0,
                    PriceTryPerKwh = row.PriceTlKwh > 0 ? row.PriceTlKwh : null,
                });
            }

            var bestHour = dto.BestSellHour;
            var best = points.OrderByDescending(p => p.SurplusKwh).FirstOrDefault();
            if (string.IsNullOrWhiteSpace(bestHour) && best != null)
                bestHour = best.Hour;

            return new ProducerForecastResponse
            {
                Degraded = false,
                BestSellHour = bestHour ?? "15:00",
                BestSellHourSurplusKwh = best?.SurplusKwh,
                Next6Hours = points,
            };
        }
        catch (OperationCanceledException ex)
        {
            _log.LogWarning(ex, "ML forecast iptal/zaman aşımı");
            return BuildFallbackForecast("Tahmin servisi zaman aşımına uğradı.");
        }
        catch (HttpRequestException ex)
        {
            _log.LogWarning(ex, "ML forecast HTTP hatası");
            return BuildFallbackForecast("Tahmin servisine ulaşılamadı.");
        }
        catch (JsonException ex)
        {
            _log.LogWarning(ex, "ML forecast JSON çözümleme");
            return BuildFallbackForecast("Tahmin yanıtı okunamadı.");
        }
        catch (Exception ex)
        {
            _log.LogError(ex, "ML forecast beklenmeyen hata");
            return BuildFallbackForecast("Tahmin alınamadı.");
        }
    }

    public async Task<AiRecommendationsResponse> GetAiRecommendationsAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var fallback = new AiRecommendationsResponse
        {
            Degraded = true,
            Warning = "Tavsiyeler alınamadı.",
            Recommendations = Array.Empty<AiRecommendationItem>(),
        };

        UserPanelRequestDto? panel = null;
        try
        {
            panel = await _panels.GetPanelForProducerAsync(userId, cancellationToken);
        }
        catch (Exception ex)
        {
            _log.LogWarning(ex, "PostgreSQL panel okunamadı (AI); demo panel. UserId={UserId}", userId);
        }

        panel ??= DemoProducerPanel.Default;

        try
        {
            var recs = await PostAnalyzeAsync(panel, cancellationToken).ConfigureAwait(false);
            return new AiRecommendationsResponse
            {
                Degraded = false,
                Recommendations = recs,
            };
        }
        catch (OperationCanceledException ex)
        {
            _log.LogWarning(ex, "ML analyze zaman aşımı. UserId={UserId}", userId);
            fallback.Warning = "Tavsiye servisi zaman aşımına uğradı.";
            return fallback;
        }
        catch (HttpRequestException ex)
        {
            _log.LogWarning(ex, "ML analyze HTTP. UserId={UserId}", userId);
            fallback.Warning = "Tavsiye servisine ulaşılamadı.";
            return fallback;
        }
        catch (JsonException ex)
        {
            _log.LogWarning(ex, "ML analyze JSON. UserId={UserId}", userId);
            fallback.Warning = "Tavsiye yanıtı beklenen formatta değil.";
            return fallback;
        }
        catch (Exception ex)
        {
            _log.LogError(ex, "ML analyze beklenmeyen. UserId={UserId}", userId);
            fallback.Warning = "Tavsiye sırasında hata oluştu.";
            return fallback;
        }
    }

    private static LiveProductionResponse BuildFallbackLive(string? warning) =>
        new()
        {
            Degraded = true,
            Warning = warning,
            Region = "Düzce",
            LiveProductionKwh = FallbackLiveKwh,
            PriceHintTryPerKwh = FallbackPriceHint,
            WeatherSummaryTr =
                "Pilot bölge Düzce için gösterge değeri kullanılıyor; ML servisi bağlandığında canlı simülasyon gelir.",
        };

    private static ProducerForecastResponse BuildFallbackForecast(string? warning)
    {
        var hours = new[] { "12:00", "13:00", "14:00", "15:00", "16:00", "17:00" };
        var list = hours.Select(h => new HourlyForecastPoint
            {
                Hour = h,
                ProductionKwh = FallbackLiveKwh,
                ConsumptionKwh = 1.2,
                SurplusKwh = Math.Round(FallbackLiveKwh - 1.2, 3),
                CloudCoverPercent = 35,
                PriceTryPerKwh = FallbackPriceHint,
            })
            .ToList();

        return new ProducerForecastResponse
        {
            Degraded = true,
            Warning = warning,
            BestSellHour = "15:00",
            BestSellHourSurplusKwh = list.Max(p => p.SurplusKwh),
            Next6Hours = list,
        };
    }

    private async Task<IReadOnlyList<AiRecommendationItem>> PostAnalyzeAsync(
        UserPanelRequestDto panel,
        CancellationToken cancellationToken)
    {
        var path = _options.AnalyzePath.TrimStart('/');
        using var content = new StringContent(
            JsonSerializer.Serialize(panel, MlJsonSerializerOptions.Instance),
            Encoding.UTF8,
            "application/json");

        using var response = await _http
            .PostAsync(path, content, cancellationToken)
            .ConfigureAwait(false);

        response.EnsureSuccessStatusCode();
        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken)
            .ConfigureAwait(false);

        var analyze = await JsonSerializer.DeserializeAsync<MlAnalyzeEnvelope>(
                stream,
                MlJsonSerializerOptions.Instance,
                cancellationToken)
            .ConfigureAwait(false);

        var raw = analyze?.AiTavsiyeleri;
        if (raw is null || raw.Count == 0)
            return Array.Empty<AiRecommendationItem>();

        var list = new List<AiRecommendationItem>();
        for (var i = 0; i < raw.Count; i++)
        {
            var row = raw[i];
            var mesaj = row.Mesaj?.Trim() ?? "";
            if (mesaj.Length == 0)
                continue;

            list.Add(new AiRecommendationItem
            {
                Kind = i % 2 == 0 ? "productionWeather" : "consumptionDemand",
                Title = BuildTitle(row.Saat, mesaj),
                Body = mesaj,
                RelatedHour = row.Saat,
            });
        }

        return list;
    }

    private static string BuildTitle(string? hour, string mesaj)
    {
        var h = string.IsNullOrWhiteSpace(hour) ? "" : hour.Trim();
        var dot = mesaj.IndexOf('.');
        string firstSentence;
        if (dot > 0 && dot < mesaj.Length - 1)
            firstSentence = mesaj[..(dot + 1)].Trim();
        else
            firstSentence = mesaj.Length <= 72 ? mesaj : mesaj[..72].TrimEnd() + "…";

        if (firstSentence.Length > 0 && firstSentence.Length <= 72)
            return firstSentence;
        if (h.Length > 0)
            return $"Saat {h}";
        return "Tavsiye";
    }

    private sealed class PyLiveResponse
    {
        public string? Region { get; set; }
        public double LiveProductionKwh { get; set; }
        public double PriceHintTlPerKwh { get; set; }
        public string? WeatherSummaryTr { get; set; }
        public string? RecommendationTr { get; set; }
    }

    private sealed class PyForecastResponse
    {
        public string? Region { get; set; }
        public string? BestSellHour { get; set; }
        public List<PyForecastHour>? Series { get; set; }
    }

    private sealed class PyForecastHour
    {
        public string? Hour { get; set; }
        public double ProductionKwh { get; set; }
        public double PriceTlKwh { get; set; }
    }

    private sealed class MlAnalyzeEnvelope
    {
        public List<MlTavsiyeRow>? AiTavsiyeleri { get; set; }
    }

    private sealed class MlTavsiyeRow
    {
        public string? Saat { get; set; }
        public string? Mesaj { get; set; }
    }
}
