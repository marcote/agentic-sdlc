import json
import re
import tomllib

from conftest import HARNESS
from test_accept import ready
from test_build import T0


def with_limit(s, line):
    cfg = (s.root / "harness.toml").read_text().replace("[limits]\n", f"[limits]\n{line}\n")
    (s.root / "harness.toml").write_text(cfg)
    s.git("commit", "-qam", "limit")


def test_e1_page_shows_suite_and_test_time(slice_repo):
    ready(slice_repo)
    rfile = slice_repo.dir / "build-report.json"
    r = json.loads(rfile.read_text())
    runs = [{"started": "2026-10-02T10:00:00+00:00", "tokens": 1, "escalations": [], "test_seconds": t} for t in (12, 4)]
    rfile.write_text(json.dumps({**r, "runs": runs}))
    slice_repo.git("commit", "-qam", "two runs")
    assert slice_repo.accept().returncode == 0
    html = (slice_repo.dir / "result.html").read_text()
    assert re.search(r"<th>Suite</th><td>\d+(\.\d+)? s</td>", html)
    assert "<th>Test time</th><td>12 s, 4 s</td>" in html


def test_e2_suite_over_budget_fails(slice_repo):
    ready(slice_repo, test_body="import time\n\n\ndef test_e1_add():\n    time.sleep(2)\n")
    with_limit(slice_repo, "suite_seconds = 1")
    main_before = slice_repo.git("rev-parse", "main")
    p = slice_repo.accept()
    assert p.returncode == 1, p.stdout + p.stderr
    assert "suite took" in p.stdout and "budget 1 s" in p.stdout
    assert slice_repo.git("rev-parse", "main") == main_before


def test_e3_no_uv_run_in_fake_or_helpers():
    cli = tomllib.loads((HARNESS / "harness.toml").read_text())["cli"]
    for name in ("fake", "fake-judge"):
        assert "uv" not in cli[name]["cmd"], name
    assert not re.search(r"""uv["',\s]+run""", (HARNESS / "tests/conftest.py").read_text())


def test_e4_t0_runs_examples_in_one_run(slice_repo):
    cfg = (slice_repo.root / "harness.toml").read_text()
    task = re.search(r'^task = "(.*)"$', cfg, re.M).group(1)
    cfg = cfg.replace(f'task = "{task}"', 'task = "echo \'{examples}\' >> .runs; ' + task + '"')
    (slice_repo.root / "harness.toml").write_text(cfg)
    (slice_repo.root / ".gitignore").write_text((slice_repo.root / ".gitignore").read_text() + ".runs\n")
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-qm", "runs log")
    slice_repo.script([T0])
    slice_repo.build()
    lines = (slice_repo.root / ".runs").read_text().splitlines()
    assert lines[0] == "e1_ or e2_" and "e2_" not in lines[1:2]


def test_e5_suite_runs_in_parallel():
    suite = tomllib.loads((HARNESS / "harness.toml").read_text())["checks"]["suite"]
    assert "-n auto" in suite
