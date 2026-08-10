#!/usr/bin/env bash
# Guard for pin P1 — "Python 3, standard library only".
# Exit 0 = every import resolves to the standard library or to a module in this project.
set -u
cd "$(dirname "$0")/../.."
STDLIB='sys|os|re|json|unittest|argparse|pathlib|itertools|collections|datetime|decimal'
bad=0
for f in ./*.py; do
  [ -f "$f" ] || continue
  for mod in $(grep -oE '^(import|from) [A-Za-z_][A-Za-z0-9_]*' "$f" | awk '{print $2}'); do
    [ -f "./$mod.py" ] && continue
    printf '%s' "$mod" | grep -qE "^($STDLIB)$" || { echo "P1: $f imports non-stdlib '$mod'"; bad=1; }
  done
done
exit $bad
