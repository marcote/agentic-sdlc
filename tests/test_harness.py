from conftest import HARNESS
from stale_names import stale_hits


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


DELETED = [
    "scripts/mutate.sh", "scripts/nvc.sh", "scripts/cases.sh", "scripts/lib/matrix.sh",
    "scripts/amendment-gate.sh", "scripts/prose.sh", ".github/workflows/amendment-gate.yml",
    ".claude/commands/align.md", ".claude/commands/plan.md", ".claude/commands/contract.md",
    ".claude/commands/tasks.md", ".claude/commands/verify.md", ".claude/commands/uat.md",
    ".claude/commands/retro.md", ".claude/commands/wow-report.md", ".claude/commands/distill.md",
    ".claude/skills/align", ".claude/skills/distill", ".claude/skills/verify", ".claude/skills/uat",
    ".claude/skills/retro", ".claude/skills/wow-report",
    "specs/028-suite-hermeticity", "scripts/setup-branch-protection.sh",
]


def test_e30_pruned():
    present = [p for p in DELETED if (HARNESS / p).exists()]
    assert present == []


def test_c1_no_removed_name_in_live_files():
    assert stale_hits(HARNESS) == []
