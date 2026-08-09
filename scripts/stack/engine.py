#!/usr/bin/env python3
"""Stack charter engine — dependency-free (python3 stdlib) reference implementation.

Deterministic capabilities over a project's stack charter (memory/stack/stack.md):

  pin-valid FILE     every pin carries the five required fields; a PROVISIONAL pin
                     has a Hedge; a [stance] pin has both Guard and Injects; a
                     SUPERSEDED pin records a date AND a reason/trigger.
  exposure FILE      the charter's exposure header — counts by Confidence plus the
                     ids you are exposed on. Byte-stable across runs.
  ground-rules FILE  coverage of the ground rules (memory/stack/base/ground-rules.md plus
                     any project layer, overridable with repeatable --rules): one line per
                     rule, "GR<n>: pin <id>" / "n/a" / "uncovered". A SUPERSEDED pin does
                     not count -- history is not a rationale.
  guards FILE        one Guard command per line, for /verify to execute. ANY pin kind may
                     declare one: whether a pin injects a per-feature coverage row (stance
                     only) is orthogonal to whether it can be checked by a command (both).
                     A substrate choice such as a dependency tool is often the more
                     mechanically checkable of the two.

This is a *reference* engine, not a requirement: the contract lives in the template
(memory/stack/base/), and an adopting repo may reimplement it in its own stack — the
same doctrine scripts/north-star/engine.py follows. The harness's own charter pins
that posture explicitly.

Exit contract (shell-friendly):
  0 = valid / emitted
  1 = invalid (reasons on stderr)
  1 = incomplete — for ground-rules: at least one rule has no verdict (listed on stderr)
  2 = error — the file cannot be read or parsed; also a rejected input: an unknown ground
      rule id, a declination missing Because/Falsifier, or a rule layer that omits a base
      rule. Every rejection NAMES what it rejected on stderr, because an exit code alone is
      also what an unimplemented subcommand produces.
  3 = empty — a well-formed charter with zero pins. Distinct from 2 on purpose: a freshly
      vendored repo seeds a stub, so "no pins yet" is an adopter's day-one state, not a
      defect. Reporting it as malformed sends them hunting a bug that is not there.
stdout carries the payload; reasons and errors go to stderr.
"""
import os
import re
import sys
import argparse

# "### S3 — Datastore: DuckDB   [substrate] SUPERSEDED"
_HEAD = re.compile(r"^###\s+(S\d+)\s*(.*)$")
# "- Confidence: PROVISIONAL — leaning this way"
_FIELD = re.compile(r"^-\s+([A-Za-z][A-Za-z-]*):\s*(.*)$")
# "### GR2 — n/a"  (a declination; NOT a pin)
_NA = re.compile(r"^###\s+(GR\d+)\s*[—-]\s*n/a\s*$", re.I)
# "### GR2 — Persistence and concurrency"  (a ground rule definition)
_RULE = re.compile(r"^###\s+(GR\d+)\b")

REQUIRED = ("Confidence", "Because", "Buys", "Forecloses", "Falsifier")


class Malformed(Exception):
    """The charter cannot be read or parsed (→ exit 2)."""


class Empty(Exception):
    """A well-formed charter with zero pins (→ exit 3). Not a defect: work not yet done."""


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
        raise Empty("no pins yet in %s — run /stack to elicit them" % path)
    return pins


def _blocks(path, head_re):
    """Fence-aware scan for '### <id> …' blocks matching head_re, with their '- Field:' lines.

    Fences are skipped: these files necessarily illustrate their own grammar in examples,
    and a fence-blind reader counts the example as real (it did, in this feature's own
    contract).
    """
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except OSError as e:
        raise Malformed("cannot read %s: %s" % (path, e))
    out, cur, last, fenced = [], None, None, False
    for raw in lines:
        if raw.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        m = head_re.match(raw)
        if m:
            cur = {"id": m.group(1).upper(), "fields": {}}
            out.append(cur)
            last = None
            continue
        if raw.startswith("### "):
            cur = None
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
    return out


