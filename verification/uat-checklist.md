# UAT Checklist — <feature>

> Walked through in `/uat`, against `acceptance.md`. UAT validates against the OBJECTIVE
> (brief), not just the spec — which is why it can reveal product gaps.

For each acceptance criterion:
- [ ] BDD scenario executed exactly as written.
- [ ] Observable result matches the `Then`.
- [ ] Does the criterion, when met, move the success metric in the brief? (if not → product GAP → `/distill`)
- [ ] State updated in `coverage.md` (→ ✅ uat).
