import random
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from database import Hane, Islem, Teklif, get_db, init_db

# --- Sabitler (fiyat algoritması) ---
BAZ_FIYAT = 2.10
MIN_FIYAT = 1.35
MAX_FIYAT = 3.80


class OfferRequest(BaseModel):
    satan_id: int
    kwh: float = Field(gt=0)


class BuyRequest(BaseModel):
    alan_id: int
    kwh: float = Field(gt=0)


async def hesapla_fiyat(session: AsyncSession) -> float:
    """Baz fiyat 2.10 TL; arz/talep simülasyonu ile sınırlı fiyat."""
    result = await session.execute(
        select(func.coalesce(func.sum(Teklif.kwh), 0.0)).where(Teklif.durum == "aktif")
    )
    toplam_arz_kwh = float(result.scalar_one())
    arz_orani = toplam_arz_kwh / 100.0
    # Hackathon simülasyonu: talep oranı rastgele (sabit aralık)
    talep_orani = random.uniform(0.2, 0.4)

    ham = BAZ_FIYAT * (1.0 - arz_orani * 0.3 + talep_orani * 0.2)
    return max(MIN_FIYAT, min(MAX_FIYAT, ham))


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield


app = FastAPI(
    title="EcoTrade P2P Borsa API",
    lifespan=lifespan,
)


@app.get("/", include_in_schema=False)
def read_root():
    return RedirectResponse(url="/docs")


@app.get("/health")
def health_check():
    return {"status": "aktif", "mesaj": "Veritabanı ve API sorunsuz çalışıyor."}


@app.post("/test-users")
async def seed_test_users(session: AsyncSession = Depends(get_db)):
    """Hackathon/test için haneler tablosuna örnek kullanıcıları ekler veya günceller."""
    test_data = [
        {"id": 1, "ad": "Ahmet", "tip": "ureten", "bakiye": 0.0},
        {"id": 2, "ad": "Ayse", "tip": "tuketen", "bakiye": 500.0},
    ]
    eklenen = []
    for u in test_data:
        hane = await session.get(Hane, u["id"])
        if hane is None:
            # Ana dizine bir .gitignore dosyası oluştur ve içine aşağıdaki standart yoksayma kurallarını ekle:
            #
            # Python
            __pycache__/
            *.py[cod]
            *.pyo
            *.pyd
            .Python
            env/
            build/
            develop-eggs/
            dist/
            downloads/
            eggs/
            .eggs/
            lib/
            lib64/
            parts/
            sdist/
            var/
            *.egg-info/
            .installed.cfg
            *.egg
            pip-log.txt
            pip-delete-this-directory.txt
            # VS Code/Eclipse ayarları
            .vscode/
            .idea/
            .DS_Store
            # Test çıktıları
            .pytest_cache/
            .coverage
            nosetests.xml
            coverage.xml
            *.cover
            # Virtual environments
            venv/
            ENV/
            env/
            .env/
            .venv/
            # SQLite
            *.db
            *.sqlite3
            # Not: Bu kod bloğu işlem kodu değildir, .gitignore içeriği olarak eklenmelidir.
            hane = Hane(
                id=u["id"],
                ad=u["ad"],
                tip=u["tip"],
                bakiye=u["bakiye"],
            )
            session.add(hane)
            eklenen.append(u["id"])
        else:
            hane.ad = u["ad"]
            hane.tip = u["tip"]
            hane.bakiye = u["bakiye"]

    await session.commit()
    return {
        "mesaj": "Test kullanıcıları kaydedildi.",
        "yeni_eklenen_idler": eklenen,
        "kullanicilar": test_data,
    }


@app.post("/offer")
async def create_offer(
    body: OfferRequest, session: AsyncSession = Depends(get_db)
):
    hane = await session.get(Hane, body.satan_id)
    if hane is None:
        raise HTTPException(status_code=404, detail="Satıcı hane bulunamadı.")

    teklif = Teklif(
        satan_id=body.satan_id,
        kwh=body.kwh,
        fiyat=0.0,
        durum="aktif",
    )
    session.add(teklif)
    await session.flush()

    yeni_fiyat = await hesapla_fiyat(session)
    teklif.fiyat = yeni_fiyat

    return {
        "teklif_id": teklif.id,
        "yeni_fiyat": yeni_fiyat,
        "mesaj": "Teklif kaydedildi ve güncel piyasa fiyatı hesaplandı.",
    }


@app.post("/buy")
async def buy_energy(body: BuyRequest, session: AsyncSession = Depends(get_db)):
    alici = await session.get(Hane, body.alan_id)
    if alici is None:
        raise HTTPException(status_code=404, detail="Alıcı hane bulunamadı.")

    arz_result = await session.execute(
        select(func.coalesce(func.sum(Teklif.kwh), 0.0)).where(Teklif.durum == "aktif")
    )
    toplam_aktif_kwh = float(arz_result.scalar_one())
    if toplam_aktif_kwh + 1e-9 < body.kwh:
        raise HTTPException(
            status_code=400,
            detail=(
                "Yetersiz aktif teklif. Mevcut toplam kWh: "
                f"{toplam_aktif_kwh:.4f}, istenen: {body.kwh:.4f}"
            ),
        )

    kalan = body.kwh
    yapilan_islemler = []

    stmt = (
        select(Teklif)
        .where(Teklif.durum == "aktif")
        .order_by(Teklif.id.asc())
    )
    result = await session.execute(stmt)
    aktif_teklifler = result.scalars().all()

    for teklif in aktif_teklifler:
        if kalan <= 0:
            break

        miktar = min(kalan, teklif.kwh)
        if miktar <= 0:
            continue

        satici = await session.get(Hane, teklif.satan_id)
        if satici is None:
            raise HTTPException(
                status_code=500,
                detail=f"Teklif #{teklif.id} için satıcı hane bulunamadı.",
            )

        birim_fiyat = teklif.fiyat
        tutar = miktar * birim_fiyat

        satici.bakiye += tutar
        alici.bakiye -= tutar

        zaman = datetime.now(timezone.utc).isoformat()
        islem_kayit = Islem(
            satan=teklif.satan_id,
            alan=body.alan_id,
            kwh=miktar,
            fiyat=birim_fiyat,
            zaman=zaman,
        )
        session.add(islem_kayit)

        teklif.kwh -= miktar
        if teklif.kwh <= 1e-9:
            teklif.kwh = 0.0
            teklif.durum = "tamamlandi"

        kalan -= miktar
        yapilan_islemler.append(
            (islem_kayit, teklif.id, miktar, birim_fiyat, tutar)
        )

    if kalan > 1e-6:
        raise HTTPException(
            status_code=400,
            detail=f"Yetersiz aktif teklif. Karşılanamayan kWh: {kalan:.4f}",
        )

    await session.flush()

    islemler_response = []
    for islem_kayit, teklif_id, miktar, birim_fiyat, tutar in yapilan_islemler:
        islemler_response.append(
            {
                "islem_id": islem_kayit.id,
                "teklif_id": teklif_id,
                "kwh": miktar,
                "birim_fiyat": birim_fiyat,
                "tutar": tutar,
            }
        )

    return {
        "alan_id": body.alan_id,
        "istenen_kwh": body.kwh,
        "karsilanan_kwh": body.kwh,
        "islemler": islemler_response,
    }

