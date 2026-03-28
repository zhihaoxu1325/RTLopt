from __future__ import annotations

from pathlib import Path
from typing import Iterable, List

from dataset.models import Category, RTLCase
from parser.ast_parser import VerilogParser


def extract_loc(file_path: str) -> int:
    return sum(1 for ln in Path(file_path).read_text(encoding="utf-8").splitlines() if ln.strip())


class DatasetLoader:
    def __init__(self) -> None:
        self.parser = VerilogParser()

    def load_from_paths(self, paths: Iterable[str], category: Category = Category.LOGIC) -> List[RTLCase]:
        cases: list[RTLCase] = []
        for idx, p in enumerate(paths):
            code = Path(p).read_text(encoding="utf-8")
            top = self.parser.top_module_name(code)
            cases.append(
                RTLCase(
                    case_id=f"case_{idx:04d}",
                    category=category,
                    top_module=top,
                    rtl_path=p,
                    loc=extract_loc(p),
                )
            )
        return cases
