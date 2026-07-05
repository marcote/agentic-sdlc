# Acceptance — Save card with 1-tap

> Acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the
> UAT step. The deterministic portion is materialized as a test in `/contract`.

## Criterion: tokenization < 300ms  (deterministic)
```gherkin
Given a valid card and an approved purchase
When the user accepts "save with 1 tap"
Then the token is returned in < 300ms
And the response never contains the PAN in the clear
```

## Criterion: save idempotency  (deterministic · [given] base/idempotency)
```gherkin
Given a save already performed with an idempotency-key
When the same request is resent with the same idempotency-key
Then no duplicate token is created
And the existing token is returned
```

## Criterion: save audit-log  (deterministic · [given] base/audit-logging)
```gherkin
Given a card save
When the token is persisted
Then an audit-log is emitted with actor + timestamp + entity
```

## Criterion: payment with saved card on 2nd purchase  (deterministic)
```gherkin
Given a user with a saved card
When they start a new purchase
Then they can pay with the saved card without re-entering data
```

## Criterion: clear message on rejection  (non-deterministic → eval case)
_(The quality/clarity of the error message when tokenization fails or the card is
rejected is evaluated with an eval case in `evals/cases/`, not with a unit test.)_
