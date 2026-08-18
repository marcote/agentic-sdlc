# WoW Report — generated 2026-08-16

Aggregates the retro ledger. **Observes, never gates** — the deterministic teeth are
`tests/check_90_retro.sh`. Input: all `specs/*/retro.md`, their `alignment.md`, and
`verification/reports/*`.

**N = 15 closed features** (004, 006, 007, 008, 009, 013, 014, 015, 016, 017, 018, 019, 020, 021,
plus 003 as `n/a`). Small sample, no statistics. Per-feature and themes only; no trends are claimed.

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

**Swept 2026-08-18**, three weeks before the scheduled date, because a trigger had already fired
and nobody had noticed.

| Feature | What is being observed | State after the sweep |
|---|---|---|
| 013 | the charter preventing stack-decision rework | **CLOSED — `confirmed`.** 018's `/plan` returned `UNPINNED` and minted `S9`; its `S7` falsifier reading changed `ADOPT-TESTCMD-INVOKED`'s design before it was written. Limit recorded: **no pin has ever `TRIPPED`** in ten features |
| 014 | ADR `0004`'s amended signal, and `UNCOVERED` stopping a later feature | renewed → **2026-10-08**. (a) fired weakly — 022 and 023 both *declined* to claim `frictionless-adoption` for a step they added. (b) has not fired and asks for rework this repo does not produce |
| 016 | the provenance stamp changing a verdict | renewed → **next pillar-moving ADR, or 2026-10-08**. A retro consulted the stamps at this sweep; no pillar has moved since ADR `0004`, so there was no drift to catch |
| 017 | an executable derivation going red on its own | renewed → **2026-10-08**. 14 derivations, zero red. This sweep edited five closed retros and the suite stayed green |
| 019 | whether the lifecycle boundary ever changes a verdict | deferred half renewed → **2026-10-08**. Consulted by 020, 021, 022 and 023; **zero verdicts changed** |
| 022 | whether obliging a mutation catches one nobody would have declared | open → 2026-09-16. **First data point is negative:** 023 closed under the gate at `0 undeclared` on the first run — one of the three consecutive zeroes its case file names as refuting |
| 023 | whether `cases.sh` ever blocks a feature that did not know it was broken | open → 2026-09-18 |

### The finding this sweep produced, which is not about any one feature

**Four of these five triggers ask to observe a failure, in a system engineered not to fail.**

- 014(b) needs a stop that *prevents rework*. Rework across the corpus, derived from Face B of every
  retro: **2 instances in 17 features**.
- 016 needs a pillar's `since` to move. None has moved since ADR `0004`.
- 017 needs a number to rot. Every number here is derived at write time, so they do not.
- 019 needs a predicate to lower a score. Fourteen features, zero `scope-reject` hits.

They are not stalled for lack of attention. **They are waiting for events this repository's own
discipline prevents**, which makes them unfalsifiable rather than unresolved. Every one now carries a
**stopping rule** so the third renewal is not an option: at 2026-10-08 an unfired trigger is closed
as *unobservable here*, said plainly, rather than carried as a permanently open row.

**The failure this sweep actually caught** is that 013's evidence arrived on 2026-08-09 and this
report already recorded it as *"partially answered"* — while `specs/013-stack-charter/retro.md`, the
artifact that owns the verdict, still read `pending-observation` nine days and five features later.
Two trackers, and the stale one holds the verdict. `B9`'s family.

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
| 019 | 13 | yes, 2 documented exceptions | 1 | 0 |
| 020 | 14 | yes, **0** exceptions | 3 | 0 |
| 021 | 10 | yes, **0** exceptions | 2 | 0 |

**The finding that matters: the harness's own tooling found 18 defects in closed, green features.**

| Found by | Count | Where they had been hiding |
|---|---|---|
| `nvc.sh` traceability (015) | 15 | untraceable criteria, nine of them in `check_95` since feature 004 |
| hand-vendoring onto a real repo (012, 018) | 2 | the pin-id parser, and the cwd-resolution defect |
| `check_90`'s verdict parser (017) | 1 | a missing colon that removed 017 from its own gate's scope |

Every one of those features was closed, green and retro'd. **Green did not mean correct; it meant
nothing had asked the question yet.**

### Recurring friction themes

**Semantic vacuity is the standing cost, and it is still unmechanised.** Five vacuous assertions
across 015, 016 (two), 018 and 019, each caught by reading or by hand-mutation, none by `nvc.sh`.
The pattern file declares semantic vacuity out of mechanical scope, so this is a known limit rather
than a surprise. `docs/backlog.md` B8.

**A shape is now visible across the last two.** 018's `ADOPT-REL-RESOLUTION` compared two runs that
could not differ; 019's `NS-PREDICATE-REACHABLE` built its test input from the thing under test.
Both are **an assertion whose input guarantees its own outcome** — a narrower family than "semantic
vacuity", and possibly a mechanisable one.

**Mutation testing is no longer manual, and the audit corrected the record.** 020 shipped a runner;
021 re-declared 018's and 019's tables as commands. **18 of 19 reproduce.** 020's own 6-of-14 rate
did not generalise — it came from mutations written against a tool that was still changing.

**The real defect in those tables was coverage, not validity.** 018 recorded 11 mutations against
16 criteria. Nobody was looking for that, and it was found by counting rather than by suspecting.

**46 declarations now run at every `/verify` and in CI, at 66s.** `check-can-fail` stopped being a
sentence in a report.

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
| North Star amendments, second wave | ADR `0005` (lifecycle boundary) | landed |
| Charter wording sharpened, not superseded | `S1` (014), `S7` (018) | both landed |
| Backlog items | 13 raised | 2 promoted to features (B1→015, B3→016), 11 open, 0 dropped |

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
