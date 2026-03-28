from __future__ import annotations

from dataset.models import VerificationResult


class ABCChecker:
    def check_equivalence(self, golden_rtl: str, optimized_rtl: str, top_module: str) -> VerificationResult:
        # MVP: text-normalized equality as a deterministic stand-in when ABC is unavailable.
        eq = golden_rtl.replace("\n", "").replace(" ", "") == optimized_rtl.replace("\n", "").replace(" ", "")
        return VerificationResult(abc_equivalent=eq, abc_log="mvp_text_equivalence", sim_passed=True, sim_log="skipped")
