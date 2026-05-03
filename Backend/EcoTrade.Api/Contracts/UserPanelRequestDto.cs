namespace EcoTrade.Api.Contracts;

/// <summary>Python <c>UserPanelData</c> ile aynı alanlar (ML servisine POST gövdesi).</summary>
public sealed class UserPanelRequestDto
{
    public double Lat { get; set; }
    public double Lon { get; set; }
    public double PanelKwp { get; set; }
    public double AzimuthDeg { get; set; }
    public double TiltDeg { get; set; }
    public string Shading { get; set; } = "Yok";
    public double InverterEfficiency { get; set; } = 0.96;
    public int NumPeople { get; set; } = 2;
    public bool HasEv { get; set; }
    public bool HasHeatPump { get; set; }
}
