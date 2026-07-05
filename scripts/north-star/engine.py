#!/usr/bin/env python3
"""North Star engine — dependency-free (python3 stdlib) reference implementation.

The single source of North Star determinism for this harness. Deterministic
capabilities over a project's North Star (memory/north-star/north-star.md):

  schema-valid FILE            validateNorthStar — validate the canonical JSON
                               block against memory/north-star/base/schema.md
  sets-changed OLD NEW         requiresAdr — did the governed pillars/scope sets
                               change (order-agnostic)?
  scope-reject OBJ --north-star FILE
                               scopeReject — does an objective contain a full
                               out_of_scope predicate (conservative substring)?
  align-verdict                alignVerdict — aggregate rubric scores (stdin JSON)
                               into a verdict; aggregates only, never scores.
  has-adr-for --added "…"      hasAdrFor — is any added file a new ADR?

Exit contract (bash-friendly, consumed by scripts/amendment-gate.sh):
  0 = affirmative / valid / hit / present
  1 = negative    / invalid (reason on stderr) / no-hit / absent
  2 = error       — malformed input: broken JSON or no canonical ```json``` block
stdout carries the minimal payload; reasons/errors go to stderr.
"""
import sys
import json
import re
import argparse

_JSON_BLOCK = re.compile(r"```json\s*\n(.*?)\n```", re.S)


class Malformed(Exception):
    """Input cannot be parsed into a canonical North Star (→ exit 2)."""


def _load(path):
    """Extract and parse the canonical ```json``` block of a North Star file."""
    try:
        with open(path, encoding="utf-8") as fh:
            txt = fh.read()
    except OSError as e:
        raise Malformed("cannot read %s: %s" % (path, e))
    m = _JSON_BLOCK.search(txt)
    if not m:
        raise Malformed("no ```json``` block found in %s" % path)
    try:
        return json.loads(m.group(1))
    except json.JSONDecodeError as e:
        raise Malformed("invalid JSON in %s: %s" % (path, e))


def _nonempty_str(v):
    return isinstance(v, str) and v.strip() != ""


def _validate(ns):
    """Return '' if schema-valid, else a precise reason (per base/schema.md)."""
    if not _nonempty_str(ns.get("mission")):
        return "mission is empty or missing"
    pillars = ns.get("pillars")
    if not isinstance(pillars, list) or len(pillars) < 1:
        return "pillars must be an array with >=1 entry"
    for i, p in enumerate(pillars):
        if not isinstance(p, dict):
            return "pillars[%d] must be an object" % i
        for k in ("id", "statement", "signal"):
            if not _nonempty_str(p.get(k)):
                return "pillars[%d].%s is empty or missing" % (i, k)
    sc = ns.get("scope")
    if not isinstance(sc, dict):
        return "scope is missing"
    for k in ("in_scope", "out_of_scope"):
        arr = sc.get(k)
        if not isinstance(arr, list) or len(arr) < 1 or not all(_nonempty_str(x) for x in arr):
            return "scope.%s must be a non-empty array of strings" % k
    al = ns.get("alignment")
    thr = al.get("threshold") if isinstance(al, dict) else None
    if not isinstance(thr, (int, float)) or isinstance(thr, bool):
        return "alignment.threshold must be a number"
    return ""


def _sig(ns):
    """Order-agnostic semantic signature of the governed sets (pillars + scope)."""
    pillars = frozenset(
        (p.get("id"), p.get("statement"), p.get("signal"))
        for p in ns.get("pillars", []) if isinstance(p, dict)
    )
    sc = ns.get("scope", {}) or {}
    scope = (frozenset(sc.get("in_scope", []) or []),
             frozenset(sc.get("out_of_scope", []) or []))
    return (pillars, scope)


def _norm(s):
    """Normalize for the conservative substring match: lowercase + collapse whitespace."""
    return re.sub(r"\s+", " ", s.strip().lower())


def cmd_schema_valid(args):
    reason = _validate(_load(args.file))
    if reason:
        sys.stderr.write(reason + "\n")
        return 1
    return 0


def cmd_sets_changed(args):
    old, new = _load(args.old), _load(args.new)
    print("changed" if _sig(old) != _sig(new) else "same")
    return 0


def cmd_scope_reject(args):
    ns = _load(args.north_star)
    obj = _norm(args.objective)
    for pred in ns.get("scope", {}).get("out_of_scope", []) or []:
        if _norm(pred) in obj:
            print(pred)
            return 0
    return 1


def cmd_align_verdict(args):
    try:
        data = json.loads(sys.stdin.read())
        scores = data["scores"]
        dims = (scores["pillarFit"], scores["scopeCompliance"], scores["missionAdvancement"])
        orphan = bool(data["orphan"])
        scope_hit = bool(data["scopeHit"])
        threshold = data["threshold"]
        if not all(isinstance(d, (int, float)) for d in dims) or not isinstance(threshold, (int, float)):
            raise TypeError("scores and threshold must be numbers")
    except (ValueError, KeyError, TypeError) as e:
        sys.stderr.write("bad align-verdict input: %s\n" % e)
        return 2
    if scope_hit:
        print("rejected")
    elif orphan:
        print("blocked")
    elif all(d >= threshold for d in dims):
        print("aligned")
    else:
        print("needs-amendment")
    return 0


_ADR_RE = re.compile(r"(^|/)memory/north-star/decisions/[0-9]{4}-[^/]+\.md$")


def cmd_has_adr_for(args):
    for f in (args.added or "").split():
        if _ADR_RE.search(f):
            return 0
    return 1


def main(argv=None):
    p = argparse.ArgumentParser(prog="engine.py", description="North Star deterministic engine")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("schema-valid")
    s.add_argument("file")
    s.set_defaults(fn=cmd_schema_valid)

    s = sub.add_parser("sets-changed")
    s.add_argument("old")
    s.add_argument("new")
    s.set_defaults(fn=cmd_sets_changed)

    s = sub.add_parser("scope-reject")
    s.add_argument("objective")
    s.add_argument("--north-star", dest="north_star", required=True)
    s.set_defaults(fn=cmd_scope_reject)

    s = sub.add_parser("align-verdict")
    s.set_defaults(fn=cmd_align_verdict)

    s = sub.add_parser("has-adr-for")
    s.add_argument("--added", default="")
    s.set_defaults(fn=cmd_has_adr_for)

    args = p.parse_args(argv)
    try:
        return args.fn(args)
    except Malformed as e:
        sys.stderr.write("malformed: %s\n" % e)
        return 2


if __name__ == "__main__":
    sys.exit(main())
