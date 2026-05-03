namespace EcoTrade.Api.Services;

/// <summary>Hackathon MVP: Python yerine anahtar kelimeye göre Türkçe mock asistan yanıtı.</summary>
public interface IHackathonChatService
{
    string BuildReply(string userMessage);
}
