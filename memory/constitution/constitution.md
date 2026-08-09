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

### D3 — Reflexive dogfood (workflow tooling runs against its own in-flight feature)

A feature that produces **workflow tooling** — a checker, tracker, gate, or report that operates on
the SDLC's own artifacts (`coverage.md`, retros, `specs/*`, `status.sh`, `check_*`, the North Star
engine) — must be **run against its own in-flight feature before closing**, not only against
synthetic fixtures. The tool's first real user is the very feature that ships it.

**Why:** a workflow tool exercised only on hermetic fixtures hides the blind spots that appear on
real artifacts. Feature 008 caught **two real bugs** this way (`status.sh` flagged its own
placeholder false-positives; the same blind spot then surfaced in `check_90`). Reflexive use is the
cheapest UAT a workflow tool has, and it is harness-specific: an adopter shipping app code does not
inherit this delta (their UAT is against their product objective, per the base UAT step).

*This is a project delta, not a base principle:* it presumes the deliverable is tooling over the
workflow itself, which is unique to this harness-as-product.

### D4 — Gate bootstrap: a feature that introduces a gate is exempt from it, on four conditions

A gate cannot judge the feature that builds it — there is nothing to read and nothing to run at
that point in the loop. This has now happened three times (`002` `/align`, `013` the `/plan`
charter guard, `014` the `UNCOVERED` verdict) and was **negotiated case by case each time**. The
exemption is real; leaving it unwritten is what makes it look like a convenient skip.

The exemption is **from being blocked, never from being run**, and it holds only with all four:

1. **Declared in `plan.md` before implementation**, as a named gate note — never a silent skip,
   and never discovered at `/verify`.
2. **The gate runs retroactively against the feature's own artifacts before close, and must emit a
   real verdict.** A trivial `PASS` because the inputs never touch proves nothing and does not
   discharge this condition. (`013` emitted `UNPINNED` against its own charter; `014`'s
   `UNCOVERED` forced four pins into `memory/stack/stack.md`.)
3. **Task ordering brings the feature into compliance with its own gate before the final verify**
   — the feature ends subject to the gate it shipped, even though it started exempt.
4. **The gate note states that every subsequent feature is subject, without exception.**

**Why this fits the constitution rather than eroding it:** condition 2 is D3 (reflexive dogfood)
made non-optional for this case, and conditions 1 and 4 keep the exemption a bounded, recorded
event instead of a precedent. Under the amended `frictionless-adoption` signal (ADR `0004`) an
exemption without a recorded justification is exactly the defect being measured.

*This is a project delta, not a base principle:* it presumes the deliverable is a gate over the
workflow itself, which is unique to this harness-as-product.

## Inherited pattern overrides

### `base/patterns/non-vacuous-checks.md` — two of five rows discharged by a gate, not per feature

**Overridden here only:** `check-traceable` and `check-no-self-match` are **not** injected as
per-feature `[given]` rows in this repository. The other three (`check-can-fail`,
`check-rejects-by-diagnostic`, `check-names-its-tree`) are injected exactly as before.

**Justification.** `tests/check_96_non_vacuous.sh` runs `scripts/nvc.sh` on **every** invocation of
the suite and fails it when any declared criterion does not emit a result in its own section, or
when a self-including scan uses an inline literal without a self-test. That is strictly stronger
than a coverage row: it covers every check in the repository on every run, including checks from
features closed months ago, rather than only the checks a feature happens to touch. It found
fifteen instances the per-feature rows never would have.

Under the amended `frictionless-adoption` signal (ADR `0004`) a mandatory step whose harm is
**already prevented by a gate** is friction without a justification — the defect the amendment
made measurable. Carrying both is bookkeeping, and the coverage row is the weaker of the two.

**Why the base pattern is unchanged.** An adopter inherits the pattern but **not** the enforcement:
`tests/` is DROP and `scripts/nvc.sh` is DROP, because both encode this repository's own test
conventions (`_pass`/`_fail`, criterion labels) rather than anything portable. For an adopter the
two rows are the only thing standing there, so removing them from `base/` would delete the rule for
everyone who cannot mechanise it. **This override is valid precisely because it is scoped to the
one repository that runs the gate**, and it stops being valid the day `nvc.sh` stops running.

*Reversal condition, stated so this cannot rot silently:* if `check_96` is removed, disabled, or
stops covering the whole `tests/` tree, this override lapses and the two rows return to per-feature
injection. `tests/check_10_constitution.sh` asserts the pairing, so the override cannot outlive the
gate it depends on.

## Inner loop budget (tuneable)
- Escalate to human after **2 identical failures** or **3 total attempts** per task.
