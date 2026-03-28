from __future__ import annotations

from dataset.models import Category


class PromptBuilder:
    def build_zero_shot(self, rtl_code: str) -> str:
        return (
            "You are an expert hardware engineer optimizing RTL code for performance and area.\n"
            "Below is an RTL module. Please optimize it while keeping its functionality unchanged.\n"
            f"{rtl_code}"
        )

    def build_few_shot(self, rtl_code: str, category: Category, examples: list[str]) -> str:
        example_text = "\n".join(examples)
        return f"Category: {category.value}\nExamples:\n{example_text}\nTarget:\n{rtl_code}"

    def build_cot(self, rtl_code: str, category: Category) -> str:
        return f"Think step-by-step for {category.value}, then output only optimized Verilog.\n{rtl_code}"
