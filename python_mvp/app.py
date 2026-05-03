"""
EcoTrade hackathon MVP: Düzce pilot bölgesi meteorolojisine dayalı anlık üretim simülasyonu
+ 6 saatlik üretim / fiyat tahmini. Groq (recommendation_service) varsa canlı öneri metni üretir.
Çalıştırma (yerel tarayıcı): uvicorn app:app --host 127.0.0.1 --port 8001
Çalıştırma (telefon / aynı Wi‑Fi LAN IP): uvicorn app:app --host 0.0.0.0 --port 8001
veya: .\\run_uvicorn.ps1   Windows güvenlik duvarında TCP 8001’e izin vermen gerekebilir.
"""

from __future__ import annotations

import math
import os
import random
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from zoneinfo import ZoneInfo

# .env her zaman app.py ile aynı klasörde aranır (uvicorn'u nereden çalıştırdığından bağımsız).
load_dotenv(Path(__file__).resolve().parent / ".env")

app = FastAPI(title="EcoTrade ML MVP", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Düzce yaklaşık koordinat (pilot bölge hikâyesi)
DUZCE_LAT = 40.8438
DUZCE_LON = 31.1565
REGION_LABEL = "Düzce"
TZ = ZoneInfo("Europe/Istanbul")

# Tipik rooftop: 5 kWp DC — jüri demosu için sabit ölçek
NOMINAL_KWP = 5.0


def _now_local() -> datetime:
    return datetime.now(TZ)


def _solar_instant_factor(hour: float) -> float:
    """Gündüz çan eğrisi; gece ~0."""
    if hour < 6.0 or hour > 20.0:
        return 0.02
    # Öğlen civarı tepe
    x = (hour - 6.0) / 14.0
    return max(0.0, math.sin(math.pi * x)) ** 1.15


def _cloud_noise(seed_hour: int) -> float:
    rng = random.Random(seed_hour * 17 + int(DUZCE_LAT * 100))
    return 0.72 + 0.26 * rng.random()


def simulate_live_production_kwh(now: datetime | None = None) -> tuple[float, str]:
    t = now or _now_local()
    hf = t.hour + t.minute / 60.0 + t.second / 3600.0
    base = NOMINAL_KWP * _solar_instant_factor(hf) * _cloud_noise(t.hour)
    # Hafif jitter — “anlık” hissi
    jitter = 0.97 + 0.06 * random.random()
    kwh = round(max(0.05, base * jitter), 2)
    if hf < 6 or hf > 20:
        summary = (
            f"{REGION_LABEL} için gece/şafak diliminde düşük üretim; "
            "pilot meteoroloji ile anlık simülasyon."
        )
    else:
        summary = (
            f"{REGION_LABEL} pilot bölgesi gündüz simülasyonu: "
            "bulutluluk ve saat bazlı basit üretim modeli."
        )
    return kwh, summary


def simulate_price_tl_per_kwh(production_kwh: float) -> float:
    """Üretim yüksekken fiyat biraz düşer (basit ters orantı)."""
    p = 2.35 - 0.12 * min(production_kwh / NOMINAL_KWP, 1.2)
    return round(max(1.15, min(4.2, p)), 2)


def build_forecast_series(now: datetime | None = None) -> tuple[list[dict[str, Any]], str]:
    t0 = (now or _now_local()).replace(minute=0, second=0, microsecond=0)
    rows: list[dict[str, Any]] = []
    best_h = ""
    best_p = -1.0
    for i in range(6):
        slot = t0 + timedelta(hours=i)
        hf = slot.hour + 0.5
        prod = NOMINAL_KWP * _solar_instant_factor(hf) * _cloud_noise(slot.hour + i)
        prod = round(max(0.0, prod), 2)
        price = simulate_price_tl_per_kwh(prod)
        label = slot.strftime("%H:%M")
        rows.append(
            {
                "hour": label,
                "production_kwh": prod,
                "price_tl_kwh": price,
            }
        )
        if prod > best_p:
            best_p = prod
            best_h = label
    if not best_h and rows:
        best_h = rows[0]["hour"]
    return rows, best_h


def _groq_two_sentence_tr(user_data: dict[str, Any]) -> str | None:
    """
    recommendation_service.py ile aynı kurallar (2 cümle, Türkçe, somut rakam).
    Modülü import etmiyoruz: o dosya GROQ_API_KEY yokken import aşamasında patlar.
    """
    key = os.getenv("GROQ_API_KEY", "").strip()
    if not key:
        return None
    try:
        from groq import Groq

        prompt = f"""Asagidaki kurallara kesinlikle uy:
KURAL: Sadece Turkiye Turkcesi kullan.
KURAL: Yanit 2 cumle olmali.
KURAL: Somut rakam kullan.

Simdi su bilgilere gore 2 cumle yaz:
- Uretim: {user_data["uretim_kwh"]} kWh
- Tuketim: {user_data["tuketim_kwh"]} kWh
- Hava: {user_data["hava"]}
- Fiyat: {user_data["fiyat"]} TL/kWh
- Komsularda enerji: {user_data["komsu_arz"]}"""
        client = Groq(api_key=key)
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=300,
        )
        return response.choices[0].message.content
    except Exception:
        return None


