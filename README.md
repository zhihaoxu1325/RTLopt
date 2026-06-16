# RTLopt

This repository contains the evaluation framework and benchmark artifacts for
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Benchmark Artifacts

The paper benchmark contains 233 RTL programs assembled from RTLLM,
VerilogEval, public GitHub repositories, and OpenCores. This repository includes
the core evaluation framework, representative examples, and an expanded
OpenCores-derived candidate pool.

The expanded candidate pool has been flattened directly under:

```text
files/
```

It adds 240 Verilog-oriented OpenCores candidates imported from the
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

## Framework

The framework code lives under `rtl_morph_eval/`. See
`rtl_morph_eval/README.md` for setup, test, and quick-start commands.
