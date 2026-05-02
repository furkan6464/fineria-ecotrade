"""
Two-layer hybrid: physics baseline (solar_physics) + XGBoost residual learner.
"""

from __future__ import annotations

import pickle
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import mean_squared_error
from solar_physics import calculate_production
from weather_api import estimate_ghi
from xgboost import XGBRegressor

np.random.seed(42)

BASE_DIR = Path(__file__).resolve().parent
FEATURES_CSV = BASE_DIR / "features.csv"
MOCK_CSV = BASE_DIR / "mock_energy_data.csv"
OUT_CSV = BASE_DIR / "hybrid_predictions.csv"
RESIDUAL_PKL = BASE_DIR / "residual_model.pkl"

# Düzce, train_model / feature pipeline START
START_UTC = pd.Timestamp("2026-01-01 00:00:00", tz="UTC")
LAT, LON = 40.76, 31.16
N_PRODUCERS = 5
N_TRAIN = 6 * 24 - 2  # 142, same as train_model

PANEL_KWP = 5.0
AZIMUTH = 180.0
TILT = 30.0
SHADING = "Yok"
INVERTER_ETA = 0.92

XGB_RESIDUAL_FEATURES = [
    "saat",
    "gun",
    "cloud_cover_percent",
    "temp_celsius",
    "onceki_uretim",
    "mevsim",
]


def _load_hourly_production() -> pd.Series:
    raw = pd.read_csv(MOCK_CSV, parse_dates=["timestamp"])
    agg = (
        raw.groupby("timestamp", sort=True)["solar_production_kwh"]
        .sum()
        .sort_index()
        .reset_index(drop=True)
    )
    return agg


def _cloud_cover_deterministic(df: pd.DataFrame) -> np.ndarray:
    """Reproducible pseudo cloud cover % for rows without weather merge."""
    rng = np.random.default_rng(42)
    base = 45.0 + 35.0 * np.sin(2 * np.pi * (df["saat"].to_numpy() - 8.0) / 24.0)
    noise = rng.uniform(-12.0, 12.0, size=len(df))
    return np.clip(base + noise, 5.0, 95.0)


def _day_of_year_per_row(n_rows: int) -> np.ndarray:
    """features row r aligns with hourly index j=r+1 → timestamp START + j hours."""
    out = np.empty(n_rows, dtype=np.int32)
    for r in range(n_rows):
        j = r + 1
        ts = START_UTC + pd.Timedelta(hours=j)
        out[r] = int(ts.dayofyear)
    return out


def main() -> None:
    df = pd.read_csv(FEATURES_CSV)
    hourly_prod = _load_hourly_production()
    n = len(df)
    if len(hourly_prod) != n + 2:
        raise ValueError(
            f"Beklenen {n + 2} saatlik kayıt mock veride, bulunan {len(hourly_prod)}",
        )

    # Bir 5 kWp panel ile kıyas: mahalle toplam güneş / üretici sayısı
    j_idx = np.arange(1, n + 1, dtype=np.int32)
    actual_production = hourly_prod.iloc[j_idx].to_numpy(dtype=float) / N_PRODUCERS

    df["temp_celsius"] = df["sicaklik"].astype(float)
    df["cloud_cover_percent"] = _cloud_cover_deterministic(df)
    df["day_of_year"] = _day_of_year_per_row(n)

    ghi = np.array(
        [
            estimate_ghi(
                float(df["cloud_cover_percent"].iloc[i]),
                float(df["saat"].iloc[i]),
                int(df["day_of_year"].iloc[i]),
            )
            for i in range(n)
        ]
    )

    physics = np.empty(n, dtype=float)
    for i in range(n):
        physics[i] = calculate_production(
            LAT,
            LON,
            PANEL_KWP,
            AZIMUTH,
            TILT,
            SHADING,
            INVERTER_ETA,
            float(ghi[i]),
            float(df["temp_celsius"].iloc[i]),
            float(df["saat"].iloc[i]),
            int(df["day_of_year"].iloc[i]),
        )
    df["physics_prediction"] = physics
    df["actual_production"] = actual_production
    df["residual"] = actual_production - physics

    X_res = df[XGB_RESIDUAL_FEATURES].copy()
    y_res = df["residual"].to_numpy()
    y_act = df["actual_production"].to_numpy()

    X_train, X_test = X_res.iloc[:N_TRAIN], X_res.iloc[N_TRAIN:]
    y_res_train, y_res_test = y_res[:N_TRAIN], y_res[N_TRAIN:]
    y_act_train, y_act_test = y_act[:N_TRAIN], y_act[N_TRAIN:]
    phys_train, phys_test = physics[:N_TRAIN], physics[N_TRAIN:]

    residual_model = XGBRegressor(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.05,
        random_state=42,
    )
    residual_model.fit(X_train, y_res_train)
    res_pred_test = residual_model.predict(X_test)

    direct_model = XGBRegressor(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.05,
        random_state=42,
    )
    direct_model.fit(X_train, y_act_train)
    direct_pred_test = direct_model.predict(X_test)

    hybrid_test = phys_test + res_pred_test

    def rmse(a: np.ndarray, b: np.ndarray) -> float:
        return float(np.sqrt(mean_squared_error(a, b)))

    rmse_phys = rmse(y_act_test, phys_test)
    rmse_xgb = rmse(y_act_test, direct_pred_test)
    rmse_hyb = rmse(y_act_test, hybrid_test)

    best = min(rmse_phys, rmse_xgb, rmse_hyb)
    tag_phys = "  [en iyi]" if rmse_phys == best else ""
    tag_xgb = "  [en iyi]" if rmse_xgb == best else ""
    tag_hyb = "  [en iyi]" if rmse_hyb == best else ""

    print(f"Fiziksel Model RMSE:  {rmse_phys:.2f} kWh{tag_phys}")
    print(f"Sadece XGBoost RMSE:  {rmse_xgb:.2f} kWh{tag_xgb}")
    print(f"Hibrit Model RMSE:    {rmse_hyb:.2f} kWh{tag_hyb}")

    r_test = np.arange(N_TRAIN, n, dtype=np.int64)
    ts_test = START_UTC + pd.to_timedelta(r_test + 2, unit="h")
    out = pd.DataFrame(
        {
            "timestamp": ts_test.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "actual_production_kwh": y_act_test,
            "physics_prediction_kwh": phys_test,
            "residual_predicted_kwh": res_pred_test,
            "hybrid_prediction_kwh": hybrid_test,
        }
    )
    out.to_csv(OUT_CSV, index=False)

    with open(RESIDUAL_PKL, "wb") as f:
        pickle.dump(residual_model, f)

    print(f"\nKaydedildi: {OUT_CSV}")
    print(f"Kaydedildi: {RESIDUAL_PKL}")


if __name__ == "__main__":
    main()
