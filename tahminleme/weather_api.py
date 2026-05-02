"""
OpenWeatherMap helpers: current weather, 24h hourly-style forecast, and clear-sky GHI estimate.
Requires: pip install requests python-dotenv
Copy .env.example to .env and set OWM_API_KEY.
"""

from __future__ import annotations

import math
import os
from datetime import datetime, timedelta, timezone

import requests
from env_loader import load_dotenv_safe

OWM_BASE = "https://api.openweathermap.org"


def get_current_weather(lat: float, lon: float, api_key: str) -> dict:
    """
    Current weather at coordinates (metric).

    Returns keys: cloud_cover_percent, temperature_celsius, humidity_percent
    """
    url = f"{OWM_BASE}/data/2.5/weather"
    r = requests.get(
        url,
        params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
        timeout=20,
    )
    r.raise_for_status()
    data = r.json()
    return {
        "cloud_cover_percent": float(data["clouds"]["all"]),
        "temperature_celsius": float(data["main"]["temp"]),
        "humidity_percent": float(data["main"]["humidity"]),
    }


def _expand_forecast_3h_to_hourly(items: list[dict], tz_offset_sec: int) -> list[dict]:
    """Turn 3-hourly blocks into 24 consecutive hourly rows (same cloud/temp per 3h slot)."""
    out: list[dict] = []
    tz = timezone(timedelta(seconds=tz_offset_sec))
    for block in items[:8]:
        ts_utc = datetime.fromtimestamp(block["dt"], tz=timezone.utc)
        cloud = float(block["clouds"]["all"])
        temp = float(block["main"]["temp"])
        for h in range(3):
            t = ts_utc + timedelta(hours=h)
            out.append(
                {
                    "timestamp": t.isoformat(),
                    "cloud_cover_percent": cloud,
                    "temp_celsius": temp,
                }
            )
            if len(out) >= 24:
                return out[:24]
    return out[:24]


def get_hourly_forecast(lat: float, lon: float, api_key: str) -> list[dict]:
    """
    Next ~24 hours of (mostly) hourly points: timestamp (UTC ISO), cloud_cover_percent, temp_celsius.

    Uses One Call 3.0 `hourly` when available; otherwise 2.5 `forecast` (3-hourly) expanded to hourly.
    """
    # One Call 3.0 — hourly list (48 entries); needs API key with One Call access on some accounts
    url_oc = f"{OWM_BASE}/data/3.0/onecall"
    r = requests.get(
        url_oc,
        params={
            "lat": lat,
            "lon": lon,
            "appid": api_key,
            "units": "metric",
            "exclude": "minutely,daily,alerts",
        },
        timeout=20,
    )
    if r.ok:
        data = r.json()
        hourly = data.get("hourly") or []
        out: list[dict] = []
        for slot in hourly[:24]:
            ts = datetime.fromtimestamp(slot["dt"], tz=timezone.utc)
            clouds_raw = slot.get("clouds", 0)
            cloud = float(
                clouds_raw if isinstance(clouds_raw, (int, float)) else clouds_raw.get("all", 0)
            )
            out.append(
                {
                    "timestamp": ts.isoformat(),
                    "cloud_cover_percent": cloud,
                    "temp_celsius": float(slot["temp"]),
                }
            )
        if len(out) >= 24:
            return out[:24]

    # Fallback: 5-day / 3-hour forecast
    url_fc = f"{OWM_BASE}/data/2.5/forecast"
    r2 = requests.get(
        url_fc,
        params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
        timeout=20,
    )
    r2.raise_for_status()
    data2 = r2.json()
    tz_off = int(data2.get("city", {}).get("timezone", 0))
    items = data2.get("list", [])
    return _expand_forecast_3h_to_hourly(items, tz_off)


def estimate_ghi(
    cloud_cover_percent: float,
    hour: float,
    day_of_year: int,
) -> float:
    """
    Rough Global Horizontal Irradiance (W/m²).

    ghi_clear = 1000 * max(0, sin((hour - 6) * pi / 12))
    ghi = ghi_clear * (1 - 0.75 * (cloud_cover_percent/100)**3.4)

    `day_of_year` is reserved for future seasonal refinement (not used in this formula).
    """
    _ = day_of_year
    ghi_clear = 1000.0 * max(0.0, math.sin((hour - 6.0) * math.pi / 12.0))
    factor = 1.0 - 0.75 * (cloud_cover_percent / 100.0) ** 3.4
    return float(ghi_clear * factor)


def _timezone_offset_seconds(lat: float, lon: float, api_key: str) -> int:
    r = requests.get(
        f"{OWM_BASE}/data/2.5/weather",
        params={"lat": lat, "lon": lon, "appid": api_key, "units": "metric"},
        timeout=15,
    )
    r.raise_for_status()
    return int(r.json().get("timezone", 0))


def _sample_duzce() -> None:
    load_dotenv_safe()
    api_key = os.getenv("OWM_API_KEY", "").strip()
    lat, lon = 40.76, 31.16

    print("--- EcoTrade weather sample (Düzce: lat=40.76, lon=31.16) ---")
    if not api_key or api_key == "your_key_here":
        print(
            "OWM_API_KEY eksik veya placeholder. .env dosyasına gerçek anahtarınızı yazın "
            "(OpenWeatherMap ücretsiz hesap: https://openweathermap.org/api )",
        )
        print("\nÖrnek (anahtar olmadan) estimate_ghi(40, 12, 82):")
        print(f"  GHI ~ {estimate_ghi(40.0, 12.0, 82):.1f} W/m^2")
        return

    try:
        cur = get_current_weather(lat, lon, api_key)
        print("\n[current]", cur)

        hourly = get_hourly_forecast(lat, lon, api_key)
        print(f"\n[hourly] {len(hourly)} kayıt (ilk 3):")
        for row in hourly[:3]:
            print(f"  {row}")

        tz_off = _timezone_offset_seconds(lat, lon, api_key)
        tz = timezone(timedelta(seconds=tz_off))

        print("\n[estimate_ghi] ilk 3 saat (yerel saat ile):")
        for row in hourly[:3]:
            ts = datetime.fromisoformat(row["timestamp"].replace("Z", "+00:00"))
            local = ts.astimezone(tz)
            local_h = float(local.hour)
            doy = local.timetuple().tm_yday
            ghi = estimate_ghi(row["cloud_cover_percent"], local_h, doy)
            print(
                f"  {row['timestamp']} | bulut={row['cloud_cover_percent']:.0f}% | "
                f"yerel_saat={local_h:.0f} | GHI~{ghi:.1f} W/m^2",
            )

    except requests.HTTPError as e:
        print(f"HTTP hatası: {e.response.status_code} — {e.response.text[:200]}")
    except requests.RequestException as e:
        print(f"İstek hatası: {e}")


if __name__ == "__main__":
    _sample_duzce()
