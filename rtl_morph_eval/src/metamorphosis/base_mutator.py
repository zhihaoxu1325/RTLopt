from __future__ import annotations

from abc import ABC, abstractmethod

from dataset.models import Category, MutantCase, RTLCase


class BaseMutator(ABC):
    category: Category

    @abstractmethod
    def mutate(self, case: RTLCase, n: int = 1) -> list[MutantCase]:
        raise NotImplementedError
