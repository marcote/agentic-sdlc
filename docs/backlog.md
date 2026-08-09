# Backlog

Findings that are **real but not scheduled**. This file exists because of a recorded root cause:
every finding was being chained into the next feature instead of being parked, so the loop never
converged. A line here is not a commitment — it is a refusal to either forget it or start it today.

An item leaves this file in exactly one of two ways: it becomes a feature under `specs/NNN-*`, or
it is **dropped with a reason**. Silence is not a disposition.

> Not the same as `verification/wow-report.md` §2. That section tracks `pending-observation`
> verdicts — predictions awaiting evidence, each with a trigger and a sweep date. This file tracks
> *work not started*.

---

## B1 — A mechanical meta-check for vacuous assertions

**Status:** open · **Raised:** 2026-08-09 (013 + 014 retros, `wow-report` §3) · **Size:** small

The constitution now carries `base/patterns/non-vacuous-checks.md`, which is the **review half**.
The mechanical half is not built: a check in `tests/` that reads `tests/check_*.sh` and fails when a
declared criterion label emits no result in the run, and when a self-scanning check embeds its
forbidden literal directly instead of assembling it at runtime.

**Why it is credible:** a traceability scan written in minutes on 2026-08-09 found a real instance
in feature 008 (`DEPFREE`, closed a month earlier, green suite, undetectable by reading).

**Why it is not trivial:** the first naive version of that scan reported **112 false positives**,
because it treated the unused failure-branch label of every passing assertion as a dead assertion.
The correct form pairs each criterion's pass and fail branches. Designing that is the actual work.

**Explicitly out of its scope if it ships:** semantic vacuity (whether a pattern is satisfied by
text that was already there) needs to know what the assertion *means*. That stays with review.

**The cheapest reason to defer it:** the pattern's `[given]` rows are now in every feature's
coverage, and the pattern states that claim as falsifiable. If a feature ships a vacuous check
*while carrying those rows*, prose has failed a third time and this stops being optional.

## B2 — Twelve eval cases have never been scored

**Status:** blocked, not open · **Raised:** 013, restated 014 · **Size:** unknown

Across `evals/cases/*` there are 12 non-deterministic cases carried as `📋 case`, unscored **by
design**: the model that authored the output grading its own output is not evidence. They are
honestly deferred today. They become decoration if they stay open indefinitely.

**Unblocks on:** an independent judge — a separate model, or a human pass.

## B3 — A North Star stub with `TODO:` placeholders passes `schema-valid`

**Status:** open · **Raised:** 2026-08-09 · **Size:** very small

The North Star seeded by `scripts/vendor.sh` contains `"TODO: ..."` strings and is nonetheless
`schema-valid`, so `/align` will run against a placeholder and produce a verdict that means
nothing. `/align` step 1 is fail-closed against a *malformed* North Star, not against an *unfilled*
one.

The fix is a placeholder check in the engine's `schema-valid`, and the repo already has the
predicate (`has_placeholder()` in `tests/lib.sh`) plus the known blind spot it must avoid: a
document that legitimately *documents* a marker inside a code span is not a placeholder.

Left open rather than fixed on sight because it changes the exit contract of a shipped engine
command, which is a feature-sized decision, not a patch.

## B4 — `status.sh` flags three anomalies that will never clear

**Status:** open · **Raised:** 2026-08-09 (feature sweep) · **Size:** small

Sweeping every feature, `001-example`, `002-north-star-governance` and `003-wow-self-validation`
each exit non-zero with `⚠ anomaly: done phase(s) … follow a pending one`. All three are
**legitimate**: 001 is the deliberately partial template example, 002 is the declared `/align`
bootstrap exception (it could not run the gate it shipped — now `D4`), and 003 is a partial
dogfood with only a brief and a retro.

The tracker is correct and the artifacts are correct. The problem is the standing baseline: a
tool whose normal output is three permanent warnings trains its reader to skip the warnings, and
the next *real* anomaly arrives into that habit. Same shape as the finding that produced sweep
dates — a signal nobody reads is worse than no signal, because it still looks rigorous.

**Not fixed on sight** because the right answer is a design choice, not a patch: an explicit
`exempt` marker in the feature folder, a repo-level known-anomalies list, or accepting that
pre-`004` features are simply out of the tracker's scope. Each has a different cost, and `D4`
argues that an exemption must be *recorded*, which rules out the cheapest option.

---

## Dropped

_(none yet — an item dropped here keeps its reason)_
