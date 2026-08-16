#!/usr/bin/env python3
"""Restore selected benchmark source files from the repository's Git history."""

import json
import subprocess
from pathlib import Path, PurePosixPath


REPO_ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = REPO_ROOT / "rtl_morph_eval" / "configs" / "benchmark_manifest.json"
SOURCE_REVISION = "b2bc713^"
EXPECTED_CASES = 233
EXPECTED_SOURCE_FILES = 2349
REFERENCE_DIR = PurePosixPath("reference_sources")
NOTES = (
    "Curated single-file RTL benchmark case. Use design.v as the only "
    "benchmark and LLM input. reference_sources contains the individual "
    "upstream files merged into design.v for provenance and review only."
)


def safe_relative_path(raw_path):
    path = PurePosixPath(raw_path)
    if not raw_path or not path.parts or path.is_absolute() or ".." in path.parts:
        raise ValueError(f"unsafe source path: {raw_path!r}")
    return path


def read_historical_blob(source_project, upstream_path):
    object_name = (
        f"{SOURCE_REVISION}:files/{source_project}/{upstream_path.as_posix()}"
    )
    try:
        return subprocess.run(
            ["git", "show", object_name],
            cwd=REPO_ROOT,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ).stdout
    except subprocess.CalledProcessError as error:
        detail = error.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"cannot read {object_name}: {detail}") from error


def source_paths(entry):
    upstream_paths = entry.get("upstream_included_files")
    if upstream_paths is not None:
        return [safe_relative_path(path) for path in upstream_paths]
    return [
        safe_relative_path(source_file["upstream_path"])
        for source_file in entry["source_files"]
    ]


def write_json(path, value):
    path.write_text(
        json.dumps(value, indent=2, ensure_ascii=True) + "\n",
        encoding="utf-8",
    )


def main():
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    plans = [(entry, source_paths(entry)) for entry in manifest]
    source_file_count = sum(len(paths) for _, paths in plans)

    if len(plans) != EXPECTED_CASES:
        raise RuntimeError(
            f"expected {EXPECTED_CASES} cases, found {len(plans)}"
        )
    if source_file_count != EXPECTED_SOURCE_FILES:
        raise RuntimeError(
            f"expected {EXPECTED_SOURCE_FILES} source files, "
            f"found {source_file_count}"
        )

    for entry, paths in plans:
        case_dir = REPO_ROOT / entry["case_dir"]
        mappings = []
        for upstream_path in paths:
            repo_path = REFERENCE_DIR / upstream_path
            target = case_dir.joinpath(*repo_path.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(
                read_historical_blob(entry["source_project"], upstream_path)
            )
            mappings.append(
                {
                    "upstream_path": upstream_path.as_posix(),
                    "repo_path": repo_path.as_posix(),
                }
            )

        entry["benchmark_input"] = "design.v"
        entry["reference_source_dir"] = REFERENCE_DIR.as_posix()
        entry["source_files"] = mappings
        entry["notes"] = NOTES
        entry.pop("upstream_included_files", None)
        entry.pop("repo_local_files", None)

        metadata_path = REPO_ROOT / entry["metadata_path"]
        write_json(metadata_path, entry)

    write_json(MANIFEST_PATH, manifest)
    print(
        f"Materialized {source_file_count} reference source files "
        f"for {len(plans)} benchmark cases."
    )


if __name__ == "__main__":
    main()
