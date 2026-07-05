# Technical plan — North Star engine (python3 reference)

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Technical decisions

- **D1 — `python3` stdlib, single-file CLI (`scripts/north-star/engine.py`).** The engine is
  one stdlib-only python3 file (`json`, `re`, `sys`, `argparse`). *Trade-off:* a split
  `schema/align/amendment.py` (mirroring poirot-fe's `*.mjs`) is more modular but adds
  import wiring and more surface to keep stdlib-pure; a single entrypoint is simplest for the
  bash caller. *Why it does not cross the North Star:* `python3` is a **system interpreter**
  (like bash/grep), not an installable dependency — the exact precedent set by 004's D1 and
  the `constitution.md` D-delta; no uv/pip/npm, no manifest → does not match `out_of_scope`
  "runtime dependencies or frameworks", no amendment needed. Constrained by:
  `agnostic-portability` + principle 6 (small baseline) + the `DEP-FREE` criterion.

- **D2 — Pure core operating on files/stdin, not on git state (testability).** Each
  subcommand is a pure function of its inputs: `schema-valid FILE`, `sets-changed OLD NEW`,
  `scope-reject OBJECTIVE [--north-star FILE]`, `align-verdict` (JSON on stdin),
  `has-adr-for --added "…"`. *Why:* lets `check_82` exercise every criterion with **fixtures**
  (north-star files, objective strings, verdict-input JSON, added-file lists) with no git
  states — same fixture discipline as `check_90`/`check_95`. Constrained by: principle 1
  (verifiability) + 2 (test-first) — a criterion not fixture-testable is not deterministic.

- **D3 — Tri-state exit contract (bash-friendly), malformed ≠ invalid.** `0` = the
  affirmative/valid answer; `1` = the well-formed negative (schema-invalid, no scope hit,
  no ADR); `2` = **error** (broken JSON / missing canonical ```json``` block). Minimal
  stdout carries the payload the caller needs (`changed`|`same`, the matched predicate, the
  verdict); reasons go to stderr. *Why:* the consumer is bash (`amendment-gate.sh`) — it
  must distinguish "the North Star is invalid" (exit 1, a governance answer) from "I could
  not parse it" (exit 2, an operational error), exactly as the current heredoc does.
  Constrained by: the distill CLI-contract decision + principle 1.

- **D4 — `scope-reject` = normalized full-predicate substring, conservative.** An objective
  is a hit iff, after normalization (lowercase + whitespace collapse), it **contains a whole
  `out_of_scope` predicate** as a contiguous substring; prints that predicate. Partial
  phrase overlap is deliberately **not** a hit. *Why:* the `/align` skill specifies a
  "conservative contiguous-phrase match"; the hard gate must have near-zero false positives,
  leaving semantic edges to the LLM judge (the scope-compliance dimension). Constrained by:
  `align/SKILL.md` step 3 + `alignment-rubric.md`.

- **D5 — `align-verdict` = pure aggregator, scoring stays with the judge.** It reads
  `{scores:{pillarFit,scopeCompliance,missionAdvancement}, orphan, scopeHit, threshold}` and
  applies the fixed cascade (`scopeHit`→`rejected`; `orphan`→`blocked`; all dims ≥
  threshold→`aligned`; else→`needs-amendment`). It performs **no** semantic scoring or
  mapping — those remain the LLM judge's job in `/align`. *Why:* keeps the deterministic
  engine deterministic; matches `alignment-rubric.md` "the rubric feeds the aggregator, does
  not average around it". Constrained by: `alignment-rubric.md` pass rule + `align/SKILL.md`
  step 6.

- **D6 — Rewire `amendment-gate.sh`, behavior-identical (regression-safe).** The embedded
  `_py` heredoc (`load`/`validate`/`sig`) **and** bash `has_new_adr` are removed; the gate
  calls `engine.py schema-valid` / `sets-changed` / `has-adr-for`. The gate keeps its **own**
  orchestration, exit semantics, and human-facing messages unchanged — only the engine
  *source* moves. *Why:* single source of truth (O2) without altering the gate's contract.
  Constrained by: `GATE-REGRESSION` (existing `check_95` must stay green) + principle 4
  (the gate's narrow-block behavior is unchanged).

- **D7 — `has-adr-for` moves from bash into the engine.** Filename-pattern logic
  (`decisions/NNNN-slug.md`, 4-digit + kebab slug) migrates from the gate's `has_new_adr` to
  an engine subcommand, so **all** North Star determinism lives in one module. *Trade-off:*
  it carries no JSON (could have stayed bash), but centralizing avoids two places drifting on
  what counts as an ADR. Constrained by: `base/amendment-protocol.md` (`hasAdrFor` semantics).

- **D8 — `tests/run.sh` needs no change.** It globs `tests/check_*.sh`; dropping
  `tests/check_82_north_star_engine.sh` wires it automatically. `SELF-CHECK` is thus the mere
  existence + green run of that file. `GATE-REGRESSION` stays owned by the untouched
  `check_95`.

## Components / modules

- **`scripts/north-star/engine.py`** → the engine. Subcommands per D2; internal `_load(path)`
  (extract canonical ```json``` block + parse, raising → exit 2). stdlib-only. The single
  source of North Star determinism.
- **`scripts/amendment-gate.sh`** → rewired per D6: same CLI/exit/messages, engine calls
  instead of the embedded heredoc + `has_new_adr`.
- **`tests/check_82_north_star_engine.sh`** → fixtures exercising the 6 capabilities across
  the 17 engine-facing criteria + `DEP-FREE` (grep imports: stdlib only; no `package.json`/
  `node_modules`/pip manifest in the engine path) + `GATE-REUSE` (grep the gate: calls
  `engine.py`, no residual `_py`/`has_new_adr`). Sourced automatically by `run.sh`.
- **`tests/fixtures/…`** → north-star variants (valid, schema-invalid kinds, prose-only diff,
  threshold-only diff, reordered sets, malformed/no-block), objective strings, verdict-input
  JSON, added-file lists.

## Testability of criteria

- **Deterministic (19)** → all fixture-testable. `check_82` covers 18 (engine + reuse +
  dep-free + self-check); `GATE-REGRESSION` is covered by the pre-existing `check_95`.
  All go **RED** in `/contract` (engine file absent → its checks fail; gate still embeds its
  heredoc → `GATE-REUSE` fails).
- **Non-deterministic** → none. The engine has no semantic/LLM component; the only semantic
  work (scoring, mapping) stays in the `/align` skill and is out of 006's scope.

## Risks

- **Rewire regresses the gate.** → Mitigation: `check_95` is untouched and must pass before
  and after; run it as the acceptance guard for `GATE-REGRESSION`. Keep the gate's messages
  byte-for-byte.
- **`scope-reject` too conservative (misses real out-of-scope briefs).** → By design: the
  judge's scope-compliance dimension is the semantic backstop. Documented in `spec.md`.
- **`python3` absent at runtime.** → The gate already fails closed (`command -v python3`);
  the engine, being python3, simply will not run without it — acceptable, it is the declared
  baseline.
- **Overreach into `/align` rewiring.** → Explicitly deferred (spec Open questions); 006
  ships the engine + rewires only the gate.
