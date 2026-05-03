from recommendation_service import get_recommendation

senaryolar = [
    {
        "ad": "Senaryo 1 - Gunes piki, tuketim dusuk",
        "veri": {
            "rol": "uretici",
            "uretim_kwh": 15,
            "tuketim_kwh": 3,
            "hava": "bugun cok gunes var",
            "fiyat": "2.80",
            "komsu_arz": "Hayir, komsularda talep var"
        }
    },
    {
        "ad": "Senaryo 2 - Gece, gunes yok",
        "veri": {
            "rol": "tuketici",
            "uretim_kwh": 0,
            "tuketim_kwh": 8,
            "hava": "gece, gunes yok",
            "fiyat": "3.50",
            "komsu_arz": "Hayir, komsularda da enerji yok"
        }
    },
    {
        "ad": "Senaryo 3 - Fiyat dusuyor, camasir onerisi",
        "veri": {
            "rol": "tuketici",
            "uretim_kwh": 0,
            "tuketim_kwh": 5,
            "hava": "bulutlu ama oglen gunes bekleniyor",
            "fiyat": "1.20",
            "komsu_arz": "Evet, komsularda fazla enerji var"
        }
    },
    {
        "ad": "Senaryo 4 - Uretici icin sat onerisi",
        "veri": {
            "rol": "uretici",
            "uretim_kwh": 20,
            "tuketim_kwh": 4,
            "hava": "bugun ve yarin gunes acik",
            "fiyat": "4.00",
            "komsu_arz": "Hayir, komsularda yuksek talep var"
        }
    },
    {
        "ad": "Senaryo 5 - Her ikisi de, denge durumu",
        "veri": {
            "rol": "her ikisi",
            "uretim_kwh": 6,
            "tuketim_kwh": 6,
            "hava": "parcali bulutlu",
            "fiyat": "2.80",
            "komsu_arz": "Evet, biraz fazla enerji var"
        }
    }
]

for senaryo in senaryolar:
    print(f"\n{'='*50}")
    print(f" {senaryo['ad']}")
    print(f"{'='*50}")
    print(f"EcoTrade Onerisi:")
    print(get_recommendation(senaryo["veri"]))