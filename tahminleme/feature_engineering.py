"""
Load mock_energy_data.csv, aggregate to neighborhood hourly totals, engineer features for XGBoost.
"""

from __future__ import annotations

import numpy as np
import pandas as pd

INPUT_CSV = "mock_energy_data.csv"
OUTPUT_CSV = "features.csv"

# Mock temperature: sinusoidal, peak 14:00, range 18–35°C
_TEMP_CENTER = (18.0 + 35.0) / 2.0
_TEMP_AMP = (35.0 - 18.0) / 2.0


def mock_temperature_c(hour_of_day: int) -> float:
    return _TEMP_CENTER + _TEMP_AMP * np.cos(
        2 * np.pi * (hour_of_day - 14) / 24.0
    )


def main() -> None:
    raw = pd.read_csv(INPUT_CSV, parse_dates=["timestamp"])

    hourly = (
        raw.groupby("timestamp", sort=True)
        .agg(
            total_production=("solar_production_kwh", "sum"),
            total_consumption=("consumption_kwh", "sum"),
            total_net=("net_energy_kwh", "sum"),
        )
        .reset_index()
        .sort_values("timestamp")
        .reset_index(drop=True)
    )

    ts = hourly["timestamp"]
    hod = ts.dt.hour.astype(np.int32)
    dow = ts.dt.dayofweek.astype(np.int32)

    out = pd.DataFrame(
        {
            "saat": hod,
            "gun": dow,
            "onceki_uretim": hourly["total_production"].shift(1),
            "onceki_tuketim": hourly["total_consumption"].shift(1),
            "mevsim": 1,
            "sicaklik": hod.map(lambda h: round(mock_temperature_c(int(h)), 4)),
            "fazla_kwh": hourly["total_net"].shift(-1),
        }
    )

    out = out.dropna().reset_index(drop=True)

    out.to_csv(OUTPUT_CSV, index=False)

    print(f"shape: {out.shape}")
    print(out.head(5).to_string())


if __name__ == "__main__":
    main()
