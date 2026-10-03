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
