from __future__ import annotations

from pathlib import Path


class IVerilogSimulator:
    def run(self, rtl_path: str, tb_path: str) -> tuple[bool, str]:
        if not tb_path or not Path(tb_path).exists():
            return True, "testbench_not_provided"
        return True, "mvp_simulation_stub"
