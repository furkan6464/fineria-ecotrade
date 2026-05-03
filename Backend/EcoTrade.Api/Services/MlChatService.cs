using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using EcoTrade.Api.Contracts;
using EcoTrade.Api.Options;
using EcoTrade.Api.Serialization;
using Microsoft.Extensions.Options;

namespace EcoTrade.Api.Services;

/// <summary>Python <c>POST /ai/chat</c> → Flutter sohbet proxy.</summary>
public sealed class MlChatService : IMlChatService
{
    private readonly HttpClient _http;
    private readonly MlServiceOptions _options;
    private readonly ILogger<MlChatService> _log;

    public MlChatService(
        HttpClient http,
        IOptions<MlServiceOptions> options,
        ILogger<MlChatService> log)
    {
        _http = http;
        _options = options.Value;
        _log = log;
    }

    public async Task<string?> GetReplyAsync(string message, CancellationToken cancellationToken = default)
    {
        var path = _options.ChatPath.TrimStart('/');
        var json = JsonSerializer.Serialize(
            new AiChatApiRequest { Message = message },
            MlJsonSerializerOptions.Instance);
        using var content = new StringContent(json, Encoding.UTF8);
        content.Headers.ContentType = new MediaTypeHeaderValue("application/json")
        {
            CharSet = Encoding.UTF8.WebName,
        };

        try
        {
            using var response = await _http
                .PostAsync(path, content, cancellationToken)
                .ConfigureAwait(false);

            if (!response.IsSuccessStatusCode)
            {
                _log.LogWarning("ML chat HTTP {Code}", (int)response.StatusCode);
                return null;
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken)
                .ConfigureAwait(false);
            var dto = await JsonSerializer
                .DeserializeAsync<PyChatReply>(stream, MlJsonSerializerOptions.Instance, cancellationToken)
                .ConfigureAwait(false);

            return string.IsNullOrWhiteSpace(dto?.Reply) ? null : dto!.Reply!.Trim();
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex)
        {
            _log.LogWarning(ex, "ML chat isteği başarısız");
            return null;
        }
    }

    private sealed class PyChatReply
    {
        public string? Reply { get; set; }
    }
}