def _effective_rules(paths):
    """Assemble the effective ground rule set. Additive only: a layer omitting a base rule
    is rejected, because the auditable escape is a declination, not removal."""
    if not paths:
        paths = ["memory/stack/base/ground-rules.md", "memory/stack/ground-rules.md"]
        paths = [p for p in paths if os.path.exists(p)]
    if not paths:
        raise Malformed("no ground rule file found")
    base = [b["id"] for b in _blocks(paths[0], _RULE)]
    if not base:
        raise Malformed("%s defines no ground rule" % paths[0])
    eff = list(base)
    for extra in paths[1:]:
        ids = [b["id"] for b in _blocks(extra, _RULE)]
        if not ids:
            continue
        # A layer that only introduces new ids is a pure addition and is fine. A layer that
        # restates any base rule is redefining the set, and must then carry ALL of them --
        # otherwise "adding" would be a way to quietly drop one.
        if any(i in base for i in ids):
            missing = [b for b in base if b not in ids]
            if missing:
                raise Malformed("%s omits base ground rule(s): %s — the floor is additive only"
                                % (extra, ", ".join(missing)))
        for i in ids:
            if i not in eff:
                eff.append(i)
    return eff


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
            # required on stance (a stance without teeth degrades to prose); optional on
            # substrate, but emitted and executed either way — see cmd_guards.
            if not _has(p, "Guard"):
                bad.append("%s: [stance] without a Guard" % p["id"])
            if not _has(p, "Injects"):
                bad.append("%s: [stance] without an Injects" % p["id"])
        if p["substrate"] and _has(p, "Injects"):
            bad.append("%s: [substrate] cannot carry Injects (coverage rows are stance-only)" % p["id"])
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
    try:
        pins = [p for p in _parse(args.file) if not p["superseded"]]
    except Empty:
        print("0 pins · 0 PINNED · 0 PROVISIONAL")
        print("Exposure: no pins yet — run /stack")
        return 0
    prov = [p for p in pins if p["fields"].get("Confidence", "").upper().startswith("PROVISIONAL")]
    pinned = len(pins) - len(prov)
    print("%d pins · %d PINNED · %d PROVISIONAL" % (len(pins), pinned, len(prov)))
    if prov:
        print("Exposure: " + ", ".join("%s %s" % (p["id"], p["title"].split("[")[0].strip(" —-")) for p in prov))
    else:
        print("Exposure: none declared")
    return 0


def cmd_ground_rules(args):
    rules = _effective_rules(args.rules)
    try:
        pins = _parse(args.file)
    except Empty:
        pins = []
    declined = _blocks(args.file, _NA)

    for d in declined:
        if d["id"] not in rules:
            raise Malformed("unknown ground rule %s declined in %s" % (d["id"], args.file))
        for f in ("Because", "Falsifier"):
            if not d["fields"].get(f, "").strip():
                raise Malformed("declination %s in %s is missing %s — a decline must record why "
                                "it was made and when it expires" % (d["id"], args.file, f))
    if not pins and not declined:
        raise Empty("no pins yet in %s — run /stack to elicit them" % args.file)

    answers = {}
    for p in pins:
        for gid in [x.strip().upper() for x in p["fields"].get("Answers", "").split(",") if x.strip()]:
            if gid not in rules:
                raise Malformed("unknown ground rule %s claimed by pin %s in %s"
                                % (gid, p["id"], args.file))
            if p["superseded"]:
                continue  # history is not a rationale
            answers.setdefault(gid, p["id"])

    na = {d["id"] for d in declined}
    uncovered = []
    for gid in rules:
        if gid in answers:
            print("%s: pin %s" % (gid, answers[gid]))
        elif gid in na:
            print("%s: n/a" % gid)
        else:
            print("%s: uncovered" % gid)
            uncovered.append(gid)
    if uncovered:
        sys.stderr.write("uncovered ground rule(s): %s\n" % ", ".join(uncovered))
        return 1
    return 0


def cmd_guards(args):
    try:
        pins = _parse(args.file)
    except Empty:
        return 0  # no stance pin means nothing to run, which is not a failure
    for p in pins:
        if not p["superseded"] and _has(p, "Guard"):
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

    s = sub.add_parser("ground-rules")
    s.add_argument("file")
    s.add_argument("--rules", action="append", default=[])
    s.set_defaults(fn=cmd_ground_rules)

    s = sub.add_parser("guards")
    s.add_argument("file")
    s.set_defaults(fn=cmd_guards)

    args = p.parse_args(argv)
    try:
        return args.fn(args)
    except Empty as e:
        sys.stderr.write("empty: %s\n" % e)
        return 3
    except Malformed as e:
        sys.stderr.write("malformed: %s\n" % e)
        return 2


if __name__ == "__main__":
    sys.exit(main())
