import json
import sys
from pathlib import Path, PurePosixPath

import pytest


REPO_ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = REPO_ROOT / "rtl_morph_eval" / "configs" / "benchmark_manifest.json"
sys.path.insert(0, str(REPO_ROOT / "rtl_morph_eval" / "scripts"))

from materialize_reference_sources import safe_relative_path  # noqa: E402


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


def _normalized_lines(text):
    return text.strip().splitlines()


@pytest.mark.parametrize(
    "raw_path",
    ["", ".", "/rtl/top.v", "../top.v", "rtl/../top.v"],
)
def test_reference_source_paths_reject_unsafe_values(raw_path):
    with pytest.raises(ValueError, match="unsafe source path"):
        safe_relative_path(raw_path)


def test_benchmark_metadata_has_local_reference_sources():
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))

    assert len(manifest) == 233

    for entry in manifest:
        case_dir = REPO_ROOT / entry["case_dir"]
        design_path = REPO_ROOT / entry["design_path"]
        metadata_path = REPO_ROOT / entry["metadata_path"]
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))

        assert entry == metadata
        assert case_dir.is_dir()
        assert design_path == case_dir / "design.v"
        assert design_path.exists()
        assert metadata_path == case_dir / "metadata.json"
        assert metadata_path.exists()
        assert metadata["design_path"] == entry["design_path"]
        assert metadata["metadata_path"] == entry["metadata_path"]
        assert "repo_local_files" not in metadata
        assert metadata["benchmark_input"] == "design.v"
        assert metadata["llm_input"] == "design.v"
        assert metadata["reference_source_dir"] == "reference_sources"

        assert "included_files" not in entry
        assert "included_files" not in metadata
        assert "upstream_included_files" not in entry
        assert "upstream_included_files" not in metadata
        assert len(entry["source_files"]) == entry["file_count"]

        design_text = design_path.read_text(encoding="utf-8")
        sections = _source_sections(design_text, entry["source_files"])
        for source_file, section in zip(entry["source_files"], sections):
            upstream_path = PurePosixPath(source_file["upstream_path"])
            repo_path = PurePosixPath(source_file["repo_path"])

            assert not upstream_path.is_absolute()
            assert ".." not in upstream_path.parts
            assert repo_path == PurePosixPath("reference_sources") / upstream_path

            reference_path = case_dir.joinpath(*repo_path.parts)
            assert reference_path.is_file()
            reference_text = reference_path.read_bytes().decode("utf-8", errors="ignore")
            assert _normalized_lines(section) == _normalized_lines(reference_text)
