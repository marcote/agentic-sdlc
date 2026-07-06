# Sourced by tests/run.sh (lib.sh already loaded). Contract of the North Star engine
# (scripts/north-star/engine.py): a dependency-free python3 reference for schema
# validation, governed-set change (requiresAdr), scope rejection, verdict aggregation
# (alignVerdict), and ADR presence (hasAdrFor). Exercises every capability against
# fixtures with the exit-code + minimal-stdout contract the bash caller relies on.
# Covers 18 deterministic criteria of acceptance.md; GATE-REGRESSION is owned by
# check_95 (the untouched amendment-gate suite).
#
# CLI contract the implementation must satisfy:
#   engine.py schema-valid FILE          exit 0 valid | 1 invalid(+reason on stderr) | 2 malformed
#   engine.py sets-changed OLD NEW       stdout changed|same, exit 0 | 2 malformed
#   engine.py scope-reject OBJ --north-star FILE   exit 0 + predicate | 1 no-hit | 2 malformed
#   engine.py align-verdict              JSON on stdin -> verdict on stdout, exit 0 | 2 bad input
#   engine.py has-adr-for --added "…"    exit 0 present | 1 absent

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
eng_out(){ # desc, expected_exit, stdout_regex, args…
  local desc="$1" exp="$2" re="$3"; shift 3
  local got; got=$(_run "$@")
  if [ "$got" = "$exp" ] && grep -qiE "$re" /tmp/eng_out 2>/dev/null; then _pass "$desc (exit $exp, out ~/$re/)"
  else _fail "$desc: expected exit $exp + /$re/, got exit $got out '$(head -1 /tmp/eng_out 2>/dev/null)'"; fi
}
eng_reason(){ # desc, expected_exit, stderr_regex, args…  (invalid must explain which field)
  local desc="$1" exp="$2" re="$3"; shift 3
  local got; got=$(_run "$@")
  if [ "$got" = "$exp" ] && grep -qiE "$re" /tmp/eng_err 2>/dev/null; then _pass "$desc (exit $exp, reason ~/$re/)"
  else _fail "$desc: expected exit $exp + stderr /$re/, got exit $got err '$(head -1 /tmp/eng_err 2>/dev/null)'"; fi
}
eng_verdict(){ # desc, json, expected_verdict
  local desc="$1" json="$2" exp="$3" out=""
  [ -f "$ENG" ] && out=$(printf '%s' "$json" | python3 "$ENG" align-verdict 2>/tmp/eng_err)
  if [ "$out" = "$exp" ]; then _pass "$desc (verdict=$exp)"
  else _fail "$desc: expected verdict '$exp', got '$out' (err: $(head -1 /tmp/eng_err 2>/dev/null))"; fi
}

# --- schema-valid (validateNorthStar) ---
eng_exit   "SCHEMA-VALID: accepts a valid North Star"          0 schema-valid "$F/valid.md"
eng_reason "SCHEMA-INVALID: rejects empty mission, names field" 1 "mission" schema-valid "$F/invalid.md"
eng_exit   "SCHEMA-MALFORMED: no json block -> error, not invalid" 2 schema-valid "$F/malformed.md"

# --- sets-changed (requiresAdr) ---
eng_out "SETS-CHANGED: governed set differs -> changed"        0 "changed" sets-changed "$F/valid.md" "$F/sets-diff.md"
eng_out "SETS-SAME-PROSE: prose/mission/threshold only -> same" 0 "same"    sets-changed "$F/valid.md" "$F/prose-diff.md"
eng_out "SETS-ORDER-AGNOSTIC: reordered entries -> same"       0 "same"     sets-changed "$F/valid.md" "$F/reordered.md"

# --- scope-reject (scopeReject) ---
eng_out  "SCOPE-HIT: full predicate substring -> hit + predicate" 0 "blocking commit hooks" scope-reject "add blocking commit hooks to the pipeline" --north-star "$F/valid.md"
eng_exit "SCOPE-MISS-PARTIAL: partial overlap is not a hit"       1 scope-reject "ship a deterministic engine in python" --north-star "$F/valid.md"
eng_out  "SCOPE-NORMALIZE: case/whitespace-insensitive hit"       0 "blocking commit hooks" scope-reject "Please   ADD   Blocking Commit Hooks now" --north-star "$F/valid.md"

# --- align-verdict (alignVerdict) : deterministic cascade ---
eng_verdict "VERDICT-REJECTED: scopeHit outranks all-5 scores" \
  '{"scores":{"pillarFit":5,"scopeCompliance":5,"missionAdvancement":5},"orphan":false,"scopeHit":true,"threshold":3}' rejected
eng_verdict "VERDICT-BLOCKED: orphan outranks passing scores" \
  '{"scores":{"pillarFit":4,"scopeCompliance":4,"missionAdvancement":4},"orphan":true,"scopeHit":false,"threshold":3}' blocked
eng_verdict "VERDICT-ALIGNED: all dims >= threshold" \
  '{"scores":{"pillarFit":3,"scopeCompliance":3,"missionAdvancement":4},"orphan":false,"scopeHit":false,"threshold":3}' aligned
eng_verdict "VERDICT-NEEDS-AMENDMENT: a dim below threshold" \
  '{"scores":{"pillarFit":4,"scopeCompliance":2,"missionAdvancement":4},"orphan":false,"scopeHit":false,"threshold":3}' needs-amendment

# --- has-adr-for (hasAdrFor) ---
eng_exit "ADR-PRESENT: an added decisions/NNNN-slug.md" 0 has-adr-for --added "src/x.ts memory/north-star/decisions/0004-new.md"
eng_exit "ADR-ABSENT: README.md / no NNNN-slug is not an ADR" 1 has-adr-for --added "src/x.ts memory/north-star/decisions/README.md"

# --- GATE-REUSE: amendment-gate.sh calls the engine, no embedded copy ---
GATE=scripts/amendment-gate.sh
if [ -f "$GATE" ] && grep -q "north-star/engine.py" "$GATE" && ! grep -qE '(_py\(\)|has_new_adr)' "$GATE"; then
  _pass "GATE-REUSE: gate calls engine.py, no embedded heredoc / has_new_adr"
else
  _fail "GATE-REUSE: gate still embeds its own engine (no engine.py call, or _py()/has_new_adr present)"
fi

# --- DEP-FREE: engine exists (tied to deliverable) and imports only python3 stdlib ---
assert_file "$ENG"
if [ -f "$ENG" ]; then
  if grep -qE '^[[:space:]]*(import|from)[[:space:]]+(requests|yaml|numpy|pydantic|click|rich|toml)' "$ENG"; then
    _fail "DEP-FREE: $ENG imports a third-party package"
  else
    assert_dep_free "$ENG"   # shared helper (feature 008, candidate B)
  fi
fi

# --- SELF-CHECK: the suite exercises the engine deliverable (globbed by run.sh) ---
# Tied to the deliverable: the engine must exist for the suite to exercise it.
assert_file "$ENG"
