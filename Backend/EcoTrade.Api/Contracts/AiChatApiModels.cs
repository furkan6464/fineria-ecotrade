namespace EcoTrade.Api.Contracts;

public sealed class AiChatApiRequest
{
    public string? Message { get; set; }
}

public sealed class AiChatApiResponse
{
    public string Reply { get; set; } = "";
}
