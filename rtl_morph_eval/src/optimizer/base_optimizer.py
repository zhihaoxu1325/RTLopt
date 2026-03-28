from __future__ import annotations

from abc import ABC, abstractmethod

from dataset.models import PromptMode


class BaseOptimizer(ABC):
    name: str

    @abstractmethod
    def optimize(self, rtl_code: str, prompt_mode: PromptMode, context: dict) -> str:
        raise NotImplementedError
