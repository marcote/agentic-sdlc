#!/usr/bin/env python3
"""Stack charter engine — dependency-free (python3 stdlib) reference implementation.

Deterministic capabilities over a project's stack charter (memory/stack/stack.md):

  pin-valid FILE     every pin carries the five required fields; a PROVISIONAL pin
                     has a Hedge; a [stance] pin has both Guard and Injects; a
                     SUPERSEDED pin records a date AND a reason/trigger.
  exposure FILE      the charter's exposure header — counts by Confidence plus the
                     ids you are exposed on. Byte-stable across runs.
  guards FILE        one [stance] Guard command per line, for /verify to execute.

This is a *reference* engine, not a requirement: the contract lives in the template
(memory/stack/base/), and an adopting repo may reimplement it in its own stack — the
same doctrine scripts/north-star/engine.py follows. The harness's own charter pins
that posture explicitly.

Exit contract (shell-friendly):
  0 = valid / emitted
  1 = invalid (reasons on stderr)
  2 = error — the file cannot be read or contains no pin at all
stdout carries the payload; reasons and errors go to stderr.
"""
import sys
import re
import argparse

# "### S3 — Datastore: DuckDB   [substrate] SUPERSEDED"
_HEAD = re.compile(r"^###\s+(S\d+)\s*(.*)$")
# "- Confidence: PROVISIONAL — leaning this way"
_FIELD = re.compile(r"^-\s+([A-Za-z][A-Za-z-]*):\s*(.*)$")

REQUIRED = ("Confidence", "Because", "Buys", "Forecloses", "Falsifier")


class Malformed(Exception):
    """The charter cannot be parsed into pins (→ exit 2)."""


def _parse(path):
    """Parse a charter into an ordered list of pin dicts.

    Continuation lines (an indented line following a field) append to that field, so
    a long Injects or Hedge may wrap without changing its meaning.
    """
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except OSError as e:
        raise Malformed("cannot read %s: %s" % (path, e))

    pins, cur, last, fenced = [], None, None, False
    for raw in lines:
        if raw.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue  # never parse pins out of an example block
        m = _HEAD.match(raw)
        if m:
            rest = m.group(2)
            cur = {
                "id": m.group(1),
                "title": rest,
                "stance": "[stance]" in rest,
                "substrate": "[substrate]" in rest,
                "superseded": "SUPERSEDED" in rest,
                "fields": {},
            }
            pins.append(cur)
            last = None
            continue
        if cur is None:
            continue
        f = _FIELD.match(raw)
        if f:
            last = f.group(1)
            cur["fields"][last] = f.group(2).strip()
        elif last and raw.startswith(" ") and raw.strip():
            cur["fields"][last] = (cur["fields"][last] + " " + raw.strip()).strip()
        elif not raw.strip():
            last = None
    if not pins:
        raise Malformed("no pin found in %s" % path)
    return pins


def _has(pin, name):
    return bool(pin["fields"].get(name, "").strip())


def _validate(pins):
    """Return a list of human-readable reasons; empty means valid."""
    bad = []
    for p in pins:
        for f in REQUIRED:
            if not _has(p, f):
                bad.append("%s: missing %s" % (p["id"], f))
        if not p["stance"] and not p["substrate"]:
            bad.append("%s: no [stance] or [substrate] kind tag" % p["id"])
        if p["fields"].get("Confidence", "").upper().startswith("PROVISIONAL") and not _has(p, "Hedge"):
            bad.append("%s: PROVISIONAL without a Hedge" % p["id"])
        if p["stance"]:
            if not _has(p, "Guard"):
                bad.append("%s: [stance] without a Guard" % p["id"])
            if not _has(p, "Injects"):
                bad.append("%s: [stance] without an Injects" % p["id"])
        if p["superseded"]:
            sup = p["fields"].get("Superseded", "")
            if not re.search(r"\d{4}-\d{2}-\d{2}", sup):
                bad.append("%s: SUPERSEDED without a date" % p["id"])
            # a date alone is not a trail: the reason/trigger must be recorded too
            if not re.search(r"[A-Za-z]{3,}", re.sub(r"\d{4}-\d{2}-\d{2}", "", sup)):
                bad.append("%s: SUPERSEDED without a reason/trigger" % p["id"])
    return bad


def cmd_pin_valid(args):
    bad = _validate(_parse(args.file))
    for reason in bad:
        sys.stderr.write(reason + "\n")
    return 1 if bad else 0


def cmd_exposure(args):
    pins = [p for p in _parse(args.file) if not p["superseded"]]
    prov = [p for p in pins if p["fields"].get("Confidence", "").upper().startswith("PROVISIONAL")]
    pinned = len(pins) - len(prov)
    print("%d pins · %d PINNED · %d PROVISIONAL" % (len(pins), pinned, len(prov)))
    if prov:
        print("Exposure: " + ", ".join("%s %s" % (p["id"], p["title"].split("[")[0].strip(" —-")) for p in prov))
    else:
        print("Exposure: none declared")
    return 0


def cmd_guards(args):
    for p in _parse(args.file):
        if p["stance"] and not p["superseded"] and _has(p, "Guard"):
            print(p["fields"]["Guard"])
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(prog="engine.py", description="Stack charter deterministic engine")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("pin-valid")
    s.add_argument("file")
    s.set_defaults(fn=cmd_pin_valid)

    s = sub.add_parser("exposure")
    s.add_argument("file")
    s.set_defaults(fn=cmd_exposure)

    s = sub.add_parser("guards")
    s.add_argument("file")
    s.set_defaults(fn=cmd_guards)

    args = p.parse_args(argv)
    try:
        return args.fn(args)
    except Malformed as e:
        sys.stderr.write("malformed: %s\n" % e)
        return 2


if __name__ == "__main__":
    sys.exit(main())
