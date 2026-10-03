# State of the art: agent memory, lessons, and checks (2024–2026)

## 1. How systems store, update and curate lessons

**ACE (Agentic Context Engineering, ICLR 2026).** Three roles: the Generator runs tasks, the Reflector extracts insights, the Curator turns them into delta updates. The context is a list of bullets. Each bullet has an ID and helpful/harmful counters. Deltas are merged by "lightweight, non-LLM logic". "Grow-and-refine" appends new bullets and updates existing ones in place. It de-duplicates by comparing semantic embeddings, either after each delta or only when the context overflows. https://arxiv.org/html/2510.04618
- Mechanical: IDs, counters, merging, embedding de-dup (default cosine threshold 0.9). https://github.com/ace-agent/ace
- Semantic: the Reflector tags bullets helpful or harmful. The Curator writes the bullet text.
- Deletion: the paper says "pruning". It does not say what is pruned. No exact rule found.
- Stated limit: ACE "relies on a reasonably strong Reflector". A weak one makes the context "noisy or even harmful". https://arxiv.org/html/2510.04618

**Dynamic Cheatsheet.** One LLM acts as the curator. It has no ground truth. It must judge correctness by itself. It refines or removes wrong entries and keeps memory compact. Faulty heuristics "can be equally amplified". Small models stalled because the memory filled with wrong attempts. https://arxiv.org/html/2504.07952v1

**Reflexion.** Reflections go in a buffer capped at Ω = 1–3 items. No curation; old items fall off. Evaluators were exact match, heuristics, an LLM, or self-written unit tests. Flaky self-written tests can pass a wrong solution. https://ar5iv.labs.arxiv.org/html/2303.11366

**ExpeL (AAAI 2024).** An LLM applies ADD, EDIT, UPVOTE or DOWNVOTE to an insight list. A new insight starts at importance 2. At 0 it is deleted. https://ar5iv.labs.arxiv.org/html/2308.10144

**Voyager.** A skill enters the library only after self-verification says the task succeeded. The key is an embedding of an LLM-written description. Retrieval takes the top 5. https://ar5iv.labs.arxiv.org/html/2305.16291 If a skill name already exists, the code deletes the old vector entry and saves a new version file (`nameV2`). https://github.com/MineDojo/Voyager/blob/main/voyager/agents/skill.py

**Mem0.** An LLM picks ADD, UPDATE, DELETE or NOOP for each new fact. It compares against the top 10 similar memories found by embeddings. DELETE handles contradictions. The graph variant marks relations invalid instead of deleting them. https://arxiv.org/html/2504.19413

**Zep/Graphiti.** An LLM compares a new edge with related edges. A contradicted edge gets an end date. Nothing is deleted; history stays. https://arxiv.org/html/2501.13956

**MemGPT/Letta.** Core memory blocks are always in context and have character limits. The agent edits them with tools. Last write wins. https://docs.letta.com/guides/agents/memory-blocks "Sleep-time" agents reorganize memory in the background, because memories "may become messy and disorganized over time". https://www.letta.com/blog/sleep-time-compute

**Claude Code.** CLAUDE.md is written by humans. Auto memory is written by Claude. Both are "context, not enforced configuration". The docs say: "if two instructions contradict each other, Claude may pick one arbitrarily." Detection is by a model: `/doctor prompt-audit` looks for conflicts and stale content and proposes edits. Nothing changes until you approve. Auto memory loads the first 200 lines or 25KB of MEMORY.md. Near the limit, the tool tells Claude to "merge or drop stale entries". Topic files load on demand. https://code.claude.com/docs/en/memory Skills load only name and description at start; the body loads when used. https://code.claude.com/docs/en/skills

**Codex AGENTS.md.** Files are concatenated from repo root down to the working directory. Closer files override because they come later. Combined size stops at 32 KiB. No conflict detection is described. https://learn.chatgpt.com/docs/agent-configuration/agents-md

**Cursor rules.** Four modes: always, by description, by glob, manual. Keep rules under 500 lines. Conflicts are resolved by a fixed precedence: team, then project, then user. https://cursor.com/docs/context/rules

**Devin Knowledge.** Devin suggests items from feedback. A human edits, saves or dismisses. Items load by trigger. https://docs.devin.ai/product-guides/knowledge

**OpenAI cookbook (memory notes).** An LLM consolidates session notes into global notes. It removes exact and near duplicates. On conflict, the newest note wins. https://developers.openai.com/cookbook/examples/agents_sdk/context_personalization

**Pattern.** Storage, IDs, counters and precedence are code. Deciding "same meaning" or "contradicts" is always a model, sometimes after an embedding prefilter. Mature systems prefer invalidate, version or downvote over silent delete.

## 2. Whole memory vs retrieval

- Whole-in-context: Letta core blocks, CLAUDE.md, AGENTS.md, Cursor "always" rules, ACE playbooks. All have size caps.
- Retrieved: Voyager (top 5), Dynamic Cheatsheet DC-RS (top 3), Mem0 (top 10), Devin, Claude Code skills and topic files.
- Anthropic calls Claude Code a hybrid: CLAUDE.md goes in up front; the rest is fetched just in time. Goal: "the smallest possible set of high-signal tokens". https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- OpenAI's cookbook argues the other way for preferences: retrieval is "brittle to phrasing, prone to missing overrides, and unable to reconcile conflicts". https://developers.openai.com/cookbook/examples/agents_sdk/context_personalization
- Mem0 vs full context on LOCOMO: full context scored higher (≈73% vs 67% judge score) but had 17.1 s vs 1.44 s p95 latency. https://arxiv.org/html/2504.19413

