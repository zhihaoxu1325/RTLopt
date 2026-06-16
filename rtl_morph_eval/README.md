# RTL Timing Logic Metamorphosis Evaluation Framework (MVP)

This repository implements an engineering MVP of the method described in
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Features
- Rule-based 4-domain classifier (`logic`, `datapath`, `timing_control_flow`, `clock_domain`)
- Four mutator plugins with reproducible seeds
- Optimizer plugin interface and three adapters
- Verification + synthesis flow abstractions
- Normalization, failure analysis, JSON/CSV report generation

## Benchmark Artifacts

The paper benchmark contains 233 RTL programs assembled from RTLLM,
VerilogEval, public GitHub repositories, and OpenCores. This repository keeps the
core evaluation framework together with representative examples and an expanded
OpenCores-derived candidate pool.

The expanded candidate pool is stored under:

```text
files/opencores_candidates/
```

It contains 240 Verilog-oriented OpenCores candidates imported from the
`fabriziotappero/ip-cores` branch index. These candidates are provided as a
backup and inspection set for building or extending benchmark releases. They are
not all claimed to be manually validated final benchmark cases: some upstream
projects have incomplete metadata, non-uniform directory layouts, mixed
testbench/model files, platform-specific path issues, or licenses that require
case-by-case review before redistribution as part of a final artifact package.

The generated manifests record source URLs, declared language/status/license,
copied Verilog files, copied license files when present, and detected module
names:

```text
rtl_morph_eval/configs/opencores_manifest.json
rtl_morph_eval/configs/opencores_manifest.csv
```

To refresh or reproduce the import:

```bash
cd rtl_morph_eval
python scripts/import_opencores.py --apply \
  --licenses BSD,LGPL,GPL,Others,Unknown \
  --prefixes arithmetic,communication,crypto,dsp,ecc,library,memory,other,processor,system,video \
  --limit 280 \
  --target-imported 240
```

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
