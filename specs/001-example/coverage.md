# Coverage — Save card with 1-tap

> Traceability matrix = source of truth for the status of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
>
> **Status of this feature: halfway there** — used to show the matrix with mixed statuses.
> Does NOT close yet (idempotency missing at 🟢 and the UAT of the payment). Remember:
> `feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

| Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked Test/Eval | Status |
|---|---|---|---|---|---|
| Tokenization p95 < 300ms | Tokenize and persist token | token < 300ms, no PAN | project | `card_token.feature` | ✅ uat |
| 0 PCI incidents | Never store PAN | response without PAN in the clear | project | `card_token.feature` | 🟢 green |
| — (every write) | Persist token | audit-log actor+ts+entity | `[given] base/audit-logging` | `audit.feature` | 🟢 green |
| — (retries) | Repeatable save | idempotency by key | `[given] base/idempotency` | `idempotency.feature` | 🔴 red |
| ↑ conversion 2nd purchase | Payment with saved card | pays without re-entering data | project | `one_tap_pay.feature` | 🟢 green |
| UX quality on error | Clear rejection message | message clarity | project | `evals/cases/reject-msg.yaml` | 📋 case |
| (out of scope) | Multi-card | selection among several | project | — | deferred |

**Open gaps:** none orphaned. Pending to close: `idempotency.feature` to 🟢
(implementation in progress, see `tasks.md` T4) and the UAT pass on criteria at 🟢.
