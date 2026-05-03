using EcoTrade.Api.Contracts;
using EcoTrade.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace EcoTrade.Api.Controllers;

/// <summary>Flutter ve diğer istemciler için ML tabanlı tahmin uçları.</summary>
[ApiController]
[Route("api/predictions")]
public sealed class PredictionController : ControllerBase
{
    private readonly IPredictionService _prediction;
    private readonly IHackathonChatService _hackathonChat;

    public PredictionController(
        IPredictionService prediction,
        IHackathonChatService hackathonChat)
    {
        _prediction = prediction;
        _hackathonChat = hackathonChat;
    }

    /// <summary>Düzce pilotu anlık üretim simülasyonu (Python MVP). Her durumda 200 + gövde.</summary>
    [HttpGet("live")]
    [ProducesResponseType(typeof(LiveProductionResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<LiveProductionResponse>> GetLive(
        CancellationToken cancellationToken)
    {
        var result = await _prediction
            .GetLiveProductionAsync(cancellationToken)
            .ConfigureAwait(false);
        return Ok(result);
    }

    /// <summary>Gelecek 6 saat üretim/tüketim/fazla eğrisi ve en iyi satış saati (Python GET /predict/forecast).</summary>
    [HttpGet("producer-forecast")]
    [ProducesResponseType(typeof(ProducerForecastResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<ProducerForecastResponse>> GetProducerForecast(
        [FromQuery] Guid? userId,
        CancellationToken cancellationToken)
    {
        var result = await _prediction
            .GetProducerForecastAsync(userId ?? Guid.Empty, cancellationToken)
            .ConfigureAwait(false);

        return Ok(result);
    }

    /// <summary>
    /// Python <c>/analyze</c> çıktısındaki <c>ai_tavsiyeleri</c> listesi (proaktif metinler).
    /// Şu an panel verisi <c>producer_sites</c> üzerinden okunur; tüketici profili için repository genişletilmelidir.
    /// </summary>
    [HttpGet("ai-recommendations")]
    [ProducesResponseType(typeof(AiRecommendationsResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<AiRecommendationsResponse>> GetAiRecommendations(
        [FromQuery] Guid userId,
        CancellationToken cancellationToken)
    {
        if (userId == Guid.Empty)
            return BadRequest(new { error = "userId (query) zorunludur ve boş olamaz." });

        var result = await _prediction
            .GetAiRecommendationsAsync(userId, cancellationToken)
            .ConfigureAwait(false);

        return Ok(result);
    }

    /// <summary>Hackathon MVP sohbet — Python yok; anahtar kelimeye göre mock Türkçe yanıt.</summary>
    [HttpPost("chat")]
    [ProducesResponseType(typeof(AiChatApiResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public ActionResult<AiChatApiResponse> PostHackathonChat([FromBody] AiChatApiRequest? body)
    {
        var msg = body?.Message?.Trim() ?? "";
        if (msg.Length == 0)
            return BadRequest(new { error = "message alanı zorunludur." });

        var reply = _hackathonChat.BuildReply(msg);
        return Ok(new AiChatApiResponse { Reply = reply });
    }
}
