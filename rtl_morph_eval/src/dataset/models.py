from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Optional


class Category(str, Enum):
    LOGIC = "logic_operation"
    DATAPATH = "data_path"
    TIMING_CTRL = "timing_control_flow"
    CLOCK_DOMAIN = "clock_domain"


class PromptMode(str, Enum):
    ZS = "zero_shot"
    FS = "few_shot"
    COT = "chain_of_thought"


class Verdict(str, Enum):
    PASS = "pass"
    FAIL = "fail"
    ERROR = "error"


@dataclass
class RTLCase:
    case_id: str
    category: Category
    top_module: str
    rtl_path: str
    testbench_path: Optional[str] = None
    loc: int = 0
    metadata: Dict = field(default_factory=dict)


@dataclass
class MutantCase:
    mutant_id: str
    parent_case_id: str
    category: Category
    rtl_path: str
    mutation_ops: List[Dict]
    semantic_intent: str
    expected_equivalent: bool = True


@dataclass
class OptimizedArtifact:
    artifact_id: str
    source_case_id: str
    optimizer_name: str
    prompt_mode: PromptMode
    rtl_in_path: str
    rtl_out_path: str
    raw_response_path: Optional[str] = None
    parse_success: bool = False


@dataclass
class VerificationResult:
    abc_equivalent: bool
    abc_log: str
    sim_passed: bool
    sim_log: str


@dataclass
class SynthesisMetrics:
    wires: float
    cells: float
    area: float
    delay: float
    power: float
    yosys_log: str = ""


@dataclass
class EvaluationRecord:
    case_id: str
    variant: str
    optimizer_name: str
    prompt_mode: PromptMode
    verification: VerificationResult
    metrics: Optional[SynthesisMetrics]
    normalized_metrics: Optional[Dict[str, float]]
    failure: bool
