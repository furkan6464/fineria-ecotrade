"""
Photovoltaic production estimate from geometry, irradiance, temperature, and losses.
"""

from __future__ import annotations

import math
from typing import Union

ShadingInput = Union[str, float]

SHADING_MAP = {
    "yok": 1.0,
    "kısmi": 0.85,
    "kismi": 0.85,
    "çok": 0.6,
    "cok": 0.6,
}


def _shading_multiplier(shading_factor: ShadingInput) -> float:
    if isinstance(shading_factor, (int, float)):
        return float(shading_factor)
    key = str(shading_factor).strip().lower()
    if key in SHADING_MAP:
        return SHADING_MAP[key]
    raise ValueError(
        f"shading_factor must be a float in [0,1] or one of {list(SHADING_MAP.keys())}",
    )


def _solar_declination_rad(day_of_year: int) -> float:
    """Declination (Cooper / common approximation), radians."""
    n = float(day_of_year)
    return math.radians(23.45) * math.sin(2.0 * math.pi * (284.0 + n) / 365.0)


def _hour_angle_rad(hour_local_solar: float) -> float:
    """Hour angle: 0 at solar noon, ~15° per hour from noon."""
    return math.radians(15.0 * (hour_local_solar - 12.0))


def _sun_elevation_azimuth(
    lat_deg: float,
    lon_deg: float,
    hour: float,
    day_of_year: int,
) -> tuple[float, float]:
    """
    Solar elevation and azimuth (radians). Azimuth clockwise from north (0 = north, pi = south).
    lon_deg unused in simplified local-solar-time model (hour assumed solar/local aligned).
    """
    _ = lon_deg
    phi = math.radians(lat_deg)
    delta = _solar_declination_rad(day_of_year)
    omega = _hour_angle_rad(hour)

    sin_el = math.sin(phi) * math.sin(delta) + math.cos(phi) * math.cos(delta) * math.cos(omega)
    sin_el = max(-1.0, min(1.0, sin_el))
    elevation = math.asin(sin_el)

    # Azimuth (clockwise from north), solar geometry convention for northern latitudes
    x = -math.sin(omega) * math.cos(delta)
    y = math.cos(omega) * math.sin(phi) * math.cos(delta) - math.sin(delta) * math.cos(phi)
    azimuth = math.atan2(x, y)

    return elevation, azimuth


def calculate_production(
    lat: float,
    lon: float,
    panel_kwp: float,
    azimuth_deg: float,
    tilt_deg: float,
    shading_factor: ShadingInput,
    inverter_efficiency: float,
    ghi_wm2: float,
    temp_celsius: float,
    hour: float,
    day_of_year: int,
) -> float:
    """
    Theoretical AC-side energy for one hour (kWh) from standard PV engineering steps.

    Step 1 — Incidence: cos_theta = max(0, cos(tilt)*sin(el) + sin(tilt)*cos(el)*cos(az_diff))
    Step 2 — POA: poa_irradiance = ghi_wm2 * cos_theta
    Step 3 — Temperature: temp_coeff = 1 - 0.004 * max(0, T - 25)
    Step 4 — Shading: "Yok"/"Kısmi"/"Çok" or numeric multiplier
    Step 5 — production_kwh = kWp * (poa/1000) * temp_coeff * shading * inverter_eff

    azimuth_deg: panel azimuth, degrees clockwise from north (south-facing ~ 180° in NH).
    inverter_efficiency: e.g. 0.95 for 95%.
    """
    solar_el, solar_az = _sun_elevation_azimuth(lat, lon, hour, day_of_year)

    if solar_el <= 0.0 or ghi_wm2 <= 0.0:
        return 0.0

    tilt_rad = math.radians(tilt_deg)
    panel_az_rad = math.radians(azimuth_deg)
    azimuth_diff_rad = solar_az - panel_az_rad

    cos_theta = math.cos(tilt_rad) * math.sin(solar_el) + math.sin(
        tilt_rad
    ) * math.cos(solar_el) * math.cos(azimuth_diff_rad)
    cos_theta = max(0.0, cos_theta)

    poa_irradiance = ghi_wm2 * cos_theta

    temp_coeff = 1.0 - 0.004 * max(0.0, temp_celsius - 25.0)
    temp_coeff = max(0.0, temp_coeff)

    shade = _shading_multiplier(shading_factor)

    production_kwh = (
        panel_kwp
        * (poa_irradiance / 1000.0)
        * temp_coeff
        * shade
        * inverter_efficiency
    )
    return float(production_kwh)


if __name__ == "__main__":
    # Düzce — 5 kWp, south (~180° from north), 30° tilt, no shading, 95% inverter
    lat_duzce = 40.76
    lon_duzce = 31.16
    kwp = 5.0
    azimuth_south = 180.0
    tilt = 30.0
    shading = "Yok"
    inv_eta = 0.95
    ghi = 850.0
    temp_c = 28.0
    hour_sol = 12.0
    doy = 172

    out = calculate_production(
        lat_duzce,
        lon_duzce,
        kwp,
        azimuth_south,
        tilt,
        shading,
        inv_eta,
        ghi,
        temp_c,
        hour_sol,
        doy,
    )

    print("Sample (Duzce, 5 kWp, south 180 deg, tilt 30 deg, Yok shading, 95% inverter):")
    print(f"  Inputs: GHI={ghi} W/m2, T={temp_c} C, hour={hour_sol}, day_of_year={doy}")
    print(f"  production_kwh (one hour) ~= {out:.4f} kWh")
