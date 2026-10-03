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
