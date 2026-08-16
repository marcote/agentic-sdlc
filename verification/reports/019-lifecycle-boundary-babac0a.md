# Verification Report — 019-lifecycle-boundary @ babac0a

spec: `specs/019-lifecycle-boundary/spec.md` · date: 2026-08-16 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

8 deterministic criteria + 4 inherited `[given]` rows, all 🟢 green. 1 row `📋 case` for the
2026-09-08 sweep. 3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=488 FAIL=0**. Baseline before this feature: 479.

| Criterion | Result |
|---|---|
| NS-LIFECYCLE-PREDICATES | 🟢 schema-valid, 4 lifecycle predicates in `out_of_scope` |
| NS-BOUNDARY-BOUNDED | 🟢 `in_scope` 6 · `out_of_scope` 9 · the same four pillar ids |
| NS-PREDICATE-REACHABLE | 🟢 all 9 predicates ≤ 10 words and firing |
| NS-ADOPTION-STAYS-IN-SCOPE | 🟢 3 adoption objectives clear every predicate |
| NS-REJECTS-NOTHING-BUILT | 🟢 **101 objectives scored, 0 hits** |
| NS-ADR-0005-COMPLETE | 🟢 4 non-empty protocol sections, next sequential number |
| AMEND-LIFECYCLE-REFLEXIVE | 🟢 blocks without `0005`, passes with it, on the reconstructed real diff |
| AMEND-PROVENANCE-QUIET | 🟢 no provenance complaint on a scope-only amendment |

**Task success: 488/488 = 100%.**

### The amendment gate in its real CI mode

```
$ bash scripts/amendment-gate.sh --range main..HEAD
amendment-gate: amendment OK (new ADR + schema-valid + suite green)     # exit 0
```

Run as CI runs it, not only through the hermetic `--files` path. `D3`.

### Guards (`S1`) and meta-checks

`guards` → `bash scripts/guards/no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 ·
`duplicates` 0 · `selfscan` 0 · `prose.sh` 0.

### Failability, one mutation at a time

| # | Mutation | Criteria that failed |
|---|---|---|
| M1 | one lifecycle predicate removed | `NS-LIFECYCLE-PREDICATES`, `NS-BOUNDARY-BOUNDED`, `NS-PREDICATE-REACHABLE` |
| M2 | a predicate rewritten as an 18-word sentence | `NS-PREDICATE-REACHABLE` (**after the fix — see below**) |
| M3 | the release predicate replaced by `"vendoring"` | `NS-ADOPTION-STAYS-IN-SCOPE` + 3 others |
| M4 | a predicate broadened to `"the suite stays green"` | `NS-REJECTS-NOTHING-BUILT` |
| M5 | ADR `0005` deleted | `NS-ADR-0005-COMPLETE`, `AMEND-LIFECYCLE-REFLEXIVE`, `AMEND-PROVENANCE-QUIET` |
| M6 | the ADR's Consequences section emptied | `NS-ADR-0005-COMPLETE` |
| M7 | a pillar `statement` moved without its `since` | `AMEND-PROVENANCE-QUIET`, `AMEND-LIFECYCLE-REFLEXIVE` |
| M8 | `in_scope` grown in the same commit | `NS-BOUNDARY-BOUNDED` |

**M3 and M4 are the two that matter.** M3 is the inward false positive — a delivery predicate
broad enough to exclude the harness's own `vendor.sh`. M4 is the outward one — a predicate broad
enough to reject work already shipped. Both were named as this feature's risks at `/plan` and both
now have a test that fails on them.

### One of my own assertions was vacuous, again, and mutation caught it

`NS-PREDICATE-REACHABLE` built its test objective **from the predicate itself**
(`"a gate for $predicate in every repo"`), so the substring was present by construction. **M2
produced no failure**: an 18-word predicate passed untouched, which is exactly the property the
criterion existed to forbid.

The fix adds the half that can fail — a **10-word cap**, derived from the five predicates that
predate this feature rather than invented. The longest of those is *"application code or product
features of an adopting project"*, at 9 words.

Recorded rather than quietly fixed. **Second consecutive feature where a self-satisfying assertion
survived until mutation testing**, after 018's `ADOPT-REL-RESOLUTION`.

### CI caught a defect the local run could not

The first version of `AMEND-LIFECYCLE-REFLEXIVE` read the previous North Star with
`git show main:…`. Green locally; **`changed=0` and both reflexive criteria FAIL on the PR**, because
a shallow detached-HEAD checkout has neither `main` nor `origin/main`.

That is precisely the `hermetic-env` `[given]` row this feature carries — *"a detached-HEAD,
no-terminal, no-local-branch checkout"*. I wrote the row into `coverage.md` and then broke it.

The before state is now **reconstructed** from the shipped artifact by removing the four predicates
ADR `0005` says it added. Still this feature's real diff; touches no git ref. Verified against a
detached-HEAD sandbox with no local branch: **493/0**.

**Recorded as a second rework, not folded into the first.** Two defects reached a state where
something else had to catch them: M2 caught one, CI caught the other.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | Every gate run deterministically. The 101-objective corpus was measured at `/distill`, before the spec claimed it. |
| Skipped steps | ⚠️ one, recorded | brief → align → distill → plan → contract (RED at 6 FAIL) → **implement** → verify. `/tasks` was again written after implementation, the same deviation 018 recorded. Two consecutive features is the evidence `B13` asked for, not a habit to normalise. |
| Hallucination | 0 | The `scope-reject` CLI signature was wrong on first use and the error surfaced immediately; corrected against `--help` rather than guessed twice. |

**The RED state was real:** 6 of 8 criteria failed before the ADR and the diff existed. The 2 that
passed are documented in `coverage.md`.

## 4. UAT — 2026-08-16

Walked criterion by criterion against `acceptance.md`. All 8 deterministic scenarios executed as
written; observable results match every `Then`.

### Does each criterion move the brief's success metrics?

| Brief metric | Moved by | Evidence |
|---|---|---|
| `out_of_scope` names the boundary in short, citable predicates | `NS-LIFECYCLE-PREDICATES`, `NS-PREDICATE-REACHABLE` | 4 predicates, all ≤ 10 words |
| each predicate says whose lifecycle it excludes | `NS-ADOPTION-STAYS-IN-SCOPE` | 3 adoption objectives clear; M3 fails |
| the amendment lands as the protocol requires | `NS-ADR-0005-COMPLETE` | 4 non-empty sections; ADR + diff in one PR |
| the gate is proved reflexively | `AMEND-LIFECYCLE-REFLEXIVE` | both directions on the real diff; `--range main..HEAD` exit 0 |
| a brief naming an excluded phase is reachable by the gate | `NS-PREDICATE-REACHABLE` | each predicate fires `scope-reject` |
| no existing in-scope work becomes rejected | `NS-REJECTS-NOTHING-BUILT` | 101 objectives, 0 hits |

### The immediate half of the falsification test — **passed**

`alignment.md` set it before the work: *if any of the closed features' objectives hits a new
predicate, the boundary is wrong and the feature has failed, not passed.* 101 objectives across
every brief in `specs/`, zero hits.

### What this feature does **not** prove, stated because the brief invites the confusion

It does not make `/align` reject more briefs. `scope-reject` has never produced a hit across
twelve features, and this feature adds four predicates that will fire only on an objective naming
them nearly verbatim. **The enforcer is the judge**, and what changed is that the judge now has a
line to read where before it had nothing. That is the honest claim and it is smaller than "the
boundary is now enforced".

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ (one recorded deviation, `/tasks` written after implementation) · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/019-lifecycle-boundary/retro.md`.
Gaps routed: none.
