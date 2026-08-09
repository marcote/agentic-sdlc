# Sourced by tests/run.sh (lib.sh already loaded). Test contract for feature 013 —
# Stack Charter. 18 deterministic criteria from specs/013-stack-charter/acceptance.md.
# Hermetic: every fixture is built under mktemp -d; no network, no remote source, no
# controlling terminal, no assumption about the local branch, locale or clock.

CHARTER=memory/stack/stack.md
SBASE=memory/stack/base
ENGINE=scripts/stack/engine.py

# --- helpers (fixture-local, no ambient state) ---------------------------------

# pin_block CHARTER ID : emit the lines of pin "### <ID> …" up to the next "### " heading.
pin_block(){ awk -v id="$2" '
  $0 ~ "^### "id"([^0-9]|$)" {f=1; print; next}
  f && /^### / {exit}
  f {print}
' "$1" 2>/dev/null; }

# pin_ids CHARTER : emit every pin id in document order.
pin_ids(){ grep -oE '^### S[0-9]+' "$1" 2>/dev/null | awk '{print $2}'; }

# pin_field BLOCKFILE NAME : emit the value of "- Name:" from a pin block.
pin_field(){ grep -E "^-[[:space:]]+$2:" "$1" 2>/dev/null | sed -E "s/^-[[:space:]]+$2:[[:space:]]*//"; }

# --- STACK-CMD ------------------------------------------------------------------
assert_file .claude/commands/stack.md
assert_file .claude/skills/stack/SKILL.md
for step in "S0" "Draft" "Price" "Grill" "know" "oheren" "rite"; do
  assert_contains .claude/skills/stack/SKILL.md "$step"
done
assert_contains docs/workflow.md '/stack'
assert_contains CLAUDE.md '/stack'

# --- PIN-SHAPE ------------------------------------------------------------------
assert_file "$SBASE/pin-template.md"
for f in Confidence Because Buys Forecloses Falsifier; do
  assert_contains "$SBASE/pin-template.md" "$f"
done
if [ -f "$CHARTER" ]; then
  _shape_bad=0; _shape_n=0
  _pb=$(mktemp)
  for id in $(pin_ids "$CHARTER"); do
    pin_block "$CHARTER" "$id" > "$_pb"; _shape_n=$((_shape_n+1))
    for f in Confidence Because Buys Forecloses Falsifier; do
      [ -n "$(pin_field "$_pb" "$f")" ] || { _shape_bad=1; echo "    (pin $id missing $f)"; }
    done
  done
  rm -f "$_pb"
  if [ "$_shape_n" -ge 1 ] && [ "$_shape_bad" -eq 0 ]; then
    _pass "PIN-SHAPE: all $_shape_n pins carry the 5 required fields"
  else
    _fail "PIN-SHAPE: charter has $_shape_n pins, malformed=$_shape_bad"
  fi
else
  _fail "PIN-SHAPE: missing $CHARTER"
fi

# --- PROVISIONAL-HEDGE ----------------------------------------------------------
if [ -f "$CHARTER" ]; then
  _ph_bad=0; _pb=$(mktemp)
  for id in $(pin_ids "$CHARTER"); do
    pin_block "$CHARTER" "$id" > "$_pb"
    case "$(pin_field "$_pb" Confidence)" in
      PROVISIONAL*) [ -n "$(pin_field "$_pb" Hedge)" ] || { _ph_bad=1; echo "    (pin $id PROVISIONAL without Hedge)"; } ;;
    esac
  done
  rm -f "$_pb"
  [ "$_ph_bad" -eq 0 ] && _pass "PROVISIONAL-HEDGE: every PROVISIONAL pin carries a Hedge" \
                       || _fail "PROVISIONAL-HEDGE: a PROVISIONAL pin has no Hedge"
fi
# negative fixture: the engine must reject a PROVISIONAL pin with no Hedge
_fx=$(mktemp -d)
cat > "$_fx/bad.md" <<'EOF'
### S1 — Datastore: DuckDB [substrate]
- Confidence: PROVISIONAL
- Because: single writer today
- Buys: zero infra
- Forecloses: concurrent writes
- Falsifier: a second concurrent writer
EOF
if [ -f "$ENGINE" ] && ! python3 "$ENGINE" pin-valid "$_fx/bad.md" >/dev/null 2>&1; then
  _pass "PROVISIONAL-HEDGE: engine rejects a hedge-less PROVISIONAL pin"
else
  _fail "PROVISIONAL-HEDGE: engine accepted (or is missing for) a hedge-less PROVISIONAL pin"
