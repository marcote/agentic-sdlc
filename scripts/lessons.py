#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""lessons.py — check memory/lessons.md.

  uv run scripts/lessons.py check

Exit: 0 clean · 1 findings.
"""
import sys
from pathlib import Path

LESSONS = "memory/lessons.md"


def rows(text):
    lines = [[c.strip() for c in l.strip().strip("|").split("|")] for l in text.splitlines() if l.startswith("|")]
    return [dict(zip(lines[0], r)) for r in lines[2:]]


def apply(text, deltas):
    """text with each lesson delta applied: an add is `proposed` for a rule and `captured` otherwise; `helpful` on a captured lesson makes it learned."""
    head = next(l for l in text.splitlines() if l.startswith("|"))
    cols = [c.strip() for c in head.strip("|").split("|")]
    table = rows(text)
    for d in deltas:
        if d["op"] == "add":
            n = max([int(r["id"][1:]) for r in table], default=0) + 1
            table.append({"id": f"L{n}", "lesson": d["lesson"].replace("|", "/"), "check": "none: judgment", "source": d["source"],
                          "helpful": "0", "harmful": "0", "status": "proposed" if d["kind"] == "rule" else "captured"})
            continue
        for r in table:
            if r["id"] == d["id"]:
                r[d["op"]] = str(int(r[d["op"]]) + 1)
                if d["op"] == "helpful" and r["status"] == "captured":
                    r["status"] = "learned"
    body = ["| " + " | ".join(cols) + " |", "|" + " --- |" * len(cols)] + ["| " + " | ".join(r[c] for c in cols) + " |" for r in table]
    return text[:text.index(head)] + "\n".join(body) + "\n"


def finding(r):
    if r["status"] != "learned":
        return None
    path, _, name = r["check"].partition("::")
    if name:
        f = Path(path)
        if not (f.is_file() and f"def {name}(" in f.read_text()):
            return f"check not found: {r['check']}"
    elif int(r["helpful"]) < 1:
        return "learned without evidence"


def main():
    if sys.argv[1:] != ["check"] or not Path(LESSONS).is_file():
        sys.exit("usage: lessons.py check (run where memory/lessons.md exists)")
    found = [f"{r['id']}: {m}" for r in rows(Path(LESSONS).read_text()) if (m := finding(r))]
    print("\n".join(found))
    sys.exit(1 if found else 0)


if __name__ == "__main__":
    main()
