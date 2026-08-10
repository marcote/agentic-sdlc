# WoW Report — generated 2026-08-09

Aggregates the retro ledger. **Observes, never gates** — the deterministic teeth are
`tests/check_90_retro.sh`. Input: all `specs/*/retro.md`, their `alignment.md`, and
`verification/reports/*`.

**N = 12 closed features** (004, 006, 007, 008, 009, 013, 014, 015, 016, 017, 018, plus 003 as
`n/a`). Small sample, no statistics. Per-feature and themes only; no trends are claimed.

> **Since the last generation (N was 7).** Five features closed: 015, 016, 017, 018 and the
> re-check of 012. The headline is in §3: **the harness found 18 real defects in features that
> were already closed and already green.**

---

## 1. Mission — is each pillar being served?

| Pillar | Features that claimed it | Signal moved | Drift |
|---|---|---|---|
| `real-enforcement` | 004, 006, 007, 008, 009, 013, 014, 015, 016, 017, 018 | **11 / 11** | none |
| `agnostic-portability` | 004, 006, 007, 009, 013, 014, 015, 016, 018 | **9 / 9** | none |
| `measurable-impact` | 004, 013, 014, 015, 016, 017, 018 | **3 / 7** · 4 `⏳` | **watch** |
| `frictionless-adoption` | 006, 007, 008, 009, 014 | **5 / 5**, and 013 recorded it moving the wrong way | none |

**`measurable-impact` is the pillar to watch, and it is the honest state rather than a failure.**
Four features left it `⏳ pending-observation`: 013, 014, 016 and 017. Each declared a trigger and
a sweep date instead of claiming a signal it could not evidence.

**018 is the first to close it `✅` on a prediction set in advance.** `alignment.md` fixed the
falsification test before the work — *does a gate behave differently on a foreign target, excluding
the known pin-id defect?* — and the answer was found at `/distill`.

## 2. Pending re-checks (worklist)

| Feature | What is being observed | Trigger | Sweep by | State |
|---|---|---|---|---|
| 013 | the charter preventing stack-decision rework | a feature's `/plan` trips a pin, or reworks a decision no pin covered | 2026-09-08 | **partially answered** — 018's `/plan` returned `UNPINNED` and minted `S9`, the second run of the accretion loop |
| 014 | ADR `0004`'s amended signal, and `UNCOVERED` stopping a later feature | (a) a mandatory step rejected for lacking a justification · (b) `UNCOVERED` stops a feature other than 014 | 2026-09-08 | open — (b) has now fired against a *foreign* charter in 018's suite, but not against a real feature of ours |
| 016 | the provenance stamp changing a verdict | a `pending-observation` closed against a pillar whose `since` moved | 2026-09-08 | open |
| 017 | an executable derivation going red on its own | a spec edited after close, or a wrong number in a future retro | 2026-09-08 | open |

**None overdue.** One sweep, four verdicts, on 2026-09-08.

**Worth flagging for that sweep:** 014's trigger (b) is now half-met in a way its author did not
foresee. `ADOPT-UNCOVERED-FIRES` shows `UNCOVERED` blocking on someone else's charter every time
the suite runs. That is the mechanism working, but it is not the same evidence as a real feature of
ours being stopped, and the sweep should not accept it as such.

## 3. Method — does the WoW add value? (N=12, small sample, no statistics)

| Feature | Gaps caught pre-implementation | RED discipline | Rework post-verify | Escalations |
|---|---|---|---|---|
| 004 | — | yes | 0 | — |
| 006 | 3 | yes | 0 | 0 |
| 007 | 3 | yes | 0 | 0 |
| 008 | 3 | yes | 0 | 0 |
| 009 | 1 | yes | 1 | 0 |
| 013 | 8 | yes | 0 | 9 |
| 014 | 10 | yes | 0 | 4 |
| 015 | 15 | yes | 0 | 3 |
| 016 | 12 | yes | 0 | 1 |
| 017 | 11 | yes | 0 | 0 |
| 018 | 16 | yes, 4 documented exceptions | 1 | 0 |

**The finding that matters: the harness's own tooling found 18 defects in closed, green features.**

| Found by | Count | Where they had been hiding |
|---|---|---|
| `nvc.sh` traceability (015) | 15 | untraceable criteria, nine of them in `check_95` since feature 004 |
| hand-vendoring onto a real repo (012, 018) | 2 | the pin-id parser, and the cwd-resolution defect |
| `check_90`'s verdict parser (017) | 1 | a missing colon that removed 017 from its own gate's scope |

