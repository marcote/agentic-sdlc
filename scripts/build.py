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
