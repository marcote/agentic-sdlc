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

## ~~B1~~ — A mechanical meta-check for vacuous assertions

**Status: PROMOTED 2026-08-09 → `specs/015-non-vacuous-checks/`** · Raised: 013 + 014 retros,
`wow-report` §3 · **Size:** small

**What moved it:** occurrence twelve. A vacuous assertion (`REPORT-PRECEDENCE` in `check_86`)
shipped **hours after** the pattern landed, while deliberately applying it. That does not formally
refute the pattern — the tracker fix was a direct patch carrying no `[given]` rows — but it
removes the reason to defer: if manual application fails in the context of highest attention, it
fails everywhere.

*Original entry retained below for the record.*

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

## B6 — The 5:1 governance-to-code ratio

**Status:** open · **Raised:** 2026-08-09 (measured) · **Size:** unknown

`specs/*.md` is **6093 lines** against **1236 lines** of `scripts/`. Coverage tables grew
20 → 25 → 31 → 37 rows across 006 → 013 → 014 → 015. Some of that is deliberate — evidence is the
product here — but `spec.md`, `plan.md` and `tasks.md` overlap heavily, and nobody has measured how
much of the overlap is load-bearing.

**Not acted on** because the cheap move (merge the three) would destroy the `/contract` boundary
that makes RED provable, and the right move needs a measurement nobody has taken: which sections
are ever *read again* after the feature closes. The first correction landed on 2026-08-09 in the
other direction — the constitution override that stops injecting two `[given]` rows per feature.

## B7 — The nested suite run scales linearly

**Status:** open · **Raised:** 2026-08-09 (measured) · **Size:** small

The suite takes **12s**; **6s** of that is `check_96` running the whole suite again to obtain a
real log. Fine today, and free of cost to adopters (`tests/` is DROP), but it doubles forever and
the doubling grows with the suite.

**Not acted on** because the alternative — having `run.sh` tee its own output for `check_96` to
read — would let the meta-check judge a log that does not yet contain its own results, which is
precisely the self-subjection `D4` requires. Any fix has to keep that.

## ~~B3~~ — A North Star stub with `TODO:` placeholders passes `schema-valid`

**Status: DONE 2026-08-09 → `specs/016-north-star-integrity/`.** Exit 3 = unfilled, byte identity
with the seeded values, refused against a real vendored target. Widened at the user's prompting to
also carry per-pillar provenance.

## B8 — Semantic vacuity has now cost two features, and stays unmechanised

**Status:** open · **Raised:** 2026-08-09 (016 `/uat`) · **Size:** unknown

Two of 016's own assertions were vacuous and `nvc.sh` caught neither: one grepped `since`, an
ordinary English word that appeared in a scoring rationale; one could not reach the code it claimed
to test, because the gate short-circuits before it. 015 had the same shape. **Two consecutive
features where the mechanical half missed the vacuity and reading caught it.**

`base/patterns/non-vacuous-checks.md` already declares semantic vacuity out of mechanical scope, so
the pattern is *accurate* — this entry records what that accuracy costs, now measured rather than
asserted.

**Deliberately not written as a rule.** *"An assertion must not match an ordinary word"* is
semantic vacuity by definition, and this repository has measured that this family is prose-
resistant three times. A rule with no mechanical form belongs here, not in the constitution.

**Two candidate mechanisms, neither obviously right:** flag a pattern that matches the file it is
asserting against *before* the change (a before/after differential), or require every assertion to
name what it expects to be absent. Both need designing.

## B9 — `status.sh` and `check_90` disagree about DONE

**Status:** open · **Raised:** 2026-08-09 (016) · **Size:** very small

`status.sh` reported `feature DONE` while `check_90` was blocking the close for a missing retro.
The tracker trusts the report's `retro: ✅` line; the gate reads the retro file. The line was
written before the file.

Two trackers, two answers, and **the wrong one is the reassuring one** — the same shape as the
overdue `pending-observation` that went invisible for 35 days.

## B5 — "Reports clean" must mean every rule ran

**Status:** open · **Raised:** 2026-08-09 (015 `/uat`) · **Size:** small

An assertion that a tool reports *clean* must execute every rule that tool enforces, and name
which ones it ran. `NVC-ZERO-FP` claimed the standing suite was clean while never running
`traceability` — the suite read **404/0 with fifteen criteria untraceable**.

Distinct from the five rows already in `base/patterns/non-vacuous-checks.md`: `check-can-fail`
asks whether an assertion *can* fail; this asks whether it *exercised what it claims*.

**Deliberately not written into the constitution yet.** Proposing this family as prose is exactly
what failed three times. It ships as a `[given]` row only together with an obvious mechanical form;
until one exists it lives here, where an unimplemented rule is honest instead of decorative.

## Dropped

_(none yet — an item dropped here keeps its reason)_