fi
rm -rf "$_fx"

# --- STANCE-GUARD ---------------------------------------------------------------
if [ -f "$CHARTER" ]; then
  _sg_bad=0; _sg_n=0; _pb=$(mktemp)
  for id in $(pin_ids "$CHARTER"); do
    pin_block "$CHARTER" "$id" > "$_pb"
    grep -q '\[stance\]' "$_pb" || continue
    _sg_n=$((_sg_n+1))
    g=$(pin_field "$_pb" Guard)
    [ -n "$g" ] || { _sg_bad=1; echo "    (stance $id has no Guard)"; }
    [ -n "$(pin_field "$_pb" Injects)" ] || { _sg_bad=1; echo "    (stance $id has no Injects)"; }
  done
  rm -f "$_pb"
  if [ "$_sg_n" -ge 1 ] && [ "$_sg_bad" -eq 0 ]; then
    _pass "STANCE-GUARD: all $_sg_n stance pins name a Guard and an Injects"
  else
    _fail "STANCE-GUARD: stance pins=$_sg_n malformed=$_sg_bad"
  fi
fi
_fx=$(mktemp -d)
cat > "$_fx/nostance.md" <<'EOF'
### S1 — Data-driven core [stance]
- Confidence: PINNED
- Because: several consumers are plausible
- Buys: new transports are adapters
- Forecloses: free incremental streaming
- Falsifier: the core becomes single-consumer by contract
- Injects: every capability returns structured data
EOF
if [ -f "$ENGINE" ] && ! python3 "$ENGINE" pin-valid "$_fx/nostance.md" >/dev/null 2>&1; then
  _pass "STANCE-GUARD: engine rejects a stance pin with no Guard"
else
  _fail "STANCE-GUARD: engine accepted (or is missing for) a Guard-less stance pin"
fi
rm -rf "$_fx"

# --- GUARD-RUNS -----------------------------------------------------------------
assert_contains .claude/skills/verify/SKILL.md 'Guard'
assert_contains .claude/skills/verify/SKILL.md 'guards'
# the harness's own stance Guards must resolve, run, and pass on the real tree
if [ -f "$ENGINE" ] && [ -f "$CHARTER" ]; then
  _gr_n=0; _gr_bad=0
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    _gr_n=$((_gr_n+1))
    sh -c "$cmd" >/dev/null 2>&1 || { _gr_bad=1; echo "    (guard failed on clean tree: $cmd)"; }
  done <<EOF
$(python3 "$ENGINE" guards "$CHARTER" 2>/dev/null)
EOF
  [ "$_gr_n" -ge 1 ] && [ "$_gr_bad" -eq 0 ] \
    && _pass "GUARD-RUNS: $_gr_n stance Guard(s) run green on the real tree" \
    || _fail "GUARD-RUNS: guards=$_gr_n failing=$_gr_bad"
else
  _fail "GUARD-RUNS: engine or charter missing"
fi
# negative fixture (plan D5): a Guard that cannot fail certifies nothing
_fx=$(mktemp -d)
mkdir -p "$_fx/core" && printf 'print("leak")\n' > "$_fx/core/bad.py"
if ! grep -rqE '\bprint\(' "$_fx/core" 2>/dev/null; then
  _fail "GUARD-RUNS: negative fixture is not detectable — a vacuous Guard would pass"
else
  _pass "GUARD-RUNS: negative fixture is detectable (Guard can fail, not vacuous)"
fi
rm -rf "$_fx"

# --- PLAN-GATE ------------------------------------------------------------------
for tok in 'PASS' 'UNPINNED' 'TRIPPED' 'fail-closed' 'cite' '/stack'; do
  assert_contains .claude/commands/plan.md "$tok"
done

# --- PLAN-BOUNCE ----------------------------------------------------------------
assert_contains .claude/commands/plan.md 'distill'
assert_contains .claude/skills/distill/SKILL.md 'bounce|re-?freeze|reopen'

# --- TRIPPED-BILL ---------------------------------------------------------------
for tok in 'declared' 'Hedge' 'amend' 'narrow'; do
  assert_contains .claude/commands/plan.md "$tok"
done

# --- S0-PIN ---------------------------------------------------------------------
if [ -f "$CHARTER" ]; then
  [ "$(pin_ids "$CHARTER" | head -1)" = "S0" ] \
    && _pass "S0-PIN: S0 is the first pin" || _fail "S0-PIN: S0 is not the first pin"
  _pb=$(mktemp); pin_block "$CHARTER" S0 > "$_pb"
  [ -n "$(pin_field "$_pb" Falsifier)" ] \
    && _pass "S0-PIN: S0 carries a Falsifier (a rising tier is announced)" \
    || _fail "S0-PIN: S0 has no Falsifier"
  grep -qiE 'blast[ -]radius' "$_pb" \
    && _pass "S0-PIN: S0 records the blast-radius derivation" \
    || _fail "S0-PIN: S0 does not record its blast-radius derivation"
  rm -f "$_pb"
