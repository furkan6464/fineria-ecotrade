"""
Train XGBoost on features.csv to predict fazla_kwh (next-hour neighborhood net).
"""

from __future__ import annotations

import json
import pickle

import numpy as np
import pandas as pd
from sklearn.metrics import mean_absolute_error, mean_squared_error
from xgboost import XGBRegressor

np.random.seed(42)

FEATURES_CSV = "features.csv"
PREDICTIONS_CSV = "predictions.csv"
MODEL_PKL = "model.pkl"
MODEL_FEATURES_JSON = "model_features.json"

FEATURE_COLS = [
    "saat",
    "gun",
    "onceki_uretim",
    "onceki_tuketim",
    "mevsim",
    "sicaklik",
]
TARGET_COL = "fazla_kwh"

# Aligned with generate_mock_data / feature_engineering: week starts 2026-01-01 00:00 UTC
START_UTC = pd.Timestamp("2026-01-01 00:00:00", tz="UTC")

# First 6 days of targets = hour indices 2..143 -> feature rows 0..141 (142 rows).
# Last 1 day = hour indices 144..167 -> feature rows 142..165 (24 rows).
N_TRAIN = 6 * 24 - 2  # 142


def target_timestamps(n_rows: int) -> pd.Series:
    """Start of the hour for which fazla_kwh applies (row r -> hour index r+2 from START)."""
    hours_from_start = np.arange(2, 2 + n_rows, dtype=np.int64)
    return START_UTC + pd.to_timedelta(hours_from_start, unit="h")


def main() -> None:
    df = pd.read_csv(FEATURES_CSV)
    df.insert(0, "timestamp", target_timestamps(len(df)))

    X = df[FEATURE_COLS]
    y = df[TARGET_COL]

    X_train, X_test = X.iloc[:N_TRAIN], X.iloc[N_TRAIN:]
    y_train, y_test = y.iloc[:N_TRAIN], y.iloc[N_TRAIN:]
    ts_test = df["timestamp"].iloc[N_TRAIN:]

    model = XGBRegressor(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.05,
        random_state=42,
    )
    model.fit(X_train, y_train)

    with open(MODEL_PKL, "wb") as f:
        pickle.dump(model, f)
    with open(MODEL_FEATURES_JSON, "w", encoding="utf-8") as f:
        json.dump(FEATURE_COLS, f, indent=2, ensure_ascii=False)
    print("Model kaydedildi: model.pkl")

    y_pred = model.predict(X_test)
    rmse = float(np.sqrt(mean_squared_error(y_test, y_pred)))
    mae = float(mean_absolute_error(y_test, y_pred))
    print(f"Model RMSE: {rmse:.2f} kWh | MAE: {mae:.2f} kWh")

    out = pd.DataFrame(
        {
            "timestamp": ts_test.dt.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "actual": y_test.values,
            "predicted": y_pred,
        }
    )
    out.to_csv(PREDICTIONS_CSV, index=False)


if __name__ == "__main__":
    main()
