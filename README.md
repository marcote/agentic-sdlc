# Agentic SDLC Harness

Agnostic template (Claude Code first) for disciplined agentic development, with
verification as north star.

> **Based on Google's work.** This harness is a practical implementation of the ideas in
> Google's whitepaper **_"The New SDLC With Vibe Coding — From ad-hoc prompting
> to Agentic Engineering"_** (Addy Osmani, Shubham Saboo, and Sokratis Kartakis, May 2026):
> the *factory model*, *context engineering* (static vs dynamic), the equation
> `Agent = Model + Harness`, *output + trajectory* evals, and the *80% problem*. The
> **constitution** concept comes from **Spec Kit** (GitHub / Microsoft). See
> [Credits and references](#credits-and-references).

## Install (from zero)
Land the harness on a repo starting from scratch, in one command:

```sh
curl -fsSL https://raw.githubusercontent.com/marcote/agentic-sdlc/main/bootstrap.sh | bash
```

`bootstrap.sh` fetches the harness, prints the vendoring **plan** (KEEP / SEED / DROP + your
detected stack + provenance), asks for confirmation on `/dev/tty`, then applies — preserving
`vendor.sh`'s dry-run-first safety. Nothing is written until you confirm. For CI / non-interactive
use, consent explicitly with `--yes`:

```sh
curl -fsSL https://raw.githubusercontent.com/marcote/agentic-sdlc/main/bootstrap.sh | bash -s -- --yes
```

With no terminal and no `--yes`, it aborts rather than writing blind. After it applies, merge any
`.harness-new` files, seed your North Star → `/stack` → first `/brief`. Already have
the harness cloned? Use `scripts/vendor.sh` directly (see `docs/vendoring.md`).

## The loop at a glance
Setup, once: seed your North Star → `/stack`.

`/brief` → `/spec` (gate H1, the owner approves) → `/build` → `/accept`

![The workflow](docs/figures/workflow.svg)

The owner approves once, at the spec page. Build and accept run as scripts without the owner,
except for escalations. Roles and CLIs live in `harness.toml`. See [docs/workflow.md](docs/workflow.md).

---

## Way of Work

The developer's primary output **is not code: it is the system that produces code**
(the *factory model*). You define the specs and guardrails; the agent implements; the
machine verifies. Four rules govern everything:

1. **Productivity first** — the inner loop never stops. Verification runs on demand, in `/accept`.
2. **Intent > syntax** — the artifact that matters is the spec: EARS requirements with examples.
3. **The constitution is code** — versioned, reviewed, inheritable. Add a rule every
   time the agent commits a repeatable mistake.
4. **Everything verifiable leaves a trail** — build and accept each write a report.

The harness **governs**; it does not name a mandatory agent CLI, model or product stack.
Any CLI with a headless JSON mode can fill a role in `harness.toml`. The judge's model family
must differ from the implementer's.

---

## Structure
- `CLAUDE.md` and `AGENTS.md` — static context (stack, hard rules, workflow).
- `harness.toml` — roles and CLIs. `harness/steps/` and `harness/prompts/` — the step and role instructions.
- `memory/constitution/` — non-negotiable principles (inheritable base + project).
- `memory/stack/` — the stack charter: load-bearing technical decisions, each pinned with its price.
- `memory/north-star/` — product governance (why it exists): `base/` + `north-star.md` +
  `decisions/` (amendment ADRs).
- `specs/_template/` — slice template (`brief.md`, `spec.md`).
- `scripts/` — `spec.py`, `build.py`, `accept.py`, `status.sh`.
- `.claude/` — the commands (`/brief`, `/spec`, `/build`, `/accept`, `/stack`).
- `docs/` — `workflow.md`, `factory-model.md`, `modules.md` and `backlog.md`.

## Starting a slice
1. `/brief` → `/spec` → `/build` → `/accept`.
2. `bash scripts/status.sh <slice>` shows which step the slice has reached.

## Inheriting the constitution in another project
`memory/constitution/base/` is a **vendored** shared asset: copy it to the new project.
The local `constitution.md` declares `extends: base` and adds its deltas. To update,
follow `memory/constitution/update-checklist.md` and re-copy `base/`.

## Verifying the harness
`uv run --python 3.12 --with pytest --with jsonschema pytest tests -q` and `bash tests/run.sh`.
Both run in CI on every pull request.

## Credits and references

This harness does not invent the methodology: it operationalizes it. Conceptual credit goes to:

- **Google — _"The New SDLC With Vibe Coding — From ad-hoc prompting to Agentic
  Engineering"_** (Addy Osmani, Shubham Saboo, Sokratis Kartakis; May 2026). Source of the
  *factory model*, *context engineering* (static/dynamic), `Agent = Model + Harness`,
  *harness engineering*, *output + trajectory* evals, the *conductor/orchestrator*, and the
  *80% problem*. All Way of Work vocabulary comes from here.
- **Spec Kit — GitHub / Microsoft.** The **constitution** concept (non-negotiables that
  govern the flow) and the `specify → plan → tasks` pipeline.

Internal documents in this repo:

- Design (rationale): `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`
- Implementation plan: `docs/superpowers/plans/2026-07-02-agentic-sdlc-harness.md`
- Flow detail: `docs/workflow.md` · Factory model: `docs/factory-model.md`