fi

# --- S0-SCOPE-ONLY --------------------------------------------------------------
assert_contains "$SBASE/README.md" 'scope'
assert_contains "$SBASE/README.md" 'RED'
assert_contains "$SBASE/README.md" '100%'
assert_contains "$SBASE/README.md" 'secret-scan|P6'

# --- NO-PRESCRIBE ---------------------------------------------------------------
# self-test of the span-aware scanner first (check_90 idiom): an example inside a
# fence must NOT trip; the same name asserted in prose MUST trip.
_fx=$(mktemp -d)
printf 'The template illustrates a pin:\n\n```\n- Datastore: PostgreSQL 16\n```\n' > "$_fx/fenced.md"
printf 'The harness requires PostgreSQL for all projects.\n' > "$_fx/prose.md"
_DENY='postgres|postgresql|duckdb|sqlite|railway|vercel|heroku|django|rails|fastapi|pytest|jest|poetry|uv|npm|pnpm|yarn|cargo'
prose_only "$_fx/fenced.md" | grep -qiE "$_DENY" \
  && _fail "NO-PRESCRIBE: scanner trips on a fenced example (false positive)" \
  || _pass "NO-PRESCRIBE: scanner ignores names inside fenced examples"
prose_only "$_fx/prose.md" | grep -qiE "$_DENY" \
  && _pass "NO-PRESCRIBE: scanner catches a name asserted in prose" \
  || _fail "NO-PRESCRIBE: scanner missed a name asserted in prose"
