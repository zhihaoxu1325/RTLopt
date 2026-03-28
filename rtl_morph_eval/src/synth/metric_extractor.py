from __future__ import annotations

from dataset.models import SynthesisMetrics


def metrics_to_dict(metrics: SynthesisMetrics) -> dict[str, float]:
    return {
        "wires": metrics.wires,
        "cells": metrics.cells,
        "area": metrics.area,
        "delay": metrics.delay,
        "power": metrics.power,
    }