**Context collapse.** In Dynamic Cheatsheet, a rewrite shrank memory from 18,282 tokens to 122. Accuracy fell from 66.7 to 57.1, below the 63.7 baseline. **Brevity bias:** optimizers drop domain heuristics and failure modes for short summaries. ACE answers both with itemized delta updates, not full rewrites. https://arxiv.org/html/2510.04618

**Context rot.** Chroma tested 18 models. All degraded as input grew, even on simple tasks. Distractors made it worse. On LongMemEval, ~300 focused tokens beat ~113k full tokens. https://www.trychroma.com/research/context-rot Mid-context facts are used worst. https://aclanthology.org/2024.tacl-1.9/ Claude Code docs: files over 200 lines "reduce adherence". https://code.claude.com/docs/en/memory

## 3. Detecting contradictions

- LLM judge: Mem0, Zep, Dynamic Cheatsheet, OpenAI cookbook, Claude Code prompt-audit. Usually an embedding search first narrows candidates.
- Embeddings alone: only for de-dup (ACE, OpenAI).
- Human: Devin approval, Claude Code prompt-audit approval, Cursor precedence.
- NLI models in agent memory: no source found.
- Measured accuracy: ConInstruct (AAAI 2026) tests conflict detection inside instructions. Best F1 was 91.5% (DeepSeek-R1) and 87.3% (Claude Sonnet 4.5). Models often detect a conflict but do not report it. GPT-4o silently answered in 97.5% of cases with 1–2 conflicts. https://arxiv.org/html/2511.14342v1
- Accuracy for rule-vs-principle conflicts in a coding harness: no source found.
- Regex or number matching for contradiction: no source found. No system uses it.

## 4. Lesson lifecycle and promotion

- Counters as usage evidence: ACE helpful/harmful counts per bullet (https://arxiv.org/html/2510.04618). ExpeL importance counts with deletion at 0 (https://ar5iv.labs.arxiv.org/html/2308.10144).
- Promotion to enforcement: Claude Code says rules that must always hold belong in hooks or permission settings, not CLAUDE.md. https://code.claude.com/docs/en/memory
- OpenAI's harness team enforced architecture "mechanically via custom linters". Lint messages carry the fix. A background agent finds stale docs and opens cleanup PRs. AGENTS.md is a short map. https://openai.com/index/harness-engineering/ (primary blocked our fetcher; quotes via https://www.ignorance.ai/p/the-emerging-harness-engineering)
- "Used" vs "captured": ACE counters are the closest. Claude Code `/skill-doctor` flags unused costly skills (https://code.claude.com/docs/en/skills). The `InstructionsLoaded` hook logs what loaded, not what was applied (https://code.claude.com/docs/en/memory). A system that tracks "captured but never used" for lessons: no source found.

## 5. Mechanical vs semantic checks

- Anthropic: code graders are "fast, cheap, objective, reproducible" but "brittle to acceptable variations". Model graders are flexible but non-deterministic and need calibration. Example: a rigid grader rejected "96.12" for "96.124991…". Advice: "read the transcripts". https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Hamel Husain: treat a judge as a binary classifier. Label data with an expert. Split train/dev/test. Report true-positive and true-negative rates, not raw agreement. Use a code assertion when error analysis shows one suffices. https://hamel.dev/blog/posts/llm-judge/
- Shankar et al.: criteria drift. You learn the criteria by grading real outputs. Validate any check, code or LLM, against human labels. https://arxiv.org/abs/2404.12272
- Reflexion: weak tests give false positives and false negatives. https://ar5iv.labs.arxiv.org/html/2303.11366

## Summary table

| practice | source | what it implies for our harness |
|---|---|---|
| Itemized delta updates, no full rewrites | ACE | Keep the table. Reflector emits row ops, never rewrites the file. |
| Code merges; model judges meaning | ACE, Mem0, Zep | Code owns IDs, counters, status. "Contradicts the constitution" is a model call. Drop the regex. |
| Embedding prefilter, LLM decides | Mem0, Zep | Optional. With a small constitution, put it all in the judge prompt. |
| Invalidate or version, don't delete | Zep, Voyager, ExpeL | Use `status: superseded` with a pointer. Keep history. |
| Counters drive retirement | ACE, ExpeL | Retire on harmful > helpful or unused for N runs. Define "used". |
| Size cap on always-loaded memory | Claude Code, Codex, Chroma | Cap the lessons table. Over the cap, consolidate or move to on-demand files. |
| Avoid collapse and brevity bias | ACE, DC | Never let the reflector summarize the whole table in one pass. |
| Contradictions get human approval | Claude Code prompt-audit, Devin | Judge flags a conflict; a human resolves it. Never auto-resolve against the constitution. |
| LLM conflict detection is ~87–91% F1 | ConInstruct | Expect misses. Ask the judge to name the conflicting clause. |
| Promote must-hold rules to hooks/lint | Claude Code, OpenAI harness | Lesson → lint/test is the endpoint. Lint text carries the fix. |
| Validate a check before trusting it | Anthropic evals, Hamel, Shankar | Run each new check on all real rows. Hand-label. Measure FP and FN. Gate only after that. |
