# Brief — Three readers of one matrix, and the one that is wrong reports confidently

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

`specs/*/coverage.md` is the traceability matrix and `CLAUDE.md` calls it *"the source of truth for
the state of each criterion"*. Three tools read it, each with its own parser:

| tool | how it locates the criterion column | on a six-column matrix |
|---|---|---|
| `scripts/status.sh` | `$5`, fixed | **reads the Origin column** |
| `scripts/mutate.sh coverage` | `$5`, fixed | reads Origin; excludes every row |
| `scripts/cases.sh` | by header name (023) | correct |

**This is not hypothetical. `status.sh` is misreporting today**, and has been since 008:

```
$ bash scripts/status.sh 001-example
coverage gaps:
  non-green: `[given] base/idempotency` (🔴 red)
```

The row it is describing is `| — (retries) | Repeatable save | idempotency by key |
\`[given] base/idempotency\` | \`idempotency.feature\` | 🔴 red |`. The criterion is
**`idempotency by key`**. The tool names the Origin cell instead, and prints it as a fact.

This gives the matrix one reader.

## Why / motivation

**A fixed-index reader of a markdown table does not fail — it reads the wrong column.** Split on the
pipe, a six-column row and a seven-column row yield the same field count. Nothing errors, nothing is
skipped, and the output is confidently wrong. That is `B11`'s family, and 023 measured a second
instance of it while building `cases.sh`.

**`B9` is the standing evidence for what happens next.** `status.sh` and `check_90` already disagreed
about whether a feature was DONE, and *the reassuring answer was the wrong one*. That was two readers
of one artifact. There are now three.

**`mutate.sh coverage` is safe by luck, not by design.** On `001-example` it reports `0 obliged,
6 excluded` — correct, because the cell it mistakes for Status is empty, so every row fails the
status test and drops out. Change the example's layout and the luck changes with it.

**`status.sh`'s status read is already layout-agnostic**, and that is the tell. It uses `$(NF-1)` —
position from the end — which is stable across both layouts, while the criterion uses `$5`. The same
file already contains both the right idea and the wrong one.

## Success metrics

- **One parser**, sourced by all three tools; no tool splits `coverage.md` on the pipe on its own.
- **`status.sh` names the right criterion on a six-column matrix**, which it does not today.
- **A matrix whose header cannot be understood is reported by every consumer**, never guessed at —
  the behaviour `cases.sh` already has, extended to the other two.
- **No verdict changes anywhere else.** The `--all` figures (205 obliged, 137 undeclared,
  0 unresolvable) and `cases.sh`'s (15 rows, 15 resolved) must be identical before and after, or the
  refactor changed meaning while claiming to change structure.
- **The suite stays green and hermetic**, and the added cost is measured.

## Out of scope

- **Changing what any tool decides.** This moves *how a row is located*, not what counts as obliged,
  green or resolvable.
- **Reformatting `001-example` to seven columns.** Making the outlier disappear is how the class of
  defect survives — the next adopter writes their own layout.
- **Vendoring the three tools.** Measured while scoping: `status.sh`, `mutate.sh` and `cases.sh`
  appear in **neither** `KEEP` nor `DROP` in `scripts/vendor.sh`, so an adopter neither receives them
  nor is told they were withheld. That is a real finding and a different one; it goes to the backlog.

## Dependency

`scripts/status.sh` (008), `scripts/mutate.sh coverage` (022), `scripts/cases.sh` (023), and the
`coverage.md` format. The shared-helper precedent is `tests/lib.sh`, whose `assert_dep_free` is used
by three checks and asserted by `HELPER-SHARED`.

**`D3` applies** — the tool governs this repository's own workflow. **`D4` does not:** this ships no
new gate, it unifies three existing readers.

**Stated in advance:** exactly one user-visible defect is fixed — `status.sh`'s criterion name. The
rest is a refactor whose success condition is that **nothing else moves**, and a refactor that
changes a number has failed even if the number looks better.
