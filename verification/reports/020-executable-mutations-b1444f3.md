# Verification Report — 020-executable-mutations @ b1444f3

spec: `specs/020-executable-mutations/spec.md` · date: 2026-08-16 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

14 deterministic criteria, all 🟢 green. 1 row `📋 case`, unscorable before the next feature.
3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=507 FAIL=0**. Baseline before this feature: 493.

All 14 criteria in `check_99_mutations.sh` pass, including the runner's own negative
(`MUT-CATCHES-VACUOUS`) and the two replays.

### Declared mutations — the new `/verify` step

```
$ bash scripts/mutate.sh run --tests tests
proved      MUT-GRAMMAR (tests/check_99_mutations.sh:27) — 0.49s
…
mutate: 14 mutation(s) under tests, 0 not proved, total elapsed 13.02s     # exit 0
```

**14 of 14 proved failable.** This is `D4` condition 2 discharged with a real verdict rather than a
trivial pass — the gate this feature ships, run against this feature's own criteria.

### Guards (`S1`) and meta-checks

`guards` → `bash scripts/guards/no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 · `duplicates` 0
· `selfscan` 0 · `prose.sh` 0.

### The falsification test — **passed**

`alignment.md` gate note 3 set it before the work: *replay 018's and 019's real vacuous criteria; if
the mechanism does not catch what actually shipped, it does not work.*

```
NOT PROVED  ADOPT-REL-RESOLUTION (…check_replay_018.sh:23) — survived its own mutation: …
NOT PROVED  NS-PREDICATE-REACHABLE (…check_replay_019.sh:25) — survived its own mutation: …
```

Both assertion blocks are character-identical to `3adc719^` and `babac0a^`; only the variables they
read are supplied. Neither was edited to be easier to catch.

### Cost, measured rather than estimated (O6, ADR `0004`)

| | |
|---|---|
| sandbox from the working tree, 287 tracked files | 0.15s |
| one mutation, end to end | 0.49–1.27s |
| 14 mutations | **13.02s** |
| `tests/run.sh`, unchanged by this feature | ~25s |

The runner is **not** inside the suite. It re-runs check files, so a check invoking it would
re-enter it once per declaration — and `check_96` already re-runs the whole suite, multiplying that
again. It runs where `Guard`s run: at `/verify` and in CI. `MUT-WIRED` asserts both, because a gate
accepted and never run is the failure `base/pin-template.md` calls worse than a vacuous check.

### Three defects found during implementation, all by the mechanism or by chasing it

**1. Six of my own fourteen mutations broke nothing.** The first run reported them `survived its own
mutation`. Every one was a `sed` that matched a comment, or a pattern that did not exist in the
file at all — for instance `s/mut\$/muX\$/` never touched the awk pattern `\[mut\$`, because the
file contains a backslash the pattern did not. **This is the strongest evidence the runner works:
its first real use found six weak assertions in the feature that shipped it.**

**2. A reentrancy bug that produced a *wrong* diagnostic.** The runner wrote its captured output to
a fixed `/tmp` path. The check file it executes itself invokes the runner, and the inner run
clobbered the outer run's capture — so a criterion that **passed** under its mutation was reported
as `emitted no result`. That reads like a broken check rather than a vacuous one, which is the more
dangerous of the two misreadings. Fixed with per-invocation `mktemp -d` in both the runner and
`check_99`.

**3. The replay fixtures were untracked, so both replays reported the right verdict for the wrong
reason.** The sandbox is built from `git ls-files`; an untracked fixture never arrives, so the
check emitted nothing and the runner said `could not be applied` and `emitted no result`. Had the
assertion accepted any `not proved`, this feature would have shipped a passing falsification test
that proved nothing. `MUT-REPLAY-*` now requires the exact string `survived its own mutation`.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | The design was chosen from measurements taken at `/distill` — 0.15s sandbox, 0.84–3.53s per check, 24.68s suite — not from an estimate. |
| Skipped steps | ✅ | brief → align → distill → plan → **tasks** → contract (RED at 13 FAIL, 0 PASS) → implement → verify. `/tasks` written **before** implementation, closing the deviation 018 and 019 both recorded. |
| Hallucination | 0 | Nothing asserted about the runner's behaviour that was not first observed in its output. |

**The RED state was real:** 13 of 13 criteria failed at `/contract`, with zero passing. The first
feature in this repository with no green-by-construction exception.

## 4. UAT — 2026-08-16

Walked criterion by criterion against `acceptance.md`. All 14 deterministic scenarios executed as
written.

### Does each criterion move the brief's success metrics?

| Brief metric | Moved by | Evidence |
|---|---|---|
| a criterion can declare its mutation inline | `MUT-GRAMMAR`, `MUT-UNBOUND-REJECTED` | 14 declarations parsed; unbound → exit 2 |
| the suite applies each and requires failure | `MUT-REQUIRES-FAIL`, `MUT-CATCHES-VACUOUS` | proved / survived, both observed |
| reverted either way, tree unchanged | `MUT-SANDBOXED` | `tests/fixtures` byte-identical |
| a criterion that cannot fail is named | `MUT-SILENCE-IS-NOT-FAILURE`, `MUT-APPLY-ERROR-DISTINCT` | three distinct outcomes |
| 019's vacuous form is caught | `MUT-REPLAY-019` | `survived its own mutation` |
| the cost is bounded and stated | `MUT-COST-REPORTED` | 13.02s for 14, reported every run |
| green, hermetic, adopters inherit the pattern | `HERMETIC-ENV-99`, `MUT-DEPFREE` | 507/0; `mutate.sh` is DROP |

### What this feature does **not** prove

Declaring a mutation is **opt-in**. Nothing requires the next author to declare one, so this makes
the proving repeatable and auditable — it does not yet prevent the sixth vacuous assertion.
`JUDGE-PREVENTS-THE-SIXTH` is deliberately unscorable until a feature closes after this one.

Saying so is not modesty. A feature that shipped an opt-in capability and claimed the family closed
would be the sixth instance, one level up.

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/020-executable-mutations/retro.md`.
Gaps routed: none.
