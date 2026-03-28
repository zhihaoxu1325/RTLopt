from __future__ import annotations

from collections import defaultdict

from dataset.models import EvaluationRecord, RTLCase


class FailureAnalyzer:
    def bucket_by_loc(self, cases: list[RTLCase], buckets: list[int] | None = None) -> dict[int, list[RTLCase]]:
        buckets = buckets or [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
        out: dict[int, list[RTLCase]] = {b: [] for b in buckets}
        for case in cases:
            key = min(buckets, key=lambda b: abs(case.loc - b))
            out[key].append(case)
        return out

    def compute_failure_rate(self, records: list[EvaluationRecord]) -> dict[str, float]:
        counts = defaultdict(int)
        fails = defaultdict(int)
        for r in records:
            counts[r.case_id] += 1
            if r.failure:
                fails[r.case_id] += 1
        return {k: fails[k] / counts[k] for k in counts}
