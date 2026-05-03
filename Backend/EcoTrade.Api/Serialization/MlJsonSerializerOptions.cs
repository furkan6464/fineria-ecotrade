using System.Text.Json;
using System.Text.Json.Serialization;

namespace EcoTrade.Api.Serialization;

/// <summary>Python FastAPI gövdeleri snake_case; System.Text.Json ile hizalama.</summary>
public static class MlJsonSerializerOptions
{
    public static JsonSerializerOptions Instance { get; } = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        PropertyNameCaseInsensitive = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
    };
}
