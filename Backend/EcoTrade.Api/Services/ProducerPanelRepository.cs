using EcoTrade.Api.Contracts;
using Npgsql;

namespace EcoTrade.Api.Services;

/// <summary>
/// Beklenen tablo (örnek şema — migration sizin sorumluluğunuzda):
/// <code>
/// CREATE TABLE producer_sites (
///   user_id UUID PRIMARY KEY,
///   lat DOUBLE PRECISION NOT NULL,
///   lon DOUBLE PRECISION NOT NULL,
///   panel_kwp DOUBLE PRECISION NOT NULL,
///   azimuth_deg DOUBLE PRECISION NOT NULL,
///   tilt_deg DOUBLE PRECISION NOT NULL,
///   shading VARCHAR(20) NOT NULL,
///   inverter_efficiency DOUBLE PRECISION NOT NULL,
///   num_people INT NOT NULL,
///   has_ev BOOLEAN NOT NULL DEFAULT FALSE,
///   has_heat_pump BOOLEAN NOT NULL DEFAULT FALSE
/// );
/// </code>
/// Geçmiş tüketim kWh ayrı tabloda tutuluyorsa, bu repository içinde bir view veya ek sorgu ile
/// <see cref="UserPanelRequestDto"/> alanlarına özet değer yansıtılmalıdır.
/// </summary>
public sealed class ProducerPanelRepository : IProducerPanelRepository
{
    private readonly string _connectionString;

    public ProducerPanelRepository(string connectionString)
    {
        _connectionString = connectionString
            ?? throw new ArgumentNullException(nameof(connectionString));
    }

    public async Task<UserPanelRequestDto?> GetPanelForProducerAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);

        const string sql = """
            SELECT lat, lon, panel_kwp, azimuth_deg, tilt_deg, shading, inverter_efficiency,
                   num_people, has_ev, has_heat_pump
            FROM producer_sites
            WHERE user_id = @uid
            """;

        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("uid", userId);

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
            return null;

        return new UserPanelRequestDto
        {
            Lat = reader.GetDouble(0),
            Lon = reader.GetDouble(1),
            PanelKwp = reader.GetDouble(2),
            AzimuthDeg = reader.GetDouble(3),
            TiltDeg = reader.GetDouble(4),
            Shading = reader.GetString(5),
            InverterEfficiency = reader.GetDouble(6),
            NumPeople = reader.GetInt32(7),
            HasEv = reader.GetBoolean(8),
            HasHeatPump = reader.GetBoolean(9),
        };
    }
}
