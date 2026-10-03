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
import re
import shlex
import subprocess
import sys
import tempfile
import time
import tomllib
from datetime import datetime, timezone
from pathlib import Path

import jsonschema

sys.path.insert(0, str(Path(__file__).parent))
import lessons
import spec as speclib

HARNESS = Path(__file__).resolve().parent.parent
SCHEMAS = HARNESS / "harness/schemas"
SCHEMA_OF = {"implementer": "implementer", "reviewer": "reviewer", "judge": "reviewer", "reflector": "reflector"}


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
        subs = {"{role}": role, "{schema}": str(schema_path), "{schema_json}": schema_path.read_text(), "{out}": str(out)}
        argv = [subs.get(a, a).replace("{harness}", str(HARNESS)).replace("{python}", sys.executable) for a in cli["cmd"]]
        secs = cfg["limits"]["call_seconds"]
        try:  # ponytail: kills the CLI only, not its children; use a process group if a tool outlives it
            p = subprocess.run(argv, input=prompt, capture_output=True, text=True, timeout=secs)
        except subprocess.TimeoutExpired:
            return None, f"agent: timeout after {secs}s"
        if p.returncode != 0:
            return None, f"agent: exit {p.returncode}: {(p.stderr or p.stdout).strip()[-300:]}"
        raw = out.read_text() if cli["payload"] == "@out" and out.exists() else p.stdout
    try:
        doc = json.loads(raw)
    except json.JSONDecodeError:
        return None, "agent: no JSON"
    counts = [dig(doc, k) for k in cli.get("tokens", [])]
    report["tokens"] = report.get("tokens", 0) + sum(int(n) for n in counts if isinstance(n, (int, float)))
    if report["tokens"] > cfg["limits"]["budget_tokens"]:
        raise Budget(f"budget exceeded: {report['tokens']} > {cfg['limits']['budget_tokens']} tokens")
    payload = doc if cli["payload"] in ("", "@out") else dig(doc, cli["payload"])
    why = schema_error(payload, json.loads(schema_path.read_text()))
    return (None, why) if why else (payload, "")


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def changed_files():
    out = git("status", "--porcelain", "--untracked-files=all")
    return {line[3:] for line in out.splitlines()}


def revert():
    git("checkout", "--", ".")
    git("reset", "-q", "--hard")  # also drops what `git add -A` staged before a reviewer call
    git("clean", "-fdq", "-e", ".fake_*")
    # a reverted source rewritten in the same second with the same size would reuse its stale .pyc
    git("clean", "-fdXq", "--", ":(glob)**/__pycache__")


def done_on_branch(slice_name):
    """The frozen test files of every T0 commit (None if there is none), and the tasks already committed."""
    t0s = git("log", "--format=%H", "--basic-regexp", "--grep", f"^build({slice_name}): T0 ").split()
    if not t0s:
        return None, set()
    files = [f for t0 in t0s for f in git("show", "--name-only", "--format=", t0).split()]
    frozen = {f for f in files if re.search(r"test_e\d+_", f + "\n" + (Path(f).read_text() if Path(f).is_file() else ""), re.I)}
    done = set(re.findall(rf"^build\({re.escape(slice_name)}\): (T\d+) ", git("log", "--format=%s"), re.M))
    return frozen, done


def examples_of(task, s):
    ids = []
    for r in speclib.ids_in(task["requirements"]):
        if r in s["reqs"]:
            ids += [e for e in re.findall(r"E\d+", s["reqs"][r]["examples"]) if e in s["examples"] and e in task.get("only", [e])]
    return ids


TEST_TIME = [0.0]  # seconds spent in the task check during this process


def run_checks(cfg, examples):
    code, out = run_raw(cfg, examples)
    return code, out[-1500:]


def run_raw(cfg, examples):
    if not examples:
        return 0, "no examples selected"
    selector = " or ".join(f"{e.lower()}_" for e in examples) or "no_examples_selected"
    cmd = cfg["checks"]["task"].replace("{examples}", selector)
    t0 = time.monotonic()
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    TEST_TIME[0] += time.monotonic() - t0
    return p.returncode, p.stdout + p.stderr


