# WoW Report — generated 2026-08-09

Aggregates the retro ledger. **Observes, never gates** — the deterministic teeth are
`tests/check_90_retro.sh`. Input: all `specs/*/retro.md`, their `alignment.md`, and
`verification/reports/*`.

**N = 7 closed features** (004, 006, 007, 008, 009, 013, 014). Small sample, no statistics.
Per-feature and themes only; no trends are claimed.

> **First run.** This report had never been generated across eight features. That is itself the
> report's most important finding, and §2 is where it shows.

---

## 1. Mission — is each pillar being served?

| Pillar | Features that claimed it | Signal moved | Drift |
|---|---|---|---|
| `real-enforcement` | 004, 006, 007, 008, 009, 013, 014 | **7 / 7** | none |
| `agnostic-portability` | 004, 006, 007, 009, 013, 014 | **6 / 6** | none |
| `frictionless-adoption` | 006, 007, 008, 009, 014 | **4 / 5** — 014 `⏳` | watch |
| `measurable-impact` | 004, 013, 014 | **1 / 3** — 013 `⏳`, 014 `⏳` | **⚠ measurable drift** |

**`measurable-impact` is the drifting pillar, and the pattern is legible.** The two features
that deferred it are the two that produce *rules about how to work* rather than a tool with an
observable outcome. Every `confirmed` verdict in this ledger belongs to a feature that shipped
something that does a thing — a CI gate, vendoring, a tracker, a bootstrap. Both `⏳` belong to
governance mechanisms whose value is real but whose *measurement* was deferred to a future
feature.

That deferral chain is the harness's structural weak spot: a method feature's proof lives in the
next feature, and the next feature keeps being another method feature.

## 2. Pending re-checks (worklist)

| Feature | Deferred since | Trigger | Sweep by | State |
|---|---|---|---|---|
| ~~006~~ | 2026-07-05 | feature 007 vendors the engine | — | **✅ CLOSED 2026-08-09 → `confirmed`** |
| 013 | 2026-08-08 | a real `UNPINNED`/`TRIPPED` against a **pre-existing** pin, or a real coherence objection | **2026-09-08** | open — did not fire in 014 |
| 014 | 2026-08-09 | friction **rejected** for lacking justification, or another feature stopped by `UNCOVERED` | **2026-09-08** | open — neither occurred |

**⚠ The finding that justifies this whole section: 006 sat `pending-observation` for 35 days
after its evidence already existed.** Its trigger fired when 007 merged on 2026-07-05; the
agnostic-portability half was even explicitly re-checked by 012 (`2602a36`). Nobody swept the
ledger, and this report — the tool built to list exactly this — had never been run.

A deferral mechanism nobody sweeps **loses findings while the ledger still reads as rigorous**,
which is worse than an open item because it is invisible. Two corrections landed today: every
`pending-observation` now carries a **sweep date** as well as an event trigger (whichever comes
first), and `specs/_template/retro.md` requires it going forward.

## 3. Method — does the WoW add value? (N = 7)

| Feature | Gaps caught pre-impl | RED discipline | Rework post-verify / post-uat | Escalations |
|---|---|---|---|---|
| 004 | — | yes | 0 / 0 | — |
| 006 | 3 + 5 edge cases | yes, no exceptions | 0 / 0 | — |
| 007 | — | yes | 0 / 0 | — |
| 008 | — | yes | 0 / 0 | — |
| 009 | — | yes | 0 / 0 | — |
| 013 | 8 | yes, 7 documented exceptions | 0 / **1** (`EMPTY-CHARTER`) | 9 |
| 014 | 10 | yes, 10 documented exceptions | 0 / **0** | 4 |

**Recurring friction themes:**

1. **Vacuous and untraceable checks — 11 occurrences, the dominant theme by far.** `e6bc658`
   (008), five in 013, five in 014, plus one found today in 008's `DEPFREE`. Shapes:
   self-detection, untraceable results, passing for an unrelated reason, semantic vacuity,
   reporting on the wrong tree. **013's retro proposed a rule; 014's plan restated it as D10;
   occurrences 6–10 happened anyway, in the same branch as the warning.** Prose does not prevent
   this. The mechanical half was demonstrated on 2026-08-09 in minutes and found a real instance
   in a feature closed a month earlier.
2. **A feature that introduces a gate cannot be gated by it.** 002, 013, 014 — three
   occurrences, negotiated ad hoc each time.
3. **Checks run against the wrong tree return confident false verdicts.** Twice on 2026-08-09:
   the amendment gate over an empty commit range, and a hermeticity check against uncommitted
   work.

## 4. Loop — does the WoW improve itself?

| | Proposed | Landed |
|---|---|---|
| Constitution patterns | `non-vacuous-checks` (013, 014) | **0 of 1** |
| Constitution deltas | gate-bootstrap exception (013, 014) | **0 of 1** — `D1`–`D3` predate both |
| North Star amendments | ADR `0004` | **1 of 1** (PR #17) |

**The loop closes on governance and stalls on practice.** An amendment to the North Star went
through its full protocol in one day. Two constitution rules have been proposed twice each,
across two features, and neither has landed — while the failure one of them describes recurred
five more times in between.

That asymmetry is the honest reading of this section: the harness improves the rules it *gates*
and forgets the rules it merely *records*.

## 5. Theater smells (human spot-check)

- **No all-green retros.** Every retro records gaps, exceptions or friction. 013 and 014 each
  self-report defects that make their author look worse — the most reliable signal available
  that they were not written to pass.
- **`⏳` verdicts are used honestly and repeatedly**, including one (014) that came back negative
  against a falsification test *written before the result was known*.
- **⚠ One real smell, now corrected:** an overdue `pending-observation` invisible for 35 days
  (§2). Not a dishonest retro — a ledger nobody read.
- **⚠ Watch:** 12 eval cases across three files have **never been scored**, by design, because
  the authoring model grading its own output is not evidence. They are honestly open and
  honestly blocked; if they stay open indefinitely they become decoration rather than deferral.

## 6. Charter health — is pinning decisions earning its ceremony?

| Signal | Count | Reading |
|---|---|---|
| Pins that **tripped** | **0** | The charter has never caught a decision going bad before the rework |
| Rework with **no pin** covering it | **0** | No rework has been traced to a missing pin either |
| Pins that **never trip and never constrain** | 0 of 9 | No bloat: every pin has been read by a gate |
| Pins **strained but not tripped** | `S1` ×1, `S2` ×2 | `S2`'s third strain is declared to be the falsifier arriving |
| Pins **created by a gate** | `S4` (013 `UNPINNED`), `S5`–`S8` (014 `UNCOVERED`) | 5 of 9 pins exist because a gate demanded them |

**Honest reading: too early, and the ratio is uninformative at 0/0.** The charter cannot yet be
called working or decorative. What *is* evidence: **5 of 9 pins exist only because a gate forced
them**, and two of those (`S7` green proves the harness's machinery not a product; `S8` fail
closed, never partially apply) recorded decisions that had governed this repository **since
feature 001 and 007 respectively without ever being written down**.

Surfacing an eight-month-old undocumented decision is not the same as preventing rework, and this
report will not claim it is. It is the strongest thing the charter has done so far.

---

## What this report says to do next

Nothing in §1–§6 recommends a new feature. The two actionable items are both small and both
overdue rather than new:

1. **Land one of the two candidate constitution rules**, or drop them explicitly. Proposing a
   rule twice and landing it zero times is the loop failing quietly (§4).
2. **Sweep the ledger on 2026-09-08.** That date now exists precisely because it did not before.
