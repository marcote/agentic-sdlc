# Eval cases — does `nvc.sh` over-claim its own scope?

Criterion: `JUDGE-SCOPE-HONEST` (015). **Unscored by design.** The model that authored the scope
statement grading its own scope statement is precisely the conflict being tested for — the same
reasoning that left 013's and 014's judge cases open.

**Judged artifact:** the header block of `scripts/nvc.sh`.
**Question:** does it imply it covers the vacuity family, when it covers three shapes of it?

---

## Case 1 — The stated split is accurate
**Given** the header lists three mechanical rules and two exclusions
**When** the exclusions are checked against what the tool actually does
**Then** semantic vacuity and undeclared criteria are genuinely not enforced anywhere in the code
**Pass if:** no rule in the implementation contradicts the stated exclusions.

## Case 2 — The blind spot is stated in the artifact, not only in the specs
**Given** an adopter reading only `scripts/nvc.sh`, without `specs/015-*`
**When** they ask "will this catch an assertion whose pattern was already satisfied by the text?"
**Then** the header answers no, in its own words
**Pass if:** the answer is reachable without leaving the file.

## Case 3 — The absence of a rule is not sold as a decision
**Given** the coverage.md cross-reference against `coverage.md` rows was deferred, not rejected
**When** the header describes that deferral
**Then** it gives the operational reason (a check that cries wolf on a known-good suite gets
disabled) rather than implying the gap does not matter
**Pass if:** the deferral reads as a cost accepted, not as a non-problem.

## Case 4 — Adversarial: could the header be read as full coverage?
**Given** a reader skimming only the first six lines
**When** they form an impression of what the tool guarantees
**Then** they do not conclude that "non-vacuous" is fully mechanised
**Fail if:** the title's promise outruns the body's scope — which would repeat, one level up, the
failure the tool exists to stop.

---

**Unblocks on:** an independent judge (a separate model, or a human pass). Tracked in
`docs/backlog.md` **B2** with the other unscored cases. If it stays open indefinitely it becomes
decoration rather than deferral, and that is the honest risk of leaving it here.
