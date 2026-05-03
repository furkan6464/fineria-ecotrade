using EcoTrade.Api.Contracts;

namespace EcoTrade.Api.Services;

public interface IPredictionService
{
    Task<LiveProductionResponse> GetLiveProductionAsync(
        CancellationToken cancellationToken = default);

    Task<ProducerForecastResponse> GetProducerForecastAsync(
        Guid producerUserId,
        CancellationToken cancellationToken = default);

    Task<AiRecommendationsResponse> GetAiRecommendationsAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
