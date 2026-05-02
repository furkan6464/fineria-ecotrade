"""
EcoTrade FastAPI: health check and POST forecast with physics + residual hybrid.

Requires: model residual_model.pkl (train_hybrid_model.py), .env OWM_API_KEY, pip packages from weather_api / solar_physics / consumption_profile.
"""

from __future__ import annotations

import concurrent.futures
import os
import pickle
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Callable, TypeVar

import pandas as pd
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, field_validator

from ai_recommendations import generate_recommendations
from consumption_forecast import forecast_consumption
from env_loader import load_dotenv_safe
from consumption_profile import generate_consumption_profile
from net_energy import calculate_net_energy
from price_forecast import forecast_neighborhood_prices
from production_forecast import forecast_production
from solar_physics import calculate_production
from weather_api import estimate_ghi, get_hourly_forecast

load_dotenv_safe()

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

app = FastAPI(title="EcoTrade API", version="2.0.0")

ANALYZE_TIMEOUT_SEC = 30.0

T = TypeVar("T")


def _run_step_with_deadline(
    label: str,
    deadline: float,
    hatalar: list[str],
    fn: Callable[[], T],
) -> T | None:
    """fn'i ayrı thread'de çalıştır; kalan süre içinde bitmezse zaman aşımı say."""
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        hatalar.append(f"{label}: zaman asimi")
        return None
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=1) as ex:
            fut = ex.submit(fn)
            return fut.result(timeout=remaining)
    except concurrent.futures.TimeoutError:
        hatalar.append(f"{label}: zaman asimi")
        return None
    except Exception as e:
        hatalar.append(f"{label}: {e}")
        return None


class UserPanelData(BaseModel):
    lat: float = Field(..., description="Enlem (derece)")
    lon: float = Field(..., description="Boylam (derece)")
    panel_kwp: float = Field(..., gt=0, le=1000, description="Panel DC gücü (kWp)")
    azimuth_deg: float = Field(..., description="Panel azimutu, 180 = güney")
    tilt_deg: float = Field(..., ge=0, le=90, description="Çatı eğimi (derece)")
    shading: str = Field(..., description='Gölgeleme: "Yok", "Kısmi", "Çok"')
    inverter_efficiency: float = Field(..., ge=0.8, le=0.99, description="İnverter verimi")
    num_people: int = Field(..., ge=1, le=50)
    has_ev: bool = Field(False)
    has_heat_pump: bool = Field(False)

    @field_validator("lat")
    @classmethod
    def validate_lat(cls, v: float) -> float:
        if not -90.0 <= v <= 90.0:
            raise ValueError("lat must be between -90 and 90")
        return v

    @field_validator("lon")
    @classmethod
    def validate_lon(cls, v: float) -> float:
        if not -180.0 <= v <= 180.0:
            raise ValueError("lon must be between -180 and 180")
        return v

    @field_validator("shading")
    @classmethod
    def validate_shading(cls, v: str) -> str:
        allowed = ("Yok", "Kısmi", "Çok")
        if v not in allowed:
            raise ValueError(f'shading must be one of: {", ".join(allowed)}')
        return v


def _owm_api_key() -> str:
    k = os.getenv("OWM_API_KEY", "").strip()
    if not k or k == "your_key_here":
        raise HTTPException(
            status_code=503,
            detail="OWM_API_KEY .env içinde tanımlı değil veya geçersiz.",
        )
    return k


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
        raise HTTPException(
            status_code=503,
            detail="residual_model.pkl bulunamadı; train_hybrid_model.py çalıştırın.",
        )
    with open(RESIDUAL_MODEL_PATH, "rb") as f:
        return pickle.load(f)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/forecast/next6h")
def forecast_next6h(body: UserPanelData) -> list[dict[str, str | float | int]]:
    """
    6 saatlik hibrit üretim / tüketim / fazla tahmini (fizik + XGB artık + tüketim profili + hava).
    """
    api_key = _owm_api_key()
    try:
        tz_off = _timezone_offset_seconds(body.lat, body.lon, api_key)
    except requests.HTTPError as e:
        raise HTTPException(
            status_code=502,
            detail=f"OpenWeatherMap konum hatası: {e.response.status_code if e.response else e}",
        ) from e
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Hava servisine ulaşılamadı: {e}") from e

    try:
        hourly = get_hourly_forecast(body.lat, body.lon, api_key)
    except requests.HTTPError as e:
        raise HTTPException(
            status_code=502,
            detail=f"Saatlik tahmin alınamadı: {e.response.status_code if e.response else e}",
        ) from e
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Hava API isteği başarısız: {e}") from e

    if len(hourly) < 6:
        raise HTTPException(
            status_code=502,
            detail="Hava servisi 6 saatlik veri döndürmedi.",
        )

    slots = hourly[:6]
    local_tz = timezone(timedelta(seconds=tz_off))
    cons = generate_consumption_profile(
        num_people=body.num_people,
        has_ev=body.has_ev,
        has_heat_pump=body.has_heat_pump,
        season="summer",
    )
    model = _load_residual_model()
    out: list[dict[str, str | float | int]] = []
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
        try:
            physics = calculate_production(
                body.lat,
                body.lon,
                body.panel_kwp,
                body.azimuth_deg,
                body.tilt_deg,
                body.shading,
                body.inverter_efficiency,
                ghi,
                temp_c,
                float(local_h),
                doy,
            )
        except (ValueError, TypeError) as e:
            raise HTTPException(status_code=400, detail=f"Fizik modeli hatası: {e}") from e

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
        hybrid = float(physics + res)
        tuketim = float(cons[local_h])
        fazla = float(hybrid - tuketim)
        saat_str = f"{local_h:02d}:00"

        out.append(
            {
                "saat": saat_str,
                "uretim_kwh": round(hybrid, 3),
                "tuketim_kwh": round(tuketim, 3),
                "fazla_kwh": round(fazla, 3),
                "cloud_cover": int(round(cloud)),
            }
        )
        prev_physics = physics

    return out


