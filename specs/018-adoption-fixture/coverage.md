# Coverage — <feature>

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → one criterion; every criterion → one eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** — every objective traces to a North Star pillar
> (`memory/north-star/north-star.md`) via the objective→pillar mapping in `specs/<feature>/alignment.md`.
> A row with an empty **Pillar** cell is a drift signal (see the orphan check of `/align`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| _(e.g.)_ `pillar-a` | _(e.g.)_ ↑ conversion | Save card 1-tap | token < 300ms | project | `card_token.feature` | 🔴 red |
| — | — | (all writes) | audit-log actor+ts | `[given] base/audit-logging` | `audit.feature` | 🔴 red |
