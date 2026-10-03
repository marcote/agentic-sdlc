# Sourced by tests/run.sh. Every learned lesson names a check that exists, or has helpful >= 1.
if out=$(uv run -q scripts/lessons.py check 2>&1); then _pass "lessons check"; else _fail "lessons check: $out"; fi
