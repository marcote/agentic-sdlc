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
