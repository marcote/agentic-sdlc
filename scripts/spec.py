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
