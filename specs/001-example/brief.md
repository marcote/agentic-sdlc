# Brief — Save card with 1-tap

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.
> (Illustrative example of the Way of Work — not real code.)

## Product objective
Allow users, after a successful purchase, to save their card with a single tap so
that the next purchase does not require re-entering data.

## Why / motivation
Every extra field in mobile checkout drops conversion. Competitors already offer
1-tap. Reducing friction on the second purchase is the cheapest retention lever
we have this quarter.

## Success metrics
- ↑ mobile conversion on 2nd purchase **+5%** (measured at 30 days).
- Card tokenization **p95 < 300ms**.
- **0 PCI incidents** in the period.

## Out of scope
- Management of multiple saved cards (see *deferred* in `coverage.md`).
- Edit/delete card from profile.
