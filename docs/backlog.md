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

**Status: PARTLY CLOSED 2026-08-16 → `specs/020-executable-mutations/`.** The *narrow* family — an
assertion whose input guarantees its own outcome — now has a mechanical form: a criterion declares
the edit that must break it, and `scripts/mutate.sh` requires it to fail. 018's and 019's real
instances are both caught in replay.

**Semantic vacuity generally is NOT closed.** Declaring is opt-in, so nothing catches an assertion
whose author never wrote a mutation for it. Two successors below.

*Original entry retained.* · **Raised:** 2026-08-09 (016 `/uat`) · **Size:** unknown

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

## B10 — Every count carries its derivation, not just Face B's five fields

**Status:** open · **Raised:** 2026-08-09 · **Size:** unknown

Three claims in one session were precise and wrong. Each was a count written from memory instead of
derived when written.

| claimed | actual | caught by |
|---|---|---|
| "3 of 5 rows mechanised" | 2 | re-checking before acting |
| `AMEND-PROV-ONLY` catches the wrong implementation | false | mutation testing |
| 013: "12 gaps caught by /distill" | 8 | the user asking |

None was vague. Vagueness was not the problem. Hedge words number **24** across the whole corpus.

The mechanism already exists: `[deriv:]`, with the retro skill's instruction *"do not type numbers
from memory"*. It covers **five fields of one artifact**. All three failures happened outside them.

**No cheap mechanical form, measured twice.** A loose count detector flagged 322 items, most of
them feature ids read as counts. A tighter one flagged 24, most of them rhetorical: *"two
features"*, *"three times"*, *"one exists"*. A check that fires on correct artifacts gets disabled,
and then the coverage row still reads green.

**Not written as a prose rule.** This repository has measured that this family does not land as
prose. Three proposals, three recurrences. It waits here for a mechanical form or a better idea.

**One candidate:** require the locator only where the count is *about this repository's own
artifacts* — the class all three failures belong to. Distinguishing that from a rhetorical count
is the unsolved part.

## B11 — A gate that selects its own inputs by string format can be opted out of by typo

**Status:** open · **Raised:** 2026-08-09 (017) · **Size:** small

`check_90` judges only features whose report reads DONE, detected by matching `BUILD: ✅`. 017's
report said `BUILD ✅`. The gate never evaluated its retro, `status.sh` reported the feature
unverified, and it merged that way. Fixing one character moved the suite from 450 to 454.

`VERDICT-FORMAT` now asserts every report parses, which closes this instance. The general shape is
open: **several gates select their inputs by matching text in the artifact they judge.** A typo
does not fail them — it removes the artifact from their scope, silently.

Same family as B9, and the same reason it matters: the failure looks like success.

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

## B12 — `since` is unvalidated when a repository has no `decisions/` directory

**Status:** open · **Raised:** 2026-08-09 (018 `/distill`) · **Size:** small

`_adr_ids()` returns `None` when `decisions/` cannot be listed, and the caller then skips the
resolution check entirely. A North Star whose pillar claims `"since": "9999"` validates at exit 0,
provided the directory is absent rather than empty.

That is the from-zero shape: an adopter seeds a North Star before writing any ADR. 016 shipped
`NS-SINCE-RESOLVES` for the case where `decisions/` exists and the id is not in it.

**Not widened into 018.** The fixture ships one ADR, so this feature never reaches the path, and
016's own spec may have intended the allowance. Deciding that needs its own reading.

## B13 — Does `/tasks` earn its place when `coverage.md` is already the work-list?

**Status:** open · **Raised:** 2026-08-09 (018 `/verify`) · **Size:** small

018 implemented straight from `coverage.md` and wrote `tasks.md` afterwards. The question is not
whether that run was sloppy; it is whether the artifact adds anything once `/distill` has frozen a
traced criterion matrix.

**Evidence both ways.** 017's `tasks.md` is five headings that restate its coverage rows. 013's and
014's are seven kilobytes each and did sequence real work — both were features that changed a
schema every adopter inherits.

Under the amended `frictionless-adoption` signal (ADR `0004`) a mandatory step whose value is
already delivered elsewhere is friction without a justification. The honest options are to scope
`/tasks` to features above some size, or to keep it and say what it buys that coverage does not.

Do not resolve this by deleting the step. Resolve it by measuring which features' task lists
sequenced anything the coverage matrix did not.

**Second data point, 2026-08-16 (019).** Written after implementation again, for the same reason:
`coverage.md` was the work-list. Two consecutive features under the same instruction to proceed
unattended. That is a pattern worth measuring, not yet a conclusion — both were small features
whose criteria were already sequenced by the RED state.

## ~~B15~~ — Who must declare a mutation?

**Status: DONE 2026-08-16 → `specs/022-mutation-coverage/`.** The trigger is neither of the two
candidates below. It is derived from the artifact that already names a feature's criteria: its
`coverage.md`. A row is obliged when it is the feature's own, deterministic, and resolves to a check
file that exists. `mutate.sh coverage --spec` gates the feature being verified; `--all` reports the
standing debt without gating it.

**The debt, now a figure instead of an impression: 137 undeclared criteria across twelve closed
features.** Features from 018 on already sit at zero, so the forward-only boundary needed no
baseline list — it fell out of the data.

**What it does not prove** is recorded in that feature's report: the gate's verdict on its own
feature is a tautology, and whether obliging catches anything is `pending-observation` until a
feature closes under it. Sweep 2026-09-16.

*Original entry retained below.* · **Raised:** 2026-08-16 (020 `/uat`) · **Size:** small

`scripts/mutate.sh` runs every declared mutation. Nothing requires a criterion to declare one, so
the mechanism catches only what its author already suspected.

Two candidate triggers, both written down rather than guessed at:

- **By diff.** Every criterion added or changed on the current branch must declare one. Proportional
  and precise, but `git diff` against a branch ref is what 019 shipped and CI rejected — a shallow
  detached-HEAD checkout has neither `main` nor `origin/main`.
- **By shape.** `nvc.sh` flags a criterion whose assertion interpolates a value read from its own
  subject, and a flagged criterion must declare one. Hermetic and self-selecting, but the two known
  instances have *different* shapes, so one regex will not see both.

Do not resolve this by requiring a mutation everywhere. The cost is about a second each, and
several hundred criteria exist.

**Better informed after 021.** The audit found that the real gap in the two tables was **coverage**,
not weak mutations: seven criteria of 018 had none at all. So the trigger should be about *criteria
without a declaration* — cheap to compute and hermetic — rather than about detecting a suspect
shape, which the two known instances show cannot be done with one pattern.

## ~~B16~~ — The by-hand mutation tables of 018 and 019 cannot be reproduced

**Status: DONE 2026-08-16 → `specs/021-mutation-audit/`.** Re-declared as commands and run.
**18 of 19 reproduce.** The one that does not was valid when it ran; the criterion changed
underneath it. The real defect was **coverage** — 018 recorded 11 mutations against 16 criteria —
and the audit found three defects in 020 while doing it.

*Original entry retained below.* · **Raised:** 2026-08-16 (020 `/retro`) · **Size:** small

018 recorded eleven mutations and 019 eight, each as a sentence in a verification report. 020's
first run found that **six of its own fourteen** hand-written mutations broke nothing.

The same rate would put several of those nineteen in the same state, and there is no way to check:
they were written as prose, not as commands. The reports read as evidence and are weaker than they
read.

Cheapest honest fix is to re-declare them as `[mut$ … $]` against the criteria that still exist, and
report how many survive. That is a measurement, not a rewrite of history.

## B14 — Twenty-one `📋 case` rows point at no case file

**Status:** open · **Raised:** 2026-08-16 · **Size:** small

Across `specs/*/coverage.md` there are **32** rows marked `📋 case`. `evals/cases/` holds **8**
files. Twenty-one rows cite no file at all, and one cites `evals/cases/reject-msg.yaml`, which does
not exist.

Nothing checks that a `📋 case` row points at anything. Same family as `B5` and `B11`: the failure
looks exactly like the success, because a row that names nothing and a row whose case is merely
unscored render identically in the matrix.

Distinct from `B2`, which is about the cases never being **scored**. This is about not knowing how
many there are to score.

## B17 — A mutation run against untracked files reports the right verdict for the wrong reason

**Status:** open · **Raised:** 2026-08-16 (022 `/retro`) · **Size:** very small

`mutate.sh run` builds its sandbox from `git ls-files`. A check file that is not yet tracked never
arrives, so every criterion in it reports `emitted no result under its mutation` — which reads as a
broken check rather than an untracked one.

**This is the second occurrence.** 020 shipped both replay fixtures broken this way and documented
it at length; 022 hit it on its first run, two features later, with all fourteen declarations
affected. Reading the report is not the same as having the failure in hand.

**Not written as a prose rule**, because that is what failed. The mechanical form is cheap and in
keeping with the runner's existing behaviour: name any untracked file under `--tests` and exit 2,
the same *silence is not an outcome* move `run` already makes for an unapplied edit and an absent
result.

## B18 — The suite is green in 22s of work and 49 minutes of wall clock

**Status:** open · **Raised:** 2026-08-17 (022 `/verify`) · **Size:** unknown

`bash tests/run.sh` reported **TOTAL PASS=541 FAIL=0** after **2923.29s**. Timing every check inside
one process with `NVC_INNER=1` sums to **~22s**, the largest single file being 4.78s. The verdict is
correct; the wall clock is two orders of magnitude off the work.

**Not caused by 022.** The same run on `main` had not finished after 10 minutes and was still at
`check_90_retro.sh`. 022 adds 2.14s of real work (`check_97`), which is not the difference.

**It is intermittent.** Earlier the same day, on the same branch, the full suite completed twice
inside a 120s call. Whatever triggers the blow-up is state-dependent, and that is the part worth
understanding before anything is changed.

**Mechanism — a hypothesis with evidence, not a diagnosis.** The recursion guard is set in exactly
one place and read in exactly one place, both inside `check_96_non_vacuous.sh`:

```
tests/check_96_non_vacuous.sh:58:  if [ "${NVC_INNER:-0}" = "1" ]; then
tests/check_96_non_vacuous.sh:62:  ( NVC_INNER=1 bash tests/run.sh ) >/tmp/nvc_inner 2>&1
```

`scripts/amendment-gate.sh:61` also respawns the suite — `bash tests/run.sh` whenever no
`--suite-cmd` is passed — and it sets no guard. A suite started down that path has `NVC_INNER`
unset, so its own `check_96` spawns another, which can reach the gate again. That path is only taken
when the gate finds a `pillars`/`scope` change to judge, which would explain why the cost depends on
git state rather than on the tests.

**Two further smells, unconfirmed:** `/tmp/nvc_inner` is a fixed path, so two overlapping runs
clobber each other's evidence; and `check_96` reads a log to judge, which is exactly the
self-subjection `D4` requires — so any fix has to keep the nested run rather than remove it.

**Related, and this supersedes it in size:** `B7` recorded the nested run as a *doubling*, measured
at 6s of 12s. It is not a doubling. `B7` should be read as the same finding taken before it grew.

**Not acted on inside 022.** It is a pre-existing defect in a different subsystem, and chaining it
into the feature that found it is the root cause this file exists to prevent.

## Dropped

_(none yet — an item dropped here keeps its reason)_
