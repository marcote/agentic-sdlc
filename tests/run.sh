#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
. tests/lib.sh
for t in tests/check_*.sh; do
  [ -f "$t" ] || continue
  echo "== $t =="
  . "$t"
done
summary
