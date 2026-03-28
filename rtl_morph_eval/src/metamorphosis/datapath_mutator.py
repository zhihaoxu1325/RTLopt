from __future__ import annotations

import random
import re
from pathlib import Path

from dataset.models import Category, MutantCase, RTLCase
from metamorphosis.base_mutator import BaseMutator
from utils.fs import write_text


class DatapathMutator(BaseMutator):
    category = Category.DATAPATH
    ternary_re = re.compile(r"assign\s+(\w+)\s*=\s*(.+?)\?\s*(.+?)\s*:\s*(.+?);", re.DOTALL)

    def __init__(self, out_dir: str = "rtl_morph_eval/data/mutants", seed: int = 11) -> None:
        self.out_dir = Path(out_dir)
        self.rng = random.Random(seed)

    def mutate(self, case: RTLCase, n: int = 1) -> list[MutantCase]:
        code = Path(case.rtl_path).read_text(encoding="utf-8")
        matches = list(self.ternary_re.finditer(code))
        if not matches:
            return []
        mutants: list[MutantCase] = []
        for i in range(n):
            m = self.rng.choice(matches)
            lhs, cond, a, b = m.group(1), m.group(2), m.group(3), m.group(4)
            helper = f"_dp_x_{i}"
            repl = (
                f"wire {helper};\n"
                f"assign {helper} = ({cond}) ? ({a}) : ({b});\n"
                f"assign {lhs} = (({cond}) == ({cond})) ? (({cond}) ? ({a}) : ({helper})) : ({b});"
            )
            new_code = code[: m.start()] + repl + code[m.end() :]
            out = self.out_dir / f"{case.case_id}_datapath_{i}.v"
            write_text(out, new_code)
            mutants.append(
                MutantCase(
                    mutant_id=f"{case.case_id}_datapath_{i}",
                    parent_case_id=case.case_id,
                    category=self.category,
                    rtl_path=str(out),
                    mutation_ops=[{"mutation_type": "cascade_mux_with_tautology", "target": lhs, "params": {"helper": helper}}],
                    semantic_intent="semantic_preserving_datapath_complexification",
                )
            )
        return mutants
