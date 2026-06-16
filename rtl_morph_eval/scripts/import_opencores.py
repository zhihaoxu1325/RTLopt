#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import html
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path


INDEX_URL = "https://fabriziotappero.github.io/opencores-scraper/cores.html"
REPO_URL = "https://github.com/fabriziotappero/ip-cores.git"
GITHUB_TREE_URL = "https://github.com/fabriziotappero/ip-cores/tree"

DEFAULT_LANGUAGES = {"Verilog"}
DEFAULT_STATUSES = {"Stable", "Mature", "Beta", "Alpha"}
DEFAULT_LICENSES = {"BSD", "LGPL", "GPL"}
DEFAULT_PREFIXES = {
    "arithmetic",
    "communication",
    "crypto",
    "dsp",
    "memory",
    "processor",
    "system",
    "video",
}

SKIP_DIR_PARTS = {
    ".git",
    "bench",
    "doc",
    "docs",
    "sim",
    "simulation",
    "software",
    "sw",
    "test",
    "tests",
    "tb",
    "verification",
}
SKIP_FILE_RE = re.compile(r"(^|[_-])(tb|test|bench|sim)([_-]|\.|$)", re.IGNORECASE)
LICENSE_FILE_RE = re.compile(r"(license|licence|copying|gpl|lgpl|bsd)", re.IGNORECASE)
MODULE_RE = re.compile(r"\bmodule\s+([A-Za-z_][A-Za-z0-9_$]*)\b")


@dataclass(frozen=True)
class CoreIndexEntry:
    branch: str
    name: str
    language: str
    status: str
    license: str
    prefix: str
    source_url: str


@dataclass(frozen=True)
class ImportedCore:
    branch: str
    name: str
    language: str
    status: str
    license: str
    prefix: str
    source_url: str
    destination: str
    verilog_files: list[str]
    license_files: list[str]
    top_candidates: list[str]


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def fetch_index(cache_path: Path, refresh: bool) -> str:
    if cache_path.exists() and not refresh:
        return cache_path.read_text(encoding="utf-8", errors="ignore")
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(INDEX_URL, timeout=60) as response:
        text = response.read().decode("utf-8", errors="ignore")
    cache_path.write_text(text, encoding="utf-8")
    return text


def clean_text(raw: str) -> str:
    raw = re.sub(r"<.*?>", "", raw, flags=re.S)
    return html.unescape(raw).strip()


def parse_index(index_html: str) -> list[CoreIndexEntry]:
    entries: list[CoreIndexEntry] = []
    for row in re.findall(r"<tr>(.*?)</tr>", index_html, flags=re.S | re.I):
        code = re.search(
            r"href='https://github\.com/fabriziotappero/ip-cores/tree/([^'#]+)'[^>]*>code</a>",
            row,
        )
        if not code:
            continue
        branch = code.group(1)
        names = re.findall(
            r"href='https://github\.com/fabriziotappero/ip-cores/tree/[^']*(?:#vhdlverilog-ip-cores-repository)?'>(.*?)</a>",
            row,
            flags=re.S,
        )
        cols = [clean_text(col) for col in re.findall(r"<td>(.*?)</td>", row, flags=re.S | re.I)]
        name = clean_text(names[0]) if names else branch
        language = cols[2] if len(cols) >= 5 else ""
        status = cols[3] if len(cols) >= 5 else ""
        license_name = cols[4] if len(cols) >= 5 else ""
        prefix = branch.split("_", 1)[0] if "_" in branch else branch
        entries.append(
            CoreIndexEntry(
                branch=branch,
                name=name,
                language=language,
                status=status,
                license=license_name,
                prefix=prefix,
                source_url=f"{GITHUB_TREE_URL}/{branch}",
            )
        )
    return entries


def split_filter(value: str | None, default: set[str]) -> set[str]:
    if not value:
        return default
    return {part.strip() for part in value.split(",") if part.strip()}


