import json

from conftest import PASS, TEST_E1


def ready(slice_repo, test_body=TEST_E1, calc="def add(a, b):\n    return a + b\n"):
    """Put a finished slice on the branch: code, test, and an empty build report."""
    slice_repo.script([])
    (slice_repo.root / "calc.py").write_text(calc)
    (slice_repo.root / "tests/test_e1_add.py").write_text(test_body)
    (slice_repo.dir / "build-report.json").write_text(json.dumps(
        {"tokens": 5, "tasks": {}, "trace": [], "assumptions": [{"task": "T1", "text": "ints only"}],
         "escalations": [], "reused": ["calc"], "new": [], "started": "2026-10-02T10:00:00+00:00"}))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "build(001-add): T1 add")


def test_e18_green_merges_into_main(slice_repo):
    ready(slice_repo)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    assert "build(001-add): T1 add" in slice_repo.git("log", "main", "--format=%s")


def test_e19_fails_twice_then_escalates(slice_repo):
    ready(slice_repo, test_body="def test_e1_add():\n    assert False\n")
    slice_repo.script([{"status": "done", "summary": "", "assumptions": [], "reused": [], "new_deps": []}])
    p = slice_repo.accept()
    assert p.returncode == 1
    fixes = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"]
    # one return to build = one FIX task; the same failure twice ends it (B4)
    assert len(fixes) == 2 and all("## Task FIX" in f for f in fixes)
    assert "ESCALATIONS" in p.stdout
    assert "build(001-add)" not in slice_repo.git("log", "main", "--format=%s")


def test_e20_results_written_back_as_reported(slice_repo):
    ready(slice_repo)
    (slice_repo.dir / "results.json").write_text(json.dumps([{"id": "H-3", "value": "0.42"}]))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "results")
    assert slice_repo.accept().returncode == 0
    ns = slice_repo.git("show", "main:memory/north-star/north-star.md")
    assert "## Reported" in ns and "- H-3: 0.42 — reported" in ns and "slice 001-add" in ns


def test_e21_module_not_in_map(slice_repo):
    ready(slice_repo)
    (slice_repo.root / "src/rule").mkdir(parents=True)
    (slice_repo.root / "src/rule/__init__.py").write_text("")
    (slice_repo.root / "docs").mkdir()
    (slice_repo.root / "docs/modules.md").write_text("| module | layer | purpose | interface | anchors | status |\n| --- | --- | --- | --- | --- | --- |\n| ghost | x | y | z | P1 | reported |\n")
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "map")
    p = slice_repo.accept()
    assert p.returncode == 1
    assert "rule: not in module map" in p.stdout and "ghost: no directory" in p.stdout


def test_e22_result_page(slice_repo):
    ready(slice_repo)
    assert slice_repo.accept().returncode == 0
    html = (slice_repo.dir / "result.html").read_text()
    for s in ("Lead time", "Interventions", "Reused", "New", "Assumptions", "ints only"):
        assert s in html


def test_e23_judge_is_another_family(slice_repo):
    spec = (slice_repo.dir / "spec.md").read_text().replace("| real-enforcement | E2 |", "| real-enforcement | judged, rubric R1 |")
    (slice_repo.dir / "spec.md").write_text(spec)
    ready(slice_repo)
    slice_repo.script([], judge=[PASS])
    assert slice_repo.accept().returncode == 0
    assert [c["role"] for c in slice_repo.calls()] == ["judge"]


def test_e23_same_family_refused(slice_repo):
    spec = (slice_repo.dir / "spec.md").read_text().replace("| real-enforcement | E2 |", "| real-enforcement | judged, rubric R1 |")
    (slice_repo.dir / "spec.md").write_text(spec)
    cfg = (slice_repo.root / "harness.toml").read_text().replace('judge = "fake-judge"', 'judge = "fake"')
    (slice_repo.root / "harness.toml").write_text(cfg)
    ready(slice_repo)
    p = slice_repo.accept()
    assert p.returncode == 2 and "different model family" in p.stderr


def test_accept_merge_conflict(slice_repo):
    ready(slice_repo)
    slice_repo.git("checkout", "-q", "main")
    (slice_repo.root / "calc.py").write_text("x = 1\n")
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "conflict on main")
    main_before = slice_repo.git("rev-parse", "main")
    slice_repo.git("checkout", "-q", "001-add")
    p = slice_repo.accept()
    assert p.returncode == 1 and "merge conflict" in p.stdout
    assert slice_repo.git("rev-parse", "main") == main_before
    assert slice_repo.git("status", "--porcelain") == ""
