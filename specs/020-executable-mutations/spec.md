# Spec — A criterion declares the mutation that makes it fail, and the suite runs it

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `scripts/mutate.sh` — parses declarations, applies each in a sandbox, requires the named
  criterion to fail. Dependency-free.
- `tests/check_99_mutations.sh` — the runner's contract, including its own negative.
- `tests/fixtures/mutations/` — the two historical vacuous criteria, replayed verbatim.
- `memory/constitution/base/patterns/non-vacuous-checks.md` — `check-can-fail` gains its executable
  form, the way `[deriv:]` gained `[deriv$ … $]`.

## Measured during the grilling, before the design was chosen

| What | Cost |
|---|---|
| sandbox from the working tree (`git ls-files` → tar, 287 files) | **0.15s** |
| one check file in isolation | **0.84s** (`check_98`) — **3.53s** (`check_80`) |
| the whole suite | **24.68s** |

A mutation that re-ran the suite would cost 25s each. One that re-runs the owning check file costs
about a second. `B7` already tracks the one nested run this repository has.

## Resolved at grilling (5)

### G-a — The grammar is `[mut$ <command> $]`, in a comment line under the criterion header

017's precedent, and its terminator for the same reason: a real command contains `]`.

```bash
# --- NS-PREDICATE-REACHABLE: every predicate is short enough to fire, and does fire ---
# --- [mut$ python3 - <<'M'\n…rewrite a predicate as 18 words…\nM $] ---
```

It binds to the **criterion header immediately above**. Not to a label written inside the
declaration: a label repeated in two places drifts, and then the runner proves a criterion that is
no longer there.

### G-b — One sandbox per mutation, built from the working tree

`git ls-files -z | tar` — tracked files only, no `.git`, and the **working tree** rather than
`HEAD`, so a mutation is proved against the code being written rather than the code last committed.

Reverting in place was rejected. `git checkout` cannot restore an untracked file, which is how two
fixture harnesses leaked state on 2026-08-09.

### G-c — Only the owning check file re-runs

Measured above: 24.68s against about a second. **Stated limitation:** a mutation whose effect
surfaces only in a *different* check file is not detected. That is also the better discipline — a
criterion that can only be broken from outside its own file is not testing what it claims.

### G-d — Only the named criterion is required to fail

Other criteria failing under the same mutation is normal and is reported, not treated as an error.
018's M2 broke eight at once.

### G-e — Declaring a mutation is **opt-in**, and this is the feature's honest limit

Hundreds of criteria exist. This ships the mechanism and applies it to a named set: **every
criterion this feature ships, plus the two historical replays.**

**So this does not yet prevent the sixth vacuous assertion.** It makes the proving repeatable and
auditable instead of a sentence in a report. Prevention needs a rule about *who must declare*, and
two candidate triggers are written into `docs/backlog.md` rather than guessed at here.

Saying this plainly is the point. A feature that shipped an opt-in capability and claimed the
family was closed would be the sixth instance, one level up.

## Requirements

### R1 — The grammar parses, and a malformed declaration is rejected by name
A declaration with no closing `$]`, or one bound to no criterion header, is reported with its file
and line. Silently skipping it would report zero mutations on a file full of them.

### R2 — Each mutation runs in its own sandbox, against the owning check file
Applied, run, discarded. The real working tree is proved byte-identical afterwards.

### R3 — The named criterion must emit `FAIL`
If it emits `PASS`, or emits nothing at all, the runner reports the criterion **and** the mutation
that failed to break it. Emitting nothing is the worse case and must not be read as failing.

### R4 — The runner has its own negative
A fixture criterion whose declared mutation provably does **not** break it is reported. A runner
that reports every criterion as failable while never applying a mutation is the family this feature
exists to catch, one level up.

### R5 — The two real instances are replayed verbatim
018's `ADOPT-REL-RESOLUTION` and 019's `NS-PREDICATE-REACHABLE`, in the form actually shipped, not
edited to be easier to catch. If the mechanism misses what really happened, it does not work.

### R6 — The cost is reported per mutation and in total
Under ADR `0004` a mandatory cost must carry a justification proportional to what it prevents.
A runner that hides its own cost cannot be judged against that.

### R7 — This feature's own criteria are subject to it (`D4`)
Every criterion in `check_99` declares a mutation and passes under it, before close.

## Edge cases (`/distill` expansion — 9)

1. **A mutation breaks the check file's syntax**, so nothing runs and no label emits. → R3: absent
   is not failed.
2. **A mutation breaks a *different* criterion but not its own.** → R3, reported by name.
3. **A criterion emits from a loop and appears twice.** The runner requires *no* `PASS` for the
   label, rather than *some* `FAIL`.
4. **A declaration bound to no criterion header** (first line of a file, or after a blank). → R1.
5. **A mutation that creates a file** rather than editing one. Sandboxed, so the discard handles
   it; in-place revert would not. → G-b.
6. **The check file under mutation is `check_96`**, which re-runs the whole suite. Cost jumps from
   ~1s to ~25s. Reported by R6 rather than hidden.
7. **A mutation with a heredoc, which the parser must not truncate at the first `$]`.** The
   terminator is scanned outside quoting the same way `nvc.sh` strips heredocs today.
8. **The runner is run twice concurrently.** Separate `mktemp -d` per invocation; no shared path.
9. **A declared mutation whose command fails to apply** (bad path, non-zero exit). Distinct from
   "applied but did not break it", and reported as its own diagnostic.

## Non-goals

Retrofitting every criterion; generating mutations; static dataflow detection; replacing the
`/verify` exploration; `check-traceable` and `check-no-self-match`, already discharged by
`check_96`.
