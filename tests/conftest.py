import subprocess
from pathlib import Path

import pytest

HARNESS = Path(__file__).resolve().parent.parent

NS = """# North Star
| term | meaning |
| --- | --- |
| **budget** | max tokens for one slice |

Pillars: real-enforcement, measurable-impact.
"""


def run(*args, cwd=None, env=None, check=False):
    """Run a command; return CompletedProcess with text output."""
    p = subprocess.run(list(args), cwd=cwd, env=env, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise AssertionError(p.stdout + p.stderr)
    return p


def spec_cmd(*args, cwd=None):
    return run("uv", "run", "-q", str(HARNESS / "scripts/spec.py"), *args, cwd=cwd)


@pytest.fixture
def ns_file(tmp_path):
    f = tmp_path / "north-star.md"
    f.write_text(NS)
    return f
