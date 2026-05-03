import os
from groq import Groq

API_KEY = os.getenv("GROQ_API_KEY")

if not API_KEY:
    raise ValueError("GROQ_API_KEY ortam degiskeni tanimli degil.")

client = Groq(api_key=API_KEY)

def build_prompt(user_data):
    return f"""Asagidaki kurallara kesinlikle uy:
KURAL: Sadece Turkiye Turkcesi kullan. Baska hicbir dil kelimesi kullanma.
KURAL: Yanit 2 cumle olmali.
KURAL: Somut rakam kullan.

Iyi ornek:
"Bugun 12 kWh fazla enerjin var, komsuna 2.80 TL uzerinden satarsan 33 TL kazanirsin. Yarin hava bulutlu olacagi icin bugun satmak daha kazancli."

Kotu ornek (YAPMA):
"Energia condiciones fazla, therefore sat."

Simdi su bilgilere gore 2 cumle yaz:
- Uretim: {user_data["uretim_kwh"]} kWh
- Tuketim: {user_data["tuketim_kwh"]} kWh  
- Hava: {user_data["hava"]}
- Fiyat: {user_data["fiyat"]} TL/kWh
- Komsularda enerji: {user_data["komsu_arz"]}"""

def get_recommendation(user_data):
    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": build_prompt(user_data)}],
        max_tokens=300
    )
    return response.choices[0].message.content

if __name__ == "__main__":
    test_verisi = {
        "rol": "uretici",
        "uretim_kwh": 12,
        "tuketim_kwh": 4,
        "hava": "yarin bulutlu",
        "fiyat": "2.80",
        "komsu_arz": "Hayir"
    }
    print("EcoTrade Onerisi:")
    print(get_recommendation(test_verisi))