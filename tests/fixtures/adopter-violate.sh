#!/usr/bin/env bash
# Scaffolding owned by the fixture, not by the check that runs it.
#
# Makes a COPY of the adopter fixture violate its own declared stances, so the harness can
# observe a declared Guard failing without ever knowing what that Guard checks. A guard that
# cannot fail certifies nothing (base/pin-template.md).
#
#   tests/fixtures/adopter-violate.sh <target-copy>
set -u
T=${1:?usage: adopter-violate.sh <target-copy>}
{
  echo ""
  echo "import requests            # violates P1: not in the standard library"
  echo "def _cache(v):"
  echo "    open('ledger.cache', 'w').write(str(v))   # violates P2: state outlives the process"
} >> "$T/ledger.py"
