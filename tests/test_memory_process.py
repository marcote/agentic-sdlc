import importlib.util
import json
import re

from conftest import HARNESS, NS, OK, PASS, run, spec_cmd
from test_accept import ready
from test_repo_memory import LESSONS, main_lessons, parse_table, put, row, table

CONSTITUTION = "memory/constitution/constitution.md"
SPEC = "specs/036-memory-process/spec.md"
CUR = {"conflicts": []}


def lessons_check(tmp_path, rows, files):
    put(tmp_path, LESSONS, table(rows))
    for rel, text in files.items():
        put(tmp_path, rel, text)
    return run("uv", "run", "-q", str(HARNESS / "scripts/lessons.py"), "check", cwd=tmp_path)


def real_l18():
    return next(r for r in parse_table((HARNESS / LESSONS).read_text())[1] if r[0] == "L18")


def test_e1_numbers_are_not_compared(tmp_path):
    l18 = real_l18()
    law = (HARNESS / CONSTITUTION).read_text()
    p = lessons_check(tmp_path, [(*l18[:6], "active")], {CONSTITUTION: law})
    assert p.returncode == 0, p.stdout + p.stderr
    spec = importlib.util.spec_from_file_location("lessons", HARNESS / "scripts/lessons.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    assert not hasattr(mod, "stated_limits")


def test_e2_unknown_status(tmp_path):
    p = lessons_check(tmp_path, [row("L1", "learned", 1)], {})
    assert p.returncode == 1
    assert "L1: unknown status learned" in p.stdout


def test_e3_promoted_check_not_found(tmp_path):
    p = lessons_check(tmp_path, [row("L1", "promoted", check="tests/test_x.py::test_missing")],
                      {"tests/test_x.py": "def test_other():\n    pass\n"})
    assert p.returncode == 1
    assert "L1: check not found: tests/test_x.py::test_missing" in p.stdout


def test_e4_promoted_check_found(tmp_path):
    # the lesson text states 35 words against the constitution's 25: no row is compared with the constitution (M1)
    p = lessons_check(tmp_path, [row("L1", "promoted", text="Write at most 35 words.", check=f"{CONSTITUTION}::D7")],
                      {CONSTITUTION: "### D7 — A semantic question goes to a model\n\nA sentence has 25 words or fewer.\n"})
    assert p.returncode == 0, p.stdout + p.stderr


def test_e5_merged_target_missing(tmp_path):
    p = lessons_check(tmp_path, [row("L2", "merged", check="merged into L99")], {})
    assert p.returncode == 1
    assert "L2: merged into a lesson that does not exist" in p.stdout


def test_e6_real_lessons_follow_migration_table():
    text = (HARNESS / SPEC).read_text()
    section = text[text.index("## 8. Migration"):text.index("## 9.")]
    cells = [[c.strip() for c in l.strip("|").split("|")] for l in section.splitlines() if l.startswith("|")]
    head = cells[0]
    want = {r[head.index("lesson")]: r[head.index("becomes")] for r in cells[2:]}
    lhead, lrows = parse_table((HARNESS / LESSONS).read_text())
    got = {r[lhead.index("id")]: r[lhead.index("status")] for r in lrows}
    assert {k: got.get(k) for k in want} == want


def with_curator(s, rows, reflector=None, curator=None, limit=None):
    """A finished slice, the fake roles reflector and curator, a lessons table and a constitution."""
    cfg = s.root / "harness.toml"
    text = re.sub(r"^(reflector|curator) = .*\n", "", cfg.read_text(), flags=re.M)
    text = text.replace("[roles]\n", '[roles]\nreflector = "fake"\ncurator = "fake"\n')
    if limit:
        text = text.replace("[limits]\n", f"[limits]\nlessons_bytes = {limit}\n")
    cfg.write_text(text)
    put(s.root, LESSONS, table(rows))
    put(s.root, CONSTITUTION, "UNIQUE_CONSTITUTION_TEXT\n")
    ready(s)
    s.plan.write_text(json.dumps({"implementer": [OK], "reviewer": [PASS], "judge": [PASS],
                                  "reflector": [reflector or {"deltas": []}], "curator": [curator or CUR]}))


def conflict(i, with_="D5", why="breaks it"):
    return {"id": i, "with": with_, "why": why}


def test_e7_new_lesson_is_active_and_helpful_counts(slice_repo):
    deltas = {"deltas": [{"op": "add", "kind": "soft", "lesson": "UNIQUE_NEW_TEXT", "source": "001-add"},
                         {"op": "helpful", "id": "L2"}]}
    with_curator(slice_repo, [row("L2", "active")], reflector=deltas)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    rows = {r[0]: r for r in main_lessons(slice_repo)}
    new = next(r for r in rows.values() if "UNIQUE_NEW_TEXT" in r[1])
    assert new[6] == "active"
    assert rows["L2"][4] == "1" and rows["L2"][6] == "active"


def test_e8_prompt_holds_active_lessons_only(slice_repo):
    from test_build import T0, T1, T2
    rows = [row("L1", "active"), row("L2", "proposed"), row("L3", "promoted"), row("L4", "merged")]
    put(slice_repo.root, LESSONS, table(rows))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "lessons")
    slice_repo.script([T0, T1, T2])
    assert slice_repo.build().returncode == 0
    prompt = next(c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer")
    assert "UNIQUE_L1_TEXT" in prompt
    assert not any(f"UNIQUE_L{n}_TEXT" in prompt for n in (2, 3, 4))


def test_e9_curator_conflict_marks_lesson_proposed(slice_repo):
    with_curator(slice_repo, [row("L2", "active")], curator={"conflicts": [conflict("L2")]})
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    prompt = next(c["prompt"] for c in slice_repo.calls() if c["role"] == "curator")
    assert "UNIQUE_CONSTITUTION_TEXT" in prompt and "UNIQUE_L2_TEXT" in prompt
    assert "Escalate to the owner after 5 identical failures" in prompt  # a labeled case of harness/curator-cases.md
    l2 = next(r for r in main_lessons(slice_repo) if r[0] == "L2")
    assert l2[6] == "proposed" and l2[2].startswith("conflict with D5:")


def test_e10_curator_failure_changes_nothing(slice_repo):
    rows = [row("L2", "active")]
    with_curator(slice_repo, rows, curator={"_crash": True})
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    assert "curator: agent: exit 7" in p.stdout + p.stderr
    assert main_lessons(slice_repo) == parse_table(table(rows))[1]


def test_e11_page_shows_curator_found_missed_false_alarms(slice_repo):
    with_curator(slice_repo, [row("L2", "active")], curator={"conflicts": [conflict("X1"), conflict("X2"), conflict("X5")]})
    assert slice_repo.accept().returncode == 0
    html = (slice_repo.dir / "result.html").read_text()
    assert "<th>Curator</th><td>2 of 4 found, 2 missed, 1 false alarm</td>" in html


def test_e12_page_shows_lessons_per_status_and_bytes(slice_repo):
    rows = [row("L1", "active", text="a" * 75), row("L2", "active", text="b" * 75),
            row("L3", "promoted"), row("L4", "merged")]
    with_curator(slice_repo, rows, limit=100)
    assert slice_repo.accept().returncode == 0
    html = (slice_repo.dir / "result.html").read_text()
    assert "<th>Lessons</th><td>2 active (150 of 100 bytes), 0 proposed, 1 promoted, 1 merged</td>" in html


REQ = "| id | requirement | {head}anchor | examples |\n| --- | --- | {sep}--- | --- |\n| S1 | When it runs, the lint shall pass. | {val}real-enforcement | {ex} |\n"
EXAMPLES = "\n| id | given | when | then |\n| --- | --- | --- | --- |\n| E1 | a | b | c |\n"
APPLIED = "\n## Memory applied\n\n| lesson | applies |\n| --- | --- |\n{rows}"
SOURCES = "\n## Sources\n\n| practice | source | implies |\n| --- | --- | --- |\n| p | s | i |\n"


def lint_spec(tmp_path, kind="mechanical", ex="E1", applied="", sources=SOURCES, active=()):
    put(tmp_path, "north-star.md", NS)
    put(tmp_path, LESSONS, table([row(i, "active") for i in active]))
    req = REQ.format(head="kind | " if kind else "", sep="--- | " if kind else "", val=f"{kind} | " if kind else "", ex=ex)
    put(tmp_path, "spec.md", "# Spec\n\n" + req + EXAMPLES + APPLIED.format(rows=applied) + sources)
    return spec_cmd("lint", "spec.md", "--north-star", "north-star.md", cwd=tmp_path)


def test_e13_semantic_requirement_needs_a_judge(tmp_path):
    p = lint_spec(tmp_path, kind="semantic")
    assert p.returncode == 1
    assert "S1: semantic requirement needs a judge" in p.stdout


def test_e14_requirement_without_kind(tmp_path):
    p = lint_spec(tmp_path, kind="")
    assert p.returncode == 1
    assert "S1: no kind" in p.stdout


def test_e15_active_lesson_not_in_memory_applied(tmp_path):
    p = lint_spec(tmp_path, applied="| L1 | yes: x |\n", active=("L1", "L3"))
    assert p.returncode == 1
    assert "L3: not in Memory applied" in p.stdout and "L1: not in Memory applied" not in p.stdout


def test_e16_no_sources_table(tmp_path):
    p = lint_spec(tmp_path, sources="")
    assert p.returncode == 1
    assert "no Sources table" in p.stdout


def test_e17_steps_and_owner_file_say_how_to_use_memory():
    brief = (HARNESS / "harness/steps/brief.md").read_text()
    spec = (HARNESS / "harness/steps/spec.md").read_text()
    owner = (HARNESS / "memory/owner.md").read_text()
    assert "research.md" in brief
    assert "memory/lessons.md" in spec and "memory/owner.md" in spec and "constitution" in spec.lower()
    assert "not intuition" in owner


def test_e18_ci_lints_only_specs_without_result_page():
    text = (HARNESS / ".github/workflows/verify.yml").read_text()
    step = text[text.index("Lint every spec"):]
    assert "result.html" in step
