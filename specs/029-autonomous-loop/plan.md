# The Autonomous Loop — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 12-step harness workflow with four steps: brief, spec, build and accept. Gate H1 is the only owner approval. An agent-agnostic script runs build, and a machine verifies accept.

**Architecture:** Four `uv` scripts with inline dependencies. `spec.py` lints a spec and renders its page. `build.py` runs role prompts through CLI adapters from `harness.toml`. `accept.py` verifies, merges and writes results back. A `fake` adapter makes the whole loop testable with no model.

**Tech Stack:** Python ≥ 3.11 through `uv` (PEP 723 inline metadata), `markdown`, `jsonschema`, `pytest`. Claude Code CLI and Codex CLI as agent adapters.

**Spec:** `specs/029-autonomous-loop/spec.md`. It was approved at gate H1 on 2026-10-02, with every amendment M1–M8 and C1–C4.

## Global Constraints

- Every script starts with a PEP 723 block and `requires-python = ">=3.11"`. The system `python3` is 3.9 and has no `tomllib`. Always run scripts with `uv run`, never with `python3`. (D5)
- Inline dependencies are limited to `markdown>=3.6` (`spec.py`) and `jsonschema>=4` (`build.py`, `accept.py`). Any other dependency is a charter amendment. (M3)
- Prose in every new or edited `.md` file: sentences of 25 words or fewer. Tables, code blocks and quotes are exempt. (C1)
- All repo artifacts are in English. (constitution D2)
- Test names carry their example id: `test_e1_<words>`, `test_e10_<words>`. The selector `e1_` must not match `e10_`.
- A test does not mock the harness's own code. It runs the real script through `subprocess` with `uv run`. (spec 5.4)
- The harness's pytest suite runs with: `uv run --python 3.12 --with pytest pytest tests -q`.
- The old shell suite keeps running with `bash tests/run.sh`. Pytest is green at the end of every task. The shell suite is green at the end of T1–T4 and T6. T5 replaces templates and commands, so it may leave red only the shell checks that T6 deletes or edits.
- Commit on branch `029-autonomous-loop`. Never commit to `main`.

## Review Focus

1. **A spec with a pipe inside a table cell.** For example, `` `a | b` `` in a requirement. The cell parser splits it, and the row gets a wrong anchor. Expected: the lint reports the row as malformed, not as "no anchor". T1 pins this with `test_lint_pipe_in_code_cell`.
2. **Build starts on a dirty tree or on `main`.** Expected: exit 2 with a message, and nothing is reverted. T3 pins this with `test_build_refuses_dirty_tree` and `test_build_refuses_main`.
3. **An agent CLI exits non-zero or prints non-JSON.** For example, the user is not logged in. Expected: the attempt fails with `agent: exit N` or `agent: no JSON`, not a crash. T2 pins this with `test_call_agent_crash`.
4. **A task range like `B1–B10` with an en dash, or `D1–D3, D5`.** Expected: the ranges expand to all ids. T1 pins this with `test_ids_in_ranges`.
5. **Accept runs while the branch is behind `main`, so the merge conflicts.** Expected: exit 1 with `merge conflict`, the merge is aborted, and `main` is unchanged. T4 pins this with `test_accept_merge_conflict`.

---

## File structure

| path | responsibility |
| --- | --- |
| `scripts/spec.py` | parse spec tables; `lint`; `page` (create) |
| `scripts/build.py` | config, agent call, prompts, task loop, report (create) |
| `scripts/accept.py` | suite, map check, judge, merge, write-back, result page (create) |
| `scripts/fake_agent.py` | scripted agent for tests (create) |
| `harness.toml` | roles, CLIs, limits, checks, paths (create; SEED for adopters) |
| `harness/prompts/implementer.md`, `reviewer.md`, `judge.md` | role prompts, one source for every CLI (create) |
| `harness/schemas/implementer.json`, `reviewer.json`, `build-report.json` | output contracts (create) |
| `harness/steps/brief.md`, `spec.md`, `accept.md` | interactive step instructions, one source (create) |
| `AGENTS.md` | Codex entry point to `harness/steps/` (create) |
| `.claude/commands/brief.md`, `spec.md`, `build.md`, `accept.md` | Claude entry points to `harness/steps/` (create) |
| `tests/conftest.py` | `HARNESS` path, `run()` helper, `slice_repo` fixture (create) |
| `tests/test_spec.py`, `test_build.py`, `test_accept.py`, `test_harness.py` | pytest suite (create) |

---

### Task 1: Spec lint and spec page

**Files:**
- Create: `scripts/spec.py`
- Create: `tests/conftest.py`
- Create: `tests/test_spec.py`

**Interfaces:**
- Produces:
  - `cells(line: str) -> list[str]`
  - `tables(text: str) -> Iterator[tuple[str, list[str], list[dict[str, str]]]]`
  - `parse(text: str) -> dict`. Keys: `reqs: dict[id, row]`, `examples: dict[id, row]`, `tasks: list[row]`, `glossary: dict[term_lower, meaning]`, `new: list[row]`.
  - `ids_in(cell: str) -> list[str]`, which expands `B1–B10` and `D1–D3, D5`.
  - `lint(spec_text: str, ns_text: str) -> list[str]`, where each finding is one line.
  - CLI: `uv run scripts/spec.py lint SPEC [--north-star PATH]` and `uv run scripts/spec.py page SPEC [--north-star PATH] [--out PATH]`.

- [ ] **Step 1: Write `tests/conftest.py`**

```python
import subprocess
from pathlib import Path

import pytest

HARNESS = Path(__file__).resolve().parent.parent

NS = """# North Star
| term | meaning |
| --- | --- |
| **budget** | max tokens for one slice |

Pillars: real-enforcement, measurable-impact.
"""


def run(*args, cwd=None, env=None, check=False):
    """Run a command; return CompletedProcess with text output."""
    p = subprocess.run(list(args), cwd=cwd, env=env, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise AssertionError(p.stdout + p.stderr)
    return p


def spec_cmd(*args, cwd=None):
    return run("uv", "run", "-q", str(HARNESS / "scripts/spec.py"), *args, cwd=cwd)


@pytest.fixture
def ns_file(tmp_path):
    f = tmp_path / "north-star.md"
    f.write_text(NS)
    return f
```

- [ ] **Step 2: Write the failing tests in `tests/test_spec.py`**

