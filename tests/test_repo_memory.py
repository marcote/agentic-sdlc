import json
import re

from conftest import HARNESS, NS, OK, PASS, SLICE_SPEC, run, spec_cmd
from test_accept import ready
from test_build import T0, T1, T2

HEADER = ["id", "lesson", "check", "source", "helpful", "harmful", "status"]
LESSONS = "memory/lessons.md"
LONG = " ".join(["word"] * 30) + ".\n"


def table(rows):
    """memory/lessons.md text; each row is (id, lesson, check, source, helpful, harmful, status)."""
    out = ["| " + " | ".join(HEADER) + " |", "|" + " --- |" * len(HEADER)]
    return "\n".join(out + ["| " + " | ".join(map(str, r)) + " |" for r in rows]) + "\n"


def parse_table(text):
    lines = [l for l in text.splitlines() if l.startswith("|")]
    cells = [[c.strip() for c in l.strip().strip("|").split("|")] for l in lines]
    return cells[0], cells[2:]


def row(i, status, helpful=0, text=None, check="none: judgment", source="001-add"):
    return (i, text or f"UNIQUE_{i}_TEXT", check, source, helpful, 0, status)


def put(root, rel, text):
    f = root / rel
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(text)


def lessons_check(tmp_path, rows):
    put(tmp_path, LESSONS, table(rows))
    put(tmp_path, "tests/test_spec.py", "def test_e1_undefined_bold_term():\n    pass\n")
    return run("uv", "run", "-q", str(HARNESS / "scripts/lessons.py"), "check", cwd=tmp_path)


def with_reflector(s, rows, reflector=None):
    """Fake reflector role, a lessons table, and a finished slice committed on the branch."""
    cfg = s.root / "harness.toml"
    text = re.sub(r"^reflector = .*\n", "", cfg.read_text(), flags=re.M)
    cfg.write_text(text.replace("[roles]\n", '[roles]\nreflector = "fake"\n'))
    put(s.root, LESSONS, table(rows))
    ready(s)
    plan = {"implementer": [OK], "reviewer": [PASS], "judge": [PASS], "reflector": [reflector or {"deltas": []}]}
    s.plan.write_text(json.dumps(plan))


def main_lessons(s):
    return parse_table(s.git("show", f"main:{LESSONS}"))[1]


def test_e1_agents_index_and_claude_import():
    assert (HARNESS / "CLAUDE.md").read_text().strip() == "@AGENTS.md"
    agents = (HARNESS / "AGENTS.md").read_text()
    assert "memory/lessons.md" in agents and "memory/owner.md" in agents


def test_e2_lessons_table_from_snapshot():
    head, rows = parse_table((HARNESS / LESSONS).read_text())
    assert head == HEADER
    sources = " ".join(r[3] for r in rows)
    for slug in ("prune-from-inventory", "clean-wrong-number", "fixtures-are-my-assumptions"):
        assert slug in sources, slug


def test_e3_owner_file_holds_preferences():
    text = (HARNESS / "memory/owner.md").read_text().lower()
    assert "spanish" in text and "english" in text
    assert "h1" in text and "interfig" in text


def test_e4_vendor_seeds_memory(tmp_path):
    run("bash", str(HARNESS / "scripts/vendor.sh"), "--apply", str(tmp_path), check=True)
    assert (tmp_path / "AGENTS.md").is_file()
    assert (tmp_path / "CLAUDE.md").read_text().strip() == "@AGENTS.md"
    assert (tmp_path / "memory/owner.md").is_file()
    head, rows = parse_table((tmp_path / LESSONS).read_text())
    assert head == HEADER and rows == []


def test_e5_promoted_with_existing_check(tmp_path):
    p = lessons_check(tmp_path, [row("L1", "promoted", check="tests/test_spec.py::test_e1_undefined_bold_term")])
    assert p.returncode == 0 and "L1" not in p.stdout, p.stdout + p.stderr


def test_e6_promoted_with_missing_check(tmp_path):
    p = lessons_check(tmp_path, [row("L3", "promoted", check="tests/test_x.py::test_missing")])
    assert p.returncode == 1
    assert "L3: check not found: tests/test_x.py::test_missing" in p.stdout



def test_e8_rejected_attempt_is_a_finding(slice_repo):
    fix = {"verdict": "fix", "findings": ["R1 scope: calc.py adds mul"], "tokens": 10}
    slice_repo.script([T0, T1, T1, T2], [PASS, fix, PASS])
    slice_repo.build()
    assert {"task": "T1", "text": "R1 scope: calc.py adds mul"} in slice_repo.report()["findings"]


