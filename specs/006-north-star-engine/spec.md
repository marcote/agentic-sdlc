# Spec — North Star engine (python3 reference implementation)

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md`
> has no orphan rows. Gate: `alignment.md` verdict = `aligned` (scope confirmed in-scope,
> batteries-included rationale).

## Context (what already exists)

The North Star deterministic logic exists **partially, embedded** in the heredoc of
`scripts/amendment-gate.sh`: `_load` (extract the canonical ```json``` block + parse),
`validate` (schema), `sig`/`sets_changed` (governed-sets signature), and a bash
`has_new_adr`. This feature **extracts that logic into one reusable python3 module**,
**adds the two missing capabilities** (`scope-reject`, `align-verdict`) that `/align`
needs, and **rewires `amendment-gate.sh` to call the module** instead of embedding its
own copy. `/align` and the evals reference the engine as their contract but are **not**
rewired here (out of scope for 006).

## Functional requirements

1. **Engine module & CLI.** A single python3 entrypoint `scripts/north-star/engine.py`,
   **stdlib-only** (`json`, `re`, `sys`, `argparse`), exposing subcommands. Invocation
   contract: **exit-code + minimal stdout** (bash-friendly); malformed input (broken JSON
   / no canonical ```json``` block) → **exit 2** (a distinct *error*, never confused with a
   valid "invalid"/"no-hit" answer).
2. **`schema-valid FILE`** (= `validateNorthStar`, per `base/schema.md`) → exit `0` valid;
   exit `1` + precise reason on stderr when invalid (empty `mission`, a pillar missing
   `id`/`statement`/`signal`, empty `scope.in_scope`/`out_of_scope`, non-numeric
   `alignment.threshold`); exit `2` on malformed input.
3. **`sets-changed OLD NEW`** (= `requiresAdr`) → stdout `changed`|`same`, exit `0`.
   Comparison is on the **semantic signature** of the governed sets (`pillars` +
   `scope.in_scope` + `scope.out_of_scope`), **order-agnostic** (frozenset); a diff limited
   to prose, `mission` wording that leaves the sets intact, or `alignment.threshold`
   → `same`.
4. **`scope-reject OBJECTIVE [--north-star FILE]`** (= `scopeReject`) → exit `0` + the
   matched `out_of_scope` predicate on stdout when the objective **contains a full
   predicate as a normalized contiguous substring** (lowercase + collapsed whitespace);
   exit `1` when no predicate matches. Deliberately **conservative**: a partial overlap
   (e.g. `deterministic engine` vs the predicate `stack-specific deterministic engine`)
   is **not** a hit — semantic edges are the judge's job, not this predicate's.
5. **`align-verdict`** (= `alignVerdict`) → reads a small JSON object from **stdin**
   (`{scores:{pillarFit,scopeCompliance,missionAdvancement}, orphan:bool, scopeHit:bool,
   threshold:int}`), prints exactly one verdict on stdout — the deterministic cascade:
   `scopeHit` → `rejected`; else `orphan` → `blocked`; else all three dimensions ≥
   `threshold` → `aligned`; else → `needs-amendment`. It **aggregates only** — scoring and
   mapping are the LLM judge's work in the `/align` skill, never the engine's.
6. **`has-adr-for --added "f1 f2 …"`** (= `hasAdrFor`) → exit `0` if any added path matches
   `memory/north-star/decisions/NNNN-*.md` (4-digit, kebab slug); exit `1` if none.
7. **Rewire `amendment-gate.sh`.** The gate calls `engine.py` for schema validation,
   sets-changed, and has-adr-for; the embedded `_py` heredoc and bash `has_new_adr` are
   **removed** (single source of truth). Behavior is **identical** — no change to the
   gate's exit semantics or the messages its suite asserts.
8. **Dependency-free.** The engine and the rewired gate use only bash/coreutils + `python3`
   stdlib — no Node/npm, no pip installs, no manifests in the source path.
9. **Self-check.** `tests/run.sh` includes a check that covers the engine and stays green;
   the existing amendment-gate suite (`check_95`) stays green after the rewire.

## User stories

- As the **harness (its own adopter)** I want a runnable, in-repo North Star engine so that
  `/align` and the amendment gate stop being "contract only, engine elsewhere".
- As an **adopter** I want a dependency-free reference engine shipped with the harness so
  that adoption is batteries-included (it runs), not a contract I must wire from scratch.
- As a **maintainer** I want the amendment gate to call one engine (no duplicated JSON
  parsing) so that the two never drift apart.

## Edge cases (80% problem)

- **Malformed vs invalid** must not collapse: broken JSON / missing ```json``` block → exit
  `2` (error), *not* exit `1` (a well-formed-but-schema-invalid North Star).
- **Order-agnostic sets:** reordering `pillars` or `scope` entries is `same`, not `changed`.
- **scopeReject normalization:** a predicate present modulo case/extra whitespace still
  hits; a merely partial phrase overlap does not.
- **align-verdict precedence:** a `scopeHit` outranks everything (even all-5 scores →
  `rejected`); an `orphan` outranks a passing score set (→ `blocked`).
- **has-adr-for pattern strictness:** `decisions/README.md` or `decisions/0001.md`
  (no slug) does **not** count; only `NNNN-slug.md`.

## Open questions / deferred

- **File layout** (single `engine.py` vs split `schema/align/amendment.py` mirroring
  poirot-fe's `*.mjs`): resolved → **single entrypoint** with subcommands (simplest for the
  bash caller; one file to keep stdlib-pure).
- **Rewiring `/align` and the evals to call the engine:** **deferred** to a later feature
  (grilling 1/3). 006 provides the engine + rewires only `amendment-gate.sh`.
- **A Node parity implementation:** out of scope — poirot-fe's `*.mjs` remains the Node
  reference; 006 does not maintain cross-stack parity.
