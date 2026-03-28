from __future__ import annotations

import csv
from dataclasses import asdict
from pathlib import Path

from dataset.models import EvaluationRecord
from utils.fs import write_json


class ReportGenerator:
    def write_json(self, records: list[EvaluationRecord], path: str) -> None:
        write_json(path, [asdict(r) for r in records])

    def write_csv(self, records: list[EvaluationRecord], path: str) -> None:
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(
                f,
                fieldnames=["case_id", "variant", "optimizer_name", "prompt_mode", "failure"],
            )
            writer.writeheader()
            for r in records:
                writer.writerow(
                    {
                        "case_id": r.case_id,
                        "variant": r.variant,
                        "optimizer_name": r.optimizer_name,
                        "prompt_mode": r.prompt_mode.value,
                        "failure": r.failure,
                    }
                )