def section(title, body):
    return f"## {title}\n\n{body}\n\n" if body else ""


def prompt_for(role, task, s, cfg, feedback="", diff="", frozen=()):
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
        + section("Frozen tests", "\n".join(f"- {f}" for f in sorted(frozen)))
        + section("Glossary", "\n".join(f"- {t}: {m}" for t, m in terms.items()))
        + section("Lessons", "\n".join(f"- {r['id']}: {r['lesson']}" for r in lessons.with_status("active")))
        + section("Module map", read(paths["module_map"]))
        + section("Charter", read(paths["charter"]))
        + section("Feedback from the last attempt", feedback)
        + section("Diff", diff[-200_000:])
    )


def norm(text):
    failed = sorted(set(re.findall(r"^FAILED (\S+)", text, re.M)))  # the same tests failing is the same failure
    if failed:
        return failed
    return re.sub(r"\d+(\.\d+)?s\b|0x[0-9a-f]+", "", text)


def run_task(task, s, cfg, report, frozen, done_examples):
    tid, feedback, last = task["task"], "", None
    entry = report["tasks"].setdefault(tid, {"status": "escalated", "attempts": 0})
    for attempt in range(1, cfg["limits"]["attempts"] + 1):
        entry["attempts"] = attempt
        report["trace"].append(f"{tid}:implementer")
        res, fail = call(cfg, "implementer", prompt_for("implementer", task, s, cfg, feedback, frozen=frozen), report)
        if res:
            structural = [a for a in res["assumptions"] if a["severity"] == "structural"]
            if res["status"] == "blocked" or structural:
                reason = "; ".join(a["text"] for a in structural) or res["summary"] or "blocked"
                if res["new_deps"]:
                    reason += "; new dependency: " + ", ".join(res["new_deps"])
                    report["new"] += res["new_deps"]
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
                if not why and rev["verdict"] != "pass":
                    report["findings"] += [{"task": tid, "text": f} for f in rev["findings"]]
            if not fail:
                report["assumptions"] += [{"task": tid, "text": a["text"]} for a in res["assumptions"]]
                report["reused"] += res["reused"]
                report["new"] += res["new_deps"]
                git("add", "-A")
                git("commit", "-q", "--allow-empty", "-m", f"build({s['slice']}): {tid} {task['does'][:60]}")
                entry["status"] = "done"
                return "done"
        if norm(fail) == last or attempt == cfg["limits"]["attempts"]:
            report["escalations"].append({"task": tid, "reason": fail})
            revert()
            return "escalated"
        last, feedback = norm(fail), fail
    return "escalated"


def late_examples(s, frozen):
    """Examples that no frozen test names."""
    text = "\n".join(f + "\n" + (Path(f).read_text() if Path(f).is_file() else "") for f in frozen).lower()
    return [e for e in s["examples"] if f"test_{e.lower()}_" not in text]