def select_entries(
    entries: list[CoreIndexEntry],
    languages: set[str],
    statuses: set[str],
    licenses: set[str],
    prefixes: set[str],
    limit: int | None,
) -> list[CoreIndexEntry]:
    selected = [
        entry
        for entry in entries
        if entry.language in languages
        and entry.status in statuses
        and entry.license in licenses
        and entry.prefix in prefixes
    ]
    selected.sort(key=lambda item: (item.prefix, item.branch))
    return selected[:limit] if limit else selected


def run(cmd: list[str], cwd: Path | None = None) -> None:
    subprocess.run(cmd, cwd=cwd, check=True)


def clone_branch(branch: str, cache_dir: Path, refresh: bool) -> Path:
    destination = cache_dir / branch
    if destination.exists() and refresh:
        shutil.rmtree(destination)
    if destination.exists():
        return destination
    destination.parent.mkdir(parents=True, exist_ok=True)
    run(
        [
            "git",
            "clone",
            "--depth",
            "1",
            "--single-branch",
            "--branch",
            branch,
            REPO_URL,
            str(destination),
        ]
    )
    return destination


def is_candidate_verilog(path: Path, core_root: Path) -> bool:
    rel = path.relative_to(core_root)
    parts = {part.lower() for part in rel.parts[:-1]}
    if parts & SKIP_DIR_PARTS:
        return False
    return not SKIP_FILE_RE.search(path.name)


def verilog_files(core_root: Path) -> list[Path]:
    files = [path for path in core_root.rglob("*.v") if is_candidate_verilog(path, core_root)]
    preferred = [path for path in files if "rtl" in {part.lower() for part in path.parts}]
    return sorted(preferred or files)


def license_files(core_root: Path) -> list[Path]:
    files: list[Path] = []
    for path in core_root.rglob("*"):
        if not path.is_file():
            continue
        if ".git" in {part.lower() for part in path.relative_to(core_root).parts}:
            continue
        if LICENSE_FILE_RE.search(path.name):
            files.append(path)
    return sorted(files)


def top_candidates(paths: list[Path]) -> list[str]:
    modules: list[str] = []
    seen: set[str] = set()
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in MODULE_RE.finditer(text):
            module = match.group(1)
            if module not in seen:
                seen.add(module)
                modules.append(module)
    return modules[:20]


def import_entry(entry: CoreIndexEntry, cache_dir: Path, output_dir: Path, refresh: bool) -> ImportedCore | None:
    core_root = clone_branch(entry.branch, cache_dir, refresh)
    source_files = verilog_files(core_root)
    if not source_files:
        return None

    destination = (output_dir / entry.branch).resolve()
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir(parents=True, exist_ok=True)

    copied: list[str] = []
    for source in source_files:
        rel = source.relative_to(core_root)
        target = destination / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        copied.append(str(rel))

    copied_licenses: list[str] = []
    for source in license_files(core_root):
        rel = source.relative_to(core_root)
        target = destination / "_licenses" / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        copied_licenses.append(str(rel))

    metadata = {
        "branch": entry.branch,
        "name": entry.name,
        "language": entry.language,
        "status": entry.status,
        "license": entry.license,
        "prefix": entry.prefix,
        "source_url": entry.source_url,
        "verilog_files": copied,
        "license_files": copied_licenses,
        "top_candidates": top_candidates(source_files),
    }
    (destination / "opencores_metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    try:
        destination_label = str(destination.relative_to(repo_root()))
    except ValueError:
        destination_label = str(destination)
    return ImportedCore(destination=destination_label, **metadata)


def write_manifest(imported: list[ImportedCore], manifest_path: Path) -> None:
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps([asdict(item) for item in imported], indent=2), encoding="utf-8")
    csv_path = manifest_path.with_suffix(".csv")
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "branch",
                "name",
                "language",
                "status",
                "license",
                "prefix",
                "source_url",
                "destination",
                "verilog_file_count",
                "license_file_count",
                "top_candidates",
            ],
        )
        writer.writeheader()
        for item in imported:
            row = asdict(item)
            row["verilog_file_count"] = len(item.verilog_files)
            row["license_file_count"] = len(item.license_files)
            row["top_candidates"] = ";".join(item.top_candidates)
            row.pop("verilog_files")
            row.pop("license_files")
            writer.writerow(row)


