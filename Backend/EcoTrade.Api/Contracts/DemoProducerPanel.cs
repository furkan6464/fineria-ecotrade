namespace EcoTrade.Api.Contracts;

/// <summary>PostgreSQL'de panel yokken veya DB kapalıyken AI/analyze demosu.</summary>
public static class DemoProducerPanel
{
    public static UserPanelRequestDto Default => new()
    {
        Lat = 40.8438,
        Lon = 31.1565,
        PanelKwp = 5.0,
        AzimuthDeg = 180,
        TiltDeg = 30,
        Shading = "Orta",
        InverterEfficiency = 0.96,
        NumPeople = 2,
        HasEv = false,
        HasHeatPump = false,
    };
}
