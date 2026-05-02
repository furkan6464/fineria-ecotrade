"""
Multi-horizon solar production forecast: physics + XGBoost residual (train_hybrid_model).
"""

from __future__ import annotations

import json
import pickle
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import pandas as pd
import requests
from solar_physics import ShadingInput, calculate_production
from weather_api import estimate_ghi, get_hourly_forecast

BASE_DIR = Path(__file__).resolve().parent
RESIDUAL_MODEL_PATH = BASE_DIR / "residual_model.pkl"
CURRENT_WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"

RESIDUAL_FEATURES = [
    "saat",
    "gun",
    "cloud_cover_percent",
    "temp_celsius",
    "onceki_uretim",
    "mevsim",
]


def _timezone_offset_seconds(lat: float, lon: float, api_key: str) -> int:
    r = requests.get(
        CURRENT_WEATHER_URL,
        params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
        timeout=20,
    )
    r.raise_for_status()
    return int(r.json().get("timezone", 0))


def _load_residual_model():
    if not RESIDUAL_MODEL_PATH.is_file():
        raise FileNotFoundError(
            f"{RESIDUAL_MODEL_PATH} bulunamadı; önce train_hybrid_model.py çalıştırın.",
        )
    with open(RESIDUAL_MODEL_PATH, "rb") as f:
        return pickle.load(f)


def _hybrid_series_for_slots(
    slots: list[dict],
    local_tz: timezone,
    lat: float,
    lon: float,
    panel_kwp: float,
    azimuth_deg: float,
    tilt_deg: float,
    shading: ShadingInput,
    inverter_efficiency: float,
    model: Any,
) -> list[dict[str, str | float]]:
    """Üretim kWh listesi: yerel saat string + hibrit üretim (gece 0)."""
    out: list[dict[str, str | float]] = []
    prev_physics = 0.0

    for slot in slots:
        ts_utc = datetime.fromisoformat(slot["timestamp"].replace("Z", "+00:00"))
        if ts_utc.tzinfo is None:
            ts_utc = ts_utc.replace(tzinfo=timezone.utc)
        local_dt = ts_utc.astimezone(local_tz)
        local_h = int(local_dt.hour)
        gun = int(local_dt.weekday())
        doy = int(local_dt.timetuple().tm_yday)
        cloud = float(slot["cloud_cover_percent"])
        temp_c = float(slot["temp_celsius"])

        ghi = estimate_ghi(cloud, float(local_h), doy)
        physics = float(
            calculate_production(
                lat,
                lon,
                panel_kwp,
                azimuth_deg,
                tilt_deg,
                shading,
                inverter_efficiency,
                ghi,
                temp_c,
                float(local_h),
                doy,
            )
        )

        if physics <= 0.0:
            uretim = 0.0
        else:
            x_row = {
                "saat": local_h,
                "gun": gun,
                "cloud_cover_percent": cloud,
                "temp_celsius": temp_c,
                "onceki_uretim": prev_physics,
                "mevsim": 1,
            }
            X = pd.DataFrame([x_row], columns=RESIDUAL_FEATURES)
            res = float(model.predict(X)[0])
            uretim = max(0.0, physics + res)

        saat_str = f"{local_h:02d}:00"
        out.append({"saat": saat_str, "uretim_kwh": round(uretim, 3)})
        prev_physics = physics

    return out


def forecast_production(
    lat: float,
    lon: float,
    panel_kwp: float,
    azimuth_deg: float,
    tilt_deg: float,
    shading: ShadingInput,
    inverter_efficiency: float,
    api_key: str,
) -> dict[str, Any]:
    """
    24 saatlik hava + fizik + residual ile üretim tahmini.

    Dönüş:
      next_1h:  {"uretim_kwh", "saat"}
      next_6h:  6 elemanlı liste
      next_24h: 24 elemanlı liste
    """
    hourly = get_hourly_forecast(lat, lon, api_key)
    if len(hourly) < 24:
        raise ValueError(
            f"Saatlik tahmin en az 24 satır olmalı; gelen: {len(hourly)}",
        )

    tz_off = _timezone_offset_seconds(lat, lon, api_key)
    local_tz = timezone(timedelta(seconds=tz_off))
    model = _load_residual_model()

    series = _hybrid_series_for_slots(
        hourly[:24],
        local_tz,
        lat,
        lon,
        panel_kwp,
        azimuth_deg,
        tilt_deg,
        shading,
        inverter_efficiency,
        model,
    )

    return {
        "next_1h": dict(series[0]),
        "next_6h": [dict(x) for x in series[:6]],
        "next_24h": [dict(x) for x in series],
    }


if __name__ == "__main__":
    from env_loader import load_dotenv_safe
    import os

    load_dotenv_safe()
    key = os.getenv("OWM_API_KEY", "").strip()
    if not key:
        raise SystemExit("OWM_API_KEY .env içinde yok.")

    lat_d, lon_d = 40.76, 31.16
    result = forecast_production(
        lat_d,
        lon_d,
        panel_kwp=5.0,
        azimuth_deg=180.0,
        tilt_deg=30.0,
        shading="Yok",
        inverter_efficiency=0.92,
        api_key=key,
    )

    print("Düzce (40.76, 31.16) — çok ufuklu güneş üretim tahmini\n")
    print("next_1h:", json.dumps(result["next_1h"], ensure_ascii=False))
    print("\nnext_6h (ilk 6 saat):")
    for row in result["next_6h"]:
        print(f"  {row}")
    print("\nnext_24h (özet: gece 0 üretim):")
    nonzero = sum(1 for r in result["next_24h"] if r["uretim_kwh"] > 0)
    print(f"  Toplam {len(result['next_24h'])} saat, gündüz üretim >0: {nonzero} saat")
    print("  İlk 3:", result["next_24h"][:3])
    print("  ...")
    print("  Son 3:", result["next_24h"][-3:])
