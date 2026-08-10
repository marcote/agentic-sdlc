---
extends: base
---

# Stack Charter — Ledger

> The load-bearing technical decisions of this project. Written by running `/stack` after
> vendoring the harness. Grammar: `base/pin-template.md`.

### P1 — Python 3, standard library only                       [substrate]
- Confidence: PINNED
- Because:    this runs on machines we do not control, inside other people's pipelines, and a
              dependency would put an install step in front of every use.
- Buys:       one command runs it anywhere a Python 3 interpreter exists.
- Forecloses: any library that would make the parsing shorter or the errors nicer.
- Falsifier:  a requirement the standard library cannot serve without hand-rolling a parser.
- Guard:      bash scripts/guards/stdlib-only.sh
- Answers:    GR4

### P2 — One command: read stdin, write stdout, keep nothing   [stance]
- Confidence: PINNED
- Because:    every consumer so far is a shell pipeline, and the core has to stay separable
              from the way it is reached.
- Buys:       a second consumer is an adapter rather than a rewrite.
- Forecloses: a long-running process, and any progress reporting that is not just output.
- Falsifier:  a consumer needs to call this without spawning a process.
- Guard:      bash scripts/guards/nothing-persists.sh
- Injects:    [given] every capability is reachable from the documented command, and nothing
              it writes outlives the process
- Answers:    GR1

### GR2 — n/a
- Because:   a pure transformation; nothing outlives the process and nothing is written
- Falsifier: any output is retained between runs, including a cache

### GR3 — n/a
- Because:   runs on a developer machine, one process at a time, never deployed
- Falsifier: it is deployed anywhere, or a second instance runs

### P3 — Verified means the documented command's output is byte-exact   [substrate]
- Confidence: PROVISIONAL — one example set so far, so the meaning is narrower than it sounds
- Because:    the output is the whole contract; nothing else about a run is observable.
- Buys:       a failure names the exact byte that moved.
- Forecloses: changing the output format without rewriting every expectation.
- Falsifier:  a consumer depends on behaviour the output does not show.
- Hedge:      expectations live in one file, regenerable by one command, so a deliberate
              format change costs a regeneration rather than an edit per case.
- Answers:    GR5

### P4 — Fail closed: exit non-zero, print nothing partial     [substrate]
- Confidence: PINNED
- Because:    the output is consumed by other programs, which cannot tell a truncated result
              from a complete one.
- Buys:       a caller can trust that output exists only when it is complete.
- Forecloses: streaming or progressive results.
- Falsifier:  a consumer needs partial output more than it needs a trustworthy one.
- Answers:    GR6
