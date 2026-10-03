# Brief — The suite isolates its fixtures and shares its evidence

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Every check in this suite builds its inputs in a private sandbox and writes its **evidence** to a
global constant:

```
tests/check_96_non_vacuous.sh:32  ( cd "$R" && bash "$NVC" traceability … ) >/tmp/nvc_out 2>&1
tests/check_96_non_vacuous.sh:33  if … grep -q "GHOST" /tmp/nvc_out …
```

The sandbox `$R` is minted per use. `/tmp/nvc_out` is not. So the file an assertion greps is not
necessarily the file its own command wrote, and **nothing in the assertion can tell the difference.**

**Measured:** 107 uses of **18** fixed `/tmp` paths across **10** of the check files. Zero in
`scripts/` — the deliverables are clean; this is the suite's own defect.

The repository already knows the correct idiom and applies it to the other half: **42 uses of
`mktemp -d` across 16 files.** The fixtures are isolated. The evidence is not.

## Why / motivation

**This is `B18`'s second smell, recorded there as unconfirmed. It is now reproducible on demand.**

| | result |
|---|---|
| the suite alone | **595 PASS / 0 FAIL**, 50s |
| three rounds of two concurrent suites | **6 of 6 runs red** — 2, 3, 2, 2, 4, 2 failures |

The failing set is **not stable**: five distinct criteria across the rounds
(`NVC-SKIP-EXPLICIT`, `NVC-SELFSCAN-ASSEMBLED`, `NVC-LABEL-SCOPED`, `NVC-LABEL-SAMEFILE`,
`NVC-ZERO-FP`), every one of them in `check_96` — the file carrying 26 of the 107 uses.

**One failure states the whole problem:**

```
NVC-ZERO-FP: trace=1 unattributed: /tmp/nvc_inner has no section for tests/check_91_matrix.sh
```

`NVC-ZERO-FP` is the rule whose job is to detect a criterion that emitted no result. It failed
because it read **the other run's log**. The meta-check built to catch silent criteria was itself
fooled by a shared file.

**The false PASS is the same mechanism and is the one that cannot be seen.** Had the other run's log
contained that section, the rule would have gone green on evidence it did not produce. Only the red
half is proved here; the green half is stated as a mechanism, not as an observation.

**What this is not.** `B18`'s headline is a suite that took **2923s** of wall clock against ~22s of
work. That did not reproduce — the same suite ran in **50s** today — and its named mechanism is
**refuted**: `amendment-gate.sh:61` respawns the suite only when it receives no `--suite-cmd`, and
all **8** gate invocations in `check_95` pass one. The three nested `run.sh` processes visible in
`ps` are a fork artifact: `( … )` forks and the child inherits `argv`. `NVC-INNER-GUARD` measures
depth by content and reports 1.

So the clock stays open in `B18` with its hypothesis struck out, **and so does the other half of
it** — `run.sh` emits no cost at all, which is why the 22s figure had to be reconstructed by hand
with `NVC_INNER=1`, after the fact, on a machine that no longer showed the problem. That belongs to
the clock, not here; see *Out of scope*.

**One hole, not 107 decisions.** `tests/lib.sh` offers no per-run temporary directory, which is why
ten files each invented a constant.

## Success metrics

- **Two concurrent suites are both green.** This is the falsifier and it is impossible to pass
  today: 6 of 6 attempts failed.
- **No check writes evidence to a path it does not own.** The count of fixed `/tmp` literals under
  `tests/` goes to zero, reported as a number rather than asserted.
- **A new one cannot be added silently** — a meta-check names the offending file and line, and is
  run against itself (`D4`).
- **No verdict moves.** The solo suite's PASS count is identical before and after; a change to how
  evidence is stored that alters a result has changed meaning, not storage.
- **Green, hermetic**, dependency-free (`S3`), with the added cost measured rather than estimated.

## Out of scope

- **Explaining the 2923s.** It has not reproduced and no mechanism survives. Guessing at a fix for
  an unobserved failure is what `021` named and this repository has paid for twice.
- **Making `run.sh` report its cost.** This was drafted here as an objective and `/align` returned
  **`blocked`** on it: `tests` is in `vendor.sh`'s `DROP`, so the suite never reaches an adopter and
  the `frictionless-adoption` signal — *steps/time to adopt* — cannot move. No pillar's signal
  responds to the suite printing elapsed times; it is maintainer ergonomics. It stays in `B18`
  with the clock it exists to diagnose.
- **Running the suite in parallel as a feature.** Concurrency is the *probe* that exposes the shared
  state, not a goal. The suite stays sequential.
- **`/tmp` paths inside fixtures' own generated content.** A fixture that legitimately documents a
  path in a heredoc is not a violation, and `check_96` already carries the precedent for that
  distinction.
- **Cleaning up temporary files.** Whether the sandboxes are removed is a different question from
  whether they are shared.

## Dependency

`tests/lib.sh`, `tests/run.sh`, and the ten check files that carry the literals.

**`D3` applies** — the suite is this repository's own workflow auditing itself. **`D4` applies:**
the new meta-check is a gate, so it must be run against itself with a real verdict.

**Stated in advance:** this fixes no product defect and moves no coverage number. Every failure it
prevents is one that has only ever been produced deliberately, by running two suites at once. The
claim is that a suite whose evidence is shared cannot be trusted to have measured what it says —
and the honest form of that claim is the falsifier, not the argument.
