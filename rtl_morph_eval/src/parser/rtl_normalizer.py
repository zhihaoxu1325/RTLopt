from __future__ import annotations


def normalize_rtl(code: str) -> str:
    lines = [ln.rstrip() for ln in code.splitlines()]
    return "\n".join(lines).strip() + "\n"
