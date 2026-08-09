# Eval case — ground-rules-judge

> Non-deterministic criteria: **JUDGE-GR-ANSWERED**, **JUDGE-NA-HONEST**
> (`specs/014-ground-rules/acceptance.md`). Scored manually (or by an LLM judge) per
> `evals/README.md`. State: 📋 case.
>
> Both cases cover **one blind spot the engine cannot close by construction**: it verifies that
> a ground rule is *claimed*, never that the claim is *honest*. `engine.py ground-rules` reads
> `Answers:` and declination blocks and reports coverage; it has no way to know whether the pin
> it credits actually settles the question, or whether an `n/a` is true.
>
> This is the sharper failure mode of the whole feature. A ground rule reported as covered when
> it is not is **worse than one reported uncovered**: it manufactures a floor that does not
> exist, and the gate then waves the project through with a clean conscience.
>
> The charters below are illustrative. An adopting repo runs the same shapes against its own.

## Case 1 — JUDGE-GR-ANSWERED rejects a topical match

**Ground rule (input):**
> `GR6` — Failure posture. *When it breaks: does it retry, corrupt, alert, or fail silently?*

**Pin (input):**
```
### S7 — Structured logging with severity levels        [substrate]
- Confidence: PINNED
- Because:    operators need to filter noise when reading output
- Buys:       machine-readable output, filterable by level
- Forecloses: free-form prose logging
- Falsifier:  a consumer needs unstructured output
- Answers:    GR6
```

**Expected judge behaviour:** **reject.** Logging is how a failure is *reported*; `GR6` asks
what the system *does* when it breaks — retry, corrupt, alert, or continue silently. The pin is
topically adjacent and answers none of it. The judge must say which part of the question is
unanswered, not merely that it dislikes the match.

**FAIL if:** the judge accepts because both concern failures. That is coverage-by-keyword, and
it converts the floor into a checkbox — the exact outcome that makes a reported floor worse
than an admitted gap.

## Case 2 — JUDGE-GR-ANSWERED accepts a genuine answer

**Same `GR6`. Pin (input):**
```
### S7 — Fail closed and loud on partial writes          [substrate]
- Confidence: PINNED
- Because:    a partially applied change is worse here than no change
- Buys:       no silent corruption; a failed run leaves the prior state intact
- Forecloses: best-effort partial progress on large batches
- Falsifier:  a workload where partial progress is more valuable than consistency
- Answers:    GR6
```

**Expected judge behaviour:** **accept**, naming which part of the question it settles (it does
not retry, it does not corrupt, it fails loudly).

**FAIL if:** the judge rejects it for not addressing *every* clause of the question. A ground
rule demands a rationale, not an exhaustive treatise; demanding completeness turns the floor
into an obstacle and pushes people toward `n/a`.

## Case 3 — JUDGE-NA-HONEST rejects a false decline

**Ground rule (input):**
> `GR2` — Persistence & concurrency. *What holds state, and how many things write to it at once?*

**Declination (input), in a project that writes report files to disk on every run:**
```
### GR2 — n/a
- Because:   this tool has no database
- Falsifier: a database is introduced
```

**Expected judge behaviour:** **reject.** The decline answers a narrower question than the one
asked. `GR2` asks what holds **state**, not whether a database exists — and this project holds
state in files, with an unexamined answer to how many processes write them concurrently. The
judge must demand a real answer, and may point out that the `Falsifier` is aimed at the wrong
condition too.

**FAIL if:** the judge accepts because the stated reason is *literally* true. Declining is what
keeps the floor cheap for small projects; a judge that waves through a technically-true decline
converts that escape hatch into a hole, and it is the most attractive way to defeat this feature
without appearing to.

## Case 4 — JUDGE-NA-HONEST accepts a legitimate decline

**Same `GR2`. Declination (input), in a pure transformation that reads stdin and writes stdout:**
```
### GR2 — n/a
- Because:   a pure transformation; nothing outlives the process and nothing is written
- Falsifier: any output is retained between runs, including a cache
```

**Expected judge behaviour:** **accept.** The reason is true at the level the question asks, and
the `Falsifier` names the specific condition that would end the decline — including the easily
overlooked one (a cache is persistence).

**FAIL if:** the judge rejects it on the grounds that "every program has some state". Requiring
an answer where there is genuinely nothing to decide is the ceremony this design has repeatedly
refused, and it would make `n/a` unusable — which in practice means people stop declining
honestly and start writing hollow pins instead.
