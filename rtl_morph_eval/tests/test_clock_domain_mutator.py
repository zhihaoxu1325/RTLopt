from pathlib import Path

from dataset.models import Category, RTLCase
from metamorphosis.clock_domain_mutator import ClockDomainMutator


def test_clock_mutator_no_clock_returns_empty(tmp_path):
    src = Path("tests/fixtures/simple_logic.v")
    case = RTLCase("c4", Category.CLOCK_DOMAIN, "simple_logic", str(src))
    mut = ClockDomainMutator(out_dir=str(tmp_path))
    assert mut.mutate(case, 1) == []
