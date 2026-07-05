# Spec — Save card with 1-tap

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when
> `coverage.md` stopped having orphan rows.

## Functional requirements
1. After an approved purchase, offer "save card with 1 tap".
2. On acceptance, tokenize the card and persist the token (never the PAN).
3. On the next purchase, offer payment with the saved card without re-entering data.

## User stories
- As a mobile buyer I want to save my card with a tap so I don't have to re-enter it
  next time.
- As a buyer I want to trust that my card data is not stored in the clear.

## Edge cases (80% problem)
- The tokenizer is down or responds > 300ms → don't block the already-approved purchase
  flow; degrade to "not saved".
- The save request is retried (unstable network) → must not duplicate tokens
  (idempotency).
- User without a persistent session → don't offer 1-tap.

## Open questions / deferred
- Multi-card and selection among several saved cards → **deferred** (out of scope of the
  brief; revisited in a later feature).
