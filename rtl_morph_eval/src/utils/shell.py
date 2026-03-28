from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence


@dataclass
class CommandResult:
    cmd: list[str]
    returncode: int
    stdout: str
    stderr: str


class ShellRunner:
    def run(self, cmd: Sequence[str], timeout_sec: int = 120, cwd: str | Path | None = None) -> CommandResult:
        p = subprocess.run(
            list(cmd),
            cwd=str(cwd) if cwd else None,
            text=True,
            capture_output=True,
            timeout=timeout_sec,
            check=False,
        )
        return CommandResult(list(cmd), p.returncode, p.stdout, p.stderr)
