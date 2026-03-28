from __future__ import annotations

import random
import re
from pathlib import Path

from dataset.models import Category, MutantCase, RTLCase
from metamorphosis.base_mutator import BaseMutator
from utils.fs import write_text


class LogicExpressionRewriter:
    assign_re = re.compile(r"assign\s+(\w+)\s*=\s*(.+?);", re.DOTALL)

    def collect_candidate_exprs(self, code: str) -> list[tuple[str, str]]:
        return self.assign_re.findall(code)

    def apply_demorgan(self, expr: str) -> str:
        expr = expr.strip()
        return f"~(~({expr}) & ~(~({expr}) | 1'b0))"

    def inject_redundant_terms(self, expr: str) -> str:
        return f"(({expr}) | (({expr}) & 1'b0))"

    def rebuild_expr(self, expr: str) -> str:
        return self.inject_redundant_terms(self.apply_demorgan(expr))


class LogicMutator(BaseMutator):
    category = Category.LOGIC

    def __init__(self, out_dir: str = "rtl_morph_eval/data/mutants", seed: int = 7) -> None:
        self.out_dir = Path(out_dir)
        self.rng = random.Random(seed)
        self.rewriter = LogicExpressionRewriter()

    def mutate(self, case: RTLCase, n: int = 1) -> list[MutantCase]:
        code = Path(case.rtl_path).read_text(encoding="utf-8")
        cands = self.rewriter.collect_candidate_exprs(code)
        if not cands:
            return []
        mutants: list[MutantCase] = []
        for i in range(n):
            lhs, rhs = self.rng.choice(cands)
            new_rhs = self.rewriter.rebuild_expr(rhs)
            new_code = code.replace(f"assign {lhs} = {rhs};", f"assign {lhs} = {new_rhs};", 1)
            out = self.out_dir / f"{case.case_id}_logic_{i}.v"
            write_text(out, new_code)
            mutants.append(
                MutantCase(
                    mutant_id=f"{case.case_id}_logic_{i}",
                    parent_case_id=case.case_id,
                    category=self.category,
                    rtl_path=str(out),
                    mutation_ops=[{"mutation_type": "logic_demorgan_redundancy", "target": lhs, "params": {}}],
                    semantic_intent="semantic_preserving_logic_complexification",
                )
            )
        return mutants
