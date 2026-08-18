# Spec — Stale is not weak, and untracked is not broken

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `scripts/mutate.sh` — two new outcomes, `STALE` and a pre-flight refusal on untracked files.
- `tests/check_89_mutation_diagnostics.sh` — the contract, every criterion declaring its mutation.
- `memory/constitution/base/patterns/non-vacuous-checks.md` — the outcomes stated as the rule.

## The measurement

| feature | weak mutations, first run | of those, **stale** (matched nothing) |
|---|---|---|
| 022 | 5 | **4** |
| 023 | 3 | **1** |
| 026 | 9 | **7** |
| 022+023, orphaned by 026's refactor | 4 | **4** |

**16 of 21**, across four features, were declarations that edited nothing — reported as criteria
that survived. Plus `B17`: two features (020, 022) where every declaration in a new check file
reported `emitted no result` because the file was untracked.

## The outcomes, after

| outcome | meaning | not proved |
|---|---|---|
| `proved` | the criterion emitted FAIL and no PASS | — |
| `NOT PROVED … survived its own mutation` | the tree changed and the criterion still passed | yes |
| **`NOT PROVED … STALE: the edit changed no bytes`** | **the criterion was never tested** | **yes** |
| `NOT PROVED … emitted no result` | the criterion produced neither PASS nor FAIL | yes |
| `NOT PROVED … could not be applied` | the edit command itself failed | yes |

And before any of it: **untracked files under `--tests` are a refusal, not an outcome.**

## Detection

**Stale — by content, not by timestamp.** `sed -i.bak` rewrites its target and creates the backup
**even when nothing matches**, so mtime is useless. The sandbox is hashed before and after the edit,
excluding `*.bak`; identical hashes mean the edit did nothing. Measured at **0.018s** per hash over
364 files.

**Untracked — pre-flight, once.** `git ls-files --others --exclude-standard` over the tests
directory, before the first sandbox is built. Any hit exits 2 naming the files. This is `B17`'s own
proposal, and it is a refusal rather than a per-declaration outcome because the failure is not about
any one declaration — 020 and 022 each had *every* declaration in a file misreported.

## Requirements

### R1 — An edit that changes no bytes reports `STALE`
Named as such, with the edit, and distinct from `survived its own mutation`.

### R2 — `STALE` is not proved
Counted in `not proved` and exit 1. The verdict does not soften; only the diagnosis sharpens.

### R3 — Weak and stale are counted separately in the summary
`021` established that adding them together is how an audit becomes a rubber stamp.

### R4 — Untracked files under `--tests` refuse the run
Exit 2, before the first sandbox, naming each file.

### R5 — The stale replay is real
026's declaration in the form it shipped — `sed -i.bak 's|^_mx_crit=0$|_mx_crit=5|'
scripts/lib/matrix.sh` — against a fixture carrying the code as it was after the refactor. It must
report `STALE`, asserted by exact string.

### R6 — The added cost is measured against the 2% predicted
Reported, and if materially higher, said so.

## Edge cases (`/distill` expansion — 7)

1. **`sed -i.bak` on a no-match** rewrites the file and creates a backup. Content hashing, `*.bak`
   excluded. → Detection.
2. **An edit that deletes a `.bak` or creates one** must not read as a change. Same exclusion.
3. **An edit that changes bytes but proves nothing** — an unreachable line flipped. Still
   `survived its own mutation`; out of scope and stated.
4. **An edit that fails outright** (`sed` syntax error) already has its own outcome and keeps it.
   Stale is *successful and inert*, which is the harder case.
5. **A declaration whose target file does not exist.** `sed` errors → `could not be applied`. Not
   stale, and the two must not merge.
6. **An untracked file that is not under `--tests`** — a fixture elsewhere. The pre-flight covers
   the tests directory only, which is where 020's and 022's instances were; anything wider is a
   guess about what a declaration touches. Stated as a limit.
7. **Every declaration stale at once** — what a refactor produces. The summary must make that
   legible rather than printing 88 similar lines.

## Non-goals

Repairing a stale declaration; judging a byte-changing mutation's strength; tidying `.bak` files;
widening the pre-flight beyond `--tests`.
