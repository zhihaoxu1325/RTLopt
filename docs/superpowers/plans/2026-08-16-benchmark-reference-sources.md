# Benchmark Reference Sources Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the 2,349 individual RTL files used by the 233 benchmarks while keeping `design.v` as the only benchmark input.

**Architecture:** Each benchmark gains a `reference_sources/` tree preserving upstream relative paths. A deterministic maintenance script restores only the selected blobs from Git history and migrates both metadata copies to an explicit ordered `source_files` mapping; tests validate the schema, path confinement, existence, and source-to-`design.v` correspondence.

**Tech Stack:** Python 3 standard library, Git object history, JSON, pytest, Markdown.

## Global Constraints

- `design.v` remains the only benchmark and LLM input.
- Restore only files currently listed by `upstream_included_files`; do not restore testbenches or unrelated project files.
- Preserve each source file's upstream relative path below `reference_sources/`.
- Reject absolute paths and `..` traversal.
- Do not add OpenCores import or refresh commands to the public README.
- Do not report publication complete until GitHub `main` matches the local commit SHA.

---

### Task 1: Lock the New Metadata and Reference Contract

**Files:**
- Modify: `rtl_morph_eval/tests/test_benchmark_metadata.py`

**Interfaces:**
- Consumes: `rtl_morph_eval/configs/benchmark_manifest.json`, per-case `metadata.json`, `design.v`, and `reference_sources/`.
- Produces: A regression test enforcing `benchmark_input`, `reference_source_dir`, and ordered `source_files` mappings.

- [ ] **Step 1: Replace the old provenance assertions with the new schema assertions**

```python
def test_benchmark_metadata_has_local_reference_sources():
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    assert len(manifest) == 233

    for entry in manifest:
        case_dir = REPO_ROOT / entry["case_dir"]
        metadata = json.loads((case_dir / "metadata.json").read_text(encoding="utf-8"))

        assert entry == metadata
        assert entry["benchmark_input"] == "design.v"
        assert entry["llm_input"] == "design.v"
        assert entry["reference_source_dir"] == "reference_sources"
        assert "upstream_included_files" not in entry
        assert len(entry["source_files"]) == entry["file_count"]

        for source_file in entry["source_files"]:
            upstream = PurePosixPath(source_file["upstream_path"])
            repo_path = PurePosixPath(source_file["repo_path"])
            assert not upstream.is_absolute() and ".." not in upstream.parts
            assert repo_path == PurePosixPath("reference_sources") / upstream
            assert (case_dir / repo_path).is_file()
```

- [ ] **Step 2: Add source-content and assembly-order assertions**

```python
def _source_sections(design_text, source_files):
    cursor = 0
    for index, source_file in enumerate(source_files):
        marker = (
            "// -----------------------------------------------------------------------------\n"
            f"// Source file: {source_file['upstream_path']}\n"
            "// -----------------------------------------------------------------------------\n"
        )
        marker_start = design_text.index(marker, cursor)
        content_start = marker_start + len(marker)
        if index + 1 < len(source_files):
            next_marker = (
                "\n\n// -----------------------------------------------------------------------------\n"
                f"// Source file: {source_files[index + 1]['upstream_path']}\n"
            )
            content_end = design_text.index(next_marker, content_start)
        else:
            content_end = len(design_text)
        yield design_text[content_start:content_end]
        cursor = content_end
```

For every source mapping, compare the yielded section and local reference with
`splitlines()` after trimming only outer blank lines. This normalizes historical
line endings without changing Verilog content.

- [ ] **Step 3: Run the focused test and confirm the old repository fails**

Run:

```bash
cd rtl_morph_eval
PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -p no:cacheprovider tests/test_benchmark_metadata.py
```

Expected: FAIL because `benchmark_input`, `reference_source_dir`,
`source_files`, and `reference_sources/` do not exist yet.

### Task 2: Restore Selected Source Files and Migrate Metadata

**Files:**
- Create: `rtl_morph_eval/scripts/materialize_reference_sources.py`
- Create: `files/bench_*/reference_sources/<upstream path>` for exactly 2,349 files
- Modify: `files/bench_*/metadata.json`
- Modify: `rtl_morph_eval/configs/benchmark_manifest.json`

**Interfaces:**
- Consumes: benchmark manifest entries and Git blobs under
  `b2bc713^:files/<source_project>/<upstream_path>`.
- Produces: repo-local source files and identical migrated manifest/per-case
  metadata entries.

- [ ] **Step 1: Implement path validation and historical blob loading**

```python
SOURCE_REVISION = "b2bc713^"


def safe_relative_path(raw_path: str) -> PurePosixPath:
    path = PurePosixPath(raw_path)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"unsafe source path: {raw_path}")
    return path


def read_historical_blob(repo_root: Path, source_project: str, upstream_path: str) -> bytes:
    object_name = f"{SOURCE_REVISION}:files/{source_project}/{upstream_path}"
    return subprocess.run(
        ["git", "show", object_name],
        cwd=repo_root,
        check=True,
        stdout=subprocess.PIPE,
    ).stdout
```

