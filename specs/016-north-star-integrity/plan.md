# Technical plan — North Star integrity

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Stack gate — verdict: `PASS`

`UNCOVERED` first: `ground-rules` exit 0 (GR1 S5 · GR2 S6 · GR3 S5 · GR4 S2 · GR5 S7 · GR6 S8).
`pin-valid` exit 0, 9 pins. No `Falsifier` tripped.

### Pins this plan rests on

| Decision | Pin |
|---|---|
| The new capability lives in the python3 reference engine | `S2` — **and its `Hedge` is live here** |
| Reachable only as a shell subcommand, documented exit contract, no importable API | `S2` `Hedge` |
| Refuses rather than half-validating; names what it rejected | `S8` |
| Asserts about the harness's governance artifacts, never product code | `S7` |
| State stays in versioned markdown; no new store for provenance | `S6` |

**`S2-HEDGE` is live, and 015 predicted exactly this.** 015's `coverage.md` deferred the row with
the note *"if implementation reaches for python3, this row stops being deferred and the hedge
applies — recorded now so the decision cannot be made in silence later."* It did. The row is
carried, not deferred, and `NS-ENGINE-CLI-ONLY` verifies it. **This is the accretion loop paying
off across features** — a deferral written by one feature became a live obligation in the next,
mechanically, without anyone remembering.

### No `UNPINNED`

The one candidate was *"provenance is metadata, not a governed field"* (G-c). It is a real decision
with a real cost if wrong — but its blast radius is the amendment gate's hash, one function, and
`S8` already covers the refusal posture. It fails the inclusion test. Recorded here rather than
inflated into a pin.

### `D3`, not `D4`

This feature ships no gate that would block itself: `schema-valid` judges the North Star, and this
feature's North Star must satisfy it (R4). That is reflexive dogfood, not a bootstrap exemption.
The distinction matters because `D4` would license an exemption, and none is needed or taken.

## Decisions

- **D1 — Exit 3 = unfilled**, mirroring the charter engine's exit 3 = empty (013). Same cause,
  same remedy, same reason for a distinct code: so the message can say *seed it* instead of sending
  someone hunting a bug that is not there. Constrained by `NS-UNFILLED`.
- **D2 — The discriminator is byte identity with a single `SEEDED` table**, asserted against what
  `vendor.sh` actually writes. Two copies of a sentinel that drift apart would make the check
  silently stop catching anything. Constrained by `NS-SEED-TABLE-SYNC`.
- **D3-impl — `since` is a four-digit ADR number, required, and must resolve.** Not a path: paths
  break on rename. Unknown id rejected by name, per 014's `Answers:` doctrine. Constrained by
  `NS-SINCE-REQUIRED`, `NS-SINCE-RESOLVES`.
- **D4-impl — Unfilled is checked before provenance.** A seeded North Star has a seeded `since`;
  reporting "ADR 0000 not found" first would be technically true and practically misleading.
  Constrained by `NS-UNFILLED-BEFORE-SINCE`.
- **D5 — The gate's governed hash is unchanged; the staleness check is additive.** Both directions
  asserted — blocked on stale, passes on provenance-only. One without the other is half a rule and
  would be satisfied by an implementation that blocks everything. Constrained by `AMEND-PROV-STALE`,
  `AMEND-PROV-ONLY`.
- **D6 — `0003` is not recorded as provenance.** It renamed every id and changed no `statement` and
  no `signal`. Recording it would redefine the field as "last touched" rather than "last changed in
  meaning", which is the question being asked. Constrained by `NS-OWN-MIGRATED`.

## Components

| Unit | Responsibility | Interface |
|---|---|---|
| `scripts/north-star/engine.py` | `SEEDED` table · unfilled detection · `since` validation | shell CLI, exit 0/1/2/3 |
| `scripts/amendment-gate.sh` | provenance staleness, additive to the governed hash | `--range` / `--files` |
| `memory/north-star/base/schema.md` | the contract: `since` + the unfilled rule | prose contract |
| `.claude/skills/align/SKILL.md` | refuse on exit 3; stamp provenance | prose contract |
| `memory/north-star/north-star.md`, `scripts/vendor.sh` | migrated / stub updated | data |

## Risks

| Risk | Mitigation |
|---|---|
| False positive on a to-do-domain product | byte identity, `NS-TODO-NOT-FALSE-POSITIVE` tests exactly that case |
| `SEEDED` drifts from the stub and the check silently dies | `NS-SEED-TABLE-SYNC` compares them |
| The gate blocks everything and `AMEND-PROV-STALE` passes vacuously | `AMEND-PROV-ONLY` is the paired positive |
| Provenance is decoration | stated in `alignment.md` as a falsification test; `measurable-impact` cannot be `✅` on half B at `/retro` |
