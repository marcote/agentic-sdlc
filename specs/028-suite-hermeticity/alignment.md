# Alignment — 028-suite-hermeticity

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on every objective; `align-verdict` `aligned`.

**The engine was proved live in the same run, in both directions.** A control carrying the exact
predicate *"release, deployment or rollout of the software being built"* returned **exit 0**, and a
paraphrase of that same predicate — *"we will not deploy or roll out anything"* — returned **exit 1**.
The second control matters more than the first: it is what shows the match is contiguous-phrase and
not semantic, so a `scope-reject` of exit 1 on the real objectives means *not matched*, not
*not checked*.

## Verdict

**`aligned`** — `{pillarFit: 3, scopeCompliance: 5, missionAdvancement: 3}`, threshold 3. Two of
three dimensions sit exactly at the floor.

Falsification run: the same input with `missionAdvancement` at 2 returns `needs-amendment`.

## The first run was `blocked`, and that is recorded rather than overwritten

The brief was submitted with **six** objectives. The sixth — *"the run reports its own cost, per
check and total"* — mapped to **no pillar**, and the engine returned **`blocked`**.

**The reason is a fact about `vendor.sh`, not a judgement.** `tests` is in `DROP`, so the suite
never reaches an adopter. `frictionless-adoption`'s signal measures *steps/time to adopt*, and an
adopter who never runs this suite cannot pay its cost. No other pillar's signal responds to
`run.sh` printing elapsed times.

Two mappings were considered and rejected as false rather than merely weak: `frictionless-adoption`
for the reason above, and `measurable-impact`, whose signal counts gaps caught and rework avoided —
neither of which moves because a timing line exists.

**Confirmed that the block came from the orphan and not from the scores:** the identical score
vector with `orphan: false` returns `needs-amendment`, not `blocked`. Those are different verdicts
with different remedies, and reporting the wrong one would have sent this to the amendment protocol
instead of to a narrower brief.

The brief was narrowed. The objective now sits in *Out of scope* with that reasoning attached, and
the timing work stays in `B18` beside the clock it exists to diagnose.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **3** | Set by O5 alone, and **3 is the honest number, not the convenient one.** O5 is the standing hygiene constraint every feature carries; against `agnostic-portability` its fit is real but loose — the changed files do not vendor, so nothing here travels. A mapping to `real-enforcement` was available and would have scored 4 by way of the pillar's dogfood clause. It was rejected: *green and dependency-free* does not advance *gates block closure*, and taking it would have been choosing the mapping by its score. |
| scope compliance | **5** | `in_scope` names *"commands, gates, and skills of the governance workflow"* and *"evals, verification, and UAT of the method"*. The suite is the method's enforcement. No `out_of_scope` predicate is approached. |
| mission advancement | **3** | **At threshold, and it belongs there.** Every failure this prevents has only ever been produced deliberately, by running two suites at once. Nobody does that. What moves is the *trustworthiness* of a number, not the number — and 026 scored 3 for a refactor whose success condition was that nothing move. Scoring 4 here would break that scale one feature later. |

## Objective→pillar mapping

| Objective (brief) | Pillars | `since` |
|---|---|---|
| O1 — two concurrent suites are both green | `real-enforcement`, `measurable-impact` | `0001`, `0002` |
| O2 — no check writes evidence to a path it does not own | `real-enforcement` | `0001` |
| O3 — a new one cannot be added silently, and the meta-check is run against itself | `real-enforcement` | `0001` |
| O4 — no verdict moves anywhere else | `measurable-impact` | `0002` |
| O5 — green, hermetic, dependency-free, with the added cost measured | `agnostic-portability` | `0001` |

`real-enforcement` carries O1–O3 because its signal names the dogfood explicitly — *"the harness
proves this by dogfooding itself"*. This suite **is** that proof, and a proof whose result depends
on what else is running on the machine is not deterministic, which is the pillar's `statement`
verbatim.

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `agnostic-portability` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

## Orphans

None, **after narrowing**. One before it — see above.

## Pillars deliberately NOT claimed

- **`frictionless-adoption`.** `tests` is `DROP`; the adopter never runs this suite, so no cost it
  imposes is theirs and its signal cannot move. This is the same fact that orphaned the sixth
  objective, and it applies to the whole feature, not only to that objective.

## Gate notes

1. **The measured claim is the falsifier, and it is the only honest form of it.** *"Shared evidence
   makes a suite untrustworthy"* is an argument. *"Two concurrent suites are both green"* is a
   command with an exit code, and it fails **6 times out of 6** today. The argument would survive a
   feature that fixed nothing; the command would not.

2. **Only the red half is proved, and the brief says so.** Three rounds produced 2, 3, 2, 2, 4 and 2
   false FAILs — a check reading another run's file and reporting a violation that is not there. A
   false **PASS** has the identical mechanism and has **not been observed**. It is stated as a
   mechanism, never as a measurement. `B14` is the standing reason for that care: an entry in this
   repository once described claims that point at nothing, using a figure that was wrong by 7×.

3. **One failure is the whole feature and should be quoted, not summarised.**
   `NVC-ZERO-FP: /tmp/nvc_inner has no section for tests/check_91_matrix.sh` — the rule whose job is
   to detect a criterion that emitted no result, failing because it read the other run's log. The
   meta-check built to catch silent criteria was fooled by a shared file.

4. **`B18`'s named mechanism is refuted, and this feature must not inherit it.** The `amendment-gate`
   respawn does not fire from the suite: all **8** gate invocations in `check_95` pass
   `--suite-cmd`. The three nested `run.sh` processes in `ps` are a fork artifact — `( … )` forks and
   the child keeps `argv`. `NVC-INNER-GUARD` measures depth by content and reports 1. Anything built
   here rests on the concurrency measurement, which reproduces, and on nothing from that hypothesis.

5. **The count is a number, not an impression: 107 uses of 18 fixed `/tmp` paths across 10 files**,
   zero in `scripts/`. It was taken before any design, and O2 requires it to be reported at zero
   rather than asserted clean — `B5`'s rule, that *reports clean* must mean the rule actually ran.
