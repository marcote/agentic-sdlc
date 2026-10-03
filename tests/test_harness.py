from conftest import HARNESS


def test_e24_template_names_four_test_kinds():
    t = (HARNESS / "specs/_template/spec.md").read_text()
    for kind in ("example", "invariant", "reconciliation", "e2e run"):
        assert kind in t.lower()
    assert "per criterion" not in t.lower() and "per function" not in t.lower()


def test_e28_one_source_for_claude_and_codex():
    for step in ("brief", "spec", "accept"):
        src = f"harness/steps/{step}.md"
        assert (HARNESS / src).is_file()
        assert src in (HARNESS / f".claude/commands/{step}.md").read_text()
        assert src in (HARNESS / "AGENTS.md").read_text()


def test_north_star_amendments_applied():
    ns = (HARNESS / "memory/north-star/north-star.md").read_text()
    assert "imposing a mandatory agent CLI, model or product stack" in ns
    assert "imposing or naming a mandatory execution runtime" not in ns
    assert "## Glossary" in ns
