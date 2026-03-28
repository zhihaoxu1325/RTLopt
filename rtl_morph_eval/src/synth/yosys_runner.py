from __future__ import annotations

from pathlib import Path

from dataset.models import SynthesisMetrics


class YosysRunner:
    def synthesize(self, rtl_path: str, top_module: str) -> SynthesisMetrics:
        code = Path(rtl_path).read_text(encoding="utf-8")
        wires = code.count("wire")
        regs = code.count("reg")
        cells = code.count("assign") + regs
        area = float(cells * 10 + wires * 2)
        delay = float(max(1, code.count("always")))
        power = area * 0.1
        return SynthesisMetrics(wires=float(wires), cells=float(cells), area=area, delay=delay, power=power, yosys_log="mvp_proxy")
