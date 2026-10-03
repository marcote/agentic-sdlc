# Vendoring the harness onto an existing repo

A **copy-once** way to land this harness onto a repo that already exists. Not a live link:
you take a snapshot, and from then on it is yours. Run `scripts/vendor.sh`.

```sh
scripts/vendor.sh <target>          # dry-run: prints the plan, writes nothing (default)
scripts/vendor.sh --apply <target>  # applies the vendoring
```

Always dry-run first — it prints exactly what each path will become before touching the target.

> **Starting from zero?** You do not need to clone the harness by hand first. `bootstrap.sh`
> (repo root) is the from-zero entry point: `curl -fsSL <raw>/bootstrap.sh | bash` fetches the
> harness into a temp dir, runs the dry-run **plan** below, confirms, applies `vendor.sh`, and
> cleans up. `vendor.sh` (this guide) is the step `bootstrap.sh` wraps — use it directly once you
> already have a local checkout.

## The four buckets

`scripts/vendor.sh` is the single source of truth for this classification (arrays at the top).

### KEEP — governance, copied verbatim, **overwrites**
The layer you do not edit; re-running refreshes it (idempotent, authoritative):
`.claude/{commands,skills,hooks,settings.json}`, `AGENTS.md`, `harness/`,
`memory/constitution/base` + `update-checklist.md`, `memory/north-star/base`, `memory/stack/base`,
`specs/_template`, `docs/workflow.md`, `docs/figures`, the scripts `spec.py`, `build.py`, `accept.py`,
`fake_agent.py`, `status.sh`, `north-star/engine.py`, `stack/engine.py` and `guards/`.

### SEED — customizable layer, stub if absent, **never clobbered**
Yours to fill; if the file already exists, vendoring writes `<file>.harness-new` beside it
and reports it for manual merge — it never overwrites your file:
`CLAUDE.md`, `harness.toml`, `memory/constitution/constitution.md` (`extends: base`),
`memory/north-star/north-star.md` (`extends: base`), `memory/stack/stack.md`, `docs/modules.md`
and `scripts/test.sh`.

### DROP — harness-self content, never copied
The harness's own product content, which you do not want:
`specs/0*-*` (except `_template`), `memory/north-star/decisions`, `verification`,
`docs/superpowers`, `README.md`, `tests/` (harness self-validation — your runtime is
`scripts/test.sh`), `docs/backlog.md` (the harness's own parked findings), and the vendoring
tooling itself (`scripts/vendor.sh`, `docs/vendoring.md` and `bootstrap.sh`).

## Stack plug (what vendoring cannot fill for you)

**`scripts/test.sh`** — vendoring detects your stack (`package.json`→`npm test`,
`pyproject.toml`→`pytest`, `go.mod`→`go test ./...`, `Cargo.toml`→`cargo test`) and seeds a
default; **unknown stack → an explicit `TODO`**. This is the one command `/build` and
`/accept` run.

`.harness-provenance` (written at `--apply`) records the source commit, date, and the list of
`.harness-new` files that need merging.

## After vendoring — the first step

Vendoring ends where the workflow begins:

1. Merge any `*.harness-new` files into your `CLAUDE.md` / constitution / North Star.
2. Edit `memory/constitution/constitution.md` — your deltas over `base`.
3. Replace the `memory/north-star/north-star.md` placeholder with your product's North Star,
   then run `/stack`.
4. Start your first slice: `/brief` → `/spec` → `/build` → `/accept`.
