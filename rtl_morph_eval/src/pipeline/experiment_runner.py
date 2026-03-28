from __future__ import annotations

from pathlib import Path

from analysis.normalization import normalize_metrics
from dataset.models import EvaluationRecord, PromptMode, RTLCase
from optimizer.base_optimizer import BaseOptimizer
from synth.yosys_runner import YosysRunner
from verify.abc_checker import ABCChecker


class ExperimentRunner:
    def __init__(self) -> None:
        self.yosys = YosysRunner()
        self.abc = ABCChecker()

    def run_one(self, case: RTLCase, variant: str, optimizer: BaseOptimizer, prompt_mode: PromptMode) -> EvaluationRecord:
        rtl = Path(case.rtl_path).read_text(encoding="utf-8")
        optimized_rtl = optimizer.optimize(rtl, prompt_mode, {"category": case.category.value})
        ver = self.abc.check_equivalence(rtl, optimized_rtl, case.top_module)
        if ver.abc_equivalent and ver.sim_passed:
            m = self.yosys.synthesize(case.rtl_path, case.top_module)
            ref = self.yosys.synthesize(case.rtl_path, case.top_module)
            norm = normalize_metrics(m, ref)
            failure = False
        else:
            m = None
            norm = None
            failure = True
        return EvaluationRecord(
            case_id=case.case_id,
            variant=variant,
            optimizer_name=optimizer.name,
            prompt_mode=prompt_mode,
            verification=ver,
            metrics=m,
            normalized_metrics=norm,
            failure=failure,
        )