```python
from conftest import spec_cmd

REQ_HEAD = "| id | requirement | anchor | examples |\n| --- | --- | --- | --- |\n"
EX_HEAD = "| id | given | when | then |\n| --- | --- | --- | --- |\n| E1 | a | b | c |\n"
TASK_HEAD = "| task | does | requirements |\n| --- | --- | --- |\n"


def lint(tmp_path, ns_file, body):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n" + body)
    return spec_cmd("lint", str(f), "--north-star", str(ns_file))


def test_e1_undefined_bold_term(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall check the **universe**. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1
    assert "S1: undefined term 'universe'" in p.stdout


def test_e1_defined_term_passes(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall check the **budget**. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 0, p.stdout


def test_e2_long_sentence(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, " ".join(["word"] * 26) + ".\n")
    assert p.returncode == 1
    assert "line 3" in p.stdout and "26 words" in p.stdout


def test_e3_not_ears(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | The data must be fresh. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1 and "S1: not EARS" in p.stdout


def test_e3_if_without_then(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | If it breaks, the lint shall fail. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert "S1: not EARS" in p.stdout


def test_e4_no_anchor(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. |  | E1 |\n\n" + EX_HEAD)
    assert p.returncode == 1 and "S1: no anchor" in p.stdout


def test_e4_anchor_not_in_north_star(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | made-up-pillar | E1 |\n\n" + EX_HEAD)
    assert "S1: anchor 'made-up-pillar' not in north star" in p.stdout


def test_e5_no_example(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement |  |\n")
    assert p.returncode == 1 and "S1: no example" in p.stdout


def test_e5_judged_passes(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | judged, rubric R1 |\n")
    assert p.returncode == 0, p.stdout


def test_e5_unknown_example(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E9 |\n")
    assert "S1: unknown example E9" in p.stdout


def test_e6_task_cites_no_requirement(tmp_path, ns_file):
    body = REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E1 |\n\n" + EX_HEAD + "\n" + TASK_HEAD + "| T3 | do it | nothing |\n"
    p = lint(tmp_path, ns_file, body)
    assert p.returncode == 1 and "T3: cites no requirement" in p.stdout


def test_e7_new_module_without_justification(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, "| item | justification |\n| --- | --- |\n| new module: edgar_client |  |\n")
    assert p.returncode == 1 and "edgar_client: no justification" in p.stdout


def test_e8_page_written(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec X\n\n## Glossary\n\n| term | meaning |\n| --- | --- |\n| **slice** | one feature |\n\n"
                 + REQ_HEAD + "| S1 | When it runs, the lint shall pass. | real-enforcement | E1 |\n\n## Examples\n\n" + EX_HEAD
                 + "\n## Plan\n\n" + TASK_HEAD + "| T1 | do | S1 |\n")
    p = spec_cmd("page", str(f), "--north-star", str(ns_file))
    assert p.returncode == 0, p.stdout + p.stderr
    html = (tmp_path / "spec.html").read_text()
    for s in ("<title>Spec X</title>", "slice", "S1", "E1", "Plan"):
        assert s in html


def test_e9_amendments_section(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n## Amendments\n\n| # | field | now | proposed |\n| --- | --- | --- | --- |\n| M1 | out_of_scope | a | b |\n")
    spec_cmd("page", str(f), "--north-star", str(ns_file))
    html = (tmp_path / "spec.html").read_text()
    assert 'id="amendments"' in html and "M1" in html


def test_page_refuses_failing_lint(tmp_path, ns_file):
    f = tmp_path / "spec.md"
    f.write_text("# Spec\n\n" + REQ_HEAD + "| S1 | The data must be fresh. | real-enforcement | E1 |\n")
    p = spec_cmd("page", str(f), "--north-star", str(ns_file))
    assert p.returncode == 1 and not (tmp_path / "spec.html").exists()


def test_ids_in_ranges(tmp_path, ns_file):
    body = (REQ_HEAD + "".join(f"| B{i} | When it runs, the lint shall pass. | real-enforcement | E1 |\n" for i in range(1, 11))
            + "\n" + EX_HEAD + "\n" + TASK_HEAD + "| T1 | a | B1–B10 |\n| T2 | b | B1-B3, B5 |\n")
    p = lint(tmp_path, ns_file, body)
    assert p.returncode == 0, p.stdout


def test_lint_pipe_in_code_cell(tmp_path, ns_file):
    p = lint(tmp_path, ns_file, REQ_HEAD + "| S1 | When it runs, the lint shall read `a | b`. | real-enforcement | E1 |\n\n" + EX_HEAD)
    assert "S1: malformed row" in p.stdout


def test_lint_runs_on_spec_029():
    from conftest import HARNESS
    p = spec_cmd("lint", str(HARNESS / "specs/029-autonomous-loop/spec.md"),
                 "--north-star", str(HARNESS / "memory/north-star/north-star.md"))
    assert p.returncode == 0, p.stdout
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `cd /Users/marcote/Code/agentic-sdlc && uv run --python 3.12 --with pytest pytest tests/test_spec.py -q`
Expected: every test FAILS, because `scripts/spec.py` does not exist (uv reports a missing file).

- [ ] **Step 4: Write `scripts/spec.py`**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["markdown>=3.6"]
# ///
"""spec.py — lint a spec and render its spec page.

  uv run scripts/spec.py lint SPEC [--north-star PATH]
  uv run scripts/spec.py page SPEC [--north-star PATH] [--out PATH]

Exit: 0 clean · 1 findings · 2 unusable input.
"""
import argparse
import re
import sys
from pathlib import Path

MAX_WORDS = 25
EARS = re.compile(r"^(When|While|If|Where|The|For each)\b.*\bshall\b", re.S)
SEP = re.compile(r"^\|[\s:|-]+\|$")


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def tables(text):
    """Yield (heading, header, rows) per markdown table. A row is a dict keyed by header."""
    heading, lines, i = "", text.splitlines(), 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("#"):
            heading = line.lstrip("#").strip()
        if line.startswith("|") and i + 1 < len(lines) and SEP.match(lines[i + 1].strip()):
            head, rows, i = cells(line), [], i + 2
            while i < len(lines) and lines[i].startswith("|"):
                c = cells(lines[i])
                row = dict(zip(head, c + [""] * (len(head) - len(c))))
                # ponytail: a pipe inside a code span splits the cell; flag it instead of parsing it
                row["_malformed"] = len(c) != len(head)
                rows.append(row)
                i += 1
            yield heading, head, rows
            continue
        i += 1


def parse(text):
    out = {"reqs": {}, "examples": {}, "tasks": [], "glossary": {}, "new": []}
    for _, head, rows in tables(text):
        if head[:4] == ["id", "requirement", "anchor", "examples"]:
            out["reqs"].update({r["id"]: r for r in rows})
        elif head[:4] == ["id", "given", "when", "then"]:
            out["examples"].update({r["id"]: r for r in rows})
        elif head[:3] == ["task", "does", "requirements"]:
            out["tasks"] += rows
        elif head[:2] == ["term", "meaning"]:
            out["glossary"].update({r["term"].strip("*").lower(): r["meaning"] for r in rows})
        elif head[:2] == ["item", "justification"]:
            out["new"] += rows
    return out


def ids_in(cell):
    found = []
    for p, a, b in re.findall(r"\b([A-Z])(\d+)(?:\s*[–-]\s*[A-Z]?(\d+))?", cell):
        found += [f"{p}{n}" for n in range(int(a), int(b or a) + 1)]
    return found


def prose(text):
    out, fenced = [], False
    for n, line in enumerate(text.splitlines(), 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced or line.startswith(("|", ">", "#")):
            continue
        s = re.sub(r"`[^`]*`", "X", line)
        for part in re.split(r"(?<=[.:;!?])\s+", s):
            k = len(part.split())
            if k > MAX_WORDS:
                out.append(f"line {n}: {k} words: {part.strip()[:50]}…")
    return out


def lint(spec_text, ns_text):
    s, ns = parse(spec_text), parse(ns_text)
    terms = s["glossary"] | ns["glossary"]
    out = prose(spec_text)
    for rid, r in s["reqs"].items():
        if r["_malformed"]:
            out.append(f"{rid}: malformed row")
            continue
        text = r["requirement"]
        out += [f"{rid}: undefined term '{t}'" for t in re.findall(r"\*\*(.+?)\*\*", text) if t.lower() not in terms]
        if not EARS.match(text) or (text.startswith("If") and " then " not in text):
            out.append(f"{rid}: not EARS")
        anchor = r["anchor"]
        if not anchor:
            out.append(f"{rid}: no anchor")
        elif anchor not in ns_text:  # ponytail: verbatim presence, not a parsed anchor list
            out.append(f"{rid}: anchor '{anchor}' not in north star")
        if "judged" in r["examples"]:
            continue
        ex = re.findall(r"E\d+", r["examples"])
        if not ex:
            out.append(f"{rid}: no example")
        out += [f"{rid}: unknown example {e}" for e in ex if e not in s["examples"]]
    for t in s["tasks"]:
        if not any(i in s["reqs"] for i in ids_in(t["requirements"])):
            out.append(f"{t['task']}: cites no requirement")
    for r in s["new"]:
        if not r["justification"]:
            out.append(f"{r['item'].split(':', 1)[-1].strip()}: no justification")
    return out


PAGE = """<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title}</title>
<style>
:root{{--bg:#f6f7f5;--fg:#1c2321;--mut:#5b6662;--rule:#d7ddd9;--acc:#0f5f6e;--warn:#9a5b00}}
@media (prefers-color-scheme:dark){{:root{{--bg:#121615;--fg:#e4e9e6;--mut:#9aa6a1;--rule:#2d3533;--acc:#6cc3d1;--warn:#f0b65a;color-scheme:dark}}}}
body{{background:var(--bg);color:var(--fg);font:15px/1.6 system-ui,sans-serif;max-width:1000px;margin:0 auto;padding:24px 16px}}
h1,h2,h3{{text-wrap:balance}} h2{{border-top:1px solid var(--rule);padding-top:12px}}
#amendments{{color:var(--warn)}}
table{{border-collapse:collapse;width:100%;font-size:14px;display:block;overflow-x:auto}}
th,td{{border-bottom:1px solid var(--rule);padding:6px 10px;text-align:left;vertical-align:top}}
code{{font-family:ui-monospace,Menlo,monospace;font-size:.9em}} img{{max-width:100%}}
</style>
{body}
"""


def page(spec_path, out_path):
    import markdown

    text = spec_path.read_text()
    title = (re.search(r"^# (.+)$", text, re.M) or [None, spec_path.parent.name])[1]
    md = markdown.Markdown(extensions=["tables", "fenced_code", "toc"])
    body = md.convert(text)
    # the toc extension slugs "7. Amendments" as "7-amendments"; give the section a stable id
    body = re.sub(r'<h2 id="[^"]*amendments[^"]*">', '<h2 id="amendments">', body)
    out_path.write_text(PAGE.format(title=title, body=body))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["lint", "page"])
    ap.add_argument("spec", type=Path)
    ap.add_argument("--north-star", type=Path, default=Path("memory/north-star/north-star.md"))
    ap.add_argument("--out", type=Path)
    a = ap.parse_args()
    if not a.spec.is_file() or not a.north_star.is_file():
        print(f"spec: missing {a.spec if not a.spec.is_file() else a.north_star}", file=sys.stderr)
        return 2
    findings = lint(a.spec.read_text(), a.north_star.read_text())
    print("\n".join(findings) or "lint: clean")
    if findings:
        return 1
    if a.cmd == "page":
        out = a.out or a.spec.with_suffix(".html")
        page(a.spec, out)
        print(f"page: {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `uv run --python 3.12 --with pytest pytest tests/test_spec.py -q`
Expected: all PASS. If `test_lint_runs_on_spec_029` fails, read its findings. Fix the spec only when the finding is a real defect of the spec. Fix `spec.py` when the finding is a false positive. Record which one it was in the commit message.

- [ ] **Step 6: Dogfood on this spec**

Run: `uv run scripts/spec.py page specs/029-autonomous-loop/spec.md --north-star memory/north-star/north-star.md --out /tmp/029-generated.html`
Expected: `lint: clean` and `page: /tmp/029-generated.html`. Do not overwrite `specs/029-autonomous-loop/spec.html`: it is the hand-made page the owner approved.

- [ ] **Step 7: Commit**

```bash
git add scripts/spec.py tests/conftest.py tests/test_spec.py
git commit -m "feat(029): T1 spec lint and spec page — S1–S9"
```

---

### Task 2: Adapters and the agent call

**Files:**
- Create: `harness.toml`
- Create: `harness/schemas/implementer.json`, `harness/schemas/reviewer.json`
- Create: `scripts/fake_agent.py`
- Create: `scripts/build.py` (config, `dig`, `call`, `--help` only)
- Create: `tests/test_build.py`
- Modify: `tests/conftest.py` (add `slice_repo`)

**Interfaces:**
- Consumes: nothing from T1.
- Produces:
  - `load_config(path: Path) -> dict`
  - `dig(doc: dict, path: str) -> Any`, which returns `0` for a missing numeric path.
  - `call(cfg: dict, role: str, prompt: str, report: dict) -> tuple[dict | None, str]`. It returns `(payload, "")` on success, or `(None, reason)`. It adds the call's tokens to `report["tokens"]`.
  - `class Budget(Exception)`, raised by `call` when `report["tokens"] > cfg["limits"]["budget_tokens"]`.
  - `HARNESS: Path`, the harness root.
  - `fake_agent.py ROLE PROMPT`. It reads the `FAKE_PLAN` JSON (`{role: [response, …]}`) and pops the responses in order; the last one repeats. It writes the files in `_write`, appends `{"role", "prompt"}` to `FAKE_LOG`, and prints the response.

- [ ] **Step 1: Write the schemas**

`harness/schemas/implementer.json`:

```json
{
  "type": "object",
  "required": ["status", "summary", "assumptions", "reused", "new_deps"],
  "properties": {
    "status": {"enum": ["done", "blocked"]},
    "summary": {"type": "string"},
    "assumptions": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["text", "severity"],
        "properties": {"text": {"type": "string"}, "severity": {"enum": ["minor", "structural"]}}
      }
    },
    "reused": {"type": "array", "items": {"type": "string"}},
    "new_deps": {"type": "array", "items": {"type": "string"}}
  }
}
```

`harness/schemas/reviewer.json`:

```json
{
  "type": "object",
  "required": ["verdict", "findings"],
  "properties": {
    "verdict": {"enum": ["pass", "fix"]},
    "findings": {"type": "array", "items": {"type": "string"}}
  }
}
```

- [ ] **Step 2: Write `harness.toml`**

```toml
# harness.toml — which agent CLI fills each role, and how build and accept check the work.
# Placeholders in cmd: {prompt} {role} {schema} {schema_json} {out} {harness}

[roles]
implementer = "claude"
reviewer = "claude-ro"
judge = "codex"          # A7: the judge's family must differ from the implementer's

[limits]
attempts = 3
budget_tokens = 3_000_000

[checks]
# {examples} expands to a pytest -k selector such as "e1_ or e2_"
task = "uv run --python 3.12 --with pytest pytest tests -q -k '{examples}'"
suite = "uv run --python 3.12 --with pytest pytest tests -q && bash tests/run.sh"
red_exit = 1

[paths]
north_star = "memory/north-star/north-star.md"
charter = "memory/stack/stack.md"
module_map = "docs/modules.md"
module_root = "src"

[cli.claude]
family = "anthropic"
cmd = ["claude", "-p", "{prompt}", "--output-format", "json", "--json-schema", "{schema_json}",
       "--permission-mode", "acceptEdits", "--allowedTools", "Read", "Edit", "Write", "Bash(uv run:*)"]
payload = "structured_output"
tokens = ["usage.input_tokens", "usage.output_tokens", "usage.cache_creation_input_tokens", "usage.cache_read_input_tokens"]

[cli.claude-ro]
family = "anthropic"
cmd = ["claude", "-p", "{prompt}", "--output-format", "json", "--json-schema", "{schema_json}", "--permission-mode", "plan"]
payload = "structured_output"
tokens = ["usage.input_tokens", "usage.output_tokens", "usage.cache_creation_input_tokens", "usage.cache_read_input_tokens"]

[cli.codex]
family = "openai"
cmd = ["codex", "exec", "--full-auto", "--output-schema", "{schema}", "--output-last-message", "{out}", "{prompt}"]
payload = "@out"
tokens = []

[cli.fake]
family = "fake"
cmd = ["uv", "run", "-q", "{harness}/scripts/fake_agent.py", "{role}", "{prompt}"]
payload = ""
tokens = ["tokens"]

[cli.fake-judge]
family = "fake-2"
cmd = ["uv", "run", "-q", "{harness}/scripts/fake_agent.py", "{role}", "{prompt}"]
payload = ""
tokens = ["tokens"]
```

- [ ] **Step 3: Write `scripts/fake_agent.py`**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""fake_agent.py ROLE PROMPT — a scripted agent for tests.

FAKE_PLAN: JSON file {role: [response, ...]}; responses pop in order, the last one repeats.
A response may carry "_write": {path: content} to simulate edits. FAKE_LOG: JSON lines of calls.
"""
import json
import os
import sys
from pathlib import Path

role, prompt = sys.argv[1], sys.argv[2]
plan_file = Path(os.environ["FAKE_PLAN"])
plan = json.loads(plan_file.read_text())
queue = plan.get(role) or [{}]
resp = queue.pop(0) if len(queue) > 1 else queue[0]
plan_file.write_text(json.dumps(plan))
with open(os.environ["FAKE_LOG"], "a") as log:
    log.write(json.dumps({"role": role, "prompt": prompt}) + "\n")
resp = dict(resp)
for path, content in resp.pop("_write", {}).items():
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(content)
if resp.pop("_crash", False):
    sys.exit(7)
print(json.dumps(resp))
```

- [ ] **Step 4: Add the `slice_repo` fixture to `tests/conftest.py`**

Append:

```python
import json
import os

SLICE_SPEC = """# Slice add

| term | meaning |
| --- | --- |
| **sum** | the result of add |

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| R1 | When add runs, the module shall return the **sum**. | real-enforcement | E1 |
| R2 | When sub runs, the module shall return the difference. | real-enforcement | E2 |

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | 2 and 3 | add runs | 5 |
| E2 | 5 and 3 | sub runs | 2 |

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | write add in calc.py | R1 | |
| T2 | write sub in calc.py, UNIQUE_T2_TEXT | R2 | |
"""

# imports sit inside the test, so a missing module fails the test (exit 1) instead of breaking collection (exit 2)
TEST_E1 = "def test_e1_add():\n    from calc import add\n    assert add(2, 3) == 5\n"
TEST_E2 = "def test_e2_sub():\n    from calc import sub\n    assert sub(5, 3) == 2\n"
OK = {"status": "done", "summary": "ok", "assumptions": [], "reused": [], "new_deps": [], "tokens": 10}
PASS = {"verdict": "pass", "findings": [], "tokens": 10}


class Slice:
    def __init__(self, root):
        self.root = root
        self.dir = root / "specs/001-add"
        self.log = root / ".fake_log"
        self.plan = root / ".fake_plan"

    def script(self, implementer, reviewer=None, judge=None):
        plan = {"implementer": implementer, "reviewer": reviewer or [PASS], "judge": judge or [PASS]}
        self.plan.write_text(json.dumps(plan))

    def env(self):
        return {**os.environ, "FAKE_PLAN": str(self.plan), "FAKE_LOG": str(self.log)}

    def calls(self):
        if not self.log.exists():
            return []
        return [json.loads(l) for l in self.log.read_text().splitlines()]

    def build(self, *args):
        return run("uv", "run", "-q", str(HARNESS / "scripts/build.py"), str(self.dir), *args, cwd=self.root, env=self.env())

    def accept(self, *args):
        return run("uv", "run", "-q", str(HARNESS / "scripts/accept.py"), str(self.dir), *args, cwd=self.root, env=self.env())

    def report(self):
        return json.loads((self.dir / "build-report.json").read_text())

    def git(self, *args):
        return run("git", *args, cwd=self.root, check=True).stdout


@pytest.fixture
def slice_repo(tmp_path):
    root = tmp_path / "repo"
    root.mkdir()
    s = Slice(root)
    s.dir.mkdir(parents=True)
    (s.dir / "spec.md").write_text(SLICE_SPEC)
    (root / "memory/north-star").mkdir(parents=True)
    (root / "memory/north-star/north-star.md").write_text(NS)
    (root / "tests").mkdir()
    (root / "tests/conftest.py").write_text("import sys, pathlib\nsys.path.insert(0, str(pathlib.Path(__file__).parent.parent))\n")
    cfg = (HARNESS / "harness.toml").read_text()
    cfg = cfg.replace('implementer = "claude"', 'implementer = "fake"')
    cfg = cfg.replace('reviewer = "claude-ro"', 'reviewer = "fake"')
    cfg = cfg.replace('judge = "codex"', 'judge = "fake-judge"')
    cfg = cfg.replace(" && bash tests/run.sh", "")
    (root / "harness.toml").write_text(cfg)
    (root / ".gitignore").write_text(".fake_log\n.fake_plan\n__pycache__/\n.pytest_cache/\n")
    run("git", "init", "-q", "-b", "main", cwd=root, check=True)
    run("git", "-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "--allow-empty", "-m", "root", cwd=root, check=True)
    run("git", "add", "-A", cwd=root, check=True)
    run("git", "-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "-m", "spec", cwd=root, check=True)
    run("git", "checkout", "-q", "-b", "001-add", cwd=root, check=True)
    run("git", "config", "user.email", "t@t", cwd=root, check=True)
    run("git", "config", "user.name", "t", cwd=root, check=True)
    return s
```

- [ ] **Step 5: Write the failing tests in `tests/test_build.py`**

```python
import json
import os

from conftest import HARNESS, OK, PASS, TEST_E1, run


def call_once(slice_repo, response):
    """Run build.call() once, in-process via a tiny uv script, and return its JSON result."""
    slice_repo.script([response])
    code = (
        "import sys, json; sys.path.insert(0, %r)\n"
        "import build\n"
        "cfg = build.load_config(build.Path('harness.toml'))\n"
        "rep = {'tokens': 0}\n"
        "p, why = build.call(cfg, 'implementer', 'hello', rep)\n"
        "print(json.dumps({'payload': p, 'why': why, 'tokens': rep['tokens']}))\n"
    ) % str(HARNESS / "scripts")
    p = run("uv", "run", "-q", "--python", "3.12", "--with", "jsonschema", "python", "-c", code,
            cwd=slice_repo.root, env=slice_repo.env())
    assert p.returncode == 0, p.stderr
    return json.loads(p.stdout.splitlines()[-1])


def test_e25_fake_receives_implementer_call(slice_repo):
    out = call_once(slice_repo, OK)
    assert out["why"] == "" and out["payload"]["status"] == "done"
    assert slice_repo.calls()[0]["role"] == "implementer"
    assert out["tokens"] == 10


def test_e26_schema_violation(slice_repo):
    out = call_once(slice_repo, {"status": 5})
    assert out["payload"] is None and out["why"] == "schema: status"


def test_call_agent_crash(slice_repo):
    out = call_once(slice_repo, {"_crash": True})
    assert out["payload"] is None and out["why"].startswith("agent: exit 7")


def test_e29_help_runs_with_no_install(tmp_path):
    p = run("uv", "run", "-q", str(HARNESS / "scripts/build.py"), "--help", cwd=tmp_path)
    assert p.returncode == 0 and "usage" in p.stdout.lower()


def test_e27_real_agents(slice_repo):
    import pytest
    clis = [c for c in os.environ.get("RUN_REAL_AGENTS", "").split(",") if c]
    if not clis:
        pytest.skip("set RUN_REAL_AGENTS=claude,codex to call real CLIs (costs tokens)")
    for cli in clis:
        cfg = (slice_repo.root / "harness.toml").read_text()
        cfg = cfg.replace('implementer = "fake"', f'implementer = "{cli}"')
        (slice_repo.root / "harness.toml").write_text(cfg)
        slice_repo.script([OK])
        code = (
            "import sys, json; sys.path.insert(0, %r)\nimport build\n"
            "cfg = build.load_config(build.Path('harness.toml'))\n"
            "p, why = build.call(cfg, 'implementer', 'Create calc.py with def add(a, b): return a + b, "
            "and tests/test_e1_add.py asserting add(2, 3) == 5. Report status done.', {'tokens': 0})\n"
            "print(json.dumps({'payload': p, 'why': why}))\n"
        ) % str(HARNESS / "scripts")
        p = run("uv", "run", "-q", "--python", "3.12", "--with", "jsonschema", "python", "-c", code,
                cwd=slice_repo.root, env=slice_repo.env())
        out = json.loads(p.stdout.splitlines()[-1])
        assert out["why"] == "", f"{cli}: {out['why']}"
        t = run("uv", "run", "--python", "3.12", "--with", "pytest", "pytest", "-q", "-k", "e1_", cwd=slice_repo.root)
        assert t.returncode == 0, f"{cli}: {t.stdout}"
        run("git", "clean", "-fdq", "-e", ".fake_*", cwd=slice_repo.root)
```

- [ ] **Step 6: Run the tests to verify they fail**

Run: `uv run --python 3.12 --with pytest pytest tests/test_build.py -q`
Expected: FAIL for E25, E26, the crash test and E29, because `scripts/build.py` does not exist. E27 is SKIPPED with its reason.

- [ ] **Step 7: Write `scripts/build.py`, part 1 (config and call)**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["jsonschema>=4"]
# ///
"""build.py — implement the plan of an approved spec, without the owner.

  uv run scripts/build.py SPEC_DIR [--config harness.toml]

Exit: 0 every task done · 3 escalations (listed once, see build-report.json) · 2 unusable input.
"""
import argparse
import json
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

import jsonschema

HARNESS = Path(__file__).resolve().parent.parent
SCHEMAS = HARNESS / "harness/schemas"
SCHEMA_OF = {"implementer": "implementer", "reviewer": "reviewer", "judge": "reviewer"}


class Budget(Exception):
    pass


def load_config(path):
    return tomllib.loads(Path(path).read_text())


def dig(doc, path):
    for k in path.split("."):
        if not isinstance(doc, dict) or k not in doc:
            return 0
        doc = doc[k]
    return doc


def schema_error(payload, schema):
    errs = sorted(jsonschema.Draft202012Validator(schema).iter_errors(payload), key=lambda e: (not e.path, e.message))
    if not errs:
        return ""
    e = errs[0]
    return "schema: " + (".".join(map(str, e.path)) or e.message)


def call(cfg, role, prompt, report):
    cli = cfg["cli"][cfg["roles"][role]]
    schema_path = SCHEMAS / f"{SCHEMA_OF[role]}.json"
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "out.json"
        subs = {"{prompt}": prompt, "{role}": role, "{schema}": str(schema_path),
                "{schema_json}": schema_path.read_text(), "{out}": str(out)}
        argv = [subs.get(a, a).replace("{harness}", str(HARNESS)) for a in cli["cmd"]]
        p = subprocess.run(argv, capture_output=True, text=True)
        if p.returncode != 0:
            return None, f"agent: exit {p.returncode}: {(p.stderr or p.stdout).strip()[-300:]}"
        raw = out.read_text() if cli["payload"] == "@out" and out.exists() else p.stdout
    try:
        doc = json.loads(raw)
    except json.JSONDecodeError:
        return None, "agent: no JSON"
    report["tokens"] = report.get("tokens", 0) + sum(dig(doc, k) or 0 for k in cli.get("tokens", []))
    if report["tokens"] > cfg["limits"]["budget_tokens"]:
        raise Budget(f"budget exceeded: {report['tokens']} > {cfg['limits']['budget_tokens']} tokens")
    payload = doc if cli["payload"] in ("", "@out") else dig(doc, cli["payload"])
    why = schema_error(payload, json.loads(schema_path.read_text()))
    return (None, why) if why else (payload, "")


def main():
    ap = argparse.ArgumentParser(description="Implement the plan of an approved spec, without the owner.")
    ap.add_argument("spec_dir", type=Path)
    ap.add_argument("--config", type=Path, default=Path("harness.toml"))
    ap.parse_args()
    return 2


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `uv run --python 3.12 --with pytest pytest tests/test_build.py -q`
Expected: E25, E26, crash and E29 PASS; E27 SKIPPED.

- [ ] **Step 9: Spike with the real CLIs (E27)**

Run: `RUN_REAL_AGENTS=claude uv run --python 3.12 --with pytest pytest tests/test_build.py -q -k e27`
Expected: PASS. If it fails, fix the `[cli.claude]` `cmd` in `harness.toml`, not the test. The structured result is in `structured_output`; this was confirmed on 2026-10-02.

Codex is not installed on the owner's machine. This step needs the owner once:
`! brew install codex && codex login` (or `npm i -g @openai/codex`).
Then run: `RUN_REAL_AGENTS=codex uv run --python 3.12 --with pytest pytest tests/test_build.py -q -k e27`.
If Codex is still absent, record the E27 Codex half as an escalation in the commit message and continue.

- [ ] **Step 10: Commit**

```bash
git add harness.toml harness/schemas scripts/fake_agent.py scripts/build.py tests/conftest.py tests/test_build.py
git commit -m "feat(029): T2 adapters — claude, codex and fake behind one call — D1–D3, D5"
```

---

### Task 3: The build loop

**Files:**
- Create: `harness/prompts/implementer.md`, `harness/prompts/reviewer.md`
- Create: `harness/schemas/build-report.json`
- Modify: `scripts/build.py` (add the loop; replace `main`)
- Modify: `tests/test_build.py` (append the loop tests)

**Interfaces:**
- Consumes: `spec.parse`, `spec.ids_in` (T1); `load_config`, `call`, `Budget`, `HARNESS` (T2).
- Produces:
  - `git(*args) -> str`
  - `prompt_for(role: str, task: dict, s: dict, cfg: dict, feedback: str = "", diff: str = "") -> str`
  - `run_task(task: dict, s: dict, cfg: dict, report: dict, frozen: set[str], done_examples: list[str]) -> str`. It returns `"done"`, `"escalated"` or `"blocked"`, and it commits on `"done"`.
  - `run_checks(cfg: dict, examples: list[str]) -> tuple[int, str]`
  - `build(spec_dir: Path, cfg: dict) -> dict`, which writes and returns the report.
  - The report keys are `tokens`, `tasks` (`{id: {status, attempts}}`), `trace`, `assumptions`, `escalations` (`[{task, reason}]`), `reused`, `new` and `started`.

- [ ] **Step 1: Write the role prompts**

`harness/prompts/implementer.md`:

```markdown
# Role: implementer

You implement ONE task of an approved spec. You work in the current repository.

Rules:
- Do only what the task and its requirements ask. Add no other behaviour.
- Make the examples pass. The tests for them are frozen: never edit a file under tests/ that exists already.
- Stop at the first step of this ladder that works:
  1. Does the code need to exist? 2. Does the repo already have it? Read the module map.
  3. Does the standard library do it? 4. Does the platform do it natively?
  5. Does a library in the charter do it? An official SDK beats a hand-made client.
  6. Can it be one line? 7. Only then: the minimum code that works.
- A new library is not yours to add. Report it in new_deps, and set status to blocked.
- Where the spec is silent, choose, and report the choice in assumptions:
  - minor: the choice does not change any result the owner reads.
  - structural: the choice changes a result, a data meaning or an interface. Then set status to blocked and change nothing.
- Do not commit. The build script commits.

Answer only with the JSON object your schema asks for.
```

`harness/prompts/reviewer.md`:

```markdown
# Role: reviewer

You review ONE task's diff. You did not write it. You change nothing.

Give verdict "fix" when the diff does one or more of these (rubric R1):
- It adds behaviour that no cited requirement asks for.
- It writes code that a charter library or an official SDK already provides.
- It duplicates a module in the module map.
- It adds an abstraction with one implementation.
- It weakens a test.

Otherwise give verdict "pass". Each finding is one line: the rule, the file, and what to do instead.

Answer only with the JSON object your schema asks for.
```

- [ ] **Step 2: Write `harness/schemas/build-report.json`**

```json
{
  "type": "object",
  "required": ["tokens", "tasks", "trace", "assumptions", "escalations", "reused", "new", "started"],
  "properties": {
    "tokens": {"type": "integer", "minimum": 0},
    "tasks": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "required": ["status", "attempts"],
        "properties": {
          "status": {"enum": ["done", "escalated", "blocked", "skipped"]},
          "attempts": {"type": "integer", "minimum": 0}
        }
      }
    },
    "trace": {"type": "array", "items": {"type": "string"}},
    "assumptions": {"type": "array", "items": {"type": "object", "required": ["task", "text"]}},
    "escalations": {"type": "array", "items": {"type": "object", "required": ["task", "reason"]}},
    "reused": {"type": "array", "items": {"type": "string"}},
    "new": {"type": "array", "items": {"type": "string"}},
    "started": {"type": "string"}
  }
}
```

- [ ] **Step 3: Append the failing loop tests to `tests/test_build.py`**

```python
from conftest import TEST_E2

CALC_ADD = "def add(a, b):\n    return a + b\n"
CALC_BOTH = CALC_ADD + "\ndef sub(a, b):\n    return a - b\n"
T0 = {**OK, "_write": {"tests/test_e1_add.py": TEST_E1, "tests/test_e2_sub.py": TEST_E2}}
T1 = {**OK, "_write": {"calc.py": CALC_ADD}}
T2 = {**OK, "_write": {"calc.py": CALC_BOTH}}


def test_build_happy_path(slice_repo):
    slice_repo.script([T0, T1, T2])
    p = slice_repo.build()
    assert p.returncode == 0, p.stdout + p.stderr
    r = slice_repo.report()
    assert {k: v["status"] for k, v in r["tasks"].items()} == {"T0": "done", "T1": "done", "T2": "done"}
    assert "T1" in slice_repo.git("log", "--format=%s", "-3")


def test_e10_vacuous_test(slice_repo):
    vacuous = {**OK, "_write": {"tests/test_e1_add.py": "def test_e1_add():\n    assert True\n", "tests/test_e2_sub.py": TEST_E2}}
    slice_repo.script([vacuous])
    p = slice_repo.build()
    assert p.returncode == 3
    assert any("vacuous: E1" in e["reason"] for e in slice_repo.report()["escalations"])


def test_e11_frozen_test_changed(slice_repo):
    cheat = {**OK, "_write": {"calc.py": CALC_ADD, "tests/test_e1_add.py": "def test_e1_add():\n    pass\n"}}
    slice_repo.script([T0, cheat, cheat, cheat])
    slice_repo.build()
    reasons = [e["reason"] for e in slice_repo.report()["escalations"]]
    assert any("frozen test changed: tests/test_e1_add.py" in x for x in reasons)


def test_e12_order_implementer_checks_reviewer(slice_repo):
    slice_repo.script([T0, T1, T2])
    slice_repo.build()
    trace = [t for t in slice_repo.report()["trace"] if t.startswith("T1:")]
    assert trace == ["T1:implementer", "T1:checks", "T1:reviewer"]


def test_e13_same_failure_twice_escalates(slice_repo):
    slice_repo.script([T0, OK])  # T1 writes nothing; the same test fails each time
    p = slice_repo.build()
    r = slice_repo.report()
    assert p.returncode == 3
    assert r["tasks"]["T1"] == {"status": "escalated", "attempts": 2}
    assert "test_e1_add" in r["escalations"][0]["reason"]


def test_e14_structural_blocks_and_others_continue(slice_repo):
    blocked = {**OK, "status": "blocked", "assumptions": [{"text": "which date counts?", "severity": "structural"}]}
    t2_alone = {**OK, "_write": {"calc.py": "def sub(a, b):\n    return a - b\n"}}
    slice_repo.script([T0, blocked, t2_alone])
    p = slice_repo.build()
    r = slice_repo.report()
    assert r["tasks"]["T1"]["status"] == "blocked" and r["tasks"]["T2"]["status"] == "done"
    assert p.stdout.count("ESCALATIONS (1)") == 1 and "which date counts?" in p.stdout


def test_e15_budget(slice_repo):
    cfg = (slice_repo.root / "harness.toml").read_text().replace("budget_tokens = 3_000_000", "budget_tokens = 1000")
    (slice_repo.root / "harness.toml").write_text(cfg)
    slice_repo.script([{**T0, "tokens": 600}], [{**PASS, "tokens": 600}])
    p = slice_repo.build()
    assert p.returncode == 3
    assert len(slice_repo.calls()) == 2
    assert "budget exceeded" in slice_repo.report()["escalations"][-1]["reason"]


def test_e16_prompt_has_only_its_task(slice_repo):
    slice_repo.script([T0, T1, T2])
    slice_repo.build()
    t1 = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer" and "## Task T1" in c["prompt"]]
    assert t1 and "UNIQUE_T2_TEXT" not in t1[0]


def test_e17_report_schema_retry_and_assumption(slice_repo):
    wrong = {**OK, "_write": {"calc.py": "def add(a, b):\n    return 0\n"}}
    right = {**T1, "assumptions": [{"text": "ints only", "severity": "minor"}]}
    slice_repo.script([T0, wrong, right, T2])
    assert slice_repo.build().returncode == 0
    r = slice_repo.report()
    import jsonschema
    jsonschema.validate(r, json.loads((HARNESS / "harness/schemas/build-report.json").read_text()))
    assert r["tasks"]["T1"]["attempts"] == 2
    assert r["assumptions"] == [{"task": "T1", "text": "ints only"}]


def test_reviewer_fix_feeds_back(slice_repo):
    fix = {"verdict": "fix", "findings": ["R1 library-first: calc.py hand-made"], "tokens": 10}
    slice_repo.script([T0, T1, T1, T2], [PASS, fix, PASS])
    assert slice_repo.build().returncode == 0
    retry = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"][2]
    assert "R1 library-first" in retry


def test_build_refuses_dirty_tree(slice_repo):
    (slice_repo.root / "stray.txt").write_text("x")
    p = slice_repo.build()
    assert p.returncode == 2 and "dirty" in p.stderr and (slice_repo.root / "stray.txt").exists()


def test_build_reruns_after_escalation(slice_repo):
    slice_repo.script([T0, OK])
    assert slice_repo.build().returncode == 3
    slice_repo.script([T1, T2])
    assert slice_repo.build().returncode != 2  # the left-over build-report.json is not "dirty"


def test_build_refuses_main(slice_repo):
    slice_repo.git("checkout", "-q", "main")
    p = slice_repo.build()
    assert p.returncode == 2 and "main" in p.stderr
```

`test_e17` imports `jsonschema`. Run the suite with `--with jsonschema`.

- [ ] **Step 4: Run the tests to verify they fail**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests/test_build.py -q`
Expected: the new tests FAIL, because `main` returns 2 and writes no report.

- [ ] **Step 5: Add the loop to `scripts/build.py`**

Add these imports at the top: `import re`, `import shlex`, `from datetime import datetime, timezone`. Insert `sys.path.insert(0, str(Path(__file__).parent))` and `import spec as speclib` after `import jsonschema`. Replace `main()`, and add the functions below above it.

```python
def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def changed_files():
    out = git("status", "--porcelain", "--untracked-files=all")
    return {line[3:] for line in out.splitlines()}


def revert():
    git("checkout", "--", ".")
    git("clean", "-fdq", "-e", ".fake_*")


def examples_of(task, s):
    ids = []
    for r in speclib.ids_in(task["requirements"]):
        if r in s["reqs"]:
            ids += [e for e in re.findall(r"E\d+", s["reqs"][r]["examples"]) if e in s["examples"]]
    return ids


def run_checks(cfg, examples):
    selector = " or ".join(f"{e.lower()}_" for e in examples) or "no_examples_selected"
    cmd = cfg["checks"]["task"].replace("{examples}", selector)
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.returncode, (p.stdout + p.stderr)[-1500:]


def section(title, body):
    return f"## {title}\n\n{body}\n\n" if body else ""


def prompt_for(role, task, s, cfg, feedback="", diff=""):
    reqs = [s["reqs"][r] for r in speclib.ids_in(task["requirements"]) if r in s["reqs"]]
    exs = [s["examples"][e] for e in examples_of(task, s)]
    words = " ".join(r["requirement"] for r in reqs).lower()
    terms = {t: m for t, m in s["glossary"].items() if t in words}
    paths = cfg["paths"]
    read = lambda p: Path(p).read_text() if Path(p).is_file() else ""
    # ponytail: the whole module map and charter go in; slice them when they outgrow the context
    return (
        (HARNESS / f"harness/prompts/{role}.md").read_text() + "\n\n"
        + f"## Task {task['task']}\n\n{task['does']}\n\n"
        + section("Requirements", "\n".join(f"- {r['id']}: {r['requirement']}" for r in reqs))
        + section("Examples", "\n".join(f"- {e['id']}: given {e['given']}; when {e['when']}; then {e['then']}" for e in exs))
        + section("Glossary", "\n".join(f"- {t}: {m}" for t, m in terms.items()))
        + section("Module map", read(paths["module_map"]))
        + section("Charter", read(paths["charter"]))
        + section("Feedback from the last attempt", feedback)
        + section("Diff", diff)
    )


def norm(text):
    return re.sub(r"\d+(\.\d+)?s\b|0x[0-9a-f]+", "", text)


def run_task(task, s, cfg, report, frozen, done_examples):
    tid, feedback, last = task["task"], "", None
    entry = report["tasks"].setdefault(tid, {"status": "escalated", "attempts": 0})
    for attempt in range(1, cfg["limits"]["attempts"] + 1):
        entry["attempts"] = attempt
        report["trace"].append(f"{tid}:implementer")
        res, fail = call(cfg, "implementer", prompt_for("implementer", task, s, cfg, feedback), report)
        if res:
            structural = [a for a in res["assumptions"] if a["severity"] == "structural"]
            if res["status"] == "blocked" or structural:
                reason = "; ".join(a["text"] for a in structural) or res["summary"] or "blocked"
                report["escalations"].append({"task": tid, "reason": reason})
                entry["status"] = "blocked"
                revert()
                return "blocked"
            report["trace"].append(f"{tid}:checks")
            touched = sorted(frozen & changed_files())
            if touched:
                git("checkout", "--", *touched)
                fail = "frozen test changed: " + ", ".join(touched)
            else:
                code, out = run_checks(cfg, done_examples + examples_of(task, s))
                fail = "" if code == 0 else f"checks failed:\n{out}"
            if not fail:
                report["trace"].append(f"{tid}:reviewer")
                git("add", "-A")
                diff = git("diff", "--cached")
                rev, why = call(cfg, "reviewer", prompt_for("reviewer", task, s, cfg, diff=diff), report)
                fail = why or ("" if rev["verdict"] == "pass" else "reviewer:\n" + "\n".join(rev["findings"]))
            if not fail:
                report["assumptions"] += [{"task": tid, "text": a["text"]} for a in res["assumptions"]]
                report["reused"] += res["reused"]
                report["new"] += res["new_deps"]
                git("add", "-A")
                git("commit", "-q", "-m", f"build({s['slice']}): {tid} {task['does'][:60]}")
                entry["status"] = "done"
                return "done"
        if norm(fail) == last or attempt == cfg["limits"]["attempts"]:
            report["escalations"].append({"task": tid, "reason": fail})
            revert()
            return "escalated"
        last, feedback = norm(fail), fail
    return "escalated"


def contract(s, cfg, report):
    """Task 0: turn every example into a failing test, then freeze those test files."""
    ids = list(s["examples"])
    t0 = {"task": "T0", "requirements": ", ".join(s["reqs"]),
          "does": "Write one test per example below, named test_<example id>_<words>, e.g. test_e1_add. "
                  "Each test must fail now, and fail as a test: a missing module must not crash the runner. "
                  "Do not implement the feature."}
    entry = report["tasks"].setdefault("T0", {"status": "escalated", "attempts": 0})
    feedback = ""
    for attempt in range(1, cfg["limits"]["attempts"] + 1):
        entry["attempts"] = attempt
        report["trace"].append("T0:implementer")
        res, fail = call(cfg, "implementer", prompt_for("implementer", t0, s, cfg, feedback), report)
        if res:
            report["trace"].append("T0:checks")
            for e in ids:
                code, out = run_checks(cfg, [e])
                if code == 0:
                    report["escalations"].append({"task": "T0", "reason": f"vacuous: {e} passes before implementation"})
                    revert()
                    return None
                if code != cfg["checks"]["red_exit"]:
                    fail = f"{e}: no failing test (exit {code})\n{out}"
                    break
        if not fail:
            report["trace"].append("T0:reviewer")
            git("add", "-A")
            rev, why = call(cfg, "reviewer", prompt_for("reviewer", t0, s, cfg, diff=git("diff", "--cached")), report)
            fail = why or ("" if rev["verdict"] == "pass" else "reviewer:\n" + "\n".join(rev["findings"]))
        if not fail:
            git("commit", "-q", "-m", f"build({s['slice']}): T0 tests for {', '.join(ids)}")
            entry["status"] = "done"
            return set(git("show", "--name-only", "--format=", "HEAD").split())
        feedback = fail
    report["escalations"].append({"task": "T0", "reason": fail})
    revert()
    return None


def needs_of(task, tasks, i):
    if "needs" in task:
        return [t for t in speclib.ids_in(task["needs"]) if t.startswith("T")]
    return [tasks[i - 1]["task"]] if i else []


def build(spec_dir, cfg):
    s = speclib.parse((spec_dir / "spec.md").read_text())
    s["slice"] = spec_dir.name
    report = {"tokens": 0, "tasks": {}, "trace": [], "assumptions": [], "escalations": [],
              "reused": [], "new": [], "started": datetime.now(timezone.utc).isoformat()}
    try:
        frozen = contract(s, cfg, report)
        if frozen is not None:
            done_examples = []
            for i, task in enumerate(s["tasks"]):
                waiting = [n for n in needs_of(task, s["tasks"], i) if report["tasks"].get(n, {}).get("status") != "done"]
                if waiting:
                    report["tasks"][task["task"]] = {"status": "skipped", "attempts": 0}
                    continue
                if run_task(task, s, cfg, report, frozen, done_examples) == "done":
                    done_examples += examples_of(task, s)
    except Budget as b:
        report["escalations"].append({"task": "budget", "reason": str(b)})
        revert()
    (spec_dir / "build-report.json").write_text(json.dumps(report, indent=2))
    return report


def main():
    ap = argparse.ArgumentParser(description="Implement the plan of an approved spec, without the owner.")
    ap.add_argument("spec_dir", type=Path)
    ap.add_argument("--config", type=Path, default=Path("harness.toml"))
    a = ap.parse_args()
    if not (a.spec_dir / "spec.md").is_file() or not a.config.is_file():
        print("build: need SPEC_DIR/spec.md and harness.toml", file=sys.stderr)
        return 2
    if git("branch", "--show-current").strip() in ("main", "master"):
        print("build: refusing to run on main; switch to the slice branch", file=sys.stderr)
        return 2
    own = str((a.spec_dir / "build-report.json").resolve().relative_to(Path.cwd().resolve()))
    if changed_files() - {".fake_log", ".fake_plan", own}:  # a previous run's report may be left over
        print("build: working tree is dirty; commit or stash first", file=sys.stderr)
        return 2
    report = build(a.spec_dir, load_config(a.config))
    if report["escalations"]:
        print(f"ESCALATIONS ({len(report['escalations'])})")
        for e in report["escalations"]:
            print(f"- {e['task']}: {e['reason']}")
        return 3
    print("build: every task done")
    return 0
```

Two notes for the implementer:
- `report.json` is written inside the spec dir after the last commit. Accept commits it.
- The fixture's `.gitignore` hides `.fake_*`. `changed_files()` still filters them, for repos without that ignore.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests/test_build.py -q`
Expected: all PASS, and E27 SKIPPED.

- [ ] **Step 7: Commit**

```bash
git add scripts/build.py harness/prompts harness/schemas/build-report.json tests/test_build.py
git commit -m "feat(029): T3 build loop — contract, task loop, escalations, report — B1–B10"
```

---

### Task 4: Accept

**Files:**
- Create: `harness/prompts/judge.md`
- Create: `scripts/accept.py`
- Create: `tests/test_accept.py`

**Interfaces:**
- Consumes: `build.load_config`, `build.call`, `build.git`, `build.run_task`, `build.revert`, `build.HARNESS` (T2, T3); `spec.parse` (T1).
- Produces:
  - `uv run scripts/accept.py SPEC_DIR [--config harness.toml]`. Exit codes: 0 merged · 1 failed and escalated · 2 unusable input.
  - The file `SPEC_DIR/result.html`.
  - The file `SPEC_DIR/results.json` is an optional input: `[{"id": str, "value": str}]`. The product's run writes it.

- [ ] **Step 1: Write `harness/prompts/judge.md`**

```markdown
# Role: judge

You score ONE judged requirement of a finished slice. You did not write the code. You change nothing.

Read the requirement, the spec (it holds the rubric the requirement names), and the slice diff.
Give verdict "pass" when the diff meets the requirement under its rubric. Otherwise give "fix",
with one finding per unmet rubric line.

Answer only with the JSON object your schema asks for.
```

- [ ] **Step 2: Write the failing tests in `tests/test_accept.py`**

```python
import json

from conftest import PASS, TEST_E1


def ready(slice_repo, test_body=TEST_E1, calc="def add(a, b):\n    return a + b\n"):
    """Put a finished slice on the branch: code, test, and an empty build report."""
    slice_repo.script([])
    (slice_repo.root / "calc.py").write_text(calc)
    (slice_repo.root / "tests/test_e1_add.py").write_text(test_body)
    (slice_repo.dir / "build-report.json").write_text(json.dumps(
        {"tokens": 5, "tasks": {}, "trace": [], "assumptions": [{"task": "T1", "text": "ints only"}],
         "escalations": [], "reused": ["calc"], "new": [], "started": "2026-10-02T10:00:00+00:00"}))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "build(001-add): T1 add")


def test_e18_green_merges_into_main(slice_repo):
    ready(slice_repo)
    p = slice_repo.accept()
    assert p.returncode == 0, p.stdout + p.stderr
    assert "build(001-add): T1 add" in slice_repo.git("log", "main", "--format=%s")


def test_e19_fails_twice_then_escalates(slice_repo):
    ready(slice_repo, test_body="def test_e1_add():\n    assert False\n")
    slice_repo.script([{"status": "done", "summary": "", "assumptions": [], "reused": [], "new_deps": []}])
    p = slice_repo.accept()
    assert p.returncode == 1
    fixes = [c["prompt"] for c in slice_repo.calls() if c["role"] == "implementer"]
    # one return to build = one FIX task; the same failure twice ends it (B4)
    assert len(fixes) == 2 and all("## Task FIX" in f for f in fixes)
    assert "ESCALATIONS" in p.stdout
    assert "build(001-add)" not in slice_repo.git("log", "main", "--format=%s")


def test_e20_results_written_back_as_reported(slice_repo):
    ready(slice_repo)
    (slice_repo.dir / "results.json").write_text(json.dumps([{"id": "H-3", "value": "0.42"}]))
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "results")
    assert slice_repo.accept().returncode == 0
    ns = slice_repo.git("show", "main:memory/north-star/north-star.md")
    assert "## Reported" in ns and "- H-3: 0.42 — reported" in ns and "slice 001-add" in ns


def test_e21_module_not_in_map(slice_repo):
    ready(slice_repo)
    (slice_repo.root / "src/rule").mkdir(parents=True)
    (slice_repo.root / "src/rule/__init__.py").write_text("")
    (slice_repo.root / "docs").mkdir()
    (slice_repo.root / "docs/modules.md").write_text("| module | layer | purpose | interface | anchors | status |\n| --- | --- | --- | --- | --- | --- |\n| ghost | x | y | z | P1 | reported |\n")
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "map")
    p = slice_repo.accept()
    assert p.returncode == 1
    assert "rule: not in module map" in p.stdout and "ghost: no directory" in p.stdout


def test_e22_result_page(slice_repo):
    ready(slice_repo)
    assert slice_repo.accept().returncode == 0
    html = (slice_repo.dir / "result.html").read_text()
    for s in ("Lead time", "Interventions", "Reused", "New", "Assumptions", "ints only"):
        assert s in html


def test_e23_judge_is_another_family(slice_repo):
    spec = (slice_repo.dir / "spec.md").read_text().replace("| real-enforcement | E2 |", "| real-enforcement | judged, rubric R1 |")
    (slice_repo.dir / "spec.md").write_text(spec)
    ready(slice_repo)
    slice_repo.script([], judge=[PASS])
    assert slice_repo.accept().returncode == 0
    assert [c["role"] for c in slice_repo.calls()] == ["judge"]


def test_e23_same_family_refused(slice_repo):
    spec = (slice_repo.dir / "spec.md").read_text().replace("| real-enforcement | E2 |", "| real-enforcement | judged, rubric R1 |")
    (slice_repo.dir / "spec.md").write_text(spec)
    cfg = (slice_repo.root / "harness.toml").read_text().replace('judge = "fake-judge"', 'judge = "fake"')
    (slice_repo.root / "harness.toml").write_text(cfg)
    ready(slice_repo)
    p = slice_repo.accept()
    assert p.returncode == 2 and "different model family" in p.stderr


def test_accept_merge_conflict(slice_repo):
    ready(slice_repo)
    slice_repo.git("checkout", "-q", "main")
    (slice_repo.root / "calc.py").write_text("x = 1\n")
    slice_repo.git("add", "-A")
    slice_repo.git("commit", "-q", "-m", "conflict on main")
    main_before = slice_repo.git("rev-parse", "main")
    slice_repo.git("checkout", "-q", "001-add")
    p = slice_repo.accept()
    assert p.returncode == 1 and "merge conflict" in p.stdout
    assert slice_repo.git("rev-parse", "main") == main_before
    assert slice_repo.git("status", "--porcelain") == ""
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests/test_accept.py -q`
Expected: every test FAILS, because `scripts/accept.py` does not exist.

- [ ] **Step 4: Write `scripts/accept.py`**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["jsonschema>=4"]
# ///
"""accept.py — verify a built slice by machine, merge it, and write its results back.

  uv run scripts/accept.py SPEC_DIR [--config harness.toml]

Exit: 0 merged · 1 a check failed twice, or the merge conflicted (escalated) · 2 unusable input.
"""
import argparse
import html
import json
import subprocess
import sys
from datetime import date, datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import build  # noqa: E402
import spec as speclib  # noqa: E402


def suite(cfg):
    p = subprocess.run(cfg["checks"]["suite"], shell=True, capture_output=True, text=True)
    return p.returncode, (p.stdout + p.stderr)[-1500:]


def map_findings(cfg):
    paths = cfg["paths"]
    root, mfile = Path(paths["module_root"]), Path(paths["module_map"])
    if not root.is_dir() and not mfile.is_file():
        return []
    dirs = {d.name for d in root.iterdir() if d.is_dir() and not d.name.startswith(("_", "."))} if root.is_dir() else set()
    rows = set()
    if mfile.is_file():
        for _, head, rs in speclib.tables(mfile.read_text()):
            if head and head[0] == "module":
                rows |= {r["module"].strip("`") for r in rs}
    return [f"{d}: not in module map" for d in sorted(dirs - rows)] + [f"{r}: no directory" for r in sorted(rows - dirs)]


def judge(spec_dir, s, cfg, report, branch):
    judged = [r for r in s["reqs"].values() if "judged" in r["examples"]]
    if not judged:
        return []
    fam = lambda role: cfg["cli"][cfg["roles"][role]]["family"]
    if fam("judge") == fam("implementer"):
        raise SystemExit("accept: the judge must use a different model family than the implementer (A7)")
    diff = build.git("diff", f"main...{branch}")[-200_000:]
    spec_text = (spec_dir / "spec.md").read_text()
    out = []
    for r in judged:
        prompt = ((build.HARNESS / "harness/prompts/judge.md").read_text()
                  + f"\n\n## Requirement {r['id']}\n\n{r['requirement']} ({r['examples']})\n\n## Spec\n\n{spec_text}\n\n## Diff\n\n{diff}")
        v, why = build.call(cfg, "judge", prompt, report)
        if why or v["verdict"] != "pass":
            out.append(f"{r['id']}: " + (why or "; ".join(v["findings"])))
    return out


def failures(spec_dir, s, cfg, report, branch):
    code, out = suite(cfg)
    found = [] if code == 0 else [f"suite failed:\n{out}"]
    return found + map_findings(cfg) + judge(spec_dir, s, cfg, report, branch)


def write_back(spec_dir, cfg):
    results = spec_dir / "results.json"
    if not results.is_file():
        return
    ns = Path(cfg["paths"]["north_star"])
    text = ns.read_text()
    if "\n## Reported\n" not in text:
        text = text.rstrip("\n") + "\n\n## Reported\n\n"
    for r in json.loads(results.read_text()):
        text += f"- {r['id']}: {r['value']} — reported {date.today().isoformat()}, slice {spec_dir.name}\n"
    ns.write_text(text)


def result_page(spec_dir, report):
    started = build.git("log", "--reverse", "--format=%cI", "main..HEAD").split() or [report.get("started", "")]
    lead = datetime.now(timezone.utc) - datetime.fromisoformat(started[0])
    rows = [
        ("Lead time", f"{lead.total_seconds() / 3600:.1f} h"),
        ("Interventions", str(1 + len(report["escalations"]))),
        ("Reused", ", ".join(report["reused"]) or "none"),
        ("New", ", ".join(report["new"]) or "none"),
        ("Assumptions", "; ".join(f"{a['task']}: {a['text']}" for a in report["assumptions"]) or "none"),
        ("Tokens", str(report["tokens"])),
    ]
    body = "".join(f"<tr><th>{k}</th><td>{html.escape(v)}</td></tr>" for k, v in rows)
    (spec_dir / "result.html").write_text(
        f"<!doctype html><meta charset='utf-8'><title>Result {spec_dir.name}</title>"
        f"<style>body{{font:15px system-ui;max-width:720px;margin:2em auto;padding:0 16px}}"
        f"th{{text-align:left;padding:6px 16px 6px 0}}</style><h1>Result {spec_dir.name}</h1><table>{body}</table>")


def main():
    ap = argparse.ArgumentParser(description="Verify a built slice by machine, merge it, write results back.")
    ap.add_argument("spec_dir", type=Path)
    ap.add_argument("--config", type=Path, default=Path("harness.toml"))
    a = ap.parse_args()
    if not (a.spec_dir / "spec.md").is_file() or not a.config.is_file():
        print("accept: need SPEC_DIR/spec.md and harness.toml", file=sys.stderr)
        return 2
    branch = build.git("branch", "--show-current").strip()
    if branch in ("main", "master"):
        print("accept: run it on the slice branch", file=sys.stderr)
        return 2
    cfg = build.load_config(a.config)
    s = speclib.parse((a.spec_dir / "spec.md").read_text())
    s["slice"] = a.spec_dir.name
    rfile = a.spec_dir / "build-report.json"
    report = json.loads(rfile.read_text()) if rfile.is_file() else {
        "tokens": 0, "tasks": {}, "trace": [], "assumptions": [], "escalations": [], "reused": [], "new": [], "started": ""}
    try:
        bad = failures(a.spec_dir, s, cfg, report, branch)
        if bad:  # A3: return to build once, with the failures as feedback
            fix = {"task": "FIX", "requirements": ", ".join(s["reqs"]),
                   "does": "Make accept pass. Failures:\n" + "\n".join(bad)}
            build.run_task(fix, s, cfg, report, set(), [])
            bad = failures(a.spec_dir, s, cfg, report, branch)
    except SystemExit as e:
        print(e, file=sys.stderr)
        return 2
    except build.Budget as b:
        bad = [str(b)]
    if bad:
        report["escalations"] += [{"task": "accept", "reason": x} for x in bad]
        rfile.write_text(json.dumps(report, indent=2))
        print(f"ESCALATIONS ({len(bad)})")
        print("\n".join(f"- {x}" for x in bad))
        return 1
    result_page(a.spec_dir, report)
    build.git("add", "-A")
    build.git("commit", "-q", "--allow-empty", "-m", f"accept({a.spec_dir.name}): verified")
    build.git("checkout", "-q", "main")
    m = subprocess.run(["git", "merge", "--no-ff", "-q", "-m", f"accept({a.spec_dir.name}): merge", branch],
                       capture_output=True, text=True)
    if m.returncode != 0:
        subprocess.run(["git", "merge", "--abort"], capture_output=True)
        build.git("checkout", "-q", branch)
        print(f"ESCALATIONS (1)\n- merge conflict: {m.stdout.strip() or m.stderr.strip()}")
        return 1
    write_back(a.spec_dir, cfg)
    build.git("add", "-A")
    build.git("commit", "-q", "--allow-empty", "-m", f"accept({a.spec_dir.name}): results reported")
    print(f"accept: merged {branch} into main")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests/test_accept.py -q`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add scripts/accept.py harness/prompts/judge.md tests/test_accept.py
git commit -m "feat(029): T4 accept — machine checks, map, judge, merge, write-back — A1–A7"
```

---

### Task 5: Templates, one-source instructions and the amendments

**Files:**
- Create: `harness/steps/brief.md`, `harness/steps/spec.md`, `harness/steps/accept.md`
- Create: `AGENTS.md`
- Create: `.claude/commands/brief.md`, `.claude/commands/spec.md`, `.claude/commands/build.md`, `.claude/commands/accept.md`
- Replace: `specs/_template/` with `brief.md` and `spec.md` only
- Modify: `memory/north-star/north-star.md` (M1–M8), `memory/constitution/constitution.md` (C1–C4), `memory/stack/stack.md` (pin S2: uv)
- Modify: `CLAUDE.md`, `docs/workflow.md`
- Create: `tests/test_harness.py`

**Interfaces:**
- Consumes: the CLI of `spec.py`, `build.py` and `accept.py`.
- Produces: the step instructions that every later slice follows.

- [ ] **Step 1: Write the failing tests in `tests/test_harness.py`**

```python
from conftest import HARNESS


def test_e24_template_names_four_test_kinds():
    t = (HARNESS / "specs/_template/spec.md").read_text()
    for kind in ("example", "invariant", "reconciliation", "e2e run"):
        assert kind in t.lower()
    assert "per criterion" not in t.lower() and "per function" not in t.lower()


def test_e28_one_source_for_claude_and_codex():
    for step in ("brief", "spec", "accept"):
        src = f"harness/steps/{step}.md"
        assert (HARNESS / src).is_file()
        assert src in (HARNESS / f".claude/commands/{step}.md").read_text()
        assert src in (HARNESS / "AGENTS.md").read_text()


def test_north_star_amendments_applied():
    ns = (HARNESS / "memory/north-star/north-star.md").read_text()
    assert "imposing a mandatory agent CLI, model or product stack" in ns
    assert "imposing or naming a mandatory execution runtime" not in ns
    assert "## Glossary" in ns
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `uv run --python 3.12 --with pytest pytest tests/test_harness.py -q`
Expected: 3 FAIL.

- [ ] **Step 3: Write the step instructions**

`harness/steps/brief.md`:

```markdown
# Step 1 — brief

Goal: the owner's objective for one slice, in `specs/<NNN-slug>/brief.md`.

1. Create the branch `<NNN-slug>` from `main`. Copy `specs/_template/brief.md`.
2. Ask the owner only what the brief template leaves empty. Ask one question at a time.
3. Write the brief in the owner's words. Do not design the solution.
4. Commit. Next step: `harness/steps/spec.md`.
```

`harness/steps/spec.md`:

```markdown
# Step 2 — spec

Goal: a spec the owner can approve at gate H1 without a second meeting.

1. Read `brief.md`, the north star, the charter, and `docs/modules.md`.
2. Copy `specs/_template/spec.md` beside the brief. Fill every section.
   - Use only terms from the glossary. Add a new term to the spec glossary.
   - Write each requirement in EARS form, with one anchor in the north star.
   - Give each requirement one or more examples with real values. A requirement no example can check is `judged`, with a rubric.
   - Plan: tasks that cite requirements. Reuse modules from the map. Justify every new module or library in the `item | justification` table.
   - A change to the north star or the charter goes in the Amendments section.
3. Run `uv run scripts/spec.py page specs/<slice>/spec.md`. Fix every finding, then run it again.
4. Optional: draw the main scenarios with interfig as SVG, and reference them in the spec.
5. Show the owner `spec.html`. This is gate H1. Apply what the owner rejects, and render again.
6. After approval: commit, then run `uv run scripts/build.py specs/<slice>`.
```

`harness/steps/accept.md`:

```markdown
# Step 4 — accept

Goal: a merged slice, verified by machine.

1. When build exits 0, run `uv run scripts/accept.py specs/<slice>`.
2. Exit 0: the slice is on `main`. Show the owner `result.html`. The owner reads it; no approval is needed.
3. Exit 1: show the owner the ESCALATIONS list. That list is the only question to the owner.
4. Exit 3 from build: show the owner its ESCALATIONS list, apply the answers to the spec, and run build again.
```

- [ ] **Step 4: Write the entry points**

`AGENTS.md`:

```markdown
# Agents

This repository uses the agentic-sdlc harness. Four steps, one owner approval (gate H1):

1. brief — follow `harness/steps/brief.md`
2. spec — follow `harness/steps/spec.md`
3. build — run `uv run scripts/build.py specs/<slice>` (no owner)
4. accept — follow `harness/steps/accept.md`

When you write code, follow `harness/prompts/implementer.md`.
```

`.claude/commands/brief.md`:

```markdown
---
description: Step 1 — write the slice brief with the owner.
---
Follow `harness/steps/brief.md`.
```

`.claude/commands/spec.md`:

```markdown
---
description: Step 2 — write the spec, lint it, render the page for gate H1.
---
Follow `harness/steps/spec.md`.
```

`.claude/commands/build.md`:

```markdown
---
description: Step 3 — run the build loop on an approved spec.
---
Run `uv run scripts/build.py specs/$ARGUMENTS`. When it exits 3, show the ESCALATIONS list once.
```

`.claude/commands/accept.md`:

```markdown
---
description: Step 4 — verify by machine and merge.
---
Follow `harness/steps/accept.md`.
```

- [ ] **Step 5: Replace the templates**

Run: `git rm -q specs/_template/acceptance.md specs/_template/coverage.md specs/_template/plan.md specs/_template/retro.md specs/_template/tasks.md`

`specs/_template/brief.md`:

```markdown
# Brief — <slice>

## Objective
What the owner wants, and why. One paragraph.

## Done means
What the owner will see when this works.

## Out of this slice
What waits for a later slice.
```

`specs/_template/spec.md`:

```markdown
# Spec <NNN> — <name>

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

## 1. Glossary

| term | meaning |
| --- | --- |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: a property every run keeps, from a north-star principle. Name the principles this slice relies on.
- reconciliation: an output compared with a published value from outside the repo.
- e2e run: a small run through every layer, with a fixed expected output.

A test may use recorded real data. A test does not mock the project's own code.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |

| item | justification |
| --- | --- |

## 6. Amendments

Changes to the north star or the charter. Gate H1 approves each row.

## 7. Assumptions and open items

| item | label |
| --- | --- |
```

- [ ] **Step 6: Apply amendments M1–M8 to `memory/north-star/north-star.md`**

Apply each row of spec section 7.1 to both the prose and the canonical JSON block:
- M1: mission, in both places.
- M2 and M3: `out_of_scope`.
- M4 and M5: `in_scope`.
- M6 and M7: the signals.

For M8, add this section after `## Scope`:

```markdown
## Glossary

Every term here has one meaning. Specs use these terms, and only gate H1 changes them.

| term | meaning |
| --- | --- |
| **slice** | One feature, from brief to merge. |
| **gate H1** | The one approval the owner gives: the spec page. |
| **build** | The step that implements the plan without the owner. A script controls it. |
| **accept** | The step that verifies the result by machine and merges it. |
| **escalation** | A stop that asks the owner for a decision. |

Every statement in this file carries one label: decided, hypothesis, open or reported.
Accept appends results under `## Reported`.
```

Then run: `uv run --python 3.12 python scripts/north-star/engine.py schema-valid memory/north-star/north-star.md`
Expected: exit 0. If the engine rejects the new `out_of_scope` wording, fix the JSON, not the engine.

- [ ] **Step 7: Apply C1–C4 to `memory/constitution/constitution.md`**

- C1: replace section D5 with:

```markdown
### D5 — About 80% of ASD-STE100

One word has one meaning: use the glossary. A sentence has 25 words or fewer; a procedure
sentence has 20 or fewer. Use the active voice. Give one instruction in one sentence. Tables,
fenced blocks and quotes are data and are exempt. `scripts/spec.py lint` checks the length.
The reviewer checks the rest.
```

- C2: delete section D4.
- C3: add after D5:

```markdown
### D6 — Implementation follows the ponytail ladder, library-first

`harness/prompts/implementer.md` holds the ladder. The reviewer enforces it with rubric R1.
An official SDK beats a hand-made client. A new library is a charter amendment at gate H1.
```

- C4: delete the override of `non-vacuous-checks` (the section "Inherited pattern overrides").

- [ ] **Step 8: Amend charter pin S3 in `memory/stack/stack.md`**

Pin S3 ("Dependency-free baseline") is the pin that M3 changes. Its own falsifier tripped: the build loop needs TOML, JSON Schema and Markdown. Replace the whole S3 block with this one, which keeps the charter's field grammar:

```markdown
### S3 — Baseline: shell, coreutils and uv with inline script dependencies [substrate]
- Confidence: PINNED
- Because:    the build loop needs TOML, JSON Schema and Markdown, and the system python3 can be
              3.9, which has no tomllib. Amendment M3 of spec 029 approved uv at gate H1.
- Buys:       one command per script (`uv run`), with no manifest, no lockfile and no manual install.
- Forecloses: running the harness where uv cannot be installed.
- Falsifier:  an adopter who cannot install uv, or a script that needs a lockfile to stay reproducible.
- Answers:    GR4
```

In pin S2, change "a stdlib-only interpreter" to "a Python ≥ 3.11 that uv provides". Change nothing else in S2.

Then run: `uv run --python 3.12 python scripts/stack/engine.py exposure memory/stack/stack.md`
Expected: exit 0. Update the generated exposure line at the top of the file with the output.

- [ ] **Step 9: Update `CLAUDE.md` and `docs/workflow.md`**

In `CLAUDE.md`, replace the "Hard rules" and "Workflow" sections with:

```markdown
## Hard rules
- The owner approves once: gate H1, the spec page. Everything after it runs without the owner, except escalations.
- A spec passes `uv run scripts/spec.py lint` before gate H1.
- Build and accept are scripts. Never skip them, and never do their work by hand.
- Code follows `harness/prompts/implementer.md`: the ponytail ladder, library-first.
- A change to the north star or the charter is an amendment approved at gate H1.

## Workflow
`/brief` → `/spec` (gate H1) → `/build` → `/accept`. See `docs/workflow.md`.
```

Replace `docs/workflow.md` with:

```markdown
# Workflow

    setup, once    north star (glossary, labels) · charter · module map
    1. brief       harness/steps/brief.md
    2. spec        harness/steps/spec.md → spec.html → gate H1 (the owner approves)
    3. build       uv run scripts/build.py specs/<slice>    (no owner)
    4. accept      uv run scripts/accept.py specs/<slice>   (machine checks, merge)

Roles and CLIs live in `harness.toml`. Any CLI with a headless JSON mode can fill a role.
The judge's model family must differ from the implementer's.
```

- [ ] **Step 10: Run every check**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests -q && bash tests/run.sh`
Expected: pytest passes. The shell suite fails only in checks that T6 deletes or edits: `check_10`, `20`, `40`, `50`, `80`, `90`, `92`, `94`, `95`, `96`, `98`. Write the list of failing labels into the commit body. T6 owns them.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat(029): T5 templates, one-source steps, amendments M1–M8 C1–C4 — Q1, Q2, D4"
```

---

### Task 6: Prune

**Files:**
- Delete: see Step 2.
- Modify: `scripts/vendor.sh` (KEEP/SEED/DROP), `scripts/status.sh` (rewrite), `.github/workflows/verify.yml`, `tests/check_82_north_star_engine.sh`, `tests/check_84_vendor.sh`, `tests/check_88_bootstrap.sh`, `tests/check_92_stack.sh`, `docs/backlog.md`
- Modify: `tests/test_harness.py` (E30)

**Interfaces:**
- Consumes: everything above.
- Produces: the harness of section 8 of the spec.

- [ ] **Step 1: Write the failing test (E30)**

Append to `tests/test_harness.py`:

```python
DELETED = [
    "scripts/mutate.sh", "scripts/nvc.sh", "scripts/cases.sh", "scripts/lib/matrix.sh",
    "scripts/amendment-gate.sh", "scripts/prose.sh", ".github/workflows/amendment-gate.yml",
    ".claude/commands/align.md", ".claude/commands/plan.md", ".claude/commands/contract.md",
    ".claude/commands/tasks.md", ".claude/commands/verify.md", ".claude/commands/uat.md",
    ".claude/commands/retro.md", ".claude/commands/wow-report.md", ".claude/commands/distill.md",
    ".claude/skills/align", ".claude/skills/distill", ".claude/skills/verify", ".claude/skills/uat",
    ".claude/skills/retro", ".claude/skills/wow-report",
]


def test_e30_pruned():
    present = [p for p in DELETED if (HARNESS / p).exists()]
    assert present == []
```

Run: `uv run --python 3.12 --with pytest pytest tests/test_harness.py -q -k e30`
Expected: FAIL, listing every path.

- [ ] **Step 2: Delete**

```bash
git rm -rq scripts/mutate.sh scripts/nvc.sh scripts/cases.sh scripts/lib scripts/amendment-gate.sh scripts/prose.sh \
  .github/workflows/amendment-gate.yml \
  .claude/commands/align.md .claude/commands/plan.md .claude/commands/contract.md .claude/commands/tasks.md \
  .claude/commands/verify.md .claude/commands/uat.md .claude/commands/retro.md .claude/commands/wow-report.md \
  .claude/commands/distill.md \
  .claude/skills/align .claude/skills/distill .claude/skills/verify .claude/skills/uat .claude/skills/retro .claude/skills/wow-report \
  tests/check_10_constitution.sh tests/check_20_spec_templates.sh tests/check_30_verification.sh \
  tests/check_40_commands.sh tests/check_50_skills.sh tests/check_70_docs_ci.sh tests/check_80_north_star.sh \
  tests/check_86_status.sh tests/check_89_mutation_diagnostics.sh tests/check_90_retro.sh tests/check_91_matrix.sh \
  tests/check_93_case_resolution.sh tests/check_94_ground_rules.sh tests/check_95_amendment_gate.sh \
  tests/check_96_non_vacuous.sh tests/check_97_mutation_coverage.sh tests/check_98_adoption.sh tests/check_99_mutations.sh \
  tests/fixtures/cases tests/fixtures/covgate tests/fixtures/diagnostics tests/fixtures/matrix tests/fixtures/mutations
```

Keep these:
- `/stack`, both the command and the skill: setup runs it once.
- `check_00`, `check_60`, `check_82`, `check_84`, `check_88` and `check_92`.
- `specs/001`–`027` and `verification/reports/`, as history.

- [ ] **Step 3: Edit the surviving shell checks**

The rule for all four files: delete each assertion that reads a file deleted in Step 2. Do not weaken an assertion about a file that still exists.

- `tests/check_82_north_star_engine.sh`: delete the `GATE-REUSE` block (it starts at the comment `# --- GATE-REUSE`) and the comment on line 7 that names `check_95`.
- `tests/check_84_vendor.sh` and `tests/check_88_bootstrap.sh`: replace every `.claude/commands/align.md` with `.claude/commands/spec.md`.
- `tests/check_92_stack.sh`: delete every `assert_contains` whose first argument is `.claude/skills/verify/SKILL.md`, `.claude/commands/plan.md`, `.claude/skills/distill/SKILL.md` or `.claude/skills/wow-report/SKILL.md`. Delete the `for tok in …` loops whose body only asserts on those files.

Run: `bash tests/run.sh`
Expected: `TOTAL PASS=<n> FAIL=0`.

- [ ] **Step 4: Update `scripts/vendor.sh` lists**

Replace the three arrays with:

```bash
KEEP=(
  .claude/commands .claude/skills .claude/hooks .claude/settings.json
  AGENTS.md harness
  memory/constitution/base memory/constitution/update-checklist.md
  memory/north-star/base memory/stack/base
  specs/_template
  docs/workflow.md
  scripts/spec.py scripts/build.py scripts/accept.py scripts/fake_agent.py
  scripts/north-star/engine.py scripts/stack/engine.py scripts/guards scripts/status.sh
)
SEED=( CLAUDE.md harness.toml memory/constitution/constitution.md memory/north-star/north-star.md \
  memory/stack/stack.md docs/modules.md scripts/test.sh )
DROP=( "specs/0*-* (except _template)" memory/north-star/decisions verification \
  docs/superpowers evals README.md tests scripts/vendor.sh docs/vendoring.md docs/backlog.md \
  bootstrap.sh scripts/setup-branch-protection.sh )
```

Create `docs/modules.md` in the harness. The harness has no `src/`, so the table stays empty. Vendoring seeds it for the adopter.

```markdown
# Module map

| module | layer | purpose | interface | anchors | status |
| --- | --- | --- | --- | --- | --- |
```

`scripts/setup-branch-protection.sh` moves from KEEP to DROP. It requires the `amendment-gate` check, which no longer exists.

Mirror the three lists in `docs/vendoring.md`. Run `bash tests/run.sh`. `check_84` and `check_88` may assert a path that the new KEEP list drops, such as `evals/rubric.md`. Change that assertion to a path in the new KEEP list, such as `scripts/build.py`. Both must pass.

- [ ] **Step 5: Rewrite `scripts/status.sh`**

```bash
#!/usr/bin/env bash
# status.sh <slice> — which of the four steps a slice has reached, and the next command.
set -u
s="${1:-}"; D="specs/$s"
[ -n "$s" ] && [ -d "$D" ] || { echo "usage: status.sh <slice>  (specs/<slice> must exist)" >&2; exit 2; }
mark(){ if [ -e "$2" ]; then echo "✓ $1"; else echo "· $1"; [ -z "${next:-}" ] && next="$3"; fi; }
next=""
mark brief  "$D/brief.md"          "/brief"
mark spec   "$D/spec.html"         "/spec"
mark build  "$D/build-report.json" "uv run scripts/build.py $D"
mark accept "$D/result.html"       "uv run scripts/accept.py $D"
if [ -n "$next" ]; then echo "next: $next"; else echo "slice DONE"; fi
```

Run: `bash scripts/status.sh 029-autonomous-loop`
Expected: `· brief`, `✓ spec`, `· build`, `· accept`, `next: /brief`. Spec 029 has no `brief.md`; the brief was the design conversation.

- [ ] **Step 6: Update CI `.github/workflows/verify.yml`**

```yaml
name: verify
on: [pull_request]

jobs:
  self-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v6
      - name: Harness tests
        run: uv run --python 3.12 --with pytest --with jsonschema pytest tests -q
      - name: Shell checks
        run: bash tests/run.sh
      - name: Lint every spec in the new format
        run: |
          rc=0
          for s in specs/0*/spec.md; do
            grep -q '^| id | requirement' "$s" || continue
            uv run scripts/spec.py lint "$s" || rc=1
          done
          exit $rc
```

The last step lints only specs with a requirement table. Old specs are history, and they have none. A lint failure fails the step.

- [ ] **Step 7: Close the backlog entry for 028**

In `docs/backlog.md`, add at the top of the list:

```markdown
## ~~B19-028~~ — Suite hermeticity (`specs/028-suite-hermeticity`)

**Status: DROPPED 2026-10-02.** Spec 029 deletes the suite that 028 would isolate. The surviving
shell checks and the new pytest suite build their evidence inside `tmp_path`.
```

- [ ] **Step 8: Run everything**

Run: `uv run --python 3.12 --with pytest --with jsonschema pytest tests -q && bash tests/run.sh`
Expected: pytest all PASS (E27 SKIPPED), and the shell suite `FAIL=0`.

Run: `find scripts tests -name '*.sh' -o -name '*.py' | xargs wc -l | tail -1`
Expected: about 2,000 lines. Record the number in the commit body; it tests the hypothesis of spec section 8.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "chore(029): T6 prune — the 12-step machinery goes; 028 dropped — P1"
```

---

## After T6

Accept for this slice runs once, by hand: `accept.py` did not exist when the slice started. Run: `uv run scripts/accept.py specs/029-autonomous-loop`.

- It runs both suites and the map check, which finds an empty map and no `src/`.
- B7 is judged, so accept calls the judge. The judge is `codex`, and A7 forbids the implementer's family. If Codex is still absent, accept exits 2. That is one escalation to the owner: install Codex.
- On success it merges into `main`.

Then the owner adopts the harness in the new trading repo, with `bootstrap.sh`.
