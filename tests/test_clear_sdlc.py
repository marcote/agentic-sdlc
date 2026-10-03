import json
import re
import subprocess

from conftest import HARNESS, run, spec_cmd

NS_ENGINE = str(HARNESS / "scripts/north-star/engine.py")
STACK_ENGINE = str(HARNESS / "scripts/stack/engine.py")
FIGURES = ("workflow", "build-loop", "accept")


def engine(path, *args, stdin=""):
    return subprocess.run(["python3", path, *args], capture_output=True, text=True, input=stdin)


def test_e1_legacy_files_gone():
    legacy = [
        "evals", "verification/uat-checklist.md", "memory/north-star/base/alignment-rubric.md",
        "memory/north-star/base/amendment-protocol.md", ".claude/commands/constitution.md",
        "memory/constitution/base/patterns/non-vacuous-checks.md",
    ]
    assert [p for p in legacy if (HARNESS / p).exists()] == []


def test_e2_north_star_engine_schema_valid_only():
    p = engine(NS_ENGINE, "align-verdict", stdin="{}")
    assert p.returncode == 2 and "invalid choice" in p.stderr
    assert engine(NS_ENGINE, "schema-valid", str(HARNESS / "memory/north-star/north-star.md")).returncode == 0


def test_e3_no_alignment_block_is_valid(tmp_path):
    block = {
        "mission": "A reusable harness that governs a disciplined agentic SDLC.",
        "pillars": [{"id": "real-enforcement", "statement": "gates block", "signal": "gaps caught", "since": "0001"}],
        "scope": {"in_scope": ["governance workflow"], "out_of_scope": ["application code"]},
    }
    f = tmp_path / "north-star.md"
    f.write_text("# NS\n\n```json\n" + json.dumps(block, indent=2) + "\n```\n")
    p = engine(NS_ENGINE, "schema-valid", str(f))
    assert p.returncode == 0, p.stderr


def test_e4_stack_engine_four_commands():
    charter = str(HARNESS / "memory/stack/stack.md")
    for cmd in ("pin-valid", "exposure", "ground-rules", "guards"):
        assert engine(STACK_ENGINE, cmd, charter).returncode == 0, cmd


def test_e5_workflow_links_three_figures():
    text = (HARNESS / "docs/workflow.md").read_text()
    for name in FIGURES:
        assert f"figures/{name}.svg" in text
        assert '<metadata id="figure-spec">' in (HARNESS / f"docs/figures/{name}.svg").read_text()


def test_e6_workflow_prose_has_no_long_sentence():
    # non-vacuous: the page must already carry its figures, or the lint passes on a stub
    assert "figures/workflow.svg" in (HARNESS / "docs/workflow.md").read_text()
    p = spec_cmd("lint", "docs/workflow.md", cwd=HARNESS)
    assert "words" not in p.stdout, p.stdout


def test_e7_readme_shows_figure_and_links_workflow():
    text = (HARNESS / "README.md").read_text()
    assert re.search(r"!\[[^\]]*\]\(docs/figures/workflow\.svg\)", text)
    assert "](docs/workflow.md)" in text


def test_e8_vendor_copies_workflow_and_figures(tmp_path):
    run("bash", str(HARNESS / "scripts/vendor.sh"), "--apply", str(tmp_path), check=True)
    assert (tmp_path / "docs/workflow.md").is_file()
    assert (tmp_path / "docs/figures/workflow.svg").is_file()


# the import sits inside each test, so a missing helper fails the test instead of breaking collection
def _repo(root, rel, text):
    f = root / rel
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(text)
    run("git", "init", "-q", cwd=root, check=True)
    run("git", "add", "-A", cwd=root, check=True)
    return root


def test_e9_stale_name_in_live_file(tmp_path):
    from stale_names import stale_hits
    root = _repo(tmp_path, "docs/notes.md", "run /distill first\n")
    assert "docs/notes.md: /distill" in stale_hits(root)


def test_e10_stale_name_in_history_path(tmp_path):
    from stale_names import stale_hits
    root = _repo(tmp_path, "specs/015-x/brief.md", "run /distill first\n")
    assert stale_hits(root) == []


def test_e11_harness_has_no_stale_name():
    from stale_names import stale_hits
    assert stale_hits(HARNESS) == []
