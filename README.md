# RTLopt

This repository contains the evaluation framework and benchmark artifacts for
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Artifacts

This repository includes the core evaluation framework and public RTL examples
for inspecting and extending the evaluation workflow.

RTL examples are stored directly under:

```text
files/
```

The paper benchmark contains 233 RTL programs assembled from RTLLM,
VerilogEval, public GitHub repositories, and OpenCores. The public `files/`
directory is not a one-to-one manifest of those 233 experimental programs.
Instead, it contains representative examples plus additional OpenCores-derived
RTL candidates for inspection and future benchmark extension. Some upstream
projects have incomplete metadata, non-uniform directory layouts, mixed
testbench/model files, platform-specific path issues, or licenses that require
case-by-case review before they can be treated as final benchmark cases.

For provenance, the generated JSON manifest records source URLs, declared
language/status/license, copied Verilog files, copied license files when
present, and detected module names:

```text
rtl_morph_eval/configs/opencores_manifest.json
```

## Run

```bash
cd rtl_morph_eval
PYTHONPATH=src python3 -m src.main tests/fixtures/simple_logic.v
```

For a custom Verilog input:

```bash
cd rtl_morph_eval
PYTHONPATH=src python3 -m src.main path/to/design.v
```

The command writes reports under:

```text
rtl_morph_eval/data/reports/
```

Run the test suite with:

```bash
cd rtl_morph_eval
pytest
```

## Framework

The framework code lives under `rtl_morph_eval/`. See
`rtl_morph_eval/README.md` for setup, test, and quick-start commands.
