from dataset.models import PromptMode, RTLCase, Category
from optimizer.gpt_optimizer import GPTOptimizer
from pipeline.experiment_runner import ExperimentRunner


def test_equiv_flow_basic(tmp_path):
    src = tmp_path / "a.v"
    src.write_text("module a(input x, output y); assign y = x; endmodule\n")
    case = RTLCase("c5", Category.LOGIC, "a", str(src))
    r = ExperimentRunner().run_one(case, "original", GPTOptimizer(), PromptMode.ZS)
    assert r.verification.abc_equivalent is True
    assert r.failure is False
