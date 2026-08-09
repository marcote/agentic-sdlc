---
extends: base
---

# Stack Charter — Agentic SDLC Harness

> The load-bearing technical decisions of **this repository**, each recorded with its price and
> its own invalidation condition. Grammar and rules: `base/pin-template.md`, `base/README.md`.
> Seeded by `/stack` (feature 013) with the decisions already live at that point — recording a
> decision that already governs the repo, not retrofitting specs onto closed features.
>
> **Adopters:** replace this file with your own. `base/` is the mechanism and travels with the
> harness; the pins below are ours and do not.

<!-- generated: python3 scripts/stack/engine.py exposure memory/stack/stack.md -->
5 pins · 4 PINNED · 1 PROVISIONAL
Exposure: S2 Reference deterministic engines written in python3

---

### S0 — Rigor tier: high                                          [substrate]
- Confidence: PINNED
- Because:    blast-radius answers — it does **not** run only on the author's machine (it is
              vendored into other people's repositories); it is used by people other than the
              author; it lands in repos that hold secrets and ships the hook that scans for
              them; and applying it writes into someone else's tree, so a bad run is not
              simply re-runnable.
- Buys:       full elicitation depth, full criteria expansion, and no argument about whether a
              given feature "deserves" the discipline.
- Forecloses: quick-and-dirty throughput on this repo — every feature pays the whole loop,
              including features that feel too small for it.
- Falsifier:  the harness stops being consumed by anyone other than the author, or stops
              writing into other people's repositories.

### S1 — Impose no runtime: the harness ships mechanism, never opinions   [stance]
- Confidence: PINNED
- Because:    the North Star names "imposing or naming a mandatory execution runtime" as an
              out-of-scope predicate, and `agnostic-portability` is measured by the contract
              surviving a vendoring onto an arbitrary repo and stack.
- Buys:       an adopter's own technical opinions become enforceable checks without inheriting
              ours; the intake gate keeps scoring in-scope.
- Forecloses: shipping ready-made guards for common stances, which would be immediately useful
              and immediately a prescription.
- Falsifier:  a deliberate, ADR-backed decision that the harness targets one ecosystem.
- Guard:      bash scripts/guards/no-prescribe.sh
- Injects:    [given] no artifact under `memory/stack/base/` names a tool, language, runtime or
              vendor as a default in prose; concrete names appear only inside fenced examples.

### S2 — Reference deterministic engines written in python3         [substrate]
- Confidence: PROVISIONAL — the hosting is a convenience, not a commitment
- Because:    the gates need deterministic aggregation somewhere, and a stdlib-only interpreter
              is present on every platform the harness already targets. Feature 006 took this
              decision for the North Star engine; 013 follows it for the charter engine.
- Buys:       gates that actually execute out of the box instead of a contract nobody has
              implemented yet — the batteries-included posture that made 006 worth shipping.
- Forecloses: a genuinely interpreter-free harness; an adopter on a platform without that
              interpreter must reimplement before the gates run at all.
- Falsifier:  the reference engines start being read as a *requirement* rather than a
              convenience — e.g. an adopter reports the harness "needs" this interpreter, or
              the intake gate scores the hosting against the out-of-scope runtime predicate.
- Hedge:      every engine is reachable only through a documented shell-level CLI contract
              (subcommands, exit codes, stdout payload) with no importable API, so a
              reimplementation in another stack is drop-in and no caller has to change. This
              costs nothing today — it is already how both engines are invoked.

### S3 — Dependency-free baseline: shell + coreutils                [substrate]
- Confidence: PINNED
- Because:    "runtime dependencies or frameworks" is an out-of-scope predicate in the North
              Star, and every adoption path so far (vendoring, bootstrap, the test suite) has
              been reachable with what a developer machine already has.
- Buys:       adoption with nothing to install, and a suite that runs anywhere the harness can
              be cloned.
- Forecloses: any dependency that would need a manifest, a lockfile or an install step —
              including ones that would make the checks considerably shorter to write.
- Falsifier:  a gate that cannot be expressed within this baseline without becoming
              unmaintainable, established by attempting it rather than by predicting it.

### S4 — Charter format: one line-oriented markdown file            [substrate]
- Confidence: PINNED
- Because:    the charter has three readers that must all work without tooling — a
              shell-level engine, the gates, and a human editing it by hand in a review diff.
              Minted by the `UNPINNED` verdict on feature 013's own plan (decision D1), which
              is the first run of the accretion loop.
- Buys:       greppable within the S3 baseline, diffable in review, editable with no parser
              and no schema step.
- Forecloses: nested or typed pin values — a field is a string, so anything structured has to
              be flattened into prose.
- Falsifier:  a field genuinely needs structure that flattening destroys — e.g. a `Guard` that
              must be an argument vector rather than a single shell string.
