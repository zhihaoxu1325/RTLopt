# RTLopt

This repository contains the evaluation framework and benchmark artifacts for
"Rethinking LLM-aided RTL Code Optimization Via Timing Logic Metamorphosis".

## Benchmark

The public RTL artifacts are organized as benchmark cases under `files/`.
Each case is self-contained:

```text
files/
  bench_0001_.../
    design.v           # only RTL input used for LLM optimization
    metadata.json      # case id, category, top module, source, license, and provenance
    reference_sources/ # individual upstream files assembled into design.v
    licenses/          # optional copied license texts for third-party provenance
```

The repository contains 233 curated case directories. `design.v` is the only
file that should be passed to the optimization flow for a case; the metadata
records how it was derived from the source project and which module is treated
as the top module. The full benchmark manifest is:

```text
rtl_morph_eval/configs/benchmark_manifest.json
```

Metadata fields use repo-local and upstream names deliberately:

- `design_path` points to the benchmark RTL file in this repository.
- `benchmark_input` is `design.v`, the only file passed to the LLM and
  evaluation flow.
- `reference_source_dir` points to `reference_sources/`, which is provided
  only for provenance, inspection, and reproduction.
- `source_files` maps each original `upstream_path` to an existing
  repo-local `repo_path` under `reference_sources/`, in the order used to
  assemble `design.v`.

Some cases are derived from third-party open RTL projects. Their metadata keeps
source and license provenance so cases can be reviewed before being used in a
final redistribution package.

## Run

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

The command writes generated mutants and reports under:

```text
rtl_morph_eval/data/mutants/
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
