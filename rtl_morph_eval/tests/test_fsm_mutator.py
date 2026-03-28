from pathlib import Path

from dataset.models import Category, RTLCase
from metamorphosis.fsm_mutator import FSMMutator


def test_fsm_mutator_injects_tag(tmp_path):
    src = Path("tests/fixtures/simple_logic.v")
    case = RTLCase("c3", Category.TIMING_CTRL, "simple_logic", str(src))
    mut = FSMMutator(out_dir=str(tmp_path))
    ms = mut.mutate(case, 1)
    assert len(ms) == 1
    assert "MUT_FSM_PASS_THROUGH" in Path(ms[0].rtl_path).read_text()
