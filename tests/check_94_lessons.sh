# Sourced by tests/run.sh. Every promoted lesson names a check that exists; every merged lesson names a lesson that exists.
if out=$(uv run -q scripts/lessons.py check 2>&1); then _pass "lessons check"; else _fail "lessons check: $out"; fi
