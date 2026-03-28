from __future__ import annotations

from statistics import mean


def average_metric(records: list[dict], key: str) -> float:
    vals = [r[key] for r in records if key in r]
    return mean(vals) if vals else 0.0