def _user_panel_dict(body: UserPanelData) -> dict[str, Any]:
    if hasattr(body, "model_dump"):
        return body.model_dump()
    return body.dict()


@app.post("/analyze")
def analyze(body: UserPanelData) -> dict[str, Any]:
    """
    Üretim (1h/6h/24h), tüketim (24h), net enerji, mahalle fiyatı (10 hane × kullanıcı profili),
    Claude tavsiyeleri — toplam ~30s zaman bütçesi; hatalar `hatalar` listesinde.
    """
    deadline = time.monotonic() + ANALYZE_TIMEOUT_SEC
    hatalar: list[str] = []

    def step_uretim():
        key = os.getenv("OWM_API_KEY", "").strip()
        if not key or key == "your_key_here":
            raise ValueError("OWM_API_KEY tanımlı değil veya geçersiz")
        return forecast_production(
            body.lat,
            body.lon,
            body.panel_kwp,
            body.azimuth_deg,
            body.tilt_deg,
            body.shading,
            body.inverter_efficiency,
            key,
        )

    uretim_tahmini: dict[str, Any] | None = _run_step_with_deadline(
        "uretim_tahmini", deadline, hatalar, step_uretim
    )

    def step_tuketim():
        profile = {
            "hourly_baseline": generate_consumption_profile(
                body.num_people,
                body.has_ev,
                body.has_heat_pump,
                "summer",
            ),
            "weekday_multiplier": 1.0,
            "weekend_multiplier": 1.0,
        }
        if uretim_tahmini and uretim_tahmini.get("next_24h"):
            prod24 = uretim_tahmini["next_24h"]
            hours = [int(str(r["saat"]).split(":")[0]) for r in prod24]
            ref_saatlar = [r["saat"] for r in prod24]
        else:
            hours = list(range(24))
            ref_saatlar = [f"{h:02d}:00" for h in hours]
        key = os.getenv("OWM_API_KEY", "").strip()
        if key and key != "your_key_here":
            tz_off = _timezone_offset_seconds(body.lat, body.lon, key)
        else:
            tz_off = 0
        local_tz = timezone(timedelta(seconds=tz_off))
        dow = int(datetime.now(timezone.utc).astimezone(local_tz).weekday())
        rows = forecast_consumption(profile, hours, dow)
        for i, row in enumerate(rows):
            row["saat"] = ref_saatlar[i]
        return rows

    tuketim_tahmini: list[dict[str, Any]] | None = _run_step_with_deadline(
        "tuketim_tahmini", deadline, hatalar, step_tuketim
    )

    def step_net():
        if not uretim_tahmini or not uretim_tahmini.get("next_24h"):
            raise ValueError("Üretim tahmini (next_24h) yok")
        if not tuketim_tahmini:
            raise ValueError("Tüketim tahmini yok")
        return calculate_net_energy(uretim_tahmini["next_24h"], tuketim_tahmini)

    net_enerji: dict[str, Any] | None = _run_step_with_deadline(
        "net_enerji", deadline, hatalar, step_net
    )

    def step_fiyat():
        if not net_enerji or not net_enerji.get("hourly"):
            raise ValueError("Net enerji verisi yok")
        neighborhood = [
            {
                "saat": r["saat"],
                "net_kwh": [float(r["fazla_kwh"])] * 10,
            }
            for r in net_enerji["hourly"]
        ]
        return forecast_neighborhood_prices(neighborhood)

    fiyat_tahmini: list[dict[str, Any]] | None = _run_step_with_deadline(
        "fiyat_tahmini", deadline, hatalar, step_fiyat
    )

    def step_ai():
        net_for_ai = net_enerji if net_enerji else {"hourly": [], "summary": {}}
        price_for_ai = fiyat_tahmini if fiyat_tahmini else []
        rec = generate_recommendations(net_for_ai, price_for_ai, _user_panel_dict(body))
        return rec.get("tavsiyeler", [])

    ai_tavsiyeleri: list[dict[str, Any]] | None = _run_step_with_deadline(
        "ai_tavsiyeleri", deadline, hatalar, step_ai
    )

    out: dict[str, Any] = {
        "uretim_tahmini": uretim_tahmini,
        "tuketim_tahmini": tuketim_tahmini,
        "net_enerji": net_enerji,
        "fiyat_tahmini": fiyat_tahmini,
        "ai_tavsiyeleri": ai_tavsiyeleri,
    }
    if hatalar:
        out["hatalar"] = hatalar
    return out
