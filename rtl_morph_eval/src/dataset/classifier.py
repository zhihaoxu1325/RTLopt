from __future__ import annotations

import re

from dataset.models import Category


def has_fsm(code: str) -> bool:
    return "next_state" in code and bool(re.search(r"case\s*\(\s*state\s*\)", code))


def has_multi_clock_domains(code: str) -> bool:
    clocks = set(re.findall(r"always\s*@\(posedge\s+(\w+)\)", code))
    return len(clocks) > 1


def has_cdc_pattern(code: str) -> bool:
    return "sync_reg" in code or "synchronizer" in code.lower()


def has_mux_heavy_datapath(code: str) -> bool:
    return code.count("?") >= 2 or code.count("case(") + code.count("case (") >= 1


def has_arithmetic_selection(code: str) -> bool:
    return any(op in code for op in ["+", "-", "*", "/"]) and ("if" in code or "case" in code)


def classify_case(code: str) -> Category:
    if has_multi_clock_domains(code) or has_cdc_pattern(code):
        return Category.CLOCK_DOMAIN
    if has_fsm(code):
        return Category.TIMING_CTRL
    if has_mux_heavy_datapath(code) or has_arithmetic_selection(code):
        return Category.DATAPATH
    return Category.LOGIC
