import os
import re
from datetime import datetime, timedelta, timezone

from conftest import HARNESS, OK, SLICE_SPEC, TEST_E1, TEST_E2, run
from test_accept import ready
from test_build import CALC_BOTH, T0, T1, T2


def iso(dt):
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def hours_ago(h):
    return iso(datetime.now(timezone.utc) - timedelta(hours=h))


def commit_at(s, when, msg, *paths):
    """Commit with a fixed committer date; no paths = an empty commit."""
    env = {"GIT_COMMITTER_DATE": when, "GIT_AUTHOR_DATE": when}
    run("git", "add", "-A", cwd=s.root, check=True)
    run("git", "commit", "-q", "--allow-empty", "-m", msg, cwd=s.root, env={**os.environ, **env}, check=True)


def brief_at(s, when):
    (s.dir / "brief.md").write_text("# brief\n")
    commit_at(s, when, "brief(001-add): the brief")


def ready_at(s, monkeypatch, when):
    monkeypatch.setenv("GIT_COMMITTER_DATE", when)
    monkeypatch.setenv("GIT_AUTHOR_DATE", when)
    ready(s)
    monkeypatch.delenv("GIT_COMMITTER_DATE")
    monkeypatch.delenv("GIT_AUTHOR_DATE")


def page_text(s):
    assert s.accept().returncode == 0
    html = (s.dir / "result.html").read_text()
    html = re.sub(r"<style>.*?</style>", "", html, flags=re.S)
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", html))


def test_e1_lead_time_from_brief(slice_repo, monkeypatch):
    commit_at(slice_repo, hours_ago(5), "design talk")
    brief_at(slice_repo, hours_ago(3))
    ready_at(slice_repo, monkeypatch, hours_ago(0))
    assert "Lead time 3.0 h" in page_text(slice_repo)


def test_e2_phase_rows(slice_repo, monkeypatch):
    brief_at(slice_repo, "2026-10-02T10:00:00Z")
    commit_at(slice_repo, "2026-10-02T11:00:00Z", "spec(001-add): approved at H1")
    ready_at(slice_repo, monkeypatch, "2026-10-02T13:30:00Z")
    text = page_text(slice_repo)
    assert "Brief → H1 1.0 h" in text and "H1 → build 2.5 h" in text and "Build → accept" in text


def test_e3_missing_h1_marker_is_unknown(slice_repo, monkeypatch):
    brief_at(slice_repo, hours_ago(3))
    ready_at(slice_repo, monkeypatch, hours_ago(1))
    text = page_text(slice_repo)
    assert "Brief → H1 unknown" in text and "H1 → build unknown" in text
    assert re.search(r"Lead time \d+\.\d h", text)


def test_e4_no_brief_measures_from_first_commit(slice_repo, monkeypatch):
    commit_at(slice_repo, hours_ago(2), "first work")
    ready_at(slice_repo, monkeypatch, hours_ago(0))
    assert "Lead time 2.0 h (from first commit)" in page_text(slice_repo)


def test_e5_spec_step_commits_h1_marker():
    assert "spec(<slice>): approved at H1" in (HARNESS / "harness/steps/spec.md").read_text()


def test_e6_extended_grep_still_finds_t0(slice_repo):
    slice_repo.script([T0, OK])
    assert slice_repo.build().returncode == 3  # T0 committed, T1 escalated
    slice_repo.git("config", "grep.patternType", "extended")
    slice_repo.log.unlink()
    slice_repo.script([T1, T2])
    p = slice_repo.build()
    prompts = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"]
    assert not any("## Task T0" in x for x in prompts)
    assert slice_repo.report()["tasks"]["T1"]["status"] == "done", p.stdout + p.stderr


def early_spec():
    """SLICE_SPEC before E2: no R2, E2 or T2."""
    keep = [l for l in SLICE_SPEC.splitlines(keepends=True) if not re.match(r"\| (R2|E2|T2) ", l)]
    return "".join(keep)


def build_then_gain_e2(s, second):
    """Build a slice that has only E1, then add E2 to the spec and build again."""
    (s.dir / "spec.md").write_text(early_spec())
    s.git("commit", "-qam", "early spec")
    s.script([{**OK, "_write": {"tests/test_e1_add.py": TEST_E1}}, T1])
    assert s.build().returncode == 0
    (s.dir / "spec.md").write_text(SLICE_SPEC)
    s.git("add", str(s.dir / "spec.md"))
    s.git("commit", "-qm", "spec gains E2")
    s.log.unlink()
    s.script(second)
    return s.build()


def test_e7_late_example_gets_its_own_t0(slice_repo):
    t0_e2 = {**OK, "_write": {"tests/test_e2_sub.py": TEST_E2}}
    p = build_then_gain_e2(slice_repo, [t0_e2, T2])
    assert p.returncode == 0, p.stdout + p.stderr
    prompts = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"]
    t0 = [x for x in prompts if "## Task T0" in x]
    assert len(t0) == 1 and "E2:" in t0[0] and "E1:" not in t0[0]
    log = slice_repo.git("log", "--format=%s")
    assert "build(001-add): T0 tests for E2" in log
    assert log.index("T0 tests for E2") > log.index("T2 ")  # newest first: the T0 commit came before T2


def test_e8_late_test_is_frozen(slice_repo):
    t0_e2 = {**OK, "_write": {"tests/test_e2_sub.py": TEST_E2}}
    cheat = {**OK, "_write": {"calc.py": CALC_BOTH, "tests/test_e2_sub.py": "def test_e2_sub():\n    pass\n"}}
    build_then_gain_e2(slice_repo, [t0_e2, cheat])
    reasons = [e["reason"] for e in slice_repo.report()["escalations"]]
    assert any("frozen test changed: tests/test_e2_sub.py" in x for x in reasons)
