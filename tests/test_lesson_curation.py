import importlib.util

from conftest import HARNESS, run
from test_repo_memory import LESSONS, parse_table, put, row, table
from test_spec import EX_HEAD, REQ_HEAD, TASK_HEAD, lint

CONSTITUTION = "memory/constitution/constitution.md"
LIMIT = "A sentence has 25 words or fewer; a procedure has steps.\n"


def real_rows():
    return {r[0]: r for r in parse_table((HARNESS / LESSONS).read_text())[1]}


def find_row(rows, *words):
    return next((r for r in rows.values() if all(w in r[1].lower() for w in words)), None)


def check_exists(check):
    path, _, name = check.partition("::")
    f = HARNESS / path
    return bool(name) and f.is_file() and f"def {name}(" in f.read_text()


def test_e1_stated_limit_differs_from_constitution(tmp_path):
    put(tmp_path, CONSTITUTION, LIMIT)
    put(tmp_path, LESSONS, table([row("L8", "learned", 1, text="Write at most 35 words.")]))
    p = run("uv", "run", "-q", str(HARNESS / "scripts/lessons.py"), "check", cwd=tmp_path)
    assert p.returncode == 1
    assert "L8: 35 words; the constitution says 25 words" in p.stdout


def test_e2_stated_limits_returns_no_finding_for_same_number():
    spec = importlib.util.spec_from_file_location("lessons", HARNESS / "scripts/lessons.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    # stated_limits(lesson_text, constitution_text) -> list of findings
    assert list(mod.stated_limits("Write at most 25 words.", LIMIT)) == []


def test_e3_id_both_requirement_and_task(tmp_path, ns_file):
    body = (REQ_HEAD + "| T1 | When it runs, the lint shall pass. | real-enforcement | E1 |\n\n" + EX_HEAD
            + "\n" + TASK_HEAD + "| T1 | do it | T1 |\n")
    p = lint(tmp_path, ns_file, body)
    assert p.returncode == 1
    assert "T1: id is both a requirement and a task" in p.stdout


def test_e4_l8_states_constitution_limit():
    text = real_rows()["L8"][1]
    assert "25 words" in text and "35 words" not in text


def test_e5_l2_retired_into_l9():
    rows = real_rows()
    assert rows["L2"][6] == "retired" and "L9" in " ".join(rows["L2"])
    assert "dropped inputs" in rows["L9"][1] and "test_e17_" in rows["L9"][2]


def test_e6_l4_l6_and_id_collision_are_learned():
    rows = real_rows()
    collision = find_row(rows, "requirement", "task", "id")
    assert collision is not None
    for r in (rows["L4"], rows["L6"], collision):
        assert r[6] == "learned", r[0]
        assert check_exists(r[2]), r[0]


def test_e7_requirement_columns_read_by_header(tmp_path, ns_file):
    head = "| id | anchor | examples | requirement |\n| --- | --- | --- | --- |\n"
    body = (head + "| S1 | real-enforcement | E1 | When it runs, the lint shall pass. |\n\n" + EX_HEAD
            + "\n" + TASK_HEAD + "| T1 | do it | S1 |\n")
    p = lint(tmp_path, ns_file, body)
    assert "not EARS" not in p.stdout and p.returncode == 0, p.stdout
