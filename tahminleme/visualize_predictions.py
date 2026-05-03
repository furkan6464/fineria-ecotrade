"""
Plot last 24 hours of actual vs predicted energy from predictions.csv.
"""

from __future__ import annotations

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

PREDICTIONS_CSV = "predictions.csv"
OUTPUT_PNG = "tahmin_grafik.png"


def _set_style() -> None:
    try:
        plt.style.use("seaborn-v0_8-whitegrid")
    except OSError:
        try:
            plt.style.use("seaborn-whitegrid")
        except OSError:
            plt.style.use("default")


def main() -> None:
    df = pd.read_csv(PREDICTIONS_CSV, parse_dates=["timestamp"])
    df = df.sort_values("timestamp").tail(24)

    t = df["timestamp"]
    actual = df["actual"].to_numpy(dtype=float)
    pred = df["predicted"].to_numpy(dtype=float)
    rmse = float(np.sqrt(np.mean((actual - pred) ** 2)))

    _set_style()
    fig, ax = plt.subplots(figsize=(12, 5))
    ax.plot(
        t,
        actual,
        color="#1f77b4",
        linewidth=2.0,
        label="Gerçek Değer",
    )
    ax.plot(
        t,
        pred,
        color="#ff7f0e",
        linewidth=2.0,
        linestyle="--",
        label="AI Tahmini",
    )

    ax.set_title("EcoTrade AI — Saatlik Enerji Fazlası Tahmini", fontsize=14, pad=12)
    ax.set_xlabel("Saat")
    ax.set_ylabel("Fazla Enerji (kWh)")
    ax.legend(loc="best")
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
    fig.autofmt_xdate()
    ax.grid(True, alpha=0.4)

    ax.text(
        0.98,
        0.98,
        f"RMSE: {rmse:.2f} kWh",
        transform=ax.transAxes,
        ha="right",
        va="top",
        fontsize=11,
        bbox=dict(boxstyle="round,pad=0.4", facecolor="white", edgecolor="#cccccc", alpha=0.95),
    )

    fig.tight_layout()
    fig.savefig(OUTPUT_PNG, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print("Grafik kaydedildi: tahmin_grafik.png")


if __name__ == "__main__":
    main()
