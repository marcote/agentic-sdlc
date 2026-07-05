# Design: English Migration

**Date:** 2026-07-05
**Branch:** `005-english-migration`

## Summary

Migrate all repo content from Spanish to English. All artifacts (docs, specs, skills,
commands, memory, scripts, CI configs) go to the repo in English. The developer may
interact with the agent in any language; the agent writes to the repo in English
regardless. This rule is codified as constitution delta D2.

## Scope

All `.md`, `.sh` (comments), and `.yml` (comments) files in the repo. The canonical
North Star JSON block is fully translated — prose and pillar IDs.

**Mostly in English:** `tests/lib.sh`, `tests/check_*.sh`, `tests/run.sh` — logic is
already in English; any Spanish comments need translating. Covered in commit 2.

## Constitution change

New delta **D2 — Language** in `memory/constitution/constitution.md`:

> All repo artifacts are written in English: docs, specs, skills, commands, memory,
> scripts, CI configs. The developer may interact with the agent in any language; the
> agent writes to the repo in English regardless.

## Pillar ID rename (ADR required)

Changing North Star pillar IDs is a governed event. The rename is cosmetic — semantics
are unchanged.

| Current (ES) | New (EN) |
|---|---|
| `enforcement-real` | `real-enforcement` |
| `portabilidad-agnostica` | `agnostic-portability` |
| `adopcion-sin-friccion` | `frictionless-adoption` |
| `impacto-medible` | `measurable-impact` |

ADR: `memory/north-star/decisions/0003-english-migration.md`

## Commit sequence

All work on branch `005-english-migration`, merged to `main` via PR.

| # | Commit message | Files |
|---|---|---|
| 1 | `chore(north-star): ADR 0003 + migrate pillar IDs to English` | `decisions/0003-english-migration.md`, `north-star.md` |
| 2 | `chore(governance): migrate docs and memory to English` | `README.md`, `CLAUDE.md`, `docs/`, `memory/constitution/`, `memory/north-star/base/`, `evals/`, `verification/*.md`, `.github/workflows/`, `scripts/`, `tests/` comments |
| 3 | `chore(tooling): migrate skills, commands, and templates to English` | `.claude/skills/`, `.claude/commands/`, `specs/_template/` |
| 4 | `chore(specs): migrate completed specs and reports to English` | `specs/001–004/`, `verification/reports/` |
| 5 | `chore(constitution): add D2 language rule` | `memory/constitution/constitution.md` |

Commit 5 goes last: the rule applies to future writing, so it is added after the repo is
already in English.

## Amendment-gate behavior

Commit 1 changes `pillars[].id` in the canonical JSON block. The amendment-gate CI check
requires: a new ADR file present in the branch + schema-valid JSON + green suite. The ADR
and the `north-star.md` change land in the same commit so the gate passes on the PR.