class LivePredictResponse(BaseModel):
    region: str = Field(default=REGION_LABEL)
    live_production_kwh: float
    price_hint_tl_per_kwh: float
    weather_summary_tr: str
    recommendation_tr: str | None = None
    latitude: float = DUZCE_LAT
    longitude: float = DUZCE_LON


class ForecastHour(BaseModel):
    hour: str
    production_kwh: float
    price_tl_kwh: float


class ForecastResponse(BaseModel):
    region: str = REGION_LABEL
    best_sell_hour: str
    series: list[ForecastHour]


@app.get("/")
def root() -> dict[str, Any]:
    """Tarayıcıda sadece host:port açılınca 404 yerine uç listesi."""
    return {
        "service": "EcoTrade ML MVP",
        "docs": "/docs",
        "health": "/health",
        "predict_live": "/predict/live",
        "predict_forecast": "/predict/forecast",
        "analyze": "/analyze",
        "ai_chat": "/ai/chat",
        "ai_suggest_legacy": "/ai/suggest",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "region": REGION_LABEL}


@app.get("/predict/live", response_model=LivePredictResponse)
def predict_live() -> LivePredictResponse:
    now = _now_local()
    kwh, summary = simulate_live_production_kwh(now)
    price = simulate_price_tl_per_kwh(kwh)

    user_data = {
        "rol": "uretici",
        "uretim_kwh": kwh,
        "tuketim_kwh": round(kwh * 0.35, 2),
        "hava": f"{REGION_LABEL} pilot meteoroloji (simüle)",
        "fiyat": str(price),
        "komsu_arz": "Hayir, komşu talep orta",
    }
    rec = _groq_two_sentence_tr(user_data)
    if not rec:
        rec = (
            f"Bugün yaklaşık {kwh:.1f} kWh anlık üretim simülasyonun var; "
            f"{REGION_LABEL} pilot verisiyle öğleden sonra satış penceresi genelde daha iyidir."
        )

    return LivePredictResponse(
        live_production_kwh=kwh,
        price_hint_tl_per_kwh=price,
        weather_summary_tr=summary,
        recommendation_tr=rec,
    )


@app.get("/predict/forecast", response_model=ForecastResponse)
def predict_forecast() -> ForecastResponse:
    series_raw, best = build_forecast_series()
    series = [ForecastHour(**r) for r in series_raw]
    return ForecastResponse(best_sell_hour=best, series=series)


# --- C# PredictionService POST /analyze + Flutter köprüsü POST /ai/chat ---


