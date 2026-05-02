"""
Personalized hourly household consumption profiles (kWh per hour).
"""

from __future__ import annotations

import numpy as np


def generate_consumption_profile(
    num_people: int,
    has_ev: bool,
    has_heat_pump: bool,
    season: str = "summer",
) -> list[float]:
    """
    Return 24 hourly kWh values (index 0 = hour 0:00-1:00).

    Base rates are per person for that hour slot; scaled by num_people.
    ±5% multiplicative noise per hour for realism.
    """
    rng = np.random.default_rng()
    hourly = np.zeros(24, dtype=float)

    night_hours = {23, 0, 1, 2, 3, 4, 5, 6}
    morning_hours = {7, 8, 9}
    midday_hours = set(range(10, 18))  # 10-17 inclusive
    evening_hours = {18, 19, 20, 21, 22}

    for h in range(24):
        if h in night_hours:
            base = 0.1 * num_people
        elif h in morning_hours:
            base = 0.4 * num_people
        elif h in midday_hours:
            base = 0.2 * num_people
        elif h in evening_hours:
            base = 0.6 * num_people
        else:
            base = 0.2 * num_people
        noise = rng.uniform(0.95, 1.05)
        hourly[h] = base * noise

    if has_ev:
        for h in (22, 23, 0):
            hourly[h] += 2.0

    if has_heat_pump and season.lower() == "summer":
        for h in range(13, 18):
            hourly[h] += 0.8

    return [float(round(x, 4)) for x in hourly]


def get_user_profile_from_input() -> list[float]:
    """Üç Türkçe soru (input); 24 saatlik profili döndürür."""
    print("--- Kişiselleştirilmiş saatlik tüketim ---\n")
    while True:
        try:
            num_people = int(input("Hanede kaç kişi yaşıyor? (tam sayı): ").strip())
            if num_people >= 1:
                break
        except ValueError:
            pass
        print("Lütfen 1 veya daha büyük bir tam sayı girin.")

    ev_str = input("Elektrikli araç (gece şarj) var mı? (e=Evet, h=Hayır): ").strip().lower()
    has_ev = ev_str in ("e", "evet", "y", "yes", "1")

    hp_str = input("Isı pompası var mı? (e=Evet, h=Hayır): ").strip().lower()
    has_heat_pump = hp_str in ("e", "evet", "y", "yes", "1")

    return generate_consumption_profile(
        num_people=num_people,
        has_ev=has_ev,
        has_heat_pump=has_heat_pump,
        season="summer",
    )


def _plot_profile(profile: list[float], path: str = "consumption_profile.png") -> None:
    import matplotlib.pyplot as plt

    hours = np.arange(24)
    fig, ax = plt.subplots(figsize=(10, 4.5))
    ax.bar(hours, profile, color="#2980b9", edgecolor="#1f4e79", linewidth=0.4)
    ax.set_xlabel("Saat")
    ax.set_ylabel("Tüketim (kWh)")
    ax.set_title("Saatlik tahmini tüketim profili")
    ax.set_xticks(hours)
    ax.set_xticklabels([f"{h:02d}" for h in hours], rotation=45, ha="right", fontsize=8)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


if __name__ == "__main__":
    profile = get_user_profile_from_input()
    print("\n24 saatlik tüketim (kWh):")
    for h, kwh in enumerate(profile):
        print(f"  {h:02d}:00  {kwh:.4f} kWh")
    _plot_profile(profile)
    print(f"\nGrafik kaydedildi: consumption_profile.png")
