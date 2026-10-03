import json
import re
import sys
import tomllib

import pytest

from conftest import HARNESS, run
import test_memory_process as tmp
from test_memory_process import CONSTITUTION, conflict, with_curator
from test_repo_memory import LESSONS, put, row, table, with_reflector

NO_LESSONS = ("from pathlib import Path\n\n\ndef test_no_lessons():\n"
              "    rows = [l for l in Path('memory/lessons.md').read_text().splitlines() if l.startswith('| L')]\n"
              "    assert not rows\n")
ADD = {"deltas": [{"op": "add", "kind": "soft", "lesson": "UNIQUE_NEW_TEXT", "source": "001-add"}]}


def lessons_check(tmp_path, rows, files):
    put(tmp_path, LESSONS, table(rows))
    for rel, text in files.items():
        put(tmp_path, rel, text)
    return run(sys.executable, str(HARNESS / "scripts/lessons.py"), "check", cwd=tmp_path)


def test_e1_memory_write_is_tested_before_merge(slice_repo):
    with_reflector(slice_repo, [], reflector=ADD)
    put(slice_repo.root, "tests/test_no_lessons.py", NO_LESSONS)
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "no lessons test")
    main_before = slice_repo.git("rev-parse", "main")
    p = slice_repo.accept()
    assert p.returncode == 1, p.stdout + p.stderr
    assert "test_no_lessons" in p.stdout
    assert slice_repo.git("rev-parse", "main") == main_before


def test_e2_only_the_slice_differs_from_the_verified_commit(slice_repo):
    with_reflector(slice_repo, [], reflector=ADD)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    report = json.loads(slice_repo.git("show", "main:specs/001-add/build-report.json"))
    paths = slice_repo.git("diff", "--name-only", report["verified"], "main").split()
    assert paths and all(x.startswith("specs/001-add/") for x in paths), paths


def test_e3_migration_test_ignores_lessons_the_table_omits(tmp_path, monkeypatch):
    tmp.test_e6_real_lessons_follow_migration_table()
    for rel in (tmp.SPEC, LESSONS):
        text = (HARNESS / rel).read_text()
        if rel == LESSONS:
            text = re.sub(r"(\| L1 \|.*\| )promoted( \|)$", r"\1active\2", text, count=1, flags=re.M)
        put(tmp_path, rel, text)
    monkeypatch.setattr(tmp, "HARNESS", tmp_path)
    with pytest.raises(AssertionError):
        tmp.test_e6_real_lessons_follow_migration_table()


def test_e4_curator_conflict_between_lessons(slice_repo):
    with_curator(slice_repo, [row("L3", "active"), row("L5", "active")], curator={"conflicts": [conflict("L3", with_="L5")]})
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    prompt = next(c["prompt"] for c in slice_repo.calls() if c["role"] == "curator")
    assert "a lesson can conflict with another active lesson" in prompt
    l3 = next(r for r in tmp.main_lessons(slice_repo) if r[0] == "L3")
    assert l3[6] == "proposed" and l3[2].startswith("conflict with L5:")


def test_e5_check_named_only_in_a_comment_is_not_found(tmp_path):
    p = lessons_check(tmp_path, [row("L1", "promoted", check="tests/test_x.py::test_a")],
                      {"tests/test_x.py": "# test_a\n\n\ndef test_other():\n    pass\n"})
    assert p.returncode == 1
    assert "L1: check not found: tests/test_x.py::test_a" in p.stdout


def test_e6_check_named_only_in_body_text_is_not_found(tmp_path):
    rows = [row("L1", "promoted", check=f"{CONSTITUTION}::D7")]
    body = lessons_check(tmp_path, rows, {CONSTITUTION: "Rule D7 says a sentence is short.\n"})
    assert body.returncode == 1
    assert "L1: check not found" in body.stdout
    head = lessons_check(tmp_path, rows, {CONSTITUTION: "### D7 — A semantic question goes to a model\n\nText.\n"})
    assert head.returncode == 0, head.stdout


def test_e7_slice_repo_runs_python_not_uv(slice_repo):
    checks = tomllib.loads((slice_repo.root / "harness.toml").read_text())["checks"]
    for name in ("task", "suite"):
        assert "uv run" not in checks[name], name
        assert checks[name].lstrip("'\"").startswith(sys.executable), name


def test_e8_suite_budget_is_25_seconds():
    assert tomllib.loads((HARNESS / "harness.toml").read_text())["limits"]["suite_seconds"] == 25
