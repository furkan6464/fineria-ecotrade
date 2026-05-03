using EcoTrade.Api.Contracts;
using EcoTrade.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace EcoTrade.Api.Controllers;

/// <summary>Flutter AI sohbet → Python Groq (veya yedek metin).</summary>
[ApiController]
[Route("api/ai")]
public sealed class AiChatController : ControllerBase
{
    private readonly IMlChatService _chat;

    public AiChatController(IMlChatService chat)
    {
        _chat = chat;
    }

    [HttpPost("chat")]
    [ProducesResponseType(typeof(AiChatApiResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<AiChatApiResponse>> PostChat(
        [FromBody] AiChatApiRequest? body,
        CancellationToken cancellationToken)
    {
        var msg = body?.Message?.Trim() ?? "";
        if (msg.Length == 0)
            return BadRequest(new { error = "message alanı zorunludur." });

        var reply = await _chat
            .GetReplyAsync(msg, cancellationToken)
            .ConfigureAwait(false);

        return Ok(new AiChatApiResponse
        {
            Reply = string.IsNullOrEmpty(reply)
                ? "Şu an yapay zekâ yanıtı alınamadı; Python servisinin (8000) ve GROQ_API_KEY ortam değişkenini kontrol et."
                : reply,
        });
    }
}
