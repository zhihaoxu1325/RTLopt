# RTL Timing Logic Metamorphosis Evaluation Framework (MVP)

This repository implements an engineering MVP of the method described in
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Features
- Rule-based 4-domain classifier (`logic`, `datapath`, `timing_control_flow`, `clock_domain`)
- Four mutator plugins with reproducible seeds
- Optimizer plugin interface and three adapters
- Verification + synthesis flow abstractions
- Normalization, failure analysis, JSON/CSV report generation

## Quick start
```bash
cd rtl_morph_eval
python -m src.main path/to/design.v
```

## Test
```bash
cd rtl_morph_eval
pytest
```
