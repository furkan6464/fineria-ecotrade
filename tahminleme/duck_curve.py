"""
24-hour Duck Curve from mock_summary.json hourly averages; EcoTrade load shift scenario.
"""

from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

SUMMARY_JSON = Path("mock_summary.json")
CSV_OUT = "duck_curve_data.csv"
CHART_OUT = "duck_curve_chart.png"

EVENING_HOURS = (18, 19, 20, 21, 22)
MIDDAY_HOURS = (11, 12, 13, 14, 15)
SHIFT_FRACTION = 0.30


def load_hourly_averages(path: Path) -> tuple[np.ndarray, np.ndarray]:
    with open(path, encoding="utf-8") as f:
        rows = json.load(f)
    df = pd.DataFrame(rows)
    avg = (
        df.groupby("hour", sort=True)[["total_production", "total_consumption"]]
        .mean()
        .reindex(range(24))
    )
    prod = avg["total_production"].to_numpy(dtype=float)
    cons = avg["total_consumption"].to_numpy(dtype=float)
    return prod, cons


def consumption_after_ecotrade(cons: np.ndarray, prod: np.ndarray) -> np.ndarray:
    """Move 30% of each evening hour's consumption to midday, weighted by solar."""
    out = cons.astype(float).copy()
    moved_total = 0.0
    for h in EVENING_HOURS:
        amt = SHIFT_FRACTION * out[h]
        moved_total += amt
        out[h] -= amt

    mid = np.array(MIDDAY_HOURS)
    solar_mid = prod[mid]
    if solar_mid.sum() > 1e-9:
        weights = solar_mid / solar_mid.sum()
    else:
        weights = np.ones(len(mid)) / len(mid)
    for w, h in zip(weights, mid):
        out[h] += moved_total * w
    return out


def main() -> None:
    prod, cons = load_hourly_averages(SUMMARY_JSON)
    trafo_oncesi = prod - cons

    cons_eco = consumption_after_ecotrade(cons, prod)
    trafo_sonrasi = prod - cons_eco

    out_df = pd.DataFrame(
        {
            "hour": np.arange(24, dtype=int),
            "trafo_oncesi": np.round(trafo_oncesi, 6),
            "trafo_sonrasi": np.round(trafo_sonrasi, 6),
        }
    )
    out_df.to_csv(CSV_OUT, index=False)

    hours = np.arange(24)
    fig, ax = plt.subplots(figsize=(10, 5.5))
    ax.plot(
        hours,
        trafo_oncesi,
        color="#c0392b",
        linewidth=2.2,
        marker="o",
        markersize=4,
        label="EcoTrade Öncesi (Trafoya Yük)",
    )
    ax.plot(
        hours,
        trafo_sonrasi,
        color="#27ae60",
        linewidth=2.2,
        marker="s",
        markersize=4,
        label="EcoTrade Sonrası (AI Optimizasyonu)",
    )
    ax.fill_between(
        hours,
        trafo_oncesi,
        trafo_sonrasi,
        color="#7dce9e",
        alpha=0.3,
        interpolate=True,
    )

    ax.axvline(13, color="#34495e", linestyle="--", linewidth=1.2, alpha=0.85)
    ax.axvline(19, color="#34495e", linestyle="--", linewidth=1.2, alpha=0.85)
    ymax = float(np.nanmax([np.nanmax(trafo_oncesi), np.nanmax(trafo_sonrasi)]))
    ymin = float(np.nanmin([np.nanmin(trafo_oncesi), np.nanmin(trafo_sonrasi)]))
    y_text = ymax - 0.05 * (ymax - ymin) if ymax > ymin else ymax + 1.0
    ax.text(13, y_text, "Güneş Zirvesi", ha="center", va="top", fontsize=9, color="#34495e")
    ax.text(19, y_text, "Akşam Talebi", ha="center", va="top", fontsize=9, color="#34495e")

    ax.set_title("Ördek Eğrisi — EcoTrade Etkisi", fontsize=14, pad=14)
    ax.set_xlabel("Saat")
    ax.set_ylabel("Trafo net yükü (üretim − tüketim) [kWh]")
    ax.set_xticks(np.arange(0, 24, 2))
    ax.set_xlim(-0.5, 23.5)
    ax.legend(loc="best")
    ax.grid(True, alpha=0.35)
    fig.tight_layout()
    fig.savefig(CHART_OUT, dpi=150)
    plt.close(fig)

    print(f"Saved {CSV_OUT}")
    print(f"Saved {CHART_OUT}")


if __name__ == "__main__":
    main()
