from fastapi import FastAPI
from pydantic import BaseModel
from recommendation_service import get_recommendation

app = FastAPI()

class EnerjiVerisi(BaseModel):
    rol: str
    uretim_kwh: float
    tuketim_kwh: float
    hava: str
    fiyat: str
    komsu_arz: str

@app.post("/ai/suggest")
def suggest(veri: EnerjiVerisi):
    user_data = veri.dict()
    oneri = get_recommendation(user_data)
    return {"oneri": oneri}