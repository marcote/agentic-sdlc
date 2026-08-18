# Matrix fixtures

`baseline-coverage.txt` was captured from `main` at `1d506c2`, **before** 026 existed and before any
line of the shared reader was written. It is the per-feature output of
`scripts/mutate.sh coverage --tests tests --all` for the 19 matrices that existed then.

It is stored rather than re-derived on purpose. 026's declared success is that **no number moves**,
and a refactor that re-derives its own baseline from the new code and reports agreement has proved
nothing. The totals necessarily change — 026 adds its own matrix — so the invariant is per-file, for
files that predate it.
