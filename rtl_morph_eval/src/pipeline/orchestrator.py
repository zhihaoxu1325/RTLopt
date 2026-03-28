from __future__ import annotations

from analysis.report_generator import ReportGenerator
from dataset.models import PromptMode, RTLCase
from metamorphosis.clock_domain_mutator import ClockDomainMutator
from metamorphosis.datapath_mutator import DatapathMutator
from metamorphosis.fsm_mutator import FSMMutator
from metamorphosis.logic_mutator import LogicMutator
from optimizer.claude_optimizer import ClaudeOptimizer
from optimizer.gpt_optimizer import GPTOptimizer
from optimizer.rtlrewriter_adapter import RTLRewriterAdapter
from pipeline.experiment_runner import ExperimentRunner


class Orchestrator:
    def __init__(self) -> None:
        self.mutators = {
            "logic_operation": LogicMutator(),
            "data_path": DatapathMutator(),
            "timing_control_flow": FSMMutator(),
            "clock_domain": ClockDomainMutator(),
        }
        self.optimizers = [GPTOptimizer(), ClaudeOptimizer(), RTLRewriterAdapter()]
        self.prompt_modes = [PromptMode.ZS, PromptMode.FS, PromptMode.COT]
        self.runner = ExperimentRunner()
        self.reporter = ReportGenerator()

    def _make_mutants(self, case: RTLCase):
        mutator = self.mutators[case.category.value]
        return mutator.mutate(case, n=1)

    def run_experiment(self, cases: list[RTLCase]) -> list:
        records = []
        for case in cases:
            mutants = self._make_mutants(case)
            variants = [("original", case)]
            for m in mutants:
                variants.append(("mutant", RTLCase(case_id=m.mutant_id, category=m.category, top_module=case.top_module, rtl_path=m.rtl_path, testbench_path=case.testbench_path, loc=case.loc)))

            for variant_name, variant_case in variants:
                for optimizer in self.optimizers:
                    for pm in self.prompt_modes:
                        records.append(self.runner.run_one(variant_case, variant_name, optimizer, pm))

        self.reporter.write_json(records, "rtl_morph_eval/data/reports/report.json")
        self.reporter.write_csv(records, "rtl_morph_eval/data/reports/report.csv")
        return records
