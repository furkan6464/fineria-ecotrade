"""
Integration tests against a running FastAPI server (default http://localhost:8000).
Requires: pip install requests
"""

from __future__ import annotations

import numbers

import requests

BASE_URL = "http://localhost:8000"
TIMEOUT_SEC = 25.0

SAMPLE_PANEL = {
    "lat": 40.76,
    "lon": 31.16,
    "panel_kwp": 5.0,
    "azimuth_deg": 180.0,
    "tilt_deg": 30.0,
    "shading": "Yok",
    "inverter_efficiency": 0.92,
    "num_people": 3,
    "has_ev": False,
    "has_heat_pump": False,
}


def main() -> None:
    passed = 0
    n = 3

    try:
        r = requests.get(f"{BASE_URL}/health", timeout=TIMEOUT_SEC)
        if r.status_code != 200:
            print(f"FAIL GET /health: HTTP {r.status_code}")
        else:
            body = r.json()
            if body == {"status": "ok"}:
                passed += 1
                print('PASS GET /health: body == {"status": "ok"}')
            else:
                print(f"FAIL GET /health: unexpected JSON {body!r}")
    except requests.RequestException as exc:
        print(f"FAIL GET /health: {type(exc).__name__}: {exc}")

    try:
        r = requests.post(
            f"{BASE_URL}/forecast/next6h",
            json=SAMPLE_PANEL,
            timeout=TIMEOUT_SEC,
        )
        if r.status_code != 200:
            print(
                f"FAIL POST /forecast/next6h: HTTP {r.status_code} — {r.text[:400]}",
            )
            print(
                "FAIL forecast payload: önceki kontroller başarısız veya .env / residual_model eksik.",
            )
        else:
            data = r.json()

            if not isinstance(data, list):
                print(f"FAIL POST /forecast/next6h: expected list, got {type(data).__name__}")
                print("FAIL forecast numeric checks skipped.")
            elif len(data) != 6:
                print(f"FAIL POST /forecast/next6h: expected 6 items, got {len(data)}")
                print("FAIL forecast numeric checks skipped.")
            else:
                required = (
                    "saat",
                    "uretim_kwh",
                    "tuketim_kwh",
                    "fazla_kwh",
                    "cloud_cover",
                )
                struct_ok = True
                for i, item in enumerate(data):
                    if not isinstance(item, dict):
                        struct_ok = False
                        print(f"FAIL POST /forecast/next6h: item {i} not object")
                        break
                    missing = [k for k in required if k not in item]
                    if missing:
                        struct_ok = False
                        print(f"FAIL POST /forecast/next6h: item {i} missing {missing}")
                        break
                if struct_ok:
                    passed += 1
                    print(
                        "PASS POST /forecast/next6h: list[6] with saat, uretim_kwh, "
                        "tuketim_kwh, fazla_kwh, cloud_cover",
                    )

                if struct_ok:
                    bad_reason = None
                    for i, item in enumerate(data):
                        for key in ("uretim_kwh", "tuketim_kwh", "fazla_kwh"):
                            v = item.get(key)
                            if isinstance(v, bool) or not isinstance(v, numbers.Real):
                                bad_reason = f"item {i}: {key} not numeric: {v!r}"
                                break
                        if bad_reason:
                            break
                    if bad_reason is None:
                        passed += 1
                        print("PASS forecast numeric fields: uretim/tuketim/fazla are numeric")
                    else:
                        print(f"FAIL forecast numeric fields: {bad_reason}")
                else:
                    print("FAIL forecast numeric fields: structure invalid")
    except requests.RequestException as exc:
        print(f"FAIL POST /forecast/next6h: {type(exc).__name__}: {exc}")
        print(f"FAIL forecast numeric fields: {type(exc).__name__}: {exc}")

    print(f"{passed}/{n} checks passed")


if __name__ == "__main__":
    main()
