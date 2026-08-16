# North Star — replay fixture for 020

```json
{
  "mission": "A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified) on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.",
  "pillars": [
    {
      "id": "real-enforcement",
      "statement": "Discipline is enforced by deterministic gates, not good intentions.",
      "signal": "Gates block closure when a condition is missing; violations are caught before merge (and the harness proves this by dogfooding itself: retro ledger / wow-report).", "since": "0001"
    },
    {
      "id": "agnostic-portability",
      "statement": "Runs on any stack or project without imposing technology or runtime.",
      "signal": "The contract (schema, gates, artifacts) remains intact when vendored onto an arbitrary repo/stack.", "since": "0001"
    },
    {
      "id": "frictionless-adoption",
      "statement": "Incorporating the harness into a new repo costs little, and every cost it does impose is justified by what that cost prevents.",
      "signal": "Steps/time to adopt (lower = better), with every mandatory step carrying a recorded justification proportional to what it prevents. The defect is an unjustified step, not a step as such: friction that buys nothing is what is being measured.", "since": "0004"
    },
    {
      "id": "measurable-impact",
      "statement": "The discipline the harness imposes must translate into better software: less rework and gaps caught before production, not gates that fire for the sake of firing.",
      "signal": "Gaps caught early (grilling/contract) and late rework avoided (post-verify/uat), aggregated per feature in the Method section of the wow-report; high = discipline prevents, not just bureaucratizes.", "since": "0002"
    }
  ],
  "scope": {
    "in_scope": [
      "commands, gates, and skills of the governance workflow",
      "product governance: constitution and North Star",
      "feature templates, coverage, and criterion state machine",
      "evals, verification, and UAT of the method",
      "adoption tooling: install, vendoring, and harness inheritance",
      "WoW self-validation (retro, wow-report) and method documentation"
    ],
    "out_of_scope": [
      "application code or product features of an adopting project",
      "stack-specific deterministic engine (provided by the adopter)",
      "imposing or naming a mandatory execution runtime",
      "blocking commit hooks",
      "runtime dependencies or frameworks",
      "product discovery and demand validation",
      "prioritisation, roadmapping or estimation across features",
      "release, deployment or rollout of the software being built",
      "production monitoring, incident response or usage analytics"
    ]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```
