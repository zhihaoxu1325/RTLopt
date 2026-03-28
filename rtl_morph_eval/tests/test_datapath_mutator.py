from pathlib import Path

from dataset.models import Category, RTLCase
from metamorphosis.datapath_mutator import DatapathMutator


def test_datapath_mutator_handles_no_ternary(tmp_path):
    src = Path("tests/fixtures/simple_logic.v")
    case = RTLCase("c2", Category.DATAPATH, "simple_logic", str(src))
    mut = DatapathMutator(out_dir=str(tmp_path))
    assert mut.mutate(case, n=1) == []
