import re

from conftest import HARNESS, NS, OK, PASS, SLICE_SPEC, TEST_E1, TEST_E2, run, spec_cmd
from test_build import CALC_ADD, CALC_BOTH, T0, T1, T2

QUIET = {**PASS, "tokens": 0}
SKELETON = "tests/check_00_skeleton.sh"
T0_SKEL = {**T0, "_write": {**T0["_write"], SKELETON: "#!/bin/sh\ntrue\n"}}
BLOCKED = {"status": "blocked", "summary": "need a choice", "reused": [], "new_deps": [], "tokens": 0,
           "assumptions": [{"text": "which sum", "severity": "structural"}]}


def implementer_prompts(s):
    return [c["prompt"] for c in s.calls() if c["role"] == "implementer"]


def test_e1_prompt_lists_frozen_tests(slice_repo):
    slice_repo.script([T0, T1, T2])
    assert slice_repo.build().returncode == 0
    t1 = next(p for p in implementer_prompts(slice_repo) if "## Task T1" in p)
    assert "Frozen tests" in t1
    assert "tests/test_e1_add.py" in t1.split("Frozen tests", 1)[1]


def test_e2_rule_forbids_frozen_edits_only():
    text = (HARNESS / "harness/prompts/implementer.md").read_text()
    assert "never edit a file under tests/ that exists already" not in text
    assert "never edit a frozen test" in text


def test_e3_unfrozen_test_edit_is_allowed(slice_repo):
    t1 = {**T1, "_write": {SKELETON: "#!/bin/sh\nexit 0\n", "calc.py": CALC_ADD}}
    slice_repo.script([T0_SKEL, t1, T2])
    p = slice_repo.build()
    r = slice_repo.report()
    assert not [e for e in r["escalations"] if "frozen" in e["reason"]], r["escalations"]
    assert r["tasks"]["T1"] == {"status": "done", "attempts": 1}, p.stdout + p.stderr


REMOVED = "scripts/guards/no-prescribe.sh"
REFERRER = "memory/stack/stack.md"
REMOVES = f"\n| removes | why |\n| --- | --- |\n| `{REMOVED}` | the guard goes |\n"


STRAY = "docs/other.md"


def lint_repo(tmp_path, files, extra=""):
    root = tmp_path / "repo"
    root.mkdir()
    (root / "north-star.md").write_text(NS)
    spec = root / "specs/099-x/spec.md"
    spec.parent.mkdir(parents=True)
    spec.write_text(SLICE_SPEC + REMOVES + extra)
    files = {REMOVED: "#!/bin/sh\n", STRAY: f"see {REMOVED}\n", **files}
    for path, text in files.items():
        (root / path).parent.mkdir(parents=True, exist_ok=True)
        (root / path).write_text(text)
    run("git", "init", "-q", cwd=root, check=True)
    run("git", "add", "-A", cwd=root, check=True)
    return spec_cmd("lint", "specs/099-x/spec.md", "--north-star", "north-star.md", cwd=root)


def test_e4_lint_reports_unnamed_referrer(tmp_path):
    p = lint_repo(tmp_path, {REFERRER: f"Guard: bash {REMOVED}\n"})
    assert p.returncode == 1, p.stdout + p.stderr
    assert f"{REMOVED}: referred by {REFERRER}" in p.stdout


def test_e5_named_referrer_is_clean(tmp_path):
    p = lint_repo(tmp_path, {REFERRER: f"Guard: bash {REMOVED}\n"}, extra=f"\nThe pin in `{REFERRER}` goes too.\n")
    assert f"{REMOVED}: referred by {STRAY}" in p.stdout and REFERRER not in p.stdout, p.stdout


def test_e6_specs_are_history(tmp_path):
    p = lint_repo(tmp_path, {"specs/015-x/spec.md": f"Guard: bash {REMOVED}\n"})
    assert f"referred by {STRAY}" in p.stdout and "specs/015-x" not in p.stdout, p.stdout


def test_e7_stale_names_imports_history():
    text = (HARNESS / "tests/stale_names.py").read_text()
    assert not re.search(r"^HISTORY\s*=", text, re.M) and '"specs/"' not in text
    assert re.search(r"^\s*(import|from)\s+(scripts\.)?spec\b", text, re.M)


def two_runs(s):
    s.script([{**T0, "tokens": 600}, BLOCKED], reviewer=[QUIET])
    s.build()
    s.script([{**T1, "tokens": 400}, {**T2, "tokens": 0}], reviewer=[QUIET])
    return s.build()


def test_e8_interventions_count_answer_commits(slice_repo):
    from test_accept import ready
    slice_repo.git("commit", "-q", "--allow-empty", "-m", "spec(001-add): approved at H1")
    ready(slice_repo)
    for n in (1, 2):
        slice_repo.git("commit", "-q", "--allow-empty", "-m", f"spec(001-add): answer escalation T{n} choose")
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    html = (slice_repo.dir / "result.html").read_text()
    assert "<th>Interventions</th><td>3</td>" in html


def test_e9_report_keeps_earlier_runs(slice_repo):
    two_runs(slice_repo)
    r = slice_repo.report()
    assert len(r["runs"]) == 2
    assert sum(x["tokens"] for x in r["runs"]) == 1000
    assert any("which sum" in e["reason"] for e in r["runs"][0]["escalations"])


def test_e10_page_shows_all_build_runs(slice_repo):
    two_runs(slice_repo)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    assert "Tokens</th><td>1000 (2 build runs)" in (slice_repo.dir / "result.html").read_text()


def test_e11_accept_step_names_answer_commit():
    assert "spec(<slice>): answer escalation" in (HARNESS / "harness/steps/accept.md").read_text()


def test_e12_031_records_true_numbers():
    lines = (HARNESS / "specs/031-clear-sdlc/spec.md").read_text().splitlines()
    for phrase in ("5 interventions", "1,010,245 tokens"):
        assert any(phrase in l and "reported" in l for l in lines), phrase
