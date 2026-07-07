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
`.claude/{commands,skills,hooks,settings.json}`, `memory/constitution/base` +
`update-checklist.md`, `memory/north-star/base`, `specs/_template`, `evals/rubric.md`,
the `verification/*` checklists, `docs/{factory-model,workflow}.md`, the North Star
engine `scripts/north-star/engine.py`, `scripts/amendment-gate.sh` +
`scripts/setup-branch-protection.sh`, and `.github/workflows/amendment-gate.yml`.

### SEED — customizable layer, stub if absent, **never clobbered**
Yours to fill; if the file already exists, vendoring writes `<file>.harness-new` beside it
and reports it for manual merge — it never overwrites your file:
`CLAUDE.md`, `memory/constitution/constitution.md` (`extends: base`),
`memory/north-star/north-star.md` (`extends: base`), and `scripts/test.sh`.

### DROP — harness-self content, never copied
The harness's own product content, which you do not want:
`specs/0*-*` (except `_template`), `memory/north-star/decisions/*`,
`verification/reports/*`, `verification/wow-report.md`, `docs/superpowers/*`,
`evals/cases/*`, `README.md`, `tests/` (harness self-validation — your runtime is
`scripts/test.sh`), and the vendoring tooling itself (`scripts/vendor.sh`, `docs/vendoring.md`).

## Stack plugs (what vendoring cannot fill for you)

Vendoring lands the governance layer and detects what it can, but two things are your
execution-runtime and stay yours:

- **`scripts/test.sh`** — vendoring detects your stack (`package.json`→`npm test`,
  `pyproject.toml`→`pytest`, `go.mod`→`go test ./...`, `Cargo.toml`→`cargo test`) and seeds a
  default; **unknown stack → an explicit `TODO`**. This is the one command `/contract` and
  `/verify` run.
- **The eval-runner** — the non-deterministic eval cases are left to your stack
  (`evals/README.md`); the rubric (`evals/rubric.md`) is copied as the contract.

`.harness-provenance` (written at `--apply`) records the source commit, date, and the list of
`.harness-new` files that need merging.

## After vendoring — the first step

Vendoring ends where the workflow begins:

1. Merge any `*.harness-new` files into your `CLAUDE.md` / constitution / North Star.
2. **`/constitution`** — seed your project constitution (deltas over `base`).
3. Replace the `memory/north-star/north-star.md` placeholder with your product's North Star,
   then it is ready for `/align`.
4. Start your first feature: `cp -r specs/_template specs/001-my-feature`, write `brief.md`,
   and run `/align` → `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` →
   `/uat` → `/retro`.
