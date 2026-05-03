"""
Historical consumption analysis and short-horizon demand forecast.
"""

from __future__ import annotations

from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd

MOCK_CSV = Path(__file__).resolve().parent / "mock_consumption_history.csv"


def analyze_historical_consumption(consumption_history: list[dict[str, Any]]) -> dict[str, Any]:
    """
    consumption_history: [{"timestamp": "2024-01-01 08:00", "kwh": 1.2}, ...]

    Returns consumption_profile with:
      - hourly_baseline: list[24] mean kWh per clock hour
      - weekday_multiplier, weekend_multiplier vs global mean
      - morning_peak_hours: 2 consecutive hours in 6-10 with highest combined baseline
      - evening_peak_hours: 3 consecutive hours in 17-23 with highest combined baseline
    """
    if not consumption_history:
        raise ValueError("consumption_history boş olamaz")

    df = pd.DataFrame(consumption_history)
    if "timestamp" not in df.columns or "kwh" not in df.columns:
        raise ValueError("Her kayıtta 'timestamp' ve 'kwh' olmalı")

    df = df.copy()
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    df["kwh"] = df["kwh"].astype(float)
    df["hour"] = df["timestamp"].dt.hour
    df["dow"] = df["timestamp"].dt.dayofweek
    df["is_weekend"] = df["dow"] >= 5

    hourly = df.groupby("hour")["kwh"].mean().reindex(range(24), fill_value=0.0)
    hourly_baseline = [float(hourly[h]) for h in range(24)]

    global_mean = float(df["kwh"].mean())
    if global_mean <= 0:
        global_mean = 1e-6

    wd = df.loc[~df["is_weekend"], "kwh"]
    we = df.loc[df["is_weekend"], "kwh"]
    weekday_mean = float(wd.mean()) if len(wd) else global_mean
    weekend_mean = float(we.mean()) if len(we) else global_mean

    weekday_multiplier = float(weekday_mean / global_mean)
    weekend_multiplier = float(weekend_mean / global_mean)

    # Morning: best consecutive 2h window with start hour in [6..9] (covers 6-10 span)
    best_m = [6, 7]
    best_ms = -1.0
    for start in range(6, 10):
        s = hourly_baseline[start] + hourly_baseline[start + 1]
        if s > best_ms:
            best_ms = s
            best_m = [start, start + 1]
    morning_peak_hours = best_m

    # Evening: best consecutive 3h with start in [17..21] (fits in 17-23)
    best_e = [17, 18, 19]
    best_es = -1.0
    for start in range(17, 22):
        s = (
            hourly_baseline[start]
            + hourly_baseline[start + 1]
            + hourly_baseline[start + 2]
        )
        if s > best_es:
            best_es = s
            best_e = [start, start + 1, start + 2]
    evening_peak_hours = best_e

    return {
        "hourly_baseline": hourly_baseline,
        "weekday_multiplier": weekday_multiplier,
        "weekend_multiplier": weekend_multiplier,
        "morning_peak_hours": morning_peak_hours,
        "evening_peak_hours": evening_peak_hours,
        "global_mean_kwh": global_mean,
        "n_samples": int(len(df)),
    }


def forecast_consumption(
    consumption_profile: dict[str, Any],
    target_hours: list[int],
    day_of_week: int,
) -> list[dict[str, str | float]]:
    """
    day_of_week: 0=Monday .. 6=Sunday (datetime.weekday() convention).

    Her hedef saat için: baseline[hour] * (hafta içi/sonu çarpanı) * U(0.95,1.05).
    """
    baseline: list[float] = consumption_profile["hourly_baseline"]
    if len(baseline) != 24:
        raise ValueError("hourly_baseline 24 elemanlı olmalı")

    is_weekend = day_of_week >= 5
    mult = (
        float(consumption_profile["weekend_multiplier"])
        if is_weekend
        else float(consumption_profile["weekday_multiplier"])
    )

    rng = np.random.default_rng()
    out: list[dict[str, str | float]] = []
    for h in target_hours:
        if h < 0 or h > 23:
            raise ValueError(f"Saat 0-23 aralığında olmalı: {h}")
        raw = baseline[h] * mult * rng.uniform(0.95, 1.05)
        out.append(
            {
                "saat": f"{h:02d}:00",
                "tahmini_tuketim_kwh": round(max(0.0, float(raw)), 3),
            }
        )
    return out


def _generate_mock_history_7days() -> list[dict[str, Any]]:
    """7 günlük saatlik sentetik tüketim (Pzt başlangıç)."""
    rng = np.random.default_rng(42)
    start = datetime(2024, 1, 1, 0, 0, 0)
    rows: list[dict[str, Any]] = []
    for i in range(7 * 24):
        ts = start + timedelta(hours=i)
        h = ts.hour
        dow = ts.weekday()
        base = 0.12
        if 7 <= h <= 9:
            base += 0.38
        if 18 <= h <= 22:
            base += 0.42
        if 12 <= h <= 14:
            base += 0.12
        if dow >= 5:
            base *= 1.18
        kwh = max(0.04, base + float(rng.normal(0, 0.04)))
        rows.append(
            {
                "timestamp": ts.strftime("%Y-%m-%d %H:%M"),
                "kwh": round(kwh, 4),
            }
        )
    return rows


if __name__ == "__main__":
    history = _generate_mock_history_7days()
    MOCK_CSV.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(history).to_csv(MOCK_CSV, index=False)
    print(f"Yazildi: {MOCK_CSV} ({len(history)} satir)\n")

    profile = analyze_historical_consumption(history)
    print("--- consumption_profile (ozet) ---")
    print(f"  global_mean_kwh: {profile['global_mean_kwh']:.4f}")
    print(f"  weekday_multiplier: {profile['weekday_multiplier']:.4f}")
    print(f"  weekend_multiplier: {profile['weekend_multiplier']:.4f}")
    print(f"  morning_peak_hours: {profile['morning_peak_hours']}")
    print(f"  evening_peak_hours: {profile['evening_peak_hours']}")
    print(f"  hourly_baseline[7..9]: {[round(profile['hourly_baseline'][h], 3) for h in range(7, 10)]}")

    # Ornek: Carsamba 12-18 arasi saatler
    wednesday = 2
    targets = [12, 13, 14, 15, 16, 17, 18]
    fc = forecast_consumption(profile, targets, wednesday)
    print("\n--- forecast_consumption (Carsamba, saatler 12-18) ---")
    for row in fc:
        print(f"  {row}")
