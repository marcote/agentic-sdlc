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
10 pins · 8 PINNED · 2 PROVISIONAL
Exposure: S2 Reference deterministic engines written in python3, S9 Portability is proved by one worked adopter, not by a stack matrix

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

### S1 — Impose no answers: mechanism and a floor of questions, never answers   [stance]
- Confidence: PINNED
- Because:    the North Star names "imposing or naming a mandatory execution runtime" as an
              out-of-scope predicate, and `agnostic-portability` is measured by the contract
              surviving a vendoring onto an arbitrary repo and stack. *Wording sharpened by
              feature 014, which ships six mandatory ground rules: the original text said
              "never opinions", which no longer described the harness. Not marked SUPERSEDED —
              the decision did not change, it was under-specified. A required question is
              mechanism; a prescribed answer is an opinion. That line is the whole distinction
              this harness stands on.*
- Buys:       an adopter's own technical opinions become enforceable checks without inheriting
              ours; the intake gate keeps scoring in-scope.
- Forecloses: shipping ready-made guards for common stances, which would be immediately useful
              and immediately a prescription.
- Falsifier:  a deliberate, ADR-backed decision that the harness targets one ecosystem, or
              any artifact under `base/` stating an answer rather than a question.
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
- Answers:    GR4
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
- Answers:    GR4

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

### S5 — Delivery: vendored files executed in place                 [substrate]
- Confidence: PINNED
- Because:    answering GR1 and GR3 together, because vendoring settles both. The harness
              reaches its users by being **copied into their repository** (`vendor.sh`,
              `bootstrap.sh`) and runs there — on a developer machine and in that repo's CI.
              It is not installed, not hosted, and not a service; there is no instance count
              because there is no deployment, only as many copies as there are clones. The
              engines are reachable as shell commands and the skills are prose that calls
              them, so the core is separable from the way it is reached.
- Buys:       adoption with nothing to install; each repo owns its copy and can diverge; the
              engines stay usable without the agent.
- Forecloses: pushing an update to existing adopters — copy-once means they re-vendor
              deliberately or not at all; and any capability that would need a running
              process.
- Falsifier:  a capability that cannot work as files-in-a-repo — anything needing a daemon,
              a registry, or cross-repo state at runtime.
- Answers:    GR1, GR3

### S6 — State lives in versioned markdown; git is the concurrency control  [substrate]
- Confidence: PINNED
- Because:    answering GR2. Every artifact the workflow reads or writes — charter, coverage,
              specs, reports, retros — is a markdown file in the repository. There is no
              database, no state file and no lock: the writer is one developer-plus-agent at a
              time, and concurrent edits are resolved by git the way any other file conflict is.
- Buys:       every state change is reviewable in a diff and recoverable from history, which is
              what makes Principle 5 (auditable trail) hold without extra machinery.
- Forecloses: any workflow step needing atomic multi-file transactions or safe simultaneous
              writers; and querying state without parsing files.
- Falsifier:  two agents writing the same feature's artifacts concurrently as a normal mode of
              work rather than an accident.
- Answers:    GR2

### S7 — Green proves this repository's harness, never an adopting project's product   [substrate]
- Confidence: PINNED
- Because:    answering GR5. `tests/run.sh` exercises this repository's **own** governance
              artifacts — that files and contracts exist, that the engines behave on fixtures,
              that gates block what they claim to block. *Wording sharpened on 2026-08-09: the
              title read "never a product", which contradicted its own body. The harness IS this
              repository's product, so an absolute reading made every check here a violation. Not
              marked SUPERSEDED — the decision did not change, it was under-specified, the same
              correction S1 took in feature 014.*
- Buys:       a green that means **one** thing. Whatever else lands in this repository — a sample
              application, a fixture with real behaviour — its own suite stays separate, so a
              passing `tests/run.sh` never silently also claims that something else works.
- Forecloses: using this suite as evidence that any product works, including a sample shipped
              here. That evidence belongs to that product's own `scripts/test.sh`. Conflating them
              is the unstated-meaning failure GR5 exists to prevent.
- Falsifier:  a check in `tests/run.sh` starts asserting the behaviour of an application rather
              than of the harness's own machinery — so that green means two things at once.
              *The previous wording ("asserts something about product code rather than about the
              harness") could not discriminate, because the harness is product code.*
- Answers:    GR5

### S8 — Failure posture: fail closed, write nothing, never partially apply  [substrate]
- Confidence: PINNED
- Because:    answering GR6. Established by practice across 007, 009 and 013 and never written
              down until now: `vendor.sh` prints its plan before touching anything,
              `bootstrap.sh` aborts rather than applying blind without consent, and every gate
              refuses rather than continuing on missing input. Nothing retries, nothing
              half-applies, and nothing continues silently.
- Buys:       an aborted run leaves the target byte-for-byte unchanged, so the recovery from
              any failure is to re-run it.
- Forecloses: best-effort partial progress, and any long operation that would need resumption
              from a checkpoint.
- Falsifier:  an operation whose partial application is genuinely more useful than its refusal.
- Answers:    GR6

### S9 — Portability is proved by one worked adopter, not by a stack matrix   [substrate]
- Confidence: PROVISIONAL — one example, chosen for what it costs rather than for what it covers
- Because:    `agnostic-portability` is measured by the contract surviving a vendoring onto an
              arbitrary repo and stack. Until feature 018 that was tested by checking which files
              landed. Running the gates needs a target that exists, and a target costs authorship.
              Minted by the `UNPINNED` verdict on 018's own plan.
- Buys:       the real gates run against someone else's artifacts on every suite run, for the
              price of one small repository a reader can hold in their head.
- Forecloses: any blind spot specific to a stack the fixture does not use. A gate that breaks
              only on a project with no manifest, or with a compiled toolchain, stays invisible
              here — and the suite will look green while it does.
- Falsifier:  an adopter reports a gate failing on their stack in a way one fixture could not
              have shown; or a second fixture is added, which retires the "one" in this pin.
- Hedge:      the check reads the fixture's path, pin ids and guard commands **from the fixture
              itself**, never from constants written into the check. Adding a second target is
              then a data change rather than a rewrite.