def main() -> int:
    parser = argparse.ArgumentParser(description="Import selected OpenCores Verilog branches from fabriziotappero/ip-cores.")
    parser.add_argument("--apply", action="store_true", help="Actually clone and copy selected cores. Without this, only print candidates.")
    parser.add_argument("--limit", type=int, default=0, help="Maximum selected cores to process. 0 means no limit.")
    parser.add_argument("--target-imported", type=int, default=0, help="Stop after this many cores have been imported. 0 means process all selected cores.")
    parser.add_argument("--languages", help="Comma-separated allowed languages.", default=None)
    parser.add_argument("--statuses", help="Comma-separated allowed development statuses.", default=None)
    parser.add_argument("--licenses", help="Comma-separated allowed licenses.", default=None)
    parser.add_argument("--prefixes", help="Comma-separated allowed branch prefixes/categories.", default=None)
    parser.add_argument("--refresh-index", action="store_true", help="Re-download the index HTML.")
    parser.add_argument("--refresh-clones", action="store_true", help="Re-clone branches already present in the cache.")
    parser.add_argument("--cache-dir", type=Path, default=repo_root() / "work" / "opencores_cache")
    parser.add_argument("--output-dir", type=Path, default=repo_root() / "files")
    parser.add_argument("--manifest", type=Path, default=repo_root() / "rtl_morph_eval" / "configs" / "opencores_manifest.json")
    args = parser.parse_args()

    html_text = fetch_index(args.cache_dir / "cores.html", args.refresh_index)
    entries = parse_index(html_text)
    selected = select_entries(
        entries,
        split_filter(args.languages, DEFAULT_LANGUAGES),
        split_filter(args.statuses, DEFAULT_STATUSES),
        split_filter(args.licenses, DEFAULT_LICENSES),
        split_filter(args.prefixes, DEFAULT_PREFIXES),
        args.limit or None,
    )

    print(f"Parsed {len(entries)} index entries; selected {len(selected)} candidates.")
    for entry in selected[: min(30, len(selected))]:
        print(f"{entry.branch}\t{entry.language}\t{entry.status}\t{entry.license}\t{entry.source_url}")
    if len(selected) > 30:
        print(f"... {len(selected) - 30} more candidates")

    if not args.apply:
        print("Dry run only. Re-run with --apply to clone and import selected cores.")
        return 0

    cache_dir = args.cache_dir.resolve()
    output_dir = args.output_dir.resolve()
    manifest_path = args.manifest.resolve()
    imported: list[ImportedCore] = []
    skipped: list[str] = []
    with tempfile.TemporaryDirectory(prefix="opencores-import-") as tmp:
        cache_dir = cache_dir if args.cache_dir else Path(tmp)
        for entry in selected:
            if args.target_imported and len(imported) >= args.target_imported:
                break
            try:
                result = import_entry(entry, cache_dir, output_dir, args.refresh_clones)
            except subprocess.CalledProcessError as exc:
                print(f"SKIP {entry.branch}: git failed with exit {exc.returncode}", file=sys.stderr)
                skipped.append(entry.branch)
                continue
            if result is None:
                print(f"SKIP {entry.branch}: no eligible Verilog files", file=sys.stderr)
                skipped.append(entry.branch)
                continue
            imported.append(result)

    write_manifest(imported, manifest_path)
    print(f"Imported {len(imported)} cores; skipped {len(skipped)}.")
    print(f"Wrote manifest: {manifest_path}")
    print(f"Wrote CSV: {manifest_path.with_suffix('.csv')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
