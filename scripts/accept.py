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


def results_problem(spec_dir, cfg):
    """Check results.json before the merge, so a bad file cannot stop accept half-way (D4)."""
    f = spec_dir / "results.json"
    if not f.is_file():
        return []
    try:
        rows = json.loads(f.read_text())
    except json.JSONDecodeError:
        rows = None
    if not isinstance(rows, list) or not all(isinstance(r, dict) and {"id", "value"} <= r.keys() for r in rows):
        return [f"{f}: not a list of {{id, value}}"]
    ns = cfg["paths"]["north_star"]
    return [] if Path(ns).is_file() else [f"{ns}: north star not found"]


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
    def when(*args):
        out = build.git("log", "--format=%cI", *args).split()
        return datetime.fromisoformat(out[0]) if out else None

    def grep(pattern):
        return when("--basic-regexp", "-1", "--grep", pattern)

    def hours(a, b):
        return f"{(b - a).total_seconds() / 3600:.1f} h" if a and b else "unknown"

    now = datetime.now(timezone.utc)
    brief = when("--diff-filter=A", "--reverse", "--", str(spec_dir / "brief.md"))
    start = brief or when("--reverse", "main..HEAD") or datetime.fromisoformat(report.get("started", "") or now.isoformat())
    h1 = grep(f"^spec({spec_dir.name}): approved at H1")
    built = grep(f"^build({spec_dir.name}): ")
    answers = build.git("log", "--basic-regexp", "--grep", f"^spec({spec_dir.name}): answer escalation", "--format=%H").split()
    runs = report.get("runs") or [report]  # a report from before "runs" is one run
    tokens = sum(r.get("tokens") or 0 for r in runs)
    rows = [
        ("Lead time", hours(start, now) + ("" if brief else " (from first commit)")),
        ("Brief → H1", hours(brief, h1)),
        ("H1 → build", hours(h1, built)),
        ("Build → accept", hours(built, now)),
        ("Interventions", str(1 + len(answers))),
        ("Reused", ", ".join(report["reused"]) or "none"),
        ("New", ", ".join(report["new"]) or "none"),
        ("Assumptions", "; ".join(f"{a['task']}: {a['text']}" for a in report["assumptions"]) or "none"),
        ("Tokens", f"{tokens} ({len(runs)} build run{'s' * (len(runs) != 1)})"),
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
    own = str((a.spec_dir / "build-report.json").resolve().relative_to(Path.cwd().resolve()))
    if build.changed_files() - {".fake_log", ".fake_plan", own}:
        print("accept: working tree is dirty; commit or stash first", file=sys.stderr)
        return 2
    cfg = build.load_config(a.config)
    s = speclib.parse((a.spec_dir / "spec.md").read_text())
    s["slice"] = a.spec_dir.name
    rfile = a.spec_dir / "build-report.json"
    report = json.loads(rfile.read_text()) if rfile.is_file() else {
        "tokens": 0, "tasks": {}, "trace": [], "assumptions": [], "escalations": [], "reused": [], "new": [], "started": ""}
    if report["escalations"] or any(t["status"] != "done" for t in report["tasks"].values()):
        print("accept: build has open escalations; answer them and re-run build", file=sys.stderr)
        return 2
    try:
        bad = failures(a.spec_dir, s, cfg, report, branch)
        if bad:  # A3: return to build once, with the failures as feedback
            fix = {"task": "FIX", "requirements": ", ".join(s["reqs"]),
                   "does": "Make accept pass. Failures:\n" + "\n".join(bad)}
            frozen = build.done_on_branch(s["slice"])[0] or set()  # B2 holds on the return
            build.run_task(fix, s, cfg, report, frozen, [])
            bad = failures(a.spec_dir, s, cfg, report, branch)
    except SystemExit as e:
        print(e, file=sys.stderr)
        return 2
    except build.Budget as b:
        build.revert()
        bad = [str(b)]
    bad = bad or results_problem(a.spec_dir, cfg)
    if bad:
        report["escalations"] += [{"task": "accept", "reason": x} for x in bad]
        rfile.write_text(json.dumps(report, indent=2))
        print(f"ESCALATIONS ({len(report['escalations'])})")  # includes what the return to build escalated
        print("\n".join(f"- {e['task']}: {e['reason']}" for e in report["escalations"]))
        return 1
    result_page(a.spec_dir, report)
    build.git("add", str(a.spec_dir / "result.html"), *([own] if (a.spec_dir / "build-report.json").is_file() else []))
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
    build.git("add", cfg["paths"]["north_star"])
    build.git("commit", "-q", "--allow-empty", "-m", f"accept({a.spec_dir.name}): results reported")
    print(f"accept: merged {branch} into main")
    return 0


if __name__ == "__main__":
    sys.exit(main())