def contract(s, cfg, report, ids):
    """Task 0: turn the given examples into failing tests, then freeze those test files."""
    reqs = [r for r in s["reqs"] if set(re.findall(r"E\d+", s["reqs"][r]["examples"])) & set(ids)]
    t0 = {"task": "T0", "requirements": ", ".join(reqs), "only": ids,
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
            code, out = run_raw(cfg, ids)  # one run; each example's result is read from the FAILED/ERROR lines
            # Only the test files T0 wrote count: other slices reuse the same example ids (test_e6_…).
            own = {f for f in changed_files() if re.search(r"(^|/)tests/|test_e\d+", f)}
            for e in ids:
                hits = [m for m in re.finditer(rf"^(PASSED|FAILED|ERROR) (\S+?)::\S*test_{e.lower()}_", out, re.M)
                        if m[2] in own]
                got = next((m for m in hits if m[1] == "PASSED"), hits[0] if hits else None)  # any own PASSED is vacuous
                if got and got[1] == "PASSED":
                    report["escalations"].append({"task": "T0", "reason": f"vacuous: {e} passes before implementation"})
                    revert()
                    return False
                if not got:
                    fail = f"{e}: no failing test (exit {code})\n{out[-1500:]}"
                    break
        if not fail:
            report["trace"].append("T0:reviewer")
            git("add", "-A")
            rev, why = call(cfg, "reviewer", prompt_for("reviewer", t0, s, cfg, diff=git("diff", "--cached")), report)
            fail = why or ("" if rev["verdict"] == "pass" else "reviewer:\n" + "\n".join(rev["findings"]))
        if not fail:
            git("commit", "-q", "-m", f"build({s['slice']}): T0 tests for {', '.join(ids)}")
            entry["status"] = "done"
            return True
        feedback = fail
    report["escalations"].append({"task": "T0", "reason": fail})
    revert()
    return False


def needs_of(task, tasks, i):
    if "needs" in task:
        return [t for t in speclib.ids_in(task["needs"]) if t.startswith("T")]
    return [tasks[i - 1]["task"]] if i else []


def build(spec_dir, cfg):
    s = speclib.parse((spec_dir / "spec.md").read_text())
    s["slice"] = spec_dir.name
    report = {"tokens": 0, "tasks": {}, "trace": [], "assumptions": [], "escalations": [],
              "reused": [], "new": [], "findings": [], "started": datetime.now(timezone.utc).isoformat()}
    try:
        old = json.loads((spec_dir / "build-report.json").read_text())
        earlier = old.get("runs") or [old]  # a report from before "runs" is one run
        earlier = [{k: r.get(k) for k in ("started", "tokens", "escalations", "test_seconds")} for r in earlier]
    except (OSError, ValueError, AttributeError):
        earlier = []
    try:
        frozen, done = done_on_branch(s["slice"])  # a re-run keeps what an earlier run committed
        late = list(s["examples"]) if frozen is None else late_examples(s, frozen)
        if late and contract(s, cfg, report, late):
            frozen, done = done_on_branch(s["slice"])
        elif late:
            frozen = None  # T0 escalated: run no task
        if frozen is not None:
            done_examples = []
            for t in sorted(done):
                report["tasks"].setdefault(t, {"status": "done", "attempts": 0})
            for i, task in enumerate(s["tasks"]):
                if task["task"] in done:
                    done_examples += examples_of(task, s)
                    continue
                waiting = [n for n in needs_of(task, s["tasks"], i) if report["tasks"].get(n, {}).get("status") != "done"]
                if waiting:
                    report["tasks"][task["task"]] = {"status": "skipped", "attempts": 0}
                    report["escalations"].append({"task": task["task"], "reason": "skipped: needs " + ", ".join(waiting)})
                    continue
                if run_task(task, s, cfg, report, frozen, done_examples) == "done":
                    done_examples += examples_of(task, s)
    except Budget as b:
        report["escalations"].append({"task": "budget", "reason": str(b)})
        revert()
    except Exception as e:  # e.g. a pre-commit hook rejects the commit
        report["escalations"].append({"task": "crash", "reason": f"{type(e).__name__}: {e} {getattr(e, 'stderr', '') or ''}".strip()})
        revert()
    finally:
        report["test_seconds"] = round(TEST_TIME[0], 1)
        report["runs"] = earlier + [{k: report[k] for k in ("started", "tokens", "escalations", "test_seconds")}]
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
    cfg = load_config(a.config)
    blind = [r for r, c in cfg["roles"].items() if not cfg["cli"][c].get("tokens")]
    if blind:
        print(f"build: warning: the budget cannot see role {', '.join(blind)} (tokens = [])", file=sys.stderr)
    report = build(a.spec_dir, cfg)
    if report["escalations"]:
        print(f"ESCALATIONS ({len(report['escalations'])})")
        for e in report["escalations"]:
            print(f"- {e['task']}: {e['reason']}")
        return 3
    print("build: every task done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
