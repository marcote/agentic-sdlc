# Alignment — 019-lifecycle-boundary

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0004`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all six objectives; `align-verdict`
`aligned`.

## Verdict

**`aligned`** — `{pillarFit: 4, scopeCompliance: 5, missionAdvancement: 4}`, threshold 3.
Falsification run: dropping `pillarFit` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | Every objective lands on `real-enforcement`, whose signal is *"gates block closure when a condition is missing"*. Today `/align` has nothing to score a discovery or release brief against, so the condition is missing in the literal sense. Held at 4, not 5: **excluding** something advances no pillar directly — it prevents a future misalignment. That is a step of inference, the same one that held 016's O4 at 4. |
| scope compliance | **5** | `in_scope` names *"product governance: constitution and North Star"* verbatim. This is that item, not an adjacent one. No `out_of_scope` predicate is near, and `scope-reject` cleared all six objectives while the control objective *"blocking commit hooks"* fired at exit 0 — so the filter was live, not asleep. |
| mission advancement | 4 | Directly observable that the predicates exist and the amendment gate accepts the change. Held below 5 because the payoff is deferred: it pays when a future brief is scored differently *because* these lines exist, and that may not happen for months. Claiming 5 would be predicting the future. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — `out_of_scope` names the lifecycle boundary in short, citable predicates | `real-enforcement` |
| O2 — each predicate says whose lifecycle it excludes, so `vendor.sh`/`bootstrap.sh` stay in scope | `real-enforcement` |
| O3 — the amendment lands as the protocol requires: ADR + diff, one PR, CI-checked | `real-enforcement` |
| O4 — the gate is proved reflexively against this feature's own diff | `real-enforcement` |
| O5 — a brief naming an excluded phase is reachable by the gate | `real-enforcement` |
| O6 — no existing in-scope work becomes rejected, checked against twelve closed features | `real-enforcement` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |

Scored under the original seed, unamended since. The pillar most likely to move underneath this
feature is `measurable-impact`, and the brief deliberately declines to touch it.

## Orphans

None.

## Pillars deliberately NOT claimed

- **`measurable-impact` — not claimed, and this is the interesting one.** The brief's own argument
  observes that this pillar's signal measures process hygiene rather than outcome. Claiming the
  pillar while declining to fix it would be laundering. The observation is recorded; the pillar is
  not claimed.
- **`frictionless-adoption` — not claimed.** A recorded exclusion arguably saves an adopter effort,
  but that is an inference, and ADR `0004` was written precisely because this pillar had been
  claimed on inferences.
- **`agnostic-portability` — not claimed.** The boundary is about lifecycle phase, not stack.

**One pillar across six objectives is unusual and is not a defect here.** The feature has one
subject: what the harness will and will not govern. A mapping that spread it across four pillars
would be the loose mapping the skill warns against.

## Gate note

1. **The false-positive risk is the whole risk, and it points inward.** The harness's own in-scope
   work includes *"adoption tooling: install, vendoring, and harness inheritance"* — which is
   delivery. A predicate reading *"release and deployment"* without saying **whose** could exclude
   `vendor.sh` and `bootstrap.sh` retroactively. O6 tests this against the twelve closed features
   rather than asserting it.

2. **Short predicates, and the reason is measured.** `scope-reject` is a contiguous-phrase match,
   so a long compound predicate can never fire. The control run proves a short one does:
   *"blocking commit hooks"* returned exit 0. Compound sentences would ship a boundary only the
   judge can ever apply.

3. **The falsification test, set before the result is known.** *Does the boundary ever change a
   verdict?* Two horizons, and only one is cheap. **Now:** if any of the twelve closed features'
   objectives hits a new predicate, the boundary is wrong and the feature has failed, not passed.
   **Later:** whether a future brief is scored differently because these lines exist — deferred to
   the **2026-09-08** sweep, with 013, 014, 016 and 017. `missionAdvancement` cannot be claimed
   confirmed on the strength of the later horizon at `/retro`.

4. **Twelve features have never produced a `scope-reject` hit.** Recorded here because it bounds
   what this feature can honestly promise: the deterministic filter is a high-confidence
   pre-filter by design, and the judge is the intended enforcer of borderline cases. This feature
   gives the judge a line to read. It does not make the hard gate fire more often, and saying
   otherwise would be a claim the last twelve features contradict.
