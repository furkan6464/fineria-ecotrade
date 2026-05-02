"""
EcoTrade: Claude ile kişiselleştirilmiş enerji tavsiyeleri (JSON).
"""

from __future__ import annotations

import json
import os
import re
from typing import Any

from env_loader import load_dotenv_safe

load_dotenv_safe()

try:
    import anthropic
except ImportError:  # pragma: no cover
    anthropic = None  # type: ignore[assignment]

CLAUDE_MODEL = "claude-sonnet-4-20250514"
SYSTEM_PROMPT = (
    "Sen EcoTrade platformunun AI enerji danışmanısın. Kullanıcıya günlük enerji yönetimi "
    "konusunda kısa, somut ve Türkçe tavsiyeler ver. Her tavsiye tek cümle olsun, aksiyon odaklı olsun."
)

_FALLBACK = {
    "tavsiyeler": [
        {
            "saat": "12:00",
            "mesaj": (
                "Öğlen üretim zirvesine yakın saatlerde yüksek tüketimli cihazları çalıştırarak "
                "şebeke çekimini azaltın."
            ),
        },
        {
            "saat": "18:00",
            "mesaj": (
                "Akşam talep artışında pompaları veya klima önceden kısarak P2P fiyat baskısını "
                "hafifletin."
            ),
        },
        {
            "saat": "10:00",
            "mesaj": (
                "Panel kapasitenizi ve inverter veriminizi düzenli kontrol ederek üretim "
                "kayıplarını sınırlayın."
            ),
        },
    ],
}


def _float_from(row: dict[str, Any], *keys: str, default: float = 0.0) -> float:
    for k in keys:
        if k in row:
            try:
                return float(row[k])
            except (TypeError, ValueError):
                continue
    return default


def _summarize_net_energy(net_energy_data: dict[str, Any]) -> dict[str, Any]:
    hourly = net_energy_data.get("hourly") or []
    if not isinstance(hourly, list):
        hourly = []

    uretim_toplam = 0.0
    tuketim_toplam = 0.0
    peak_uretim_saat = ""
    peak_uretim_val = -1.0
    tuketim_by_saat: list[tuple[str, float]] = []

    for row in hourly:
        if not isinstance(row, dict):
            continue
        saat = str(row.get("saat", ""))
        u = _float_from(row, "uretim", "uretim_kwh")
        t = _float_from(row, "tuketim", "tuketim_kwh", "tahmini_tuketim_kwh")
        uretim_toplam += u
        tuketim_toplam += t
        if u > peak_uretim_val:
            peak_uretim_val = u
            peak_uretim_saat = saat
        tuketim_by_saat.append((saat, t))

    tuketim_by_saat.sort(key=lambda x: x[1], reverse=True)
    peak_tuketim_saatler = [s for s, v in tuketim_by_saat[:3] if v > 0]

    satici_saatler = [
        str(r["saat"]) for r in hourly if isinstance(r, dict) and r.get("durum") == "SATICI"
    ]
    alici_saatler = [
        str(r["saat"]) for r in hourly if isinstance(r, dict) and r.get("durum") == "ALICI"
    ]

    summary = net_energy_data.get("summary") if isinstance(net_energy_data.get("summary"), dict) else {}

    return {
        "uretim_toplam_kwh": round(uretim_toplam, 3),
        "tuketim_toplam_kwh": round(tuketim_toplam, 3),
        "peak_uretim_saat": peak_uretim_saat or "—",
        "peak_tuketim_saatler": peak_tuketim_saatler,
        "satici_saatler": satici_saatler,
        "alici_saatler": alici_saatler,
        "ozet_en_iyi_satis": summary.get("en_iyi_satis_saati", ""),
        "ozet_en_kotu": summary.get("en_kotu_saat", ""),
    }


def _summarize_prices(price_forecast: list[dict[str, Any]]) -> dict[str, Any]:
    rows = [r for r in price_forecast if isinstance(r, dict) and "fiyat_tl_kwh" in r]
    if not rows:
        return {"ucuz_saat": "—", "pahali_saat": "—", "ucuz_fiyat": 0.0, "pahali_fiyat": 0.0}

    def fiyat(r: dict[str, Any]) -> float:
        try:
            return float(r["fiyat_tl_kwh"])
        except (TypeError, ValueError):
            return 0.0

    ucuz = min(rows, key=fiyat)
    pahali = max(rows, key=fiyat)
    return {
        "ucuz_saat": str(ucuz.get("saat", "")),
        "pahali_saat": str(pahali.get("saat", "")),
        "ucuz_fiyat": round(fiyat(ucuz), 4),
        "pahali_fiyat": round(fiyat(pahali), 4),
    }


def _profile_lines(user_profile: dict[str, Any]) -> str:
    if not user_profile:
        return "Panel bilgisi verilmedi."
    keys = [
        ("panel_kwp", "kWp"),
        ("azimuth_deg", "azimut (°)"),
        ("tilt_deg", "eğim (°)"),
        ("shading", "gölgeleme"),
        ("inverter_efficiency", "inverter verimi"),
        ("num_people", "hane kişi sayısı"),
        ("has_ev", "elektrikli araç"),
        ("has_heat_pump", "ısı pompası"),
        ("lat", "enlem"),
        ("lon", "boylam"),
    ]
    parts: list[str] = []
    for k, label in keys:
        if k in user_profile:
            parts.append(f"- {label}: {user_profile[k]}")
    return "\n".join(parts) if parts else str(user_profile)