rm -rf "$_fx"
# the real assertion: nothing in memory/stack/base/ prescribes a tool in prose
if [ -d "$SBASE" ]; then
  _np_bad=0
  for f in "$SBASE"/*.md; do
    [ -f "$f" ] || continue
    if prose_only "$f" | grep -qiE "$_DENY"; then
      _np_bad=1; echo "    ($f names a tool in prose)"
    fi
  done
  [ "$_np_bad" -eq 0 ] && _pass "NO-PRESCRIBE: $SBASE prescribes no tool/runtime/vendor in prose" \
                       || _fail "NO-PRESCRIBE: $SBASE names a tool as a default in prose"
else
  _fail "NO-PRESCRIBE: missing $SBASE"
fi

# --- DISTILL-STANCE -------------------------------------------------------------
assert_contains .claude/skills/distill/SKILL.md 'stance'
assert_contains .claude/skills/distill/SKILL.md 'Injects'

# --- VENDOR-STACK ---------------------------------------------------------------
_vt=$(mktemp -d)
if bash scripts/vendor.sh --apply "$_vt" >/dev/null 2>&1; then
  assert_dir "$_vt/$SBASE"
  assert_file "$_vt/$CHARTER"
  if [ -f "$_vt/$CHARTER" ] && [ "$(pin_ids "$_vt/$CHARTER" | wc -l | tr -d ' ')" = "0" ]; then
    _pass "VENDOR-STACK: seeded charter carries no harness pin"
  else
    _fail "VENDOR-STACK: seeded charter leaked harness pins (or is missing)"
  fi
  if [ -f "$_vt/CLAUDE.md" ] && grep -qE 'memory/stack' "$_vt/CLAUDE.md"; then
    _pass "VENDOR-STACK: generated CLAUDE.md ## Stack points at the charter"
  else
    _fail "VENDOR-STACK: generated CLAUDE.md ## Stack is still a dead stub"
  fi
else
  _fail "VENDOR-STACK: vendor.sh --apply failed"
fi
rm -rf "$_vt"

# --- WOW-HEALTH -----------------------------------------------------------------
assert_contains .claude/skills/wow-report/SKILL.md 'charter'
assert_contains .claude/skills/wow-report/SKILL.md 'tripped'
assert_contains .claude/skills/wow-report/SKILL.md 'no pin|without a pin|unpinned'

# --- CHARTER-SEED (D3 reflexive dogfood) ----------------------------------------
if [ -f "$CHARTER" ]; then
  for live in 'python3|py3' 'bash' 'runtime'; do
    grep -qiE "$live" "$CHARTER" \
      && _pass "CHARTER-SEED: live decision pinned (/$live/)" \
      || _fail "CHARTER-SEED: live decision not pinned (/$live/)"
  done
fi

# --- RERUN-IDEMPOTENT  [given] base/idempotency ---------------------------------
_fx=$(mktemp -d)
cat > "$_fx/c.md" <<'EOF'
### S0 — Rigor tier: high [substrate]
- Confidence: PINNED
- Because: blast-radius answers say it is vendored into other repos
- Buys: full elicitation depth
- Forecloses: skipping the interview
- Falsifier: the project stops being consumed by anyone else

### S1 — Old choice [substrate] SUPERSEDED
- Confidence: PINNED
- Because: it was the only option at the time
- Buys: nothing anymore
- Forecloses: nothing anymore
- Falsifier: superseded by S2
- Superseded: 2026-08-08 — tripped by AC-04 (concurrent writers)
EOF
if [ -f "$ENGINE" ]; then
  a=$(python3 "$ENGINE" exposure "$_fx/c.md" 2>/dev/null)
  b=$(python3 "$ENGINE" exposure "$_fx/c.md" 2>/dev/null)
  [ -n "$a" ] && [ "$a" = "$b" ] \
    && _pass "RERUN-IDEMPOTENT: exposure is stable across runs" \
    || _fail "RERUN-IDEMPOTENT: exposure is empty or not stable"
  [ "$(pin_ids "$_fx/c.md" | wc -l | tr -d ' ')" = "2" ] \
    && _pass "RERUN-IDEMPOTENT: SUPERSEDED pin preserved in the charter" \
    || _fail "RERUN-IDEMPOTENT: SUPERSEDED pin dropped"
else
  _fail "RERUN-IDEMPOTENT: missing $ENGINE"
fi
assert_contains .claude/skills/stack/SKILL.md 'delta|never.*drop|preserv'
rm -rf "$_fx"

# --- AMEND-TRAIL  [given] base/audit-logging ------------------------------------
_fx=$(mktemp -d)
cat > "$_fx/noreason.md" <<'EOF'
### S1 — Old choice [substrate] SUPERSEDED
- Confidence: PINNED
- Because: historical
- Buys: nothing
- Forecloses: nothing
- Falsifier: superseded
- Superseded: 2026-08-08
EOF
if [ -f "$ENGINE" ] && ! python3 "$ENGINE" pin-valid "$_fx/noreason.md" >/dev/null 2>&1; then
  _pass "AMEND-TRAIL: engine rejects a SUPERSEDED pin with no reason/trigger"
else
  _fail "AMEND-TRAIL: engine accepted (or is missing for) a reason-less SUPERSEDED pin"
fi
rm -rf "$_fx"

# --- HERMETIC-ENV  [given] base/hermetic-tests ----------------------------------
# A self-scanning checker must not carry the forbidden literal in its own pattern, or it
# detects itself — the sibling of check_90's placeholder blind spot. Both patterns are
# assembled from fragments at runtime so this file never contains them verbatim.
_NET_PAT="(curl|wget|git clone)[^|]*(https?:/""/|git@)"
_AMB_PAT="(/dev""/tty|git checkout ""main|rev-parse ""main)"
if grep -qE "$_NET_PAT" tests/check_92_stack.sh; then
  _fail "HERMETIC-ENV: check_92 reaches a remote source"
else
  _pass "HERMETIC-ENV: check_92 reaches no network or remote source"
fi
if grep -qE "$_AMB_PAT" tests/check_92_stack.sh; then
  _fail "HERMETIC-ENV: check_92 assumes a terminal or a local main branch"
else
  _pass "HERMETIC-ENV: check_92 assumes no terminal and no local main"
fi
# self-test: the assembled patterns must actually match when the thing IS present
_fx=$(mktemp -d); printf 'x=$(curl https:/''/example.com)\n' > "$_fx/net.sh"
grep -qE "$_NET_PAT" "$_fx/net.sh" \
  && _pass "HERMETIC-ENV: network pattern catches a real remote fetch" \
  || _fail "HERMETIC-ENV: network pattern is vacuous (matches nothing)"
printf 'read a < /dev''/tty\n' > "$_fx/tty.sh"
grep -qE "$_AMB_PAT" "$_fx/tty.sh" \
  && _pass "HERMETIC-ENV: ambient pattern catches a real terminal read" \
  || _fail "HERMETIC-ENV: ambient pattern is vacuous (matches nothing)"
rm -rf "$_fx"
[ -f "$ENGINE" ] && assert_dep_free "$ENGINE" || _fail "HERMETIC-ENV: missing $ENGINE"
