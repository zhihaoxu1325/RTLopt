from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class MutationOp:
    mutation_type: str
    target: str
    params: dict = field(default_factory=dict)
