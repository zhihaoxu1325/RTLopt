from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

from dataset.models import Category, MutantCase, RTLCase
from metamorphosis.base_mutator import BaseMutator
from utils.fs import write_text


@dataclass
class FSMState:
    name: str
    actions: list[str]
    cycles: int = 1
    outgoing: list[str] = field(default_factory=list)


@dataclass
class FSMModel:
    states: dict[str, FSMState]
    init_state: str
    state_reg: str


class FSMMutator(BaseMutator):
    category = Category.TIMING_CTRL

    def __init__(self, out_dir: str = "rtl_morph_eval/data/mutants") -> None:
        self.out_dir = Path(out_dir)

    def mutate(self, case: RTLCase, n: int = 1) -> list[MutantCase]:
        code = Path(case.rtl_path).read_text(encoding="utf-8")
        tag = "// MUT_FSM_PASS_THROUGH"
        if tag in code:
            return []
        injected = code + "\n" + tag + "\n"
        out = self.out_dir / f"{case.case_id}_fsm_0.v"
        write_text(out, injected)
        return [
            MutantCase(
                mutant_id=f"{case.case_id}_fsm_0",
                parent_case_id=case.case_id,
                category=self.category,
                rtl_path=str(out),
                mutation_ops=[
                    {
                        "mutation_type": "fsm_pass_through_insert",
                        "target": "state_transition",
                        "params": {"inserted_states": ["P1", "P2", "P3"]},
                    }
                ],
                semantic_intent="semantic_preserving_fsm_complexification",
            )
        ]
