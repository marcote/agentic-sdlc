# Workflow

    setup, once    north star (glossary, labels) · charter (/stack) · module map
    1. brief       harness/steps/brief.md
    2. spec        harness/steps/spec.md → spec.html → gate H1 (the owner approves)
    3. build       uv run scripts/build.py specs/<slice>    (no owner)
    4. accept      uv run scripts/accept.py specs/<slice>   (machine checks, merge)

Roles and CLIs live in `harness.toml`. Any CLI with a headless JSON mode can fill a role.
The judge's model family must differ from the implementer's.
