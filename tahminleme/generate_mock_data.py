"""
Generate 7 days of hourly mock energy data: producers (1-5) and consumers (6-10).
"""

from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone

import numpy as np
import pandas as pd

np.random.seed(42)

N_DAYS = 7
N_HOURS = N_DAYS * 24
N_HOUSEHOLDS = 10
PRODUCERS = range(1, 6)
CONSUMERS = range(6, 11)
NIGHT_HOURS = set(range(0, 6)) | set(range(21, 24))
START = datetime(2026, 1, 1, 0, 0, 0, tzinfo=timezone.utc)


def solar_kwh(hour_of_day: int) -> float:
    """Solar production with Gaussian daytime curve; zero at night."""
    if hour_of_day in NIGHT_HOURS:
        return 0.0
    raw = 5.0 * np.exp(-0.5 * ((hour_of_day - 13) / 3) ** 2) + np.random.normal(
        0, 0.2
    )
    return float(max(0.0, raw))


def consumption_kwh(hour_of_day: int) -> float:
    """Base 1.0 + morning/evening peaks + uniform noise in [-0.3, 0.3]."""
    load = 1.0
    if 7 <= hour_of_day <= 9:
        load += 2.0
    if 18 <= hour_of_day <= 22:
        load += 2.5
    load += np.random.uniform(-0.3, 0.3)
    return float(max(0.0, load))


def main() -> None:
    rows: list[dict] = []
    summary: list[dict] = []

    for h in range(N_HOURS):
        ts = START + timedelta(hours=h)
        hod = ts.hour

        hour_prod = 0.0
        hour_cons = 0.0

        for hid in PRODUCERS:
            solar = solar_kwh(hod)
            cons = 0.0
            net = solar - cons
            hour_prod += solar
            rows.append(
                {
                    "timestamp": ts,
                    "household_id": hid,
                    "solar_production_kwh": solar,
                    "consumption_kwh": cons,
                    "net_energy_kwh": net,
                }
            )

        for hid in CONSUMERS:
            solar = 0.0
            cons = consumption_kwh(hod)
            net = solar - cons
            hour_cons += cons
            rows.append(
                {
                    "timestamp": ts,
                    "household_id": hid,
                    "solar_production_kwh": solar,
                    "consumption_kwh": cons,
                    "net_energy_kwh": net,
                }
            )

        hour_net = hour_prod - hour_cons
        summary.append(
            {
                "hour": hod,
                "total_production": round(hour_prod, 6),
                "total_consumption": round(hour_cons, 6),
                "total_net": round(hour_net, 6),
            }
        )

    df = pd.DataFrame(rows)
    df.sort_values(["timestamp", "household_id"], inplace=True)
    for col in ("solar_production_kwh", "consumption_kwh", "net_energy_kwh"):
        df[col] = df[col].round(6)
    df.to_csv(
        "mock_energy_data.csv",
        index=False,
        date_format="%Y-%m-%dT%H:%M:%S%z",
    )

    with open("mock_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)

    print(f"Wrote mock_energy_data.csv ({len(df)} rows)")
    print(f"Wrote mock_summary.json ({len(summary)} hourly totals)")


if __name__ == "__main__":
    main()
