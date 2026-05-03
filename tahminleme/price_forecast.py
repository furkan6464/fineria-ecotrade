"""
Dynamic P2P energy price from neighborhood supply and demand (TL/kWh).
"""

from __future__ import annotations

import random
from pathlib import Path
from typing import Any

try:
    import matplotlib.pyplot as plt
except ImportError:  # pragma: no cover - optional for headless import
    plt = None  # type: ignore[assignment]


def calculate_p2p_price(
    total_supply_kwh: float,
    total_demand_kwh: float,
    base_price_tl: float = 2.5,
    grid_price_tl: float = 4.0,
) -> float:
    """
    Price moves toward base when supply exceeds demand, toward grid when demand exceeds supply.

    price = base + (grid - base) * demand / (supply + demand)
    Result is clamped to [base_price_tl, grid_price_tl].
    """
    s = max(0.0, float(total_supply_kwh))
    d = max(0.0, float(total_demand_kwh))
    denom = s + d
    if denom <= 0.0:
        raw = float(base_price_tl)
    else:
        ratio = d / denom
        raw = float(base_price_tl) + (float(grid_price_tl) - float(base_price_tl)) * ratio
    lo, hi = (base_price_tl, grid_price_tl) if base_price_tl <= grid_price_tl else (grid_price_tl, base_price_tl)
    return round(min(max(raw, lo), hi), 4)


def _hourly_nets(row: dict[str, Any]) -> list[float]:
    """Extract per-household net kWh (surplus positive, deficit negative) for one hour."""
    if "net_kwh" in row and isinstance(row["net_kwh"], list):
        return [float(x) for x in row["net_kwh"]]
    if "fazlalar" in row and isinstance(row["fazlalar"], list):
        return [float(x) for x in row["fazlalar"]]
    if "hane_net_kwh" in row and isinstance(row["hane_net_kwh"], list):
        return [float(x) for x in row["hane_net_kwh"]]
    raise KeyError(
        "Saat satirinda 'net_kwh', 'fazlalar' veya 'hane_net_kwh' listesi gerekli."
    )


def forecast_neighborhood_prices(
    neighborhood_net_energy: list[dict[str, Any]],
    base_price_tl: float = 2.5,
    grid_price_tl: float = 4.0,
) -> list[dict[str, Any]]:
    """
    neighborhood_net_energy: her eleman {"saat": "14:00", "net_kwh": [h1, h2, ...]}, vb.

    Arz: hane bazinda pozitif net toplami. Talep: negatif netlerin mutlak degeri toplami.
    """
    out: list[dict[str, Any]] = []
    for row in neighborhood_net_energy:
        saat = str(row["saat"])
        nets = _hourly_nets(row)
        arz = float(sum(max(0.0, n) for n in nets))
        talep = float(sum(max(0.0, -n) for n in nets))
        fiyat = calculate_p2p_price(arz, talep, base_price_tl, grid_price_tl)
        if arz > talep:
            durum = "ARZ_FAZLASI"
        elif talep > arz:
            durum = "TALEP_FAZLASI"
        else:
            durum = "DENGEDE"
        out.append(
            {
                "saat": saat,
                "fiyat_tl_kwh": fiyat,
                "arz_kwh": round(arz, 3),
                "talep_kwh": round(talep, 3),
                "durum": durum,
            }
        )
    return out


def _saat_sort_key(saat: str) -> tuple[int, int]:
    parts = saat.strip().split(":")
    h = int(parts[0])
    m = int(parts[1]) if len(parts) > 1 else 0
    return h, m


def mock_neighborhood_10_hane_24h(seed: int = 42) -> list[dict[str, Any]]:
    """10 hane, 24 saat: gunduz uretim fazlasi, aksam talep baskisi."""
    rng = random.Random(seed)
    rows: list[dict[str, Any]] = []
    for hour in range(24):
        saat = f"{hour:02d}:00"
        nets: list[float] = []
        for _ in range(10):
            # Ortak profil: oglen yuksek uretim fazlasi, gece/aksam talep
            solar_bias = max(0.0, 1.4 * (1.0 - abs(hour - 13) / 8.0))
            evening_need = max(0.0, 0.9 * (1.0 - abs(hour - 20) / 5.0))
            base_load = rng.uniform(0.3, 1.1)
            noise = rng.uniform(-0.35, 0.35)
            net = round(solar_bias - evening_need - base_load * 0.4 + noise, 3)
            nets.append(net)
        rows.append({"saat": saat, "net_kwh": nets})
    rows.sort(key=lambda r: _saat_sort_key(str(r["saat"])))
    return rows


def plot_price_forecast(
    hourly_prices: list[dict[str, Any]],
    out_path: str | Path = "price_forecast_chart.png",
) -> Path:
    """Fiyat egrisini kaydeder; matplotlib gerekir."""
    if plt is None:
        raise ImportError("Grafik icin 'matplotlib' kurun: pip install matplotlib")

    path = Path(out_path)
    saatler = [h["saat"] for h in hourly_prices]
    fiyatlar = [float(h["fiyat_tl_kwh"]) for h in hourly_prices]

    fig, ax = plt.subplots(figsize=(10, 4.5))
    ax.plot(range(len(saatler)), fiyatlar, color="#1a5f4a", linewidth=2, marker="o", markersize=4)
    ax.set_xticks(range(len(saatler)))
    ax.set_xticklabels(saatler, rotation=45, ha="right", fontsize=8)
    ax.set_ylabel("Fiyat (TL/kWh)")
    ax.set_xlabel("Saat")
    ax.set_title("Mahalle P2P enerji fiyati (10 hane, mock)")
    ax.grid(True, alpha=0.3)
    ax.set_ylim(2.3, 4.2)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)
    return path.resolve()


if __name__ == "__main__":
    mock = mock_neighborhood_10_hane_24h()
    prices = forecast_neighborhood_prices(mock)
    chart = plot_price_forecast(prices, Path(__file__).resolve().parent / "price_forecast_chart.png")
    print(f"Kaydedildi: {chart}")
    print("Ornek (ilk 3 saat):", prices[:3])
