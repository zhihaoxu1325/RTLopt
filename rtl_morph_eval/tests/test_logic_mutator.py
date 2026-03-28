from pathlib import Path

from dataset.models import Category, RTLCase
from metamorphosis.logic_mutator import LogicMutator


def test_logic_mutator_generates_mutant(tmp_path):
    src = Path("tests/fixtures/simple_logic.v")
    case = RTLCase("c1", Category.LOGIC, "simple_logic", str(src))
    mut = LogicMutator(out_dir=str(tmp_path))
    ms = mut.mutate(case, n=1)
    assert len(ms) == 1
    code = Path(ms[0].rtl_path).read_text()
    assert "~(~(" in code
