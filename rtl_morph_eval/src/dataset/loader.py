from __future__ import annotations

import json
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
            rtl_path = Path(p)
            code = rtl_path.read_text(encoding="utf-8")
            metadata_path = rtl_path.with_name("metadata.json")
            metadata = json.loads(metadata_path.read_text(encoding="utf-8")) if metadata_path.exists() else {}
            top = metadata.get("top_module") or self.parser.top_module_name(code)
            case_category = Category(metadata.get("category", category.value))
            case_id = metadata.get("case_id", f"case_{idx:04d}")
            cases.append(
                RTLCase(
                    case_id=case_id,
                    category=case_category,
                    top_module=top,
                    rtl_path=p,
                    loc=extract_loc(p),
                    metadata=metadata,
                )
            )
        return cases
