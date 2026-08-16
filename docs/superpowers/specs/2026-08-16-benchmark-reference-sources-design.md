# Benchmark Reference Sources Design

## Goal

Keep every benchmark as one unambiguous LLM input while also publishing the
individual upstream RTL files used to assemble that input. A reviewer must be
able to locate both the runnable benchmark and each provenance file without
following an external link.

## Case Layout

Each of the 233 benchmark directories uses this layout:

```text
files/bench_<id>_<name>/
|-- design.v
|-- metadata.json
|-- reference_sources/
|   `-- <original upstream relative path>
`-- licenses/                     # optional, existing behavior
```

`design.v` remains the only benchmark input supplied to the LLM and the only
RTL file consumed by the default evaluation command. `reference_sources/`
contains only the upstream files that were merged into `design.v`; testbenches,
unused RTL, generated files, and unrelated project files remain excluded.

The original relative path is preserved below `reference_sources/` to avoid
filename collisions and make provenance auditable.

## Metadata Contract

Each per-case `metadata.json` and the corresponding manifest entry contains:

- `benchmark_input`: `"design.v"`.
- `reference_source_dir`: `"reference_sources"`.
- `source_files`: an ordered list of objects with `upstream_path` and
  `repo_path`.

Example:

```json
{
  "benchmark_input": "design.v",
  "reference_source_dir": "reference_sources",
  "source_files": [
    {
      "upstream_path": "rtl/verilog/i2c_master_top.v",
      "repo_path": "reference_sources/rtl/verilog/i2c_master_top.v"
    }
  ]
}
```

The `source_files` order is the assembly order used by `design.v`.
`repo_path` is relative to the benchmark directory. The old
`upstream_included_files` field is removed so that no path-only field can be
mistaken for a missing repository file.

`repo_local_files` continues to identify the two primary case files,
`design.v` and `metadata.json`; the reference tree is described separately by
`reference_source_dir` and `source_files`.

## Recovery

The 2,349 referenced source files are recovered from the parent of commit
`b2bc713`, where the imported OpenCores project trees still exist in Git
history. Only paths already listed in the current
`upstream_included_files` arrays are restored.

Recovery must reject absolute paths and parent-directory traversal. It must also
fail if any historical blob is missing instead of silently producing an
incomplete reference tree.

## Documentation

The root README and `rtl_morph_eval/README.md` state:

- Use only `design.v` for the benchmark and LLM optimization flow.
- `reference_sources/` is provenance material for inspection and reproduction.
- `source_files` maps each original upstream path to a repository-local file.

## Verification

Automated tests cover all 233 cases and require:

1. Every manifest and metadata entry follows the same schema.
2. Every `source_files[].repo_path` exists under its case directory.
3. No reference path escapes its case directory.
4. The number of source mappings matches `file_count`.
5. Source files appear in `design.v` in the declared order with identical
   content after the benchmark's generated section headers are removed.
6. The default benchmark input remains exactly `design.v`.

The full test suite and the named I2C reviewer case are run after restoration.

## Publishing

The implementation is committed locally, pushed to `origin/main`, and then
checked through the GitHub Connector. Local success is not reported as remote
success until the remote branch SHA matches the local commit.
