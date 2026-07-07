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
  - **Re-check CLOSED (2026-07-06):** after PR #11 merged (`3070acd`), the live raw URL was
    curled and `curl -fsSL … | bash -s -- --yes` ran against a throwaway `git init` repo. It
    cloned over HTTPS from `github.com/marcote/agentic-sdlc.git` and landed the full harness —
    the stamped provenance `source: https://github.com/marcote/agentic-sdlc.git @ 3070acd222…`
    is the evidence the network hop (not just the local-checkout mechanism) works end-to-end.
    frictionless-adoption is now confirmed **including** the internet fetch; no caveat remains.

## Face B — Method (validates the WoW) — DERIVED from artifacts
- **Gaps caught by /distill:** 1 blocking grilling ambiguity (the `--yes` / `/dev/tty` / no-TTY consent model) + edge cases (pipe holds stdin → `/dev/tty`; no-TTY-no-`--yes` abort; `--yes` with no TTY; decline path; git absent; temp leak; self-leak via DROP; fork/test source) `[deriv: spec.md "Edge cases" + coverage.md; distill AskUserQuestion on --yes]` — the notable one: grilling surfaced that the interactive prompt has **no honest hermetic RED**, so `CONFIRM-TTY` was carved out as UAT-only and a testability seam (`HARNESS_REPO`) entered the design.
- **RED→GREEN discipline:** yes `[deriv: coverage.md "RED plan"→"Implementation done": 🔴 10 FAIL → 🟢 234 PASS; suite 223/10 at /contract → 234/0 after impl]` — clean arc, no assert refinement needed. Disclosure: `DEPFREE` reused the shared `assert_dep_free` in `tests/lib.sh` (007's Face C candidate, landed by 008), so it did **not** re-implement (and mis-implement) the check the way 007 did — the WoW improvement paid off.
- **Rework post-/verify:** 1 batch (2 portability bugs, **caught by CI, not by the local /verify**) · **post-/uat:** 0 `[deriv: verification/reports/009-bootstrap-a572cfc.md §5; CI run 28835273808 self-verify 235 PASS / 4 FAIL → fix commit]`. The local suite was green (239/0) but CI reddened: (a) `bootstrap.sh` used `[ -r /dev/tty ]` to detect "no terminal" — a readable `/dev/tty` node with no terminal behind it (GitHub Actions) defeated it; fixed with `exec 3<>/dev/tty && [ -t 3 ]`. (b) `check_88` cloned `$(pwd)` assuming a local `main` branch — CI's detached-HEAD checkout has none; fixed by exporting the committed HEAD tree into a throwaway `main` source. Honest: `/verify` passed on a machine whose `/dev/tty` + branch layout hid both — the hermetic local run was **not representative of CI**.
- **Escalations to the human:** 0 inner-loop `[deriv: this session — implementation was a single pass, no 2-identical-failure escalation]`. Distinct from the 4 design decisions taken with the human (channel / safety / version in brainstorm + `--yes` in distill) — those are intake gates, not inner-loop escalations.
- **Friction from the WoW itself:** (1) **`/verify` green ≠ CI green.** The hermetic local suite passed while CI reddened on `/dev/tty` semantics + detached-HEAD checkout — the two environments the tests must survive differ in exactly the axes this feature exercises (terminal + fetch). The WoW has no "run under CI-like conditions" gate before push; the PR CI *is* that gate, but it fires after `/verify` signs off, so the report briefly claimed a cleanliness it did not have. (2) A **network-fetch + interactive feature is awkward to test hermetically** — the `HARNESS_REPO`/`HARNESS_REF` seams and the robust tty detection both exist purely to survive test/CI environments; third feature (006/007/009) to invent an ad-hoc test seam. (3) `CONFIRM-TTY` is the second interactive criterion needing the "UAT-observed, no hermetic RED" carve-out. (4) Positive: the shared `assert_dep_free` helper meant `DEPFREE` just worked — the 007→008 self-improvement loop closed here.

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** (1) *External-fetch test seam* — features that fetch from a
  network source should expose an env override (à la `HARNESS_REPO`) so the suite exercises them
  offline against a local fixture; name it so 006/007/009's ad-hoc seams become one documented
  pattern. (2) *Interactive-IO criteria are UAT-observed* — a criterion whose behavior is a real
  terminal prompt (`/dev/tty`) has no honest hermetic RED; document it as validated via a pty at
  `/uat` (like the `UAT (config)` / guard exclusion), so it is not re-derived per feature.
  (3) *Environment-sensitive tests must not assume the dev box* — a test touching `/dev/tty`,
  branch layout, `$TMPDIR`, or locale should be written to survive a detached-HEAD, no-terminal
  CI checkout (build fixtures, don't read the ambient repo); `/verify` green on one box is not CI
  green. Apply via `memory/constitution/update-checklist.md`.
- **Candidate amendments → North Star:** none. scopeCompliance was 5 with no edge; the "host the
  raw URL" follow-up is operational, not a governance change. Leave the North Star as-is.
