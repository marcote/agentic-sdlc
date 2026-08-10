#!/usr/bin/env bash
# Guard for pin P2 — "read stdin, write stdout, keep nothing".
# Exit 0 = nothing in this project opens a file for writing or appending.
set -u
cd "$(dirname "$0")/../.."
if grep -nE "open\([^)]*[\"'][wa]" ./*.py 2>/dev/null; then
  echo "P2: a module writes to a file; nothing may outlive the process"
  exit 1
fi
exit 0
