# Brief — Ground rules: a project cannot start below the quality bar

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Feature 013 made the workflow **ask** before deciding, and made every answer carry its price.
It did not make the workflow **ask about anything in particular**. A charter holding one pin
passes the `/plan` gate today, so a project can reach its first technical plan without ever
having decided how anything reaches it, what holds its state, where it runs, or what a green
test proves.

This feature adds the **ground rules**: a small, fixed set of aspects that every project must
have a recorded rationale for before implementation begins. Each ground rule is answered by a
pin, or explicitly declined as `n/a` **with a reason** — never by silence, and never by
omission. `/plan` gains a fourth verdict, `UNCOVERED`, for a charter that leaves one unanswered.

The distinction that makes this possible: **ground rules name questions, not answers.** *"How
does anything outside reach this?"* prescribes no technology; it only forbids not having
thought about it. That is what lets the harness become opinionated for the first time without
imposing a stack — an answer list would hit the North Star's `out_of_scope` predicate on
imposing a runtime; a question list does not.

## Why / motivation

013 closed the *mute assumption* only where a decision was already on the table. It has no
answer for the decision **nobody raised at all** — which is the more common failure, and the
one that produces a project with no quality floor rather than a project with a wrong pin.

The gap is demonstrable, not theoretical: a charter containing only `S0` validates clean, and
`/plan` proceeds (`scripts/stack/engine.py pin-valid` → exit 0). Nothing in the harness asserts
that the charter *covers* anything.

Every one of the load-bearing surprises that motivated 013 maps to a question that was simply
never asked — a datastore chosen without asking how many processes write, an interface fused to
stdout without asking who else consumes it, a deploy target decided last. Recording the answer
well (013) does not help when the question never came up.

This also completes the request 013 was built from. The original ask was for the harness to be
*more opinionated* — to enforce API-first, or a particular toolchain. That form of it was
correctly rejected: naming tools in `base/` imposes a stack. Naming the **aspects that must
have a rationale** does not, and it delivers the same protection: a project cannot quietly
start below the bar.

## Success metrics

- **Exactly six ground rules ship in `memory/stack/base/`**, universal and vendored: consumption
  shape; persistence and concurrency; deployment and topology; language, runtime and execution;
  what "verified" means; failure posture. **Six is a hard cap** — a seventh may only enter by
  removing one, or in two years this is a thirty-question wizard.
- **Each ground rule names a question and no answer.** No tool, language, runtime or vendor is
  named as a default, so `no-prescribe.sh` stays green and the intake gate keeps scoring
  in-scope.
- **Every ground rule resolves to a pin or to `n/a` with a stated reason.** An unanswered ground
  rule is a distinct, reportable state — not the same as a declined one, and not silence.
- **The engine reports coverage per ground rule** — `axis → pin id | n/a + reason | uncovered`
  — so the bar is mechanically checkable rather than a matter of judgment.
- **`/plan` emits `UNCOVERED`** and refuses to proceed while any ground rule lacks a verdict,
  joining `PASS` / `UNPINNED` / `TRIPPED` as a fourth outcome that is never silence.
- **`/stack` walks all six explicitly** during elicitation, so the default path produces a
  covered charter rather than one that later trips the gate.
- **Ground rules do not scale with `S0`.** This is the second floor alongside `P6`: `S0` scales
  how deep each answer goes and how many pins exist beyond the floor — never whether a ground
  rule is answered at all. A disposable script may answer four of six with `n/a`, and those
  four reasons are written down.
- **A project may add ground rules, never remove one.** Same inheritance idiom as
  `constitution.md` extending `base`. The escape hatch is `n/a` with a reason, which is
  auditable; removal would not be.
- **The harness's own charter is brought to full coverage** (D3 reflexive dogfood): all six
  resolved for this repository, with `n/a` used honestly where a rule genuinely does not apply.
- **Dependency-free and non-blocking**: no new runtime dependency; the gate is a workflow step
  like `/distill`'s `MEAS-GATE`, never a commit hook.

## Out of scope

- **Prescribing any answer.** No default datastore, toolchain, deploy target or interface style
  anywhere in `base/`. The ground rules are questions; the answers are the adopter's, per
  project.
- **A seventh ground rule.** The cap is a feature, not a limitation. Growth pressure is the
  failure mode this design is guarding against.
- **A portable profile of personal defaults.** Considered and **rejected on evidence**, not
  deferred: a profile that lives outside the repository is invisible to CI, to teammates and to
  a fresh clone, which breaks Principle 5 (auditable trail); and a profile that lives inside the
  repository is simply the charter. Scope, stack and constraints differ per project — what must
  be constant is the *bar*, not the answers. That is this feature.
- **Cross-project seeding of a charter** (e.g. copying pins from another repository). A
  convenience, not a correctness problem, and separable. Not now.
- **Re-verifying features 001–013 against the ground rules.** Closed features are not reopened;
  the floor applies from this feature forward.

## Dependency

Depends on **013 (stack charter)**: ground rules resolve to pins, are reported by
`scripts/stack/engine.py`, and are enforced by the `/plan` gate — all delivered by 013. This
feature adds the floor those mechanisms had no way to express.

It is also the first feature to pass through 013's `/plan` gate for real. Its own charter starts
below the new bar, so it should draw a genuine `UNCOVERED`. That closes the `pending-observation`
left open by 013's retro, whose re-check trigger was exactly a real gate verdict against a
pre-existing pin.
