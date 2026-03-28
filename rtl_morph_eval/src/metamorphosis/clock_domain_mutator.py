from __future__ import annotations

import re
from pathlib import Path

from dataset.models import Category, MutantCase, RTLCase
from metamorphosis.base_mutator import BaseMutator
from utils.fs import write_text


class ClockDomainMutator(BaseMutator):
    category = Category.CLOCK_DOMAIN

    def __init__(self, out_dir: str = "rtl_morph_eval/data/mutants") -> None:
        self.out_dir = Path(out_dir)

    def mutate(self, case: RTLCase, n: int = 1) -> list[MutantCase]:
        code = Path(case.rtl_path).read_text(encoding="utf-8")
        m = re.search(r"always\s*@\(posedge\s+(\w+)\)", code)
        if not m:
            return []
        clk = m.group(1)
        stub = (
            "\n// MUT_CLOCK_DOMAIN_SPLIT\n"
            f"wire clk1 = {clk};\n"
            f"wire clk2 = {clk};\n"
            "reg sync_reg1, sync_reg2;\n"
            "always @(posedge clk1) sync_reg1 <= sync_reg1;\n"
            "always @(posedge clk2) sync_reg2 <= sync_reg1;\n"
        )
        out = self.out_dir / f"{case.case_id}_clock_0.v"
        write_text(out, code + stub)
        return [
            MutantCase(
                mutant_id=f"{case.case_id}_clock_0",
                parent_case_id=case.case_id,
                category=self.category,
                rtl_path=str(out),
                mutation_ops=[{"mutation_type": "clock_split_with_synchronizer", "target": clk, "params": {"depth": 2}}],
                semantic_intent="semantic_preserving_clock_domain_complexification",
            )
        ]
