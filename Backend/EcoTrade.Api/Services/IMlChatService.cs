namespace EcoTrade.Api.Services;

public interface IMlChatService
{
    Task<string?> GetReplyAsync(string message, CancellationToken cancellationToken = default);
}
