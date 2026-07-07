# Acceptance — One-command bootstrap for from-zero adoption

> Measurable acceptance criteria in BDD. EACH criterion IS the eval and the UAT step. The
> deterministic portion materialises as a test in `/contract`.
> Fully deterministic and hermetic via `check_88_bootstrap.sh` — the network fetch is exercised
> against a **local checkout** through the `HARNESS_REPO` override (no real network in the suite).
> One `CONFIRM-TTY` criterion is UAT-only (a real terminal prompt cannot be faked hermetically).

## Criterion: FETCH  (deterministic)
```gherkin
Given HARNESS_REPO points at a local harness checkout and a temp target directory
When I run `bootstrap.sh --yes <target>`
Then it clones the harness (no pre-existing clone in the target) and lands the vendored tree,
  proving the fetch step ran without a manual `git clone`
```

## Criterion: PLAN-FIRST  (deterministic)
```gherkin
Given a temp target
When I run `bootstrap.sh --yes <target>`
Then stdout shows the vendor.sh plan (KEEP / SEED / DROP entries, detected stack, provenance)
  and no file is written to the target before that plan is printed
```

## Criterion: APPLY-YES  (deterministic)
```gherkin
Given a temp target
When I run `bootstrap.sh --yes <target>`
Then the target is identical to a direct `scripts/vendor.sh --apply <target>`: governance
  present (.claude/commands, scripts/north-star/engine.py), .harness-provenance stamped
```

## Criterion: NOTTY-ABORT  (deterministic)
```gherkin
Given a temp target and no controlling TTY (stdin not a terminal) and no --yes
When I run `bootstrap.sh <target>`
Then it aborts with a message, exits non-zero, and leaves the target byte-for-byte unchanged
```

## Criterion: CLEANUP  (deterministic)
```gherkin
Given a temp target
When I run `bootstrap.sh` both to completion (--yes) and to an abort (no-TTY)
Then the temporary harness clone it created is removed on both exit paths (no leftover temp dir)
```

## Criterion: GIT-REQUIRED  (deterministic)
```gherkin
Given `git` is not available on PATH
When I run `bootstrap.sh --yes <target>`
Then it aborts early with a clear "git required" message and writes nothing to the target
```

## Criterion: DROP-SELF  (deterministic)
```gherkin
Given a temp target
When I run `scripts/vendor.sh --apply <target>`
Then bootstrap.sh does not appear in the target (it is in vendor.sh's DROP list)
```

## Criterion: DEPFREE  (deterministic, invariant tied to deliverable)
```gherkin
Given bootstrap.sh exists
When I inspect it
Then it invokes only git + bash/coreutils (no npm/node/uv/pip toolchain) and adds no
  installable manifest to the harness
```

## Criterion: HANDOFF-DOC  (deterministic)
```gherkin
Given README.md and docs/vendoring.md
When I read them
Then the `curl -fsSL <raw>/bootstrap.sh | bash` one-liner is documented (with the `--yes`
  CI variant), and docs/vendoring.md cross-references the bootstrap as the from-zero entry
```

## Criterion: CONFIRM-TTY  (UAT — interactive, excluded from the /contract RED set)
```gherkin
Given a real terminal
When I run `bootstrap.sh <target>` interactively and the plan is shown
Then a `[y/N]` prompt reads from /dev/tty; `N`/empty aborts untouched, `y` applies
```

## Criterion: SELF-CHECK  (deterministic)
```gherkin
Given tests/run.sh
When it runs
Then it includes check_88_bootstrap.sh exercising bootstrap.sh hermetically and the suite is green
```
