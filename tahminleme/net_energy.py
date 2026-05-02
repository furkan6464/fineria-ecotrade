"""
Net energy: production minus consumption with status and summary (Turkish).
"""

from __future__ import annotations

from typing import Any


def _uretim(row: dict[str, Any]) -> float:
    for k in ("uretim_kwh", "uretim"):
        if k in row:
            return float(row[k])
    raise KeyError("Uretim icin 'uretim_kwh' veya 'uretim' gerekli")


def _tuketim(row: dict[str, Any]) -> float:
    for k in ("tahmini_tuketim_kwh", "tuketim_kwh", "tuketim"):
        if k in row:
            return float(row[k])
    raise KeyError("Tuketim icin 'tahmini_tuketim_kwh', 'tuketim_kwh' veya 'tuketim' gerekli")


def _durum(fazla: float) -> str:
    if fazla > 0.5:
        return "SATICI"
    if fazla < -0.5:
        return "ALICI"
    return "DENGEDE"


def calculate_net_energy(
    production_forecast: list[dict[str, Any]],
    consumption_forecast: list[dict[str, Any]],
) -> dict[str, Any]:
    """
    Iki listeyi 'saat' alanina gore birlestirir (kesisim).

    production_forecast: [{"saat": "14:00", "uretim_kwh": ...}, ...]
    consumption_forecast: [{"saat": "14:00", "tahmini_tuketim_kwh": ...}, ...]
    """
    prod_by = {str(p["saat"]): p for p in production_forecast}
    cons_by = {str(c["saat"]): c for c in consumption_forecast}
    common = sorted(set(prod_by.keys()) & set(cons_by.keys()))

    if not common:
        raise ValueError("Ortak saat yok; saat stringleri (HH:00) eslesmeli.")

    hourly: list[dict[str, Any]] = []
    fazlalar: list[float] = []

    for saat in common:
        u = _uretim(prod_by[saat])
        t = _tuketim(cons_by[saat])
        fazla = round(u - t, 3)
        fazlalar.append(fazla)
        hourly.append(
            {
                "saat": saat,
                "uretim": round(u, 3),
                "tuketim": round(t, 3),
                "fazla_kwh": fazla,
                "durum": _durum(fazla),
            }
        )

    toplam_fazla = float(sum(max(0.0, f) for f in fazlalar))
    toplam_acik = float(sum(max(0.0, -f) for f in fazlalar))

    best_idx = max(range(len(fazlalar)), key=lambda i: fazlalar[i])
    worst_idx = min(range(len(fazlalar)), key=lambda i: fazlalar[i])
    en_iyi = hourly[best_idx]["saat"]
    en_kotu = hourly[worst_idx]["saat"]

    tavsiye = (
        f"Bugun en fazla saat {en_iyi}'te satis yapabilirsiniz. "
        f"En zor saat: {en_kotu} (tuketim baskisi)."
    )

    summary = {
        "toplam_fazla_kwh": round(toplam_fazla, 3),
        "toplam_acik_kwh": round(toplam_acik, 3),
        "en_iyi_satis_saati": en_iyi,
        "en_kotu_saat": en_kotu,
        "tavsiye": tavsiye,
    }

    return {"hourly": hourly, "summary": summary}


if __name__ == "__main__":
    prod = [
        {"saat": "14:00", "uretim_kwh": 4.1},
        {"saat": "19:00", "uretim_kwh": 0.2},
    ]
    cons = [
        {"saat": "14:00", "tahmini_tuketim_kwh": 1.8},
        {"saat": "19:00", "tahmini_tuketim_kwh": 2.9},
    ]
    out = calculate_net_energy(prod, cons)
    print(out)
