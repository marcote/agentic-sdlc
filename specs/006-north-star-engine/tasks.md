# Tasks — North Star engine

> Executable breakdown. Produced by `/tasks`. GATE PASSED: every RED-required deterministic
> criterion has a linked test (`check_82`) in 🔴 RED (18/18). `GATE-REGRESSION` is an
> annotated must-not-regress guard on `check_95` (excluded from the RED-required set, like
> 004's `UAT (config)` rows). Each task drives its rows 🔴→🟢 via `bash tests/run.sh`.

## Tasks

- [ ] **T1: Engine skeleton + `_load` + argparse dispatch.** Create
  `scripts/north-star/engine.py` (stdlib-only), a subcommand dispatcher, and the internal
  `_load(path)` that extracts the canonical ```json``` block and parses it, mapping any
  extraction/parse failure to **exit 2**. — enables all rows; directly covers the malformed
  path of `SCHEMA-MALFORMED`.

- [ ] **T2: `schema-valid` subcommand.** Port `validate()` from the gate heredoc; exit `0`
  valid / `1` invalid (+ offending field on stderr) / `2` malformed. — covers `SCHEMA-VALID`,
  `SCHEMA-INVALID`, `SCHEMA-MALFORMED`.

- [ ] **T3: `sets-changed` subcommand.** Port `sig()` (order-agnostic frozenset signature of
  `pillars` + `scope`); print `changed`|`same`, exit 0. — covers `SETS-CHANGED`,
  `SETS-SAME-PROSE`, `SETS-ORDER-AGNOSTIC`.

- [ ] **T4: `scope-reject` subcommand.** Normalize (lowercase + collapse whitespace) the
  objective and each `out_of_scope` predicate; hit iff a full predicate is a contiguous
  substring; print the predicate + exit 0, else exit 1. — covers `SCOPE-HIT`,
  `SCOPE-MISS-PARTIAL`, `SCOPE-NORMALIZE`.

- [ ] **T5: `align-verdict` subcommand.** Read `{scores,orphan,scopeHit,threshold}` from
  stdin; apply the cascade (`scopeHit`→rejected; `orphan`→blocked; all dims ≥ threshold
  →aligned; else needs-amendment); print the verdict; bad input → exit 2. — covers
  `VERDICT-REJECTED`, `VERDICT-BLOCKED`, `VERDICT-ALIGNED`, `VERDICT-NEEDS-AMENDMENT`.

- [ ] **T6: `has-adr-for` subcommand.** From `--added "…"`, exit 0 iff any path matches
  `memory/north-star/decisions/NNNN-slug.md` (4-digit + kebab slug), else exit 1. — covers
  `ADR-PRESENT`, `ADR-ABSENT`.

- [ ] **T7: Rewire `amendment-gate.sh`.** Replace the embedded `_py` heredoc and bash
  `has_new_adr` with calls to `engine.py schema-valid` / `sets-changed` / `has-adr-for`;
  keep the gate's own CLI, exit semantics, and messages byte-for-byte. — covers `GATE-REUSE`;
  guards `GATE-REGRESSION` (run `check_95` before/after — must stay green).

- [ ] **T8: Close DEP-FREE + SELF-CHECK; full green.** Confirm the engine imports only
  python3 stdlib (no third-party, no toolchain, no manifest) and that `bash tests/run.sh` is
  fully green (`check_82` + `check_95` + the rest). — covers `DEP-FREE`, `SELF-CHECK`;
  confirms `GATE-REGRESSION`.

## Escalation

Inner loop per task: 🔴→🟢. **ESCALATE** to the human after 2 identical failures or 3 attempts
on any task (constitution) instead of burning tokens — the 20% conceptual gap goes to review.
