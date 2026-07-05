# Brief — Vendoring the harness onto an existing repo

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Give an adopter a **repeatable, deterministic way to land this harness onto a repo
that already exists** — a **copy-once snapshot**, not a living link. The deliverable is
`docs/vendoring.md` + `scripts/vendor.sh`, which together: lay down the **governance
layer** verbatim, **strip the harness's own content** (its North Star, its dogfooding
specs, its reports), **seed the customizable layer without clobbering** what the target
already has, and **stamp provenance**. After it runs, the target goes from "empty of
harness" to "ready for its first `/constitution` → `/align`" with no manual reverse
engineering.

## Why / motivation

Adoption knowledge today is **scattered across the README** (Structure / "Inheriting the
constitution" / "Starting a feature") with **no single guide and no tooling**. The only
vendoring actually modeled is the `constitution/base/` copy. A dev adopting the harness
has to reverse-engineer what to keep, seed, or drop — and must manually avoid copying the
harness's *own* `north-star.md`, `specs/001–004`, ADRs, and reports into their project.
That is error-prone, undocumented, and contradicts a harness that preaches
"everything verifiable leaves a trail". Vendoring makes adoption a first-class,
inspectable operation.

## Success metrics

- `scripts/vendor.sh <target>` in **dry-run (default)** prints the full plan —
  keep / seed / drop, file collisions, and the detected test command — **without writing
  anything**.
- `--apply` lands the **governance layer verbatim**: `.claude/commands`, `.claude/skills`,
  `.claude/hooks`, `constitution/base` + `update-checklist`, `north-star/base`,
  `specs/_template`, the verification checklists, `evals/rubric.md`, `docs/{workflow,
  factory-model}.md`, the `amendment-gate`, and the North Star engine (feature 006).
- **Harness-self content is never copied**: `specs/001–004`, `north-star/decisions/*`,
  `verification/reports/*`, `wow-report.md`, `docs/superpowers/*`, and the harness's own
  `north-star.md`.
- **Non-destructive seed**: existing target files (`CLAUDE.md`, the constitution project
  layer, `north-star.md`) are **never overwritten** — a `.harness-new` is written
  alongside and reported for manual merge.
- **Provenance stamped**: source repo + commit SHA + date + the list of seeded files that
  still need attention.
- **Stack detected** (`package.json` / `go.mod` / `pyproject.toml` / `Cargo.toml`) → a
  default test command is seeded; unknown stack → an explicit documented TODO (no wrong
  guess).
- The guide **hands off to the existing workflow**: the target's first real step after
  vendoring is `/constitution` → seed North Star → first feature. Vendoring ends where the
  loop begins.
- **Dependency-free**: bash/coreutils + `python3` stdlib, consistent with the rest of the
  harness (`amendment-gate.sh` already assumes this baseline).

## Out of scope

- **Update / sync path.** This is copy-once by decision — no base/project synchronization
  across the whole tree, no submodule/subtree. (The constitution's existing
  `update-checklist` covers its own base; nothing broader.)
- **The interactive `/adopt` skill.** Aspirational; a conversational vendoring that detects
  an existing `CLAUDE.md`, proposes merges, and seeds the North Star from context. Future
  feature, not this one.
- **Writing the adopter's runtime.** The eval-runner and the adopter's test suite are the
  execution-runtime layer (the adopter owns them); vendoring only marks the plug.
- **The North Star engine itself.** Built first as **feature 006**; vendoring only *copies*
  it as KEEP once it exists.

## Dependency

Depends on **feature 006 (North Star engine, python3 reference)**. Until 006 lands, the
engine is a *documented plug*; once it lands, it graduates to **KEEP** and `vendor.sh`
copies it verbatim. This is why 006 is sequenced first.
