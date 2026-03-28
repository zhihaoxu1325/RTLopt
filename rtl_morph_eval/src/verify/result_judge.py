from __future__ import annotations

from dataset.models import VerificationResult


def is_verification_passed(result: VerificationResult) -> bool:
    return result.abc_equivalent and result.sim_passed
