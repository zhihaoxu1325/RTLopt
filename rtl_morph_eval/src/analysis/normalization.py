from __future__ import annotations

from dataset.models import SynthesisMetrics


def normalize_metrics(metrics: SynthesisMetrics, yosys_ref: SynthesisMetrics) -> dict[str, float]:
    def safe_div(a: float, b: float) -> float:
        return a / b if b else 0.0

    return {
        "wires": safe_div(metrics.wires, yosys_ref.wires),
        "cells": safe_div(metrics.cells, yosys_ref.cells),
        "area": safe_div(metrics.area, yosys_ref.area),
        "delay": safe_div(metrics.delay, yosys_ref.delay),
        "power": safe_div(metrics.power, yosys_ref.power),
    }
