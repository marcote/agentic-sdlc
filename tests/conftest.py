import subprocess
import sys
from pathlib import Path

import pytest

HARNESS = Path(__file__).resolve().parent.parent

collect_ignore = ["fixtures"]

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
    return run(sys.executable, str(HARNESS / "scripts/spec.py"), *args, cwd=cwd)


@pytest.fixture
def ns_file(tmp_path):
    f = tmp_path / "north-star.md"
    f.write_text(NS)
    return f


import json
import os

SLICE_SPEC = """# Slice add

| term | meaning |
| --- | --- |
| **sum** | the result of add |

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| R1 | When add runs, the module shall return the **sum**. | real-enforcement | E1 |
| R2 | When sub runs, the module shall return the difference. | real-enforcement | E2 |

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | 2 and 3 | add runs | 5 |
| E2 | 5 and 3 | sub runs | 2 |

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | write add in calc.py | R1 | |
| T2 | write sub in calc.py, UNIQUE_T2_TEXT | R2 | |
"""

# imports sit inside the test, so a missing module fails the test (exit 1) instead of breaking collection (exit 2)
TEST_E1 = "def test_e1_add():\n    from calc import add\n    assert add(2, 3) == 5\n"
TEST_E2 = "def test_e2_sub():\n    from calc import sub\n    assert sub(5, 3) == 2\n"
OK = {"status": "done", "summary": "ok", "assumptions": [], "reused": [], "new_deps": [], "tokens": 10}
PASS = {"verdict": "pass", "findings": [], "tokens": 10}


class Slice:
    def __init__(self, root):
        self.root = root
        self.dir = root / "specs/001-add"
        self.log = root / ".fake_log"
        self.plan = root / ".fake_plan"

    def script(self, implementer, reviewer=None, judge=None):
        plan = {"implementer": implementer, "reviewer": reviewer or [PASS], "judge": judge or [PASS]}
        self.plan.write_text(json.dumps(plan))

    def env(self):
        return {**os.environ, "FAKE_PLAN": str(self.plan), "FAKE_LOG": str(self.log)}

    def calls(self):
        if not self.log.exists():
            return []
        return [json.loads(l) for l in self.log.read_text().splitlines()]

    def build(self, *args):
        return run(sys.executable, str(HARNESS / "scripts/build.py"), str(self.dir), *args, cwd=self.root, env=self.env())

    def accept(self, *args):
        return run(sys.executable, str(HARNESS / "scripts/accept.py"), str(self.dir), *args, cwd=self.root, env=self.env())

    def report(self):
        return json.loads((self.dir / "build-report.json").read_text())

    def git(self, *args):
        return run("git", *args, cwd=self.root, check=True).stdout


@pytest.fixture
def slice_repo(tmp_path):
    root = tmp_path / "repo"
    root.mkdir()
    s = Slice(root)
    s.dir.mkdir(parents=True)
    (s.dir / "spec.md").write_text(SLICE_SPEC)
    (root / "memory/north-star").mkdir(parents=True)
    (root / "memory/north-star/north-star.md").write_text(NS)
    (root / "tests").mkdir()
    (root / "tests/conftest.py").write_text("import sys, pathlib\nsys.path.insert(0, str(pathlib.Path(__file__).parent.parent))\n")
    cfg = (HARNESS / "harness.toml").read_text()
    cfg = cfg.replace('implementer = "claude"', 'implementer = "fake"')
    cfg = cfg.replace('reviewer = "claude-ro"', 'reviewer = "fake"')
    cfg = cfg.replace('reflector = "claude-ro"', 'reflector = "fake"')
    cfg = cfg.replace('judge = "claude-ro"', 'judge = "fake-judge"')
    cfg = cfg.replace(" && bash tests/run.sh", "").replace("suite_seconds = 30\n", "")
    (root / "harness.toml").write_text(cfg)
    (root / ".gitignore").write_text(".fake_log\n.fake_plan\n__pycache__/\n.pytest_cache/\n")
    run("git", "init", "-q", "-b", "main", cwd=root, check=True)
    run("git", "-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "--allow-empty", "-m", "root", cwd=root, check=True)
    run("git", "add", "-A", cwd=root, check=True)
    run("git", "-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "-m", "spec", cwd=root, check=True)
    run("git", "checkout", "-q", "-b", "001-add", cwd=root, check=True)
    run("git", "config", "user.email", "t@t", cwd=root, check=True)
    run("git", "config", "user.name", "t", cwd=root, check=True)
    return s
