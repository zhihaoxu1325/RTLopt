# RTL Timing Logic Metamorphosis Evaluation Framework (MVP)

This repository implements an engineering MVP of the method described in
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Features
- Rule-based 4-domain classifier (`logic`, `datapath`, `timing_control_flow`, `clock_domain`)
- Four mutator plugins with reproducible seeds
- Optimizer plugin interface and three adapters
- Verification + synthesis flow abstractions
- Normalization, failure analysis, JSON/CSV report generation

## Quick Start

Benchmark cases live under `../files/bench_*/`. Each case uses one
`design.v` as the optimization input; adjacent metadata records the selected
top module and provenance.

Run one benchmark case:

```bash
cd rtl_morph_eval
PYTHONPATH=src python3 -m src.main ../files/bench_0001_library_common_design_environment/design.v
```

Run the full public benchmark:

```bash
cd rtl_morph_eval
PYTHONPATH=src python3 -m src.main ../files/bench_*/design.v
```

For a local smoke test independent of the benchmark files:

```bash
cd rtl_morph_eval
PYTHONPATH=src python3 -m src.main tests/fixtures/simple_logic.v
```

Generated mutants and reports are written under:

```text
data/mutants/
data/reports/
```

## Test
```bash
cd rtl_morph_eval
pytest
```
