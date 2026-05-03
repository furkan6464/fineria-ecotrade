using EcoTrade.Api.Contracts;

namespace EcoTrade.Api.Services;

/// <summary>PostgreSQL üzerinden üretici panel / tüketim profili okur.</summary>
public interface IProducerPanelRepository
{
    Task<UserPanelRequestDto?> GetPanelForProducerAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
