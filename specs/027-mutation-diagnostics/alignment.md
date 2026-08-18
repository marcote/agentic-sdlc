# Alignment — 027-mutation-diagnostics

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all six objectives; `align-verdict`
`aligned`. Proved live in the same run — a control carrying the exact predicate *"prioritisation,
roadmapping or estimation across features"* fired at exit 0.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 3}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **5** | `real-enforcement`'s signal names *"the harness proves this by dogfooding itself"*. This is the harness's own gate reporting its own failures accurately, and the evidence is 12 misdiagnoses across four of this repository's features. No inference. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"*. `mutate.sh` is the verification of the method's own checks. No `out_of_scope` predicate approached. |
| mission advancement | **3** | **At threshold, and it is the honest floor.** This fixes no criterion, moves no coverage number, and closes no vacuity. It changes what the runner *says* when something is already wrong. The claim — that the next stale declaration is read correctly the first time — is unobservable from inside the feature that ships it. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — an edit that changes no bytes is its own outcome | `real-enforcement` |
| O2 — untracked files stop the run before it starts | `real-enforcement` |
| O3 — stale still counts as not proved | `real-enforcement` |
| O4 — weak and stale counted separately | `measurable-impact` |
| O5 — the replay uses the declaration as it shipped | `measurable-impact` |
| O6 — green, hermetic, cost measured against the 2% predicted | `frictionless-adoption` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

## Orphans

None.

## Pillars deliberately NOT claimed

- **`agnostic-portability` is not claimed at all.** `mutate.sh` is in neither `KEEP` nor `DROP`
  (`B20`), so nothing here travels and claiming portability would be false.

## Gate note

1. **The cost is predicted before it is measured, and the prediction is falsifiable.** A content hash
   of the 364-file sandbox took **0.018s**; two per mutation across 88 declarations should add ~3.2s
   to a 147s run, about **2%**. If `/verify` measures materially more, the design is wrong and the
   report says so rather than quietly accepting the number it finds.

2. **The verdict must not soften.** A stale declaration means the criterion was never tested, so it
   is *more* alarming than a weak one, not less. If `stale` were counted as anything but not-proved,
   this feature would have converted 12 loud failures into 12 quiet ones. `O3` exists to forbid that
   and `/uat` checks the exit code, not the wording.

3. **The replay must use the declaration exactly as it shipped.** 020 nearly shipped a falsification
   test that proved nothing because its replay fixtures were untracked and it accepted any
   `not proved`. The stale replay must assert the exact string, against 026's real declaration —
   `s|^_mx_crit=0$|_mx_crit=5|` — not a convenient rewrite of it.

4. **This feature cannot demonstrate its own value.** Every declaration it ships will be written
   knowing the new outcome exists. Whether the diagnosis lands is a claim about the *next* author,
   and it is recorded as a `📋 case` rather than scored here.