def _build_user_prompt(
    net_summary: dict[str, Any],
    price_summary: dict[str, Any],
    user_profile: dict[str, Any],
) -> str:
    return f"""Aşağıdaki verilere dayanarak tam 3 tavsiye üret.

Kullanıcı panel / profil:
{_profile_lines(user_profile)}

Bugünkü üretim özeti:
- Toplam üretim (tahmini): {net_summary["uretim_toplam_kwh"]} kWh
- Üretim zirve saati: {net_summary["peak_uretim_saat"]}

Bugünkü tüketim özeti:
- Toplam tüketim (tahmini): {net_summary["tuketim_toplam_kwh"]} kWh
- En yüksek tüketim saatleri: {", ".join(net_summary["peak_tuketim_saatler"]) or "—"}

Net enerji (saatlik durum):
- SATICI olduğun saatler: {", ".join(net_summary["satici_saatler"]) or "—"}
- ALICI olduğun saatler: {", ".join(net_summary["alici_saatler"]) or "—"}
- Özet (varsa): en iyi satış saati {net_summary["ozet_en_iyi_satis"] or "—"}, en zor saat {net_summary["ozet_en_kotu"] or "—"}

Mahalle P2P fiyat özeti:
- En ucuz saat: {price_summary["ucuz_saat"]} ({price_summary["ucuz_fiyat"]} TL/kWh)
- En pahalı saat: {price_summary["pahali_saat"]} ({price_summary["pahali_fiyat"]} TL/kWh)

Yanıtı YALNIZCA geçerli JSON olarak ver, başka metin ekleme. Şu şema:
{{
  "tavsiyeler": [
    {{"saat": "HH:MM", "mesaj": "tek cümle, aksiyon odaklı Türkçe"}},
    {{"saat": "HH:MM", "mesaj": "..."}},
    {{"saat": "HH:MM", "mesaj": "..."}}
  ]
}}
Tam 3 eleman olmalı; saat alanları verilerle tutarlı olsun."""


def _extract_json_object(text: str) -> dict[str, Any] | None:
    text = text.strip()
    m = re.search(r"\{[\s\S]*\}", text)
    if not m:
        return None
    try:
        return json.loads(m.group(0))
    except json.JSONDecodeError:
        return None


def _normalize_response(data: dict[str, Any] | None) -> dict[str, Any]:
    if not data or "tavsiyeler" not in data:
        return dict(_FALLBACK)
    t = data["tavsiyeler"]
    if not isinstance(t, list):
        return dict(_FALLBACK)
    out: list[dict[str, str]] = []
    for item in t:
        if isinstance(item, dict) and "mesaj" in item:
            saat = str(item.get("saat", "12:00"))
            out.append({"saat": saat, "mesaj": str(item["mesaj"]).strip()})
        if len(out) >= 3:
            break
    i = 0
    while len(out) < 3 and i < len(_FALLBACK["tavsiyeler"]):
        out.append(dict(_FALLBACK["tavsiyeler"][i]))
        i += 1
    return {"tavsiyeler": out[:3]}


def generate_recommendations(
    net_energy_data: dict[str, Any],
    price_forecast: list[dict[str, Any]],
    user_profile: dict[str, Any],
    *,
    api_key: str | None = None,
) -> dict[str, Any]:
    """
    Claude ile 3 Türkçe tavsiye döner; API hatasında statik yedek kullanılır.

    net_energy_data: calculate_net_energy çıktısı (hourly + summary).
    price_forecast: forecast_neighborhood_prices çıktısı.
    """
    key = (api_key or os.getenv("ANTHROPIC_API_KEY", "")).strip()
    net_summary = _summarize_net_energy(net_energy_data)
    price_summary = _summarize_prices(price_forecast)
    user_prompt = _build_user_prompt(net_summary, price_summary, user_profile)

    if not key or anthropic is None:
        return _normalize_response(None)

    try:
        client = anthropic.Anthropic(api_key=key)
        msg = client.messages.create(
            model=CLAUDE_MODEL,
            max_tokens=1200,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user_prompt}],
        )
        text_parts: list[str] = []
        for block in msg.content:
            if hasattr(block, "text"):
                text_parts.append(block.text)
        raw = "".join(text_parts)
        parsed = _extract_json_object(raw)
        return _normalize_response(parsed)
    except Exception:
        return dict(_FALLBACK)


if __name__ == "__main__":
    demo_net = {
        "hourly": [
            {"saat": "14:00", "uretim": 4.1, "tuketim": 1.8, "durum": "SATICI"},
            {"saat": "19:00", "uretim": 0.2, "tuketim": 2.9, "durum": "ALICI"},
        ],
        "summary": {"en_iyi_satis_saati": "14:00", "en_kotu_saat": "19:00"},
    }
    demo_prices = [
        {"saat": "14:00", "fiyat_tl_kwh": 2.6},
        {"saat": "19:00", "fiyat_tl_kwh": 3.9},
    ]
    demo_profile = {"panel_kwp": 5.0, "has_ev": True, "num_people": 3}
    out = generate_recommendations(demo_net, demo_prices, demo_profile)
    print(json.dumps(out, ensure_ascii=False, indent=2))
