from __future__ import annotations


def estimate_delay_proxy(cell_count: float) -> float:
    return max(1.0, cell_count / 20.0)