- [ ] **Step 2: Implement idempotent materialization and metadata migration**

For each manifest entry, read source paths from `upstream_included_files` on
the first run or `source_files[].upstream_path` on later runs. Write each blob
to:

```python
repo_path = PurePosixPath("reference_sources") / safe_relative_path(upstream_path)
target = case_dir.joinpath(*repo_path.parts)
target.parent.mkdir(parents=True, exist_ok=True)
target.write_bytes(blob)
```

Then set:

```python
entry["benchmark_input"] = "design.v"
entry["reference_source_dir"] = "reference_sources"
entry["source_files"] = [
    {
        "upstream_path": path,
        "repo_path": str(PurePosixPath("reference_sources") / path),
    }
    for path in source_paths
]
entry.pop("upstream_included_files", None)
entry["notes"] = (
    "Curated single-file RTL benchmark case. Use design.v as the only "
    "benchmark and LLM input. reference_sources contains the individual "
    "upstream files merged into design.v for provenance and review only."
)
```

Write each migrated entry to its `metadata_path`, then write the full manifest
with UTF-8, two-space indentation, and a trailing newline. Print case and file
counts and fail unless they are exactly 233 and 2,349.

- [ ] **Step 3: Materialize all reference sources**

Run:

```bash
python3 rtl_morph_eval/scripts/materialize_reference_sources.py
```

Expected:

```text
Materialized 2349 reference source files for 233 benchmark cases.
```

- [ ] **Step 4: Run the focused test**

Run:

```bash
cd rtl_morph_eval
PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -p no:cacheprovider tests/test_benchmark_metadata.py
```

Expected: PASS.

### Task 3: Document the Benchmark/Reference Boundary

**Files:**
- Modify: `README.md`
- Modify: `rtl_morph_eval/README.md`

**Interfaces:**
- Consumes: the Task 2 directory and metadata schema.
- Produces: reviewer-facing guidance that distinguishes runnable input from provenance files.

- [ ] **Step 1: Update the root benchmark layout and metadata field descriptions**

Document `reference_sources/` next to `design.v` and state explicitly:

```text
design.v is the only file passed to the LLM and evaluation flow.
reference_sources/ contains the individual source files assembled into design.v
and is provided only for provenance, inspection, and reproduction.
source_files maps every upstream_path to an existing repo_path.
```

Remove the statement that upstream files are not expected to exist locally.

- [ ] **Step 2: Update the framework quick start**

Keep both existing run commands unchanged. Replace
`upstream_included_files` documentation with `benchmark_input`,
`reference_source_dir`, and `source_files`; do not add materialization or
OpenCores import commands.

- [ ] **Step 3: Check documentation and schema vocabulary**

Run:

```bash
rg -n '"upstream_included_files"|not expected to exist|import_opencores' \
  README.md rtl_morph_eval/README.md files rtl_morph_eval/configs
```

Expected: no matches.

### Task 4: Verify, Commit, and Publish

**Files:**
- Verify all files changed in Tasks 1-3.

**Interfaces:**
- Consumes: complete implementation.
- Produces: tested local commit and matching GitHub `main`.

- [ ] **Step 1: Run metadata and repository integrity checks**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path

manifest = json.loads(Path("rtl_morph_eval/configs/benchmark_manifest.json").read_text())
refs = list(Path("files").glob("bench_*/reference_sources/**/*.v"))
print("cases", len(manifest))
print("reference_rtl", len(refs))
print("design_v", len(list(Path("files").glob("bench_*/design.v"))))
print("metadata_json", len(list(Path("files").glob("bench_*/metadata.json"))))
PY
```

Expected: 233 cases, 2,349 reference RTL files, 233 `design.v` files, and
233 metadata files.

- [ ] **Step 2: Run the full test suite without workspace caches**

Run:

```bash
cd rtl_morph_eval
PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -p no:cacheprovider
```

Expected: all tests pass.

- [ ] **Step 3: Run the named reviewer case without retaining generated output**

Use the standard command with its output directories redirected to the external
task cache. If that cache is unavailable, do not use a workspace fallback;
report the smoke-test limitation and rely on the source-equality regression plus
the full cache-free test suite.

- [ ] **Step 4: Review and commit only intended changes**

Run `git status -sb`, `git diff --check`, inspect `git diff --stat`, and
commit the implementation with:

```bash
git add README.md rtl_morph_eval/README.md \
  rtl_morph_eval/configs/benchmark_manifest.json \
  rtl_morph_eval/scripts/materialize_reference_sources.py \
  rtl_morph_eval/tests/test_benchmark_metadata.py files
git commit -m "Publish benchmark reference sources"
```

- [ ] **Step 5: Push and verify remote state**

Run:

```bash
git push origin main
git rev-parse HEAD
```

Then query GitHub `zhihaoxu1325/RTLopt` and require remote `main` to report
the same SHA. If terminal DNS remains unavailable, use the GitHub Connector only
for remote verification; do not claim the local commit was pushed.
