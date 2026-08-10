#!/usr/bin/env bash
# The one command the workflow runs. Authored by this project; vendor.sh must not clobber it.
set -u
cd "$(dirname "$0")/.."
python3 -m unittest test_ledger >/tmp/adopter_suite 2>&1
rc=$?
echo "adopter-suite: exit $rc ($(tail -1 /tmp/adopter_suite))"
exit $rc