def test_e9_reflector_adds_and_credits(slice_repo):
    deltas = {"deltas": [{"op": "add", "kind": "soft", "lesson": "UNIQUE_NEW_TEXT", "source": "001-add"},
                         {"op": "helpful", "id": "L2"}]}
    with_reflector(slice_repo, [row("L2", "active")], reflector=deltas)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    rows = {r[0]: r for r in main_lessons(slice_repo)}
    new = next(r for r in rows.values() if "UNIQUE_NEW_TEXT" in r[1])
    assert new[6] == "active"
    assert rows["L2"][4] == "1" and rows["L2"][6] == "active"


def test_e10_rule_lesson_is_proposed(slice_repo):
    deltas = {"deltas": [{"op": "add", "kind": "rule", "lesson": "UNIQUE_RULE_TEXT", "source": "001-add"}]}
    with_reflector(slice_repo, [], reflector=deltas)
    assert slice_repo.accept().returncode == 0
    new = next(r for r in main_lessons(slice_repo) if "UNIQUE_RULE_TEXT" in r[1])
    assert new[6] == "proposed"


def test_e11_page_lists_proposed_lessons(tmp_path):
    put(tmp_path, "north-star.md", NS)
    put(tmp_path, "specs/099-x/spec.md", SLICE_SPEC)
    put(tmp_path, LESSONS, table([row("L1", "proposed", text="UNIQUE_PROPOSED_TEXT")]))
    p = spec_cmd("page", "specs/099-x/spec.md", "--north-star", "north-star.md", cwd=tmp_path)
    assert p.returncode == 0, p.stdout + p.stderr
    html = (tmp_path / "specs/099-x/spec.html").read_text()
    assert "Proposed lessons" in html and "UNIQUE_PROPOSED_TEXT" in html


def test_e12_prompt_has_captured_and_learned(slice_repo):
    rows = [row("L1", "learned", 1), row("L2", "captured"), row("L3", "proposed"), row("L4", "retired")]
    put(slice_repo.root, LESSONS, table(rows))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "lessons")
    slice_repo.script([T0, T1, T2])
    assert slice_repo.build().returncode == 0
    prompt = next(c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer")
    assert "Lessons" in prompt and "UNIQUE_L1_TEXT" in prompt and "UNIQUE_L2_TEXT" in prompt
    assert "UNIQUE_L3_TEXT" not in prompt and "UNIQUE_L4_TEXT" not in prompt


def test_e13_reflector_failure_still_merges(slice_repo):
    with_reflector(slice_repo, [], reflector={"_crash": True})
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    assert "build(001-add): T1 add" in slice_repo.git("log", "main", "--format=%s")
    assert "reflector: agent: exit 7" in p.stdout + p.stderr


def test_e14_page_counts_lessons(slice_repo):
    rows = [row(f"L{i}", "learned", 1) for i in range(1, 5)] + [row(f"L{i}", "captured") for i in (5, 6)]
    with_reflector(slice_repo, rows)
    assert slice_repo.accept().returncode == 0
    assert "Lessons 4 learned / 6" in (slice_repo.dir / "result.html").read_text()


def prose_check(tmp_path):
    put(tmp_path, "memory/owner.md", LONG)
    put(tmp_path, "docs/workflow.md", LONG)
    return run("uv", "run", "-q", str(HARNESS / "scripts/prose.py"), cwd=tmp_path)


def test_e15_prose_check_covers_owner_file(tmp_path):
    p = prose_check(tmp_path)
    assert p.returncode == 1
    assert "memory/owner.md" in p.stdout and "30 words" in p.stdout


def test_e16_prose_check_skips_docs(tmp_path):
    p = prose_check(tmp_path)
    assert "memory/owner.md" in p.stdout and "docs/workflow.md" not in p.stdout


def test_e17_prose_check_counts_across_line_breaks(tmp_path):
    words = ["word"] * 30
    wrapped = "\n".join(" ".join(words[i : i + 10]) for i in range(0, 30, 10)) + ".\n"
    put(tmp_path, "memory/owner.md", wrapped)
    p = run("uv", "run", "-q", str(HARNESS / "scripts/prose.py"), cwd=tmp_path)
    assert "memory/owner.md" in p.stdout and "30 words" in p.stdout


def test_e18_prose_check_skips_history_paths(tmp_path):
    put(tmp_path, "memory/north-star/decisions/0004-x.md", " ".join(["word"] * 40) + ".\n")
    p = run("uv", "run", "-q", str(HARNESS / "scripts/prose.py"), cwd=tmp_path)
    assert "0004-x.md" not in p.stdout
