from __future__ import annotations

from dataset.models import PromptMode
from optimizer.base_optimizer import BaseOptimizer


class GPTOptimizer(BaseOptimizer):
    name = "gpt"

    def optimize(self, rtl_code: str, prompt_mode: PromptMode, context: dict) -> str:
        return rtl_code
