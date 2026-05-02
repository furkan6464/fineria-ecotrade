from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, Integer, String, Float

# Veritabanı dosyamızın adı ve yolu
DATABASE_URL = "sqlite+aiosqlite:///./ecotrade.db"

engine = create_async_engine(DATABASE_URL, echo=True)
async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

# 1. TABLO: Haneler (Kullanıcılar)
class Hane(Base):
    __tablename__ = "haneler"
    id = Column(Integer, primary_key=True, index=True)
    ad = Column(String, index=True)
    tip = Column(String)  # 'ureten' veya 'tuketen'
    bakiye = Column(Float, default=0.0)

# 2. TABLO: Teklifler (Satış Emirleri)
class Teklif(Base):
    __tablename__ = "teklifler"
    id = Column(Integer, primary_key=True, index=True)
    satan_id = Column(Integer)
    kwh = Column(Float)
    fiyat = Column(Float)
    durum = Column(String, default="aktif")  # 'aktif' veya 'tamamlandi'

# 3. TABLO: İşlemler (Gerçekleşen Alım-Satımlar)
class Islem(Base):
    __tablename__ = "islemler"
    id = Column(Integer, primary_key=True, index=True)
    satan = Column(Integer)
    alan = Column(Integer)
    kwh = Column(Float)
    fiyat = Column(Float)
    zaman = Column(String)

# Uygulama başlarken tabloları otomatik oluşturacak fonksiyon
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def get_db():
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
