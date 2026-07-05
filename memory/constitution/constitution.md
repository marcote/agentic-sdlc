---
extends: base
---

# Constitution — Project

Extends `base` (see `base/principles.md`). Add project-specific principles and overrides
here. Overriding a `base/pattern` requires explicit justification.

## Project deltas

### D1 — The `amendment-gate`: instance of the narrow governance exception (Principle 4)

Principle 4 (base) allows **one** exception to "nothing blocks a push": a *narrow
governance gate on the protected integration branch*. The **`amendment-gate`**
(CI + branch protection, feature 004) is the **concrete instance** of that exception in
this project, and it is **narrow by design**: it blocks *only* when a commit/push changes the
**`pillars`/`scope`** sets of the North Star's canonical JSON block without meeting the protocol
(new ADR + schema-valid + green suite). Normal feature development — which does not touch
the pillars/scope sets — **is not blocked**: the gate exits `exit 0` (not-applicable).

**Why this fits Principle 4:** its intent is **productivity first** (not blocking feature
throughput). A North Star amendment is not feature throughput: it is a governance event
that `base/amendment-protocol.md` already declares gated (ADR + PR).
Gating it in CI enforces that protocol when a sole maintainer cannot give the approval —
it uses exactly the exception that Principle 4 now carves out, without blocking throughput.

*Branch protection note:* by making the `amendment-gate` status-check *required* on `main`,
GitHub gates **all** direct pushes to `main` (they must go through PR + CI), not just
amendments. That preserves Principle 4 — local commits and pushes to work branches remain
free — but it is worth being explicit: `main` is a protected integration point for
everything, not only for `pillars`/`scope` changes.

### D2 — Language

All repo artifacts are written in English: docs, specs, skills, commands, memory,
scripts, and CI configs. The developer may interact with the agent in any language;
the agent writes to the repo in English regardless.

## Inherited pattern overrides
_(none — to deactivate a pattern, list it here with its justification)_

## Inner loop budget (tuneable)
- Escalate to human after **2 identical failures** or **3 total attempts** per task.
