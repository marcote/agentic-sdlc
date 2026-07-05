# Checklist for updating the constitution

When the agent commits a repeatable mistake or a rule changes:

- [ ] Is it a universal principle? → `base/principles.md`. Or a practice with criteria? → new `base/patterns/<x>.md`.
- [ ] If it is a pattern: include the `**Injected criteria:**` section with at least one `[given]`.
- [ ] Is it project-specific? → `constitution.md` (deltas/overrides).
- [ ] Update the date/reason in the commit.
- [ ] Re-copy `base/` to the projects that inherit it (vendored).
