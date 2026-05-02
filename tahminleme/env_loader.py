"""
Load .env into os.environ. Handles UTF-8, UTF-8 BOM, and UTF-16 (PowerShell echo redirect).
"""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv


def load_dotenv_safe(path: str | Path = ".env") -> None:
    p = Path(path)
    if not p.is_file():
        load_dotenv(p, override=True)
        return

    raw = p.read_bytes()
    # PowerShell: echo "KEY=x" > .env often writes UTF-16 LE with BOM
    if raw.startswith(b"\xff\xfe"):
        text = raw[2:].decode("utf-16-le")
        _apply_lines(text)
        return
    if raw.startswith(b"\xfe\xff"):
        text = raw[2:].decode("utf-16-be")
        _apply_lines(text)
        return

    load_dotenv(p, encoding="utf-8-sig", override=True)


def _apply_lines(text: str) -> None:
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key:
            os.environ[key] = val