class UserPanelRequest(BaseModel):
    """EcoTrade.Api UserPanelRequestDto (snake_case JSON)."""

    lat: float
    lon: float
    panel_kwp: float
    azimuth_deg: float
    tilt_deg: float
    shading: str = "Yok"
    inverter_efficiency: float = 0.96
    num_people: int = 2
    has_ev: bool = False
    has_heat_pump: bool = False


def _ai_tips_from_panel(panel: UserPanelRequest) -> list[dict[str, str]]:
    now = _now_local()
    kwh, summary = simulate_live_production_kwh(now)
    rows, best = build_forecast_series(now)
    scale = min(panel.panel_kwp / NOMINAL_KWP, 2.5) if NOMINAL_KWP > 0 else 1.0
    tips: list[dict[str, str]] = []
    for r in rows[:3]:
        hour = str(r["hour"])
        prod = round(float(r["production_kwh"]) * scale, 2)
        tips.append(
            {
                "saat": hour,
                "mesaj": (
                    f"{REGION_LABEL} ({hour}): tahmini ~{prod} kWh; "
                    f"{panel.panel_kwp:.1f} kWp panel, gölge: {panel.shading}. "
                    f"{summary[:100]}"
                ),
            }
        )
    if not tips:
        tips.append(
            {
                "saat": best or "12:00",
                "mesaj": (
                    f"Panel {panel.panel_kwp:.1f} kWp; anlık simülasyon ~{kwh:.2f} kWh."
                ),
            }
        )
    return tips


@app.post("/analyze")
def analyze(panel: UserPanelRequest) -> dict[str, Any]:
    """C# → ai_tavsiyeleri (saat + mesaj)."""
    return {"ai_tavsiyeleri": _ai_tips_from_panel(panel)}


class AiChatBody(BaseModel):
    message: str


def _groq_chat_reply(user_message: str) -> str | None:
    key = os.getenv("GROQ_API_KEY", "").strip()
    if not key:
        return None
    try:
        from groq import Groq

        client = Groq(api_key=key)
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Sen EcoTrade yenilenebilir enerji ve mahalle elektrik ticareti "
                        "uygulamasının Türkçe asistanısın. En fazla dört cümle; net ve samimi ol. "
                        "Çamaşır/bulaşık makinesi vb. ne zaman çalıştırmalı veya güneş/piyasa "
                        "için en uygun saat sorulduğunda geniş aralık (ör. 11:00–15:00) yerine "
                        "tek bir net saat ver: özellikle **saat 14.00** veya **14:00** ifadesini "
                        "mutlaka kullan; istenirse bu saati bir cümleyle gerekçelendir."
                    ),
                },
                {"role": "user", "content": user_message},
            ],
            max_tokens=500,
        )
        text = response.choices[0].message.content
        return text.strip() if text else None
    except Exception:
        return None


@app.post("/ai/chat")
def ai_chat(body: AiChatBody) -> dict[str, str]:
    """Flutter → C# → burada Groq (veya yedek metin)."""
    msg = body.message.strip()
    if not msg:
        return {"reply": "Kısa bir soru yazabilirsin."}
    reply = _groq_chat_reply(msg)
    if reply:
        return {"reply": reply}
    return {
        "reply": (
            f"Tam dil modeli için GROQ_API_KEY gerekir. "
            f"'{msg[:80]}' konusunda üstteki tahmin kartlarına bakabilirsin."
        )
    }


# Eski main.py uyumluluğu (isteğe bağlı)
class EnerjiVerisi(BaseModel):
    rol: str
    uretim_kwh: float
    tuketim_kwh: float
    hava: str
    fiyat: str
    komsu_arz: str


@app.post("/ai/suggest")
def suggest(veri: EnerjiVerisi) -> dict[str, str]:
    data = veri.model_dump()
    text = _groq_two_sentence_tr(data)
    if not text:
        text = (
            "Şu anki verilere göre tüketimini düşük fiyatlı saatlere kaydırmak "
            "hem maliyeti hem komşu arzını dengeler."
        )
    return {"oneri": text}
