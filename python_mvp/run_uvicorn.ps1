# EcoTrade python_mvp — telefon / LAN üzerinden erişim için host zorunlu: 0.0.0.0
# (127.0.0.1 sadece bilgisayardan localhost; Flutter LAN IP ile bağlanamaz.)
Set-Location $PSScriptRoot
.\.venv\Scripts\Activate.ps1
uvicorn app:app --host 0.0.0.0 --port 8001 --reload
