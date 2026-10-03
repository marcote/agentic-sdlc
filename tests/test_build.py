import json
import os

from conftest import HARNESS, OK, PASS, TEST_E1, run


def call_once(slice_repo, response):
    """Run build.call() once, in-process via a tiny uv script, and return its JSON result."""
    slice_repo.script([response])
    code = (
        "import sys, json; sys.path.insert(0, %r)\n"
        "import build\n"
        "cfg = build.load_config(build.Path('harness.toml'))\n"
        "rep = {'tokens': 0}\n"
        "p, why = build.call(cfg, 'implementer', 'hello', rep)\n"
        "print(json.dumps({'payload': p, 'why': why, 'tokens': rep['tokens']}))\n"
    ) % str(HARNESS / "scripts")
    p = run("uv", "run", "-q", "--python", "3.12", "--with", "jsonschema", "python", "-c", code,
            cwd=slice_repo.root, env=slice_repo.env())
    assert p.returncode == 0, p.stderr
    return json.loads(p.stdout.splitlines()[-1])


def test_e25_fake_receives_implementer_call(slice_repo):
    out = call_once(slice_repo, OK)
    assert out["why"] == "" and out["payload"]["status"] == "done"
    assert slice_repo.calls()[0]["role"] == "implementer"
    assert out["tokens"] == 10


def test_e26_schema_violation(slice_repo):
    out = call_once(slice_repo, {"status": 5})
    assert out["payload"] is None and out["why"] == "schema: status"


def test_call_agent_crash(slice_repo):
    out = call_once(slice_repo, {"_crash": True})
    assert out["payload"] is None and out["why"].startswith("agent: exit 7")


def test_e29_help_runs_with_no_install(tmp_path):
    p = run("uv", "run", "-q", str(HARNESS / "scripts/build.py"), "--help", cwd=tmp_path)
    assert p.returncode == 0 and "usage" in p.stdout.lower()


def test_e27_real_agents(slice_repo):
    import pytest
    clis = [c for c in os.environ.get("RUN_REAL_AGENTS", "").split(",") if c]
    if not clis:
        pytest.skip("set RUN_REAL_AGENTS=claude,codex to call real CLIs (costs tokens)")
    for cli in clis:
        cfg = (slice_repo.root / "harness.toml").read_text()
        cfg = cfg.replace('implementer = "fake"', f'implementer = "{cli}"')
        (slice_repo.root / "harness.toml").write_text(cfg)
        slice_repo.script([OK])
        code = (
            "import sys, json; sys.path.insert(0, %r)\nimport build\n"
            "cfg = build.load_config(build.Path('harness.toml'))\n"
            "p, why = build.call(cfg, 'implementer', 'Create calc.py with def add(a, b): return a + b, "
            "and tests/test_e1_add.py asserting add(2, 3) == 5. Report status done.', {'tokens': 0})\n"
            "print(json.dumps({'payload': p, 'why': why}))\n"
        ) % str(HARNESS / "scripts")
        p = run("uv", "run", "-q", "--python", "3.12", "--with", "jsonschema", "python", "-c", code,
                cwd=slice_repo.root, env=slice_repo.env())
        out = json.loads(p.stdout.splitlines()[-1])
        assert out["why"] == "", f"{cli}: {out['why']}"
        t = run("uv", "run", "--python", "3.12", "--with", "pytest", "pytest", "-q", "-k", "e1_", cwd=slice_repo.root)
        assert t.returncode == 0, f"{cli}: {t.stdout}"
        run("git", "clean", "-fdq", "-e", ".fake_*", cwd=slice_repo.root)


from conftest import TEST_E2

CALC_ADD = "def add(a, b):\n    return a + b\n"
CALC_BOTH = CALC_ADD + "\ndef sub(a, b):\n    return a - b\n"
T0 = {**OK, "_write": {"tests/test_e1_add.py": TEST_E1, "tests/test_e2_sub.py": TEST_E2}}
T1 = {**OK, "_write": {"calc.py": CALC_ADD}}
T2 = {**OK, "_write": {"calc.py": CALC_BOTH}}


def test_build_happy_path(slice_repo):
    slice_repo.script([T0, T1, T2])
    p = slice_repo.build()
    assert p.returncode == 0, p.stdout + p.stderr
    r = slice_repo.report()
    assert {k: v["status"] for k, v in r["tasks"].items()} == {"T0": "done", "T1": "done", "T2": "done"}
    assert "T1" in slice_repo.git("log", "--format=%s", "-3")


