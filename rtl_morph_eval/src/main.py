from __future__ import annotations

import argparse
from pathlib import Path

from dataset.classifier import classify_case
from dataset.loader import DatasetLoader
from pipeline.orchestrator import Orchestrator


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("rtl", nargs="+", help="Input Verilog files")
    args = ap.parse_args()

    loader = DatasetLoader()
    cases = loader.load_from_paths(args.rtl)
    for c in cases:
        code = Path(c.rtl_path).read_text(encoding="utf-8")
        c.category = classify_case(code)

    orch = Orchestrator()
    records = orch.run_experiment(cases)
    print(f"Generated {len(records)} evaluation records")


if __name__ == "__main__":
    main()
