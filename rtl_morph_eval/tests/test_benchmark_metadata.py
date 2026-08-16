import json
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]


def test_benchmark_metadata_uses_unambiguous_source_file_fields():
    manifest_path = REPO_ROOT / "rtl_morph_eval" / "configs" / "benchmark_manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    assert len(manifest) == 233

    for entry in manifest:
        case_dir = REPO_ROOT / entry["case_dir"]
        design_path = REPO_ROOT / entry["design_path"]
        metadata_path = REPO_ROOT / entry["metadata_path"]
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))

        assert case_dir.is_dir()
        assert design_path == case_dir / "design.v"
        assert design_path.exists()
        assert metadata_path == case_dir / "metadata.json"
        assert metadata_path.exists()
        assert metadata["design_path"] == entry["design_path"]
        assert metadata["metadata_path"] == entry["metadata_path"]
        assert metadata["repo_local_files"] == ["design.v", "metadata.json"]

        assert "included_files" not in entry
        assert "included_files" not in metadata
        assert "upstream_included_files" in entry
        assert "upstream_included_files" in metadata
        assert entry["upstream_included_files"] == metadata["upstream_included_files"]
        assert "repo-local benchmark input" in entry["notes"]
        assert "repo-local benchmark input" in metadata["notes"]
