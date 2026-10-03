# Sourced by tests/run.sh. Every agent-facing file passes the prose check.
if out=$(uv run -q scripts/prose.py 2>&1); then _pass "prose check"; else _fail "prose check: $out"; fi