def test_e10_vacuous_test(slice_repo):
    vacuous = {**OK, "_write": {"tests/test_e1_add.py": "def test_e1_add():\n    assert True\n", "tests/test_e2_sub.py": TEST_E2}}
    slice_repo.script([vacuous])
    p = slice_repo.build()
    assert p.returncode == 3
    assert any("vacuous: E1" in e["reason"] for e in slice_repo.report()["escalations"])


def test_e11_frozen_test_changed(slice_repo):
    cheat = {**OK, "_write": {"calc.py": CALC_ADD, "tests/test_e1_add.py": "def test_e1_add():\n    pass\n"}}
    slice_repo.script([T0, cheat, cheat, cheat])
    slice_repo.build()
    reasons = [e["reason"] for e in slice_repo.report()["escalations"]]
    assert any("frozen test changed: tests/test_e1_add.py" in x for x in reasons)


def test_e12_order_implementer_checks_reviewer(slice_repo):
    slice_repo.script([T0, T1, T2])
    slice_repo.build()
    trace = [t for t in slice_repo.report()["trace"] if t.startswith("T1:")]
    assert trace == ["T1:implementer", "T1:checks", "T1:reviewer"]


def test_e13_same_failure_twice_escalates(slice_repo):
    slice_repo.script([T0, OK])  # T1 writes nothing; the same test fails each time
    p = slice_repo.build()
    r = slice_repo.report()
    assert p.returncode == 3
    assert r["tasks"]["T1"] == {"status": "escalated", "attempts": 2}
    assert "test_e1_add" in r["escalations"][0]["reason"]


def test_e14_structural_blocks_and_others_continue(slice_repo):
    blocked = {**OK, "status": "blocked", "assumptions": [{"text": "which date counts?", "severity": "structural"}]}
    t2_alone = {**OK, "_write": {"calc.py": "def sub(a, b):\n    return a - b\n"}}
    slice_repo.script([T0, blocked, t2_alone])
    p = slice_repo.build()
    r = slice_repo.report()
    assert r["tasks"]["T1"]["status"] == "blocked" and r["tasks"]["T2"]["status"] == "done"
    assert p.stdout.count("ESCALATIONS (1)") == 1 and "which date counts?" in p.stdout


def test_e15_budget(slice_repo):
    cfg = (slice_repo.root / "harness.toml").read_text().replace("budget_tokens = 3_000_000", "budget_tokens = 1000")
    (slice_repo.root / "harness.toml").write_text(cfg)
    slice_repo.git("commit", "-qam", "lower budget")
    slice_repo.script([{**T0, "tokens": 600}], [{**PASS, "tokens": 600}])
    p = slice_repo.build()
    assert p.returncode == 3
    assert len(slice_repo.calls()) == 2
    assert "budget exceeded" in slice_repo.report()["escalations"][-1]["reason"]


def test_e16_prompt_has_only_its_task(slice_repo):
    slice_repo.script([T0, T1, T2])
    slice_repo.build()
    t1 = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer" and "## Task T1" in c["prompt"]]
    assert t1 and "UNIQUE_T2_TEXT" not in t1[0]


def test_e17_report_schema_retry_and_assumption(slice_repo):
    wrong = {**OK, "_write": {"calc.py": "def add(a, b):\n    return 0\n"}}
    right = {**T1, "assumptions": [{"text": "ints only", "severity": "minor"}]}
    slice_repo.script([T0, wrong, right, T2])
    assert slice_repo.build().returncode == 0
    r = slice_repo.report()
    import jsonschema
    jsonschema.validate(r, json.loads((HARNESS / "harness/schemas/build-report.json").read_text()))
    assert r["tasks"]["T1"]["attempts"] == 2
    assert r["assumptions"] == [{"task": "T1", "text": "ints only"}]


def test_reviewer_fix_feeds_back(slice_repo):
    fix = {"verdict": "fix", "findings": ["R1 library-first: calc.py hand-made"], "tokens": 10}
    slice_repo.script([T0, T1, T1, T2], [PASS, fix, PASS])
    assert slice_repo.build().returncode == 0
    retry = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"][2]
    assert "R1 library-first" in retry


def test_build_refuses_dirty_tree(slice_repo):
    (slice_repo.root / "stray.txt").write_text("x")
    p = slice_repo.build()
    assert p.returncode == 2 and "dirty" in p.stderr and (slice_repo.root / "stray.txt").exists()


def test_build_reruns_after_escalation(slice_repo):
    slice_repo.script([T0, OK])
    assert slice_repo.build().returncode == 3
    slice_repo.script([T1, T2])
    assert slice_repo.build().returncode != 2  # the left-over build-report.json is not "dirty"


def test_build_refuses_main(slice_repo):
    slice_repo.git("checkout", "-q", "main")
    p = slice_repo.build()
    assert p.returncode == 2 and "main" in p.stderr
