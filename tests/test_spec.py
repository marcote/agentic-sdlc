from conftest import spec_cmd

REQ_HEAD = "| id | requirement | anchor | examples |\n| --- | --- | --- | --- |\n"
EX_HEAD = "| id | given | when | then |\n| --- | --- | --- | --- |\n| E1 | a | b | c |\n"
TASK_HEAD = "| task | does | requirements |\n| --- | --- | --- |\n"


def lint(tmp_path, ns_file, body):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n" + body)
    return spec_cmd("lint", str(f), "--north-star", str(ns_file))


def test_e1_undefined_bold_term(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall check the **universe**. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1
    assert "S1: undefined term 'universe'" in p.stdout


def test_e1_defined_term_passes(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall check the **budget**. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 0, p.stdout


def test_e2_long_sentence(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, " ".join(["word"] * 26) + ".\n")
    assert p.returncode == 1
    assert "line 3" in p.stdout and "26 words" in p.stdout


def test_e3_not_ears(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | The data must be fresh. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1 and "S1: not EARS" in p.stdout


def test_e3_if_without_then(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | If it breaks, the lint shall fail. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert "S1: not EARS" in p.stdout


def test_e4_no_anchor(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. |  | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1 and "S1: no anchor" in p.stdout


def test_e4_anchor_not_in_north_star(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | made-up-pillar | E1 |\n\n" + EX_HEAD)
    assert "S1: anchor 'made-up-pillar' not in north star" in p.stdout


def test_e5_no_example(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement |  |\n")
    assert p.returncode == 1 and "S1: no example" in p.stdout


def test_e5_judged_passes(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | judged, rubric R1 |\n")
    assert p.returncode == 0, p.stdout


def test_e5_unknown_example(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E9 |\n")
    assert "S1: unknown example E9" in p.stdout


def test_e6_task_cites_no_requirement(tmp_path, ns_file):
    body = REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E1 |\n\n" + EX_HEAD + "\n" + TASK_HEAD + "| T3 | do it | nothing |\n"
    p = lint(tmp_path, ns_file, body)
    assert p.returncode == 1 and "T3: cites no requirement" in p.stdout


def test_e7_new_module_without_justification(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, "| item | justification |\n| --- | --- |\n| new module: edgar_client |  |\n")
    assert p.returncode == 1 and "edgar_client: no justification" in p.stdout


def test_e8_page_written(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec X\n\n## Glossary\n\n| term | meaning |\n| --- | --- |\n| **slice** | one feature |\n\n"
                 + REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E1 |\n\n## Examples\n\n" + EX_HEAD
                 + "\n## Plan\n\n" + TASK_HEAD + "| T1 | do | S1 |\n")
    p = spec_cmd("page", str(f), "--north-star", str(ns_file))
    assert p.returncode == 0, p.stdout + p.stderr
    html = (tmp_path / "spec.html").read_text()
    for s in ("<title>Spec X</title>", "slice", "S1", "E1", "Plan"):
        assert s in html


def test_e9_amendments_section(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n## Amendments\n\n| # | field | now | proposed |\n| --- | --- | --- | --- |\n| M1 | out_of_scope | a | b |\n")
    spec_cmd("page", str(f), "--north-star", str(ns_file))
    html = (tmp_path / "spec.html").read_text()
    assert 'id="amendments"' in html and "M1" in html


def test_page_refuses_failing_lint(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n" + REQ_HEAD + "| S1 | The data must be fresh. | real-enforcement | E1 |\n")
    p = spec_cmd("page", str(f), "--north-star", str(ns_file))
    assert p.returncode == 1 and not (tmp_path / "spec.html").exists()


def test_ids_in_ranges(tmp_path, ns_file):
    body = (REQ_HEAD + "".join(f"| B{i} | When it runs, the lint shall pass. | real-enforcement | E1 |\n" for i in range(1, 11))
            + "\n" + EX_HEAD + "\n" + TASK_HEAD + "| T1 | a | B1–B10 |\n| T2 | b | B1-B3, B5 |\n")
    p = lint(tmp_path, ns_file, body)
    assert p.returncode == 0, p.stdout


def test_lint_pipe_in_code_cell(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall read `a | b`. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert "S1: malformed row" in p.stdout


def test_lint_runs_on_spec_029():
    from conftest import HARNESS
    p = spec_cmd("lint", str(HARNESS / "specs/029-autonomous-loop/spec.md"),
                 "--north-star", str(HARNESS / "memory/north-star/north-star.md"))
    assert p.returncode == 0, p.stdout
