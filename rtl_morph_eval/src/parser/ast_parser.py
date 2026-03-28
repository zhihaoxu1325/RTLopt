from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass
class VerilogAST:
    source: str


class VerilogParser:
    """Lightweight parser facade.

    For MVP we keep source text only and perform pattern-based transforms.
    """

    module_re = re.compile(r"module\s+(\w+)")

    def parse(self, code: str) -> VerilogAST:
        return VerilogAST(source=code)

    def top_module_name(self, code: str) -> str:
        m = self.module_re.search(code)
        return m.group(1) if m else "top"
