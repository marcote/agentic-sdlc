# Retro — 009-bootstrap @ a572cfc (working tree)

closes: `specs/009-bootstrap/alignment.md` · `verification/reports/009-bootstrap-a572cfc.md` · date: 2026-07-06

> Closes the measurable prediction that `/align` opened (align↔retro column). A feature is not
> DONE until this retro closes its three faces.

## Face A — Mission (closes the /align prediction)
Source: `alignment.md` mapping (frictionless-adoption, real-enforcement, agnostic-portability) + `north-star.md` signals.

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| frictionless-adoption | Steps/time to adopt the harness (lower = better) | ✅ moved | UAT-1 (report §4): from a bare `git init` repo with **no harness present**, one `bootstrap.sh --yes` landed the full tree + provenance + cleanup. Was multi-step undocumented folklore ("clone → find vendor.sh → run"). Coverage `FETCH`/`APPLY-YES` ✅ uat |
| real-enforcement | Gates block when a condition is missing; harness dogfoods itself | ✅ moved | `NOTTY-ABORT` (no-TTY + no `--yes` → abort, nothing written) + `CONFIRM-TTY` UAT-2 (`n` → ABORTED over a real pty): the safety gate blocks blind writes. Coverage rows ✅ uat + report §4. Feature ran through the real `/align` engine (`alignment.md`) |
| agnostic-portability | Contract stays intact when vendored onto an arbitrary stack; dependency-free | ✅ moved (synthetic target) | `DEPFREE` (git + bash/coreutils only, `assert_dep_free` green) + UAT-1 landed the vendored tree (incl. `engine.py`) onto a fresh temp repo. Coverage `DEPFREE`/`DROP-SELF` ✅ uat |

- **Align calibration:** pillarFit 4 held (real-enforcement mapping is genuinely loose — a confirm
  prompt is not a deterministic closure gate — which is exactly why it was held at 4, not 5);
  scopeCompliance 5 held (`scope-reject` cleared all 3 objectives, no edge); missionAdvancement 3
  held **honestly** — the min was pulled down by the preventive dependency-free/reuse objective,
  and in retrospect that is correct, not conservative (unlike 007's 3, which was pessimistic).
- **Mission verdict:** confirmed
  - All three pillars moved with locators. **Caveat (survived self-challenge):** the from-zero
    gesture was validated with `HARNESS_REPO` pointing at a **local checkout** — the mechanism
    (fetch → plan → confirm → apply → cleanup) is proven end-to-end, but the *actual*
    `curl … | bash` over the network from the hosted raw URL is **not yet exercised** (hosting is
    out of scope by decision). Same synthetic-target caveat as 007 for agnostic-portability.
  - **Re-check trigger:** once `raw.githubusercontent.com/marcote/agentic-sdlc/main/bootstrap.sh`
    is reachable, run the real `curl … | bash` against a throwaway repo once — that closes the
    network hop this retro leaves open.

## Face B — Method (validates the WoW) — DERIVED from artifacts
- **Gaps caught by /distill:** 1 blocking grilling ambiguity (the `--yes` / `/dev/tty` / no-TTY consent model) + edge cases (pipe holds stdin → `/dev/tty`; no-TTY-no-`--yes` abort; `--yes` with no TTY; decline path; git absent; temp leak; self-leak via DROP; fork/test source) `[deriv: spec.md "Edge cases" + coverage.md; distill AskUserQuestion on --yes]` — the notable one: grilling surfaced that the interactive prompt has **no honest hermetic RED**, so `CONFIRM-TTY` was carved out as UAT-only and a testability seam (`HARNESS_REPO`) entered the design.
- **RED→GREEN discipline:** yes `[deriv: coverage.md "RED plan"→"Implementation done": 🔴 10 FAIL → 🟢 234 PASS; suite 223/10 at /contract → 234/0 after impl]` — clean arc, no assert refinement needed. Disclosure: `DEPFREE` reused the shared `assert_dep_free` in `tests/lib.sh` (007's Face C candidate, landed by 008), so it did **not** re-implement (and mis-implement) the check the way 007 did — the WoW improvement paid off.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/009-bootstrap-a572cfc.md §5 — Gaps routed: none]`. (The first UAT attempt failed on *my test scaffolding* — I cloned the source repo wrong — not on the product; no criterion or code changed.)
- **Escalations to the human:** 0 inner-loop `[deriv: this session — implementation was a single pass, no 2-identical-failure escalation]`. Distinct from the 4 design decisions taken with the human (channel / safety / version in brainstorm + `--yes` in distill) — those are intake gates, not inner-loop escalations.
- **Friction from the WoW itself:** (1) A **network-fetch feature is awkward to test hermetically** — the WoW's hermetic-suite requirement forced the `HARNESS_REPO`/`HARNESS_REF` env seams into the product purely for offline testing + forks; clean, but it is the third feature (006/007/009) to invent an ad-hoc test seam. (2) `CONFIRM-TTY` is the second interactive criterion to need the "UAT-observed, no hermetic RED" carve-out — the pattern works but is re-derived each time. (3) Positive: the shared `assert_dep_free` helper meant `DEPFREE` just worked — the self-improvement loop from 007→008 closed here.

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** (1) *External-fetch test seam* — features that fetch from a
  network source should expose an env override (à la `HARNESS_REPO`) so the suite exercises them
  offline against a local fixture; name it so 006/007/009's ad-hoc seams become one documented
  pattern. (2) *Interactive-IO criteria are UAT-observed* — a criterion whose behavior is a real
  terminal prompt (`/dev/tty`) has no honest hermetic RED; document it as validated via a pty at
  `/uat` (like the `UAT (config)` / guard exclusion), so it is not re-derived per feature. Apply
  via `memory/constitution/update-checklist.md`.
- **Candidate amendments → North Star:** none. scopeCompliance was 5 with no edge; the "host the
  raw URL" follow-up is operational, not a governance change. Leave the North Star as-is.
