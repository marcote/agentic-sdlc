# Sourced by tests/run.sh (lib.sh already loaded). Contract of the North Star engine
# (scripts/north-star/engine.py): a dependency-free python3 reference for schema
# validation. Exercises it against fixtures with the exit-code contract the bash
# caller relies on.
#
# CLI contract the implementation must satisfy:
#   engine.py schema-valid FILE          exit 0 valid | 1 invalid(+reason on stderr) | 2 malformed

ENG=scripts/north-star/engine.py
F=tests/fixtures/north-star-engine

# _run ARGS… -> echoes exit code. Sentinel 127 when the engine file is absent, so a
# missing engine never masquerades as a real exit 2 (malformed) or any other answer.
_run(){ [ -f "$ENG" ] || { echo 127; return; }; python3 "$ENG" "$@" >/tmp/eng_out 2>/tmp/eng_err; echo $?; }

eng_exit(){ # desc, expected_exit, args…
  local desc="$1" exp="$2"; shift 2
  local got; got=$(_run "$@")
  if [ "$got" = "$exp" ]; then _pass "$desc (exit $exp)"
  else _fail "$desc: expected exit $exp, got $got (err: $(head -1 /tmp/eng_err 2>/dev/null))"; fi
}
eng_reason(){ # desc, expected_exit, stderr_regex, args…  (invalid must explain which field)
  local desc="$1" exp="$2" re="$3"; shift 3
  local got; got=$(_run "$@")
  if [ "$got" = "$exp" ] && grep -qiE "$re" /tmp/eng_err 2>/dev/null; then _pass "$desc (exit $exp, reason ~/$re/)"
  else _fail "$desc: expected exit $exp + stderr /$re/, got exit $got err '$(head -1 /tmp/eng_err 2>/dev/null)'"; fi
}

# --- schema-valid (validateNorthStar) ---
eng_exit   "SCHEMA-VALID: accepts a valid North Star"          0 schema-valid "$F/valid.md"
eng_reason "SCHEMA-INVALID: rejects empty mission, names field" 1 "mission" schema-valid "$F/invalid.md"
eng_exit   "SCHEMA-MALFORMED: no json block -> error, not invalid" 2 schema-valid "$F/malformed.md"

# --- the removed commands are gone: only schema-valid is offered ---
eng_exit "ONLY-SCHEMA-VALID: align-verdict is no longer a command" 2 align-verdict

# --- DEP-FREE: engine exists (tied to deliverable) and imports only python3 stdlib ---
assert_file "$ENG"
if [ -f "$ENG" ]; then
  if grep -qE '^[[:space:]]*(import|from)[[:space:]]+(requests|yaml|numpy|pydantic|click|rich|toml)' "$ENG"; then
    _fail "DEP-FREE: $ENG imports a third-party package"
  else
    assert_dep_free "$ENG" "DEP-FREE"   # labelled so the result ties to the criterion (015)
  fi
fi

# --- SELF-CHECK: the suite exercises the engine deliverable (globbed by run.sh) ---
# Tied to the deliverable: the engine must exist for the suite to exercise it.
if [ -f "$ENG" ]; then _pass "SELF-CHECK: deliverable present at "$ENG""
else _fail "SELF-CHECK: missing deliverable "$ENG""; fi
