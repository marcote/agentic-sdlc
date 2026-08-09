# Spec — The meta-check: an assertion must be able to fail, and be seen doing it

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverable

`tests/check_96_non_vacuous.sh` — one more file picked up by `tests/run.sh`'s existing
`check_*.sh` glob. No new command, no new dependency, bash + coreutils (`S3`).

## Mechanism (three grilling decisions, resolved)

### D-a — Detection is at **runtime**, not by static branch pairing

Declared labels are parsed statically; whether each one *emitted* is read from the **actual run
output**. This implements the brief's wording literally ("every criterion label declared in a check
file emits a result in the run") and dissolves the helper-delegation problem for free: at runtime
`assert_dep_free FILE LABEL` emits through `lib.sh`, which already prefixes the label.

*Measured before choosing.* Naive static pairing over the standing suite produced **one true
positive and one false positive** — it flagged `DEPFREE` in `check_86`, whose pass branch is
correct but delegated to a helper. A rule with a 50% false-positive rate on a known-good suite is
the 112-false-positive trap in miniature.

### D-b — Self-scanning is constrained by a **verifiable convention**, not a heuristic

A check whose scan target **can include the scanning file itself** must build the forbidden
pattern in a runtime-assembled variable rather than passing an inline literal, and must declare a
self-test criterion proving the check is not matching itself.

*The convention already exists in the codebase.* `check_92` and `check_94` assemble `$_NET_PAT`,
`$_AMB_PAT`, `$_NET94`, `$_AMB94` at runtime — the fixes 013 and 014 arrived at independently —
and `DROP-SELF` in `check_84` is an existing self-test label. This feature names the practice and
enforces it; it does not invent it.

**The trigger is the target set, not the mere presence of a scan.** `check_92` and `check_94`
target the `tests/check_*` glob, which contains them, so they must comply — and they already do.
`check_86`'s `HELPER-SHARED` greps a **closed, explicitly named** set (`tests/lib.sh` and
`check_82`/`84`/`95`) that cannot include `check_86`, so the rule does not fire on it. Measured:
zero false positives on the standing suite.

### D-c — Scope is the **labelled** criteria only

The rule governs the **61** criteria that declare a label. The **127** bare
`assert_file`/`assert_contains` calls are supporting assertions, not coverage criteria; demanding
identity from them is the retrofit the brief puts out of scope, and it is precisely where the 112
false positives came from. A coverage row covered only by anonymous assertions stays invisible to
this check — stated as a limitation, not papered over.

## Requirements

### R1 — Declaration parsing
A criterion label is `[A-Z][A-Z0-9-]*` declared in either form, unioned:
- a section header `# --- LABEL: …`
- an emitting call `_pass "LABEL: …"` / `_fail "LABEL: …"`

Heredoc bodies are excluded: fixtures in this suite write check-shaped text, and parsing that text
as declarations would manufacture phantom criteria.

### R2 — Emission verification
The suite is executed and its output captured. Every declared label must appear in that output as
`PASS: LABEL:`, `FAIL: LABEL:` or `SKIP: LABEL:`.

### R3 — Explicit skip
A criterion that legitimately does not execute in this environment emits `SKIP: LABEL: <reason>`.
**Silence is never a valid outcome** — the same doctrine as `/plan`'s "exactly one verdict, never
silence". `lib.sh` gains `_skip()`.

### R4 — Section-scoped traceability  *(corrected at implementation — see below)*
A criterion's result must appear in **its own file's section** of the run log, not merely somewhere
in it. `run.sh` prints `== tests/check_XX.sh ==` before each file, so `(file, label)` attribution
already exists and is what makes a result actually traceable.

A label declared **twice inside the same file** stays a violation: sections cannot disambiguate
that one.

> **Spec correction, made at implementation and recorded rather than silently applied.** R4
> originally demanded **global** label uniqueness. Run against the standing, green suite it fired
> **four times** — `HERMETIC-ENV` (check_92, check_94), `SELF-CHECK` (five files), `DEP-FREE` and
> `DEPFREE`. Those are not defects: an inherited `[given]` criterion is *supposed* to recur across
> the features that carry it, and that is the constitution's injection mechanism working. A rule
> that is wrong on a known-good suite is the one that gets disabled, which this feature's own
> `alignment.md` scored as a commitment. Section-scoping is strictly stronger — it catches a result
> emitted under the wrong file, which global uniqueness never could — and it has zero false
> positives here.

### R5 — Recursion guard, and self-subjection (`D4`)
The inner run is spawned with a guard variable. In the inner run the meta-check **skips only the
spawn step**; every other assertion it owns runs normally, so its own labels appear in the captured
output and it is judged by its own rule. Per `D4` the exemption is from being *blocked*, never from
being *run*.

### R6 — Fail closed on an unusable run
If the inner run produces no output, or is red for an unrelated reason, the meta-check reports
**that**, names what it executed, and emits **no** traceability verdict. A missing label cannot be
distinguished from an aborted check, and reporting one as the other is the confident-false-verdict
shape (`S8`; `check-names-its-tree`).

### R7 — Self-scan rule
For each check whose scan target can include itself: the pattern is a runtime-assembled variable,
and a self-test criterion is declared. Inline literal against a self-including target → rejected,
naming the file and the literal.

### R8 — Fix what it flags
`check_82`'s `DEP-FREE` calls `assert_dep_free "$ENG"` with **no label**, so its result cannot be
tied to the criterion. Found by this feature's own scan, in a feature closed on 2026-07-05, green
the whole time. Fixed here.

### R9 — Stated scope split
The shipped file states which shapes it enforces and which remain with review. A check implying
full coverage would repeat this feature's failure mode one level up.

## Edge cases (`/distill` expansion — 8)

1. **Recursion.** Spawning the suite from inside the suite. → R5.
2. **Helper-delegated results.** `DEPFREE` passes correctly through `assert_dep_free`. → D-a.
3. **Legitimate non-execution.** A criterion gated on a missing deliverable, or `hermetic-offline`
   where there is no network. Silence would be indistinguishable from the defect. → R3.
4. **Heredoc fixtures.** This suite writes check-shaped text into temp files. → R1.
5. **Duplicate labels across files.** → R4.
6. **Red inner run.** Labels missing because a check aborted, not because they are untraceable.
   → R6.
7. **Closed-target scanners.** `check_86` greps named files that exclude itself; firing on it would
   be a false positive. → D-b.
8. **The meta-check's own labels.** It must be traceable by its own rule, which R5's partial guard
   is what makes possible. → R5.

## Non-goals

Semantic vacuity; amending the constitution pattern; retrofitting features 001–014 beyond what the
check flags; scoring; enforcement on an adopter's suite (`tests/` is DROP).

## Known limitation, stated deliberately

**An undeclared criterion is invisible.** The check verifies that everything *declared* emits; it
cannot know about a criterion nobody wrote down. Cross-referencing `coverage.md` rows against
emissions would close that, and was considered and deferred at grilling: coverage ids across ten
features follow no single convention, so it would start noisy — and a check that cries wolf on a
known-good suite gets disabled, which is worse than absent because the row still reads green.
Recorded in `docs/backlog.md`, not silently dropped.