Every one of those features was closed, green and retro'd. **Green did not mean correct; it meant
nothing had asked the question yet.**

### Recurring friction themes

**Semantic vacuity is the standing cost, and it is still unmechanised.** Four vacuous assertions
across 015, 016 (two) and 018, each caught by reading or by hand-mutation, none by `nvc.sh`. The
pattern file declares semantic vacuity out of mechanical scope, so this is a known limit rather
than a surprise — but it has now cost four features. `docs/backlog.md` B8.

**Mutation testing is the only thing that catches it, and it is entirely manual.** 018 ran eleven
mutations by hand; one of them exposed the feature's own vacuous criterion. That is a high-value
step with no tooling behind it.

**Escalations collapsed and that is not obviously good.** 9 → 4 → 3 → 1 → 0 → 0 across 013 to 018.
Part is genuine: the ground rules and the charter now answer questions that used to need a human.
Part is the last two sessions running unattended by explicit request. The number should not be read
as a quality signal until a session with a human in the loop produces one.

## 4. Loop — does the WoW improve itself?

| Source | Proposed | Landed |
|---|---|---|
| Constitution rules | `D3`, `D4`, `D5`, plus the `non-vacuous-checks` override | all 4 landed |
| North Star amendments | ADR `0004` (`frictionless-adoption` signal) | landed |
| Charter pins minted by `/plan` | `S4` (013), `S9` (018) | both landed |
| Charter wording sharpened, not superseded | `S1` (014), `S7` (018) | both landed |
| Backlog items | 13 raised | 2 promoted to features (B1→015, B3→016), 10 open, 0 dropped |

**The loop closes, and the backlog is where it stops being a treadmill.** Ten open items is not a
failure: `docs/backlog.md` exists precisely because chaining every finding into the next feature is
the recorded root cause of the loop not converging.

**Two pins have now been sharpened rather than superseded.** Both times the decision had not
changed — the wording was under-specified and read as something stronger. `S7` is the clearer case:
its title said green never proves *a product*, which made every check in this repository a
violation, because the harness **is** this repository's product.

## 5. Theater smells (human spot-check, Layer 4)

| Smell | Feature | Reading |
|---|---|---|
| Zero rework, zero escalations, all green | 017 | 11 gaps caught, 6 metacharacter bugs at `/contract`, and its own verdict-line typo found afterwards. Not too clean — the friction moved earlier in the loop, which is where it is supposed to be. |
| `⏳` on four consecutive features | 013, 014, 016, 017 | The opposite of a smell. Each declined to claim a signal without evidence and fixed a date. 018 is the first that could honestly claim one. |
| Escalations at 0 for two features | 017, 018 | Explained by unattended sessions, not by the absence of decisions. 018 took a real one — `S9` — without asking, which is the intended behaviour under that instruction but is worth a human's eye. |
| A retro that praises its own feature | 018 | It records one rework, one recorded deviation (`/tasks` written after implementation), and files two backlog items against itself. Not clean. |

**No retro has an empty Evidence cell, and none is overdue.**

## 6. Charter health — is pinning decisions earning its ceremony?

**Pins that tripped:** zero `TRIPPED` verdicts across 013–018.

**Pins that constrained without tripping:** this is where the charter is actually earning its keep.

| Pin | Where it constrained | Effect |
|---|---|---|
| `S7` | 018's design | The fixture's own suite result is reported and never counted. Without the pin, adding it to the total would have been the obvious move. |
| `S3` | 018 `G-c` | `uv` rejected as the fixture's toolchain; the fixture runs on what the suite already has. |
| `S2` | 016, 018 | Both carried the `Hedge` as a live coverage row; neither opened an importable seam. |
| `S1` | every feature | `no-prescribe.sh` runs at every `/verify`. |

**Rework with no pin (charter gaps):** zero. Every load-bearing decision the last six features
needed was either pinned or minted at `/plan`.

**Pins that never trip and never constrain:** `S0`, `S4`, `S5`, `S6`, `S8` have constrained no
recorded decision since being written. That is **not yet** bloat — they were seeded in 013 as
decisions already governing the repository, and four of them answer a ground rule, which is a
constraint on the floor rather than on a plan. Worth re-reading at the 2026-09-08 sweep.

**The ratio, read as the skill asks.** Two pins minted by `UNPINNED`, zero charter gaps, zero
trips. Many trips and no gaps would mean the charter is doing its job; gaps with no trips would
mean it is decorative. **Zero and zero means it has not been stressed yet** — no feature has taken
a decision that a pin declared wrong. Until one does, the charter's value is the elicitation, not
the enforcement, and saying otherwise would be laundering.
