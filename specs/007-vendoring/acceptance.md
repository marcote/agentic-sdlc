# Acceptance — Vendoring the harness onto an existing repo

> Measurable acceptance criteria in BDD. EACH criterion IS the eval and the UAT step. The
> deterministic portion materialises as a test in `/contract`.
> Fully deterministic — exercised hermetically via `check_84_vendor.sh` against a temp target.
> No non-deterministic eval cases (vendoring is mechanical file classification).

## Criterion: DRYRUN-NOWRITE  (deterministic)
```gherkin
Given a temp target directory
When I run `scripts/vendor.sh <target>` without --apply
Then the target is left byte-for-byte unchanged (nothing written)
```

## Criterion: DRYRUN-PLAN  (deterministic)
```gherkin
Given a temp target with a package.json
When I run `scripts/vendor.sh <target>` (dry-run)
Then stdout lists KEEP / SEED / DROP entries, the detected stack + test command, and the
  provenance that would be stamped
```

## Criterion: KEEP-COPIED  (deterministic)
```gherkin
Given a temp target
When I run `scripts/vendor.sh --apply <target>`
Then the governance layer is present verbatim, including .claude/commands/align.md,
  scripts/north-star/engine.py, and memory/constitution/base/principles.md
```

## Criterion: KEEP-OVERWRITE  (deterministic)
```gherkin
Given a target already vendored, with a KEEP file locally modified
When I run `scripts/vendor.sh --apply <target>` again
Then the modified KEEP file is overwritten back to the snapshot (authoritative, idempotent)
```

## Criterion: DROP-ABSENT  (deterministic)
```gherkin
Given a temp target
When I run `scripts/vendor.sh --apply <target>`
Then none of specs/001-example, verification/reports/, README.md, or tests/ appears in the target
```

## Criterion: SEED-STUB  (deterministic)
```gherkin
Given a temp target with none of the SEED files
When I run `scripts/vendor.sh --apply <target>`
Then memory/north-star/north-star.md and memory/constitution/constitution.md are created as
  `extends: base` stubs, and CLAUDE.md is created as an adopter stub
```

## Criterion: SEED-NOCLOBBER  (deterministic)
```gherkin
Given a temp target that already contains a CLAUDE.md with its own content
When I run `scripts/vendor.sh --apply <target>`
Then the existing CLAUDE.md is unchanged, a CLAUDE.md.harness-new is written alongside, and it
  is reported as needing merge
```

## Criterion: STACK-DETECT  (deterministic)
```gherkin
Given a temp target with a pyproject.toml (and separately, one with no known manifest)
When I run `scripts/vendor.sh --apply <target>`
Then scripts/test.sh is seeded with `pytest` (and for the unknown stack, with an explicit
  `# TODO: set your test command`)
```

## Criterion: PROVENANCE  (deterministic)
```gherkin
Given a temp target
When I run `scripts/vendor.sh --apply <target>`
Then a .harness-provenance file is written containing a commit SHA (or "non-git source"), a
  date, and the list of .harness-new files
```

## Criterion: DEPFREE  (deterministic, invariant tied to deliverable)
```gherkin
Given scripts/vendor.sh exists
When I inspect it
Then it invokes only bash/coreutils + python3 (no npm/node/uv/pip toolchain) and introduces no
  installable manifest into the harness
```

## Criterion: HANDOFF  (deterministic)
```gherkin
Given docs/vendoring.md
When I read it
Then it documents the KEEP/SEED/DROP buckets, the stack plugs, and the post-vendor first step
  (/constitution → seed North Star → first feature)
```

## Criterion: SELF-CHECK  (deterministic)
```gherkin
Given tests/run.sh
When it runs
Then it includes check_84_vendor.sh exercising vendor.sh hermetically and the suite is green
```
