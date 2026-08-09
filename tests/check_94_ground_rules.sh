# Sourced by tests/run.sh (lib.sh already loaded). Test contract for feature 014 —
# Ground rules. 14 deterministic criteria from specs/014-ground-rules/acceptance.md.
# Hermetic: every fixture is built under mktemp -d, in the block that uses it (013's
# fifth vacuous assertion borrowed a fixture from another block and silently checked a
# missing file). Every assertion ships a negative case.

GRBASE=memory/stack/base/ground-rules.md
GRPROJ=memory/stack/ground-rules.md
CHARTER=memory/stack/stack.md
ENGINE=scripts/stack/engine.py

# gr_ids FILE : emit the ground rule ids in document order, IGNORING fenced blocks —
# ground-rules.md necessarily shows an example declination (`### GR2 — n/a`) inside a
# fence, and a fence-blind counter reads it as a seventh rule. Same code-span blindness
# as prose_only and the engine parser, this time in a counter rather than a scanner.
gr_ids(){ awk '/^[[:space:]]*```/{f=!f; next} !f' "$1" 2>/dev/null | grep -oE '^### GR[0-9]+' | awk '{print $2}'; }

# --- GR-SIX ---------------------------------------------------------------------
assert_file "$GRBASE"
if [ -f "$GRBASE" ]; then
  _n=$(gr_ids "$GRBASE" | wc -l | tr -d ' ')
  [ "$_n" = "6" ] && _pass "GR-SIX: exactly six ground rules ship" \
                  || _fail "GR-SIX: $_n ground rules ship, expected exactly 6"
  _expected="GR1 GR2 GR3 GR4 GR5 GR6"
  [ "$(gr_ids "$GRBASE" | tr '\n' ' ' | sed 's/ $//')" = "$_expected" ] \
    && _pass "GR-SIX: ids are GR1..GR6 in order" \
    || _fail "GR-SIX: ids are not GR1..GR6 in order"
  _bad=0
  for id in $(gr_ids "$GRBASE"); do
    blk=$(awk -v id="$id" '$0 ~ "^### "id"([^0-9]|$)" {f=1} f && /^### / && $2 != id {exit} f' "$GRBASE")
    printf '%s' "$blk" | grep -qE '^-[[:space:]]+Question:' || { _bad=1; echo "    ($id has no Question)"; }
    printf '%s' "$blk" | grep -qE '^-[[:space:]]+Prevents:' || { _bad=1; echo "    ($id has no Prevents)"; }
  done
  [ "$_bad" -eq 0 ] && _pass "GR-SIX: every rule states a Question and what it Prevents" \
                    || _fail "GR-SIX: a rule is missing Question or Prevents"
fi
# negative: a seventh must be detectable as over the cap
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6 7; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/seven.md"
[ "$(gr_ids "$_fx/seven.md" | wc -l | tr -d ' ')" = "7" ] \
  && _pass "GR-SIX: a seventh rule is detectable (cap is asserted, not assumed)" \
  || _fail "GR-SIX: the counter cannot see a seventh rule — the cap check is vacuous"
rm -rf "$_fx"

# --- ANSWERS-FIELD --------------------------------------------------------------
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/rules.md"
cat > "$_fx/ok.md" <<'EOF'
### S1 — Consumption shape [substrate]
- Confidence: PINNED
- Because: one consumer today, more are plausible
- Buys: transports are adapters
- Forecloses: fusing compute and transport
- Falsifier: the core is contractually pinned to one consumer
- Answers: GR1, GR3

### S2 — No answers field [substrate]
- Confidence: PINNED
- Because: it answers no ground rule
- Buys: nothing relevant here
- Forecloses: nothing relevant here
- Falsifier: it starts answering one
EOF
sed 's/Answers: GR1, GR3/Answers: GR9/' "$_fx/ok.md" > "$_fx/unknown.md"
if [ -f "$ENGINE" ]; then
  out=$(python3 "$ENGINE" ground-rules "$_fx/ok.md" --rules "$_fx/rules.md" 2>/dev/null)
  printf '%s' "$out" | grep -qE '^GR1: pin S1' && printf '%s' "$out" | grep -qE '^GR3: pin S1' \
    && _pass "ANSWERS-FIELD: a list-valued Answers records against every id it names" \
    || _fail "ANSWERS-FIELD: Answers list not recorded (got: $(printf '%s' "$out" | tr '\n' ';'))"
  python3 "$ENGINE" pin-valid "$_fx/ok.md" >/dev/null 2>&1 \
    && _pass "ANSWERS-FIELD: a pin with no Answers field is still valid" \
    || _fail "ANSWERS-FIELD: Answers wrongly became mandatory"
  # exit 2 alone is NOT enough: argparse also exits 2 for an unknown subcommand, so the
  # assertion would pass simply because the capability does not exist yet. Require the
  # engine's own diagnostic. (Sixth occurrence of this family in two features.)
  _err=$(python3 "$ENGINE" ground-rules "$_fx/unknown.md" --rules "$_fx/rules.md" 2>&1 >/dev/null); _rc=$?
  if [ "$_rc" -eq 2 ] && printf '%s' "$_err" | grep -qiE 'unknown ground rule|GR9'; then
    _pass "ANSWERS-FIELD: an unknown ground rule id is rejected by name, not ignored"
  else
    _fail "ANSWERS-FIELD: unknown id exited $_rc without naming it (err: $(printf '%s' "$_err" | head -1))"
  fi
else
  _fail "ANSWERS-FIELD: missing $ENGINE"
fi
rm -rf "$_fx"

# --- NA-FORM  [given] base/audit-logging ----------------------------------------
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/rules.md"
cat > "$_fx/na.md" <<'EOF'
### GR2 — n/a
- Because: this is a pure computation; nothing survives the process
- Falsifier: anything needs to outlive a single run
EOF
cat > "$_fx/na-nofals.md" <<'EOF'
### GR2 — n/a
- Because: this is a pure computation; nothing survives the process
EOF
if [ -f "$ENGINE" ]; then
  python3 "$ENGINE" ground-rules "$_fx/na.md" --rules "$_fx/rules.md" 2>/dev/null | grep -qE '^GR2: n/a' \
    && _pass "NA-FORM: a declination with Because + Falsifier is recorded as n/a" \
    || _fail "NA-FORM: a well-formed declination was not recorded"
  _err=$(python3 "$ENGINE" ground-rules "$_fx/na-nofals.md" --rules "$_fx/rules.md" 2>&1 >/dev/null); _rc=$?
  if [ "$_rc" -eq 2 ] && printf '%s' "$_err" | grep -qiE 'falsifier'; then
    _pass "NA-FORM: a declination with no Falsifier is rejected by name (a decline must expire)"
  else
    _fail "NA-FORM: declination without Falsifier exited $_rc without naming Falsifier"
  fi
  # a declination is NOT a pin: it must not be counted as one
  python3 "$ENGINE" exposure "$_fx/na.md" 2>/dev/null | grep -qE '^0 pins' \
    && _pass "NA-FORM: a declination is not counted as a pin" \
    || _fail "NA-FORM: a declination leaked into the pin count"
fi
rm -rf "$_fx"

# --- GR-COVERAGE ----------------------------------------------------------------
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/rules.md"
cat > "$_fx/mixed.md" <<'EOF'
### S1 — Something [substrate]
- Confidence: PINNED
- Because: a reason
- Buys: something
- Forecloses: something else
- Falsifier: a condition
- Answers: GR1

### GR2 — n/a
- Because: not applicable here
- Falsifier: it becomes applicable
EOF
if [ -f "$ENGINE" ]; then
  a=$(python3 "$ENGINE" ground-rules "$_fx/mixed.md" --rules "$_fx/rules.md" 2>/dev/null)
  b=$(python3 "$ENGINE" ground-rules "$_fx/mixed.md" --rules "$_fx/rules.md" 2>/dev/null)
  [ -n "$a" ] && [ "$a" = "$b" ] && _pass "GR-COVERAGE: output is byte-stable across runs" \
                                 || _fail "GR-COVERAGE: output empty or unstable"
  printf '%s' "$a" | grep -qE '^GR3: uncovered' \
    && _pass "GR-COVERAGE: an untouched rule reports uncovered" \
    || _fail "GR-COVERAGE: an untouched rule did not report uncovered"
  python3 "$ENGINE" ground-rules "$_fx/mixed.md" --rules "$_fx/rules.md" >/dev/null 2>&1; _rc=$?
  [ "$_rc" -eq 1 ] && _pass "GR-COVERAGE: incomplete coverage exits 1" \
                   || _fail "GR-COVERAGE: incomplete coverage exited $_rc, expected 1"
  # positive control: a fully covered charter must exit 0, or exit 1 means nothing
  { cat "$_fx/mixed.md"; for i in 3 4 5 6; do printf '\n### GR%d — n/a\n- Because: r\n- Falsifier: f\n' "$i"; done; } > "$_fx/full.md"
  python3 "$ENGINE" ground-rules "$_fx/full.md" --rules "$_fx/rules.md" >/dev/null 2>&1; _rc=$?
  [ "$_rc" -eq 0 ] && _pass "GR-COVERAGE: full coverage exits 0 (the exit code discriminates)" \
                   || _fail "GR-COVERAGE: full coverage exited $_rc, expected 0"
fi
rm -rf "$_fx"

# --- SUPERSEDED-NOT-COVERAGE ----------------------------------------------------
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/rules.md"
cat > "$_fx/sup.md" <<'EOF'
### S1 — Old datastore [substrate] SUPERSEDED
- Confidence: PINNED
- Because: it was the only option then
- Buys: nothing anymore
- Forecloses: nothing anymore
- Falsifier: superseded by a later pin
- Superseded: 2026-08-08 — tripped by concurrent writers
- Answers: GR2
EOF
if [ -f "$ENGINE" ]; then
  python3 "$ENGINE" ground-rules "$_fx/sup.md" --rules "$_fx/rules.md" 2>/dev/null | grep -qE '^GR2: uncovered' \
    && _pass "SUPERSEDED-NOT-COVERAGE: a superseded pin does not count as coverage" \
    || _fail "SUPERSEDED-NOT-COVERAGE: history counted as a rationale"
fi
rm -rf "$_fx"

# --- PLAN-UNCOVERED -------------------------------------------------------------
# Labelled explicitly: assert_contains reports the path and pattern but not the criterion,
# so its results cannot be traced back to a coverage row. T7 of this feature is exactly
# "confirm each assertion actually runs" — an unlabelled result cannot answer that.
_pu_bad=0
for tok in 'UNCOVERED' 'ground rule' 'PASS' 'UNPINNED' 'TRIPPED'; do
  grep -qE "$tok" .claude/commands/plan.md || { _pu_bad=1; echo "    (plan.md missing /$tok/)"; }
done
[ "$_pu_bad" -eq 0 ] \
  && _pass "PLAN-UNCOVERED: /plan documents four verdicts including UNCOVERED" \
  || _fail "PLAN-UNCOVERED: /plan does not document all four verdicts"
# the gate must evaluate coverage FIRST — a charter below the floor makes the rest premature
awk '/UNCOVERED/{u=NR} /### `PASS`/{p=NR} END{exit !(u && p && u < p)}' .claude/commands/plan.md \
  && _pass "PLAN-UNCOVERED: UNCOVERED is documented before the other verdicts" \
  || _fail "PLAN-UNCOVERED: UNCOVERED is not evaluated first"

# --- STACK-WALKS-SIX ------------------------------------------------------------
assert_contains .claude/skills/stack/SKILL.md 'ground rule'
if [ -f .claude/skills/stack/SKILL.md ]; then
  _n=$(grep -oE 'GR[1-6]' .claude/skills/stack/SKILL.md | sort -u | wc -l | tr -d ' ')
  [ "$_n" = "6" ] && _pass "STACK-WALKS-SIX: the skill names all six ground rules" \
                  || _fail "STACK-WALKS-SIX: the skill names $_n of 6 ground rules"
fi

# --- MIGRATION ------------------------------------------------------------------
assert_contains .claude/skills/stack/SKILL.md 'migrat'
# the gate must NOT soften: no grace period anywhere in the enforcement surface
_grace=0
for f in .claude/commands/plan.md .claude/skills/stack/SKILL.md "$GRBASE"; do
  [ -f "$f" ] || continue
  # A denial is not a grant: the enforcement surface legitimately says "there is NO grace
  # period", and a pattern that cannot tell assertion from negation flags its own fix.
  if grep -iE 'grace period|warn(ing)? only|does not block yet' "$f" \
     | grep -viE 'no grace period|without a grace period|never a grace period' | grep -q .; then
    _grace=1; echo "    ($f grants a grace period)"
  fi
done
[ "$_grace" -eq 0 ] && _pass "MIGRATION: no grace period granted — the gate stays hard" \
                    || _fail "MIGRATION: a grace period leaked into the enforcement surface"
# non-vacuity: the pattern must still catch a real grant, and must not catch a denial
_fx=$(mktemp -d)
printf 'Adopters get a grace period of three features before this blocks.\n' > "$_fx/grant.md"
printf 'There is no grace period; the gate blocks from the first run.\n' > "$_fx/deny.md"
grep -iE 'grace period' "$_fx/grant.md" | grep -viE 'no grace period|without a grace period|never a grace period' | grep -q . \
  && _pass "MIGRATION: the grace-period pattern catches a real grant" \
  || _fail "MIGRATION: the grace-period pattern is vacuous (matches no grant)"
grep -iE 'grace period' "$_fx/deny.md" | grep -viE 'no grace period|without a grace period|never a grace period' | grep -q . \
  && _fail "MIGRATION: the grace-period pattern flags a denial as a grant" \
  || _pass "MIGRATION: the pattern tells a denial apart from a grant"
rm -rf "$_fx"

# --- GR-FLOOR-NO-SCALE ----------------------------------------------------------
assert_contains "$GRBASE" 'S0'
assert_contains memory/stack/base/README.md 'ground rule'
if [ -f "$GRBASE" ]; then
  grep -qiE 'second floor|does not scale|never whether' "$GRBASE" \
    && _pass "GR-FLOOR-NO-SCALE: the floor is stated not to scale with S0" \
    || _fail "GR-FLOOR-NO-SCALE: nothing states the floor is independent of S0"
fi

# --- GR-ADD-NOT-REMOVE ----------------------------------------------------------
_fx=$(mktemp -d)
{ for i in 1 2 3 4 5 6; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/base.md"
printf '### GR7 — extra project rule\n- Question: q\n- Prevents: p\n' > "$_fx/add.md"
{ for i in 1 2 3 4 5; do printf '### GR%d — r%d\n- Question: q\n- Prevents: p\n\n' "$i" "$i"; done; } > "$_fx/omits.md"
printf '### S1 — x [substrate]\n- Confidence: PINNED\n- Because: b\n- Buys: b\n- Forecloses: f\n- Falsifier: f\n' > "$_fx/c.md"
if [ -f "$ENGINE" ]; then
  python3 "$ENGINE" ground-rules "$_fx/c.md" --rules "$_fx/base.md" --rules "$_fx/add.md" 2>/dev/null | grep -qE '^GR7:' \
    && _pass "GR-ADD-NOT-REMOVE: a project layer may ADD a ground rule" \
    || _fail "GR-ADD-NOT-REMOVE: an added project rule did not enter the effective set"
  _err=$(python3 "$ENGINE" ground-rules "$_fx/c.md" --rules "$_fx/base.md" --rules "$_fx/omits.md" 2>&1 >/dev/null); _rc=$?
  if [ "$_rc" -eq 2 ] && printf '%s' "$_err" | grep -qiE 'omits|missing base|additive'; then
    _pass "GR-ADD-NOT-REMOVE: a layer omitting a base rule is rejected by name"
  else
    _fail "GR-ADD-NOT-REMOVE: omission exited $_rc without naming the missing rule"
  fi
fi
rm -rf "$_fx"

# --- CHARTER-COVERED (D3 reflexive dogfood) -------------------------------------
if [ -f "$ENGINE" ] && [ -f "$CHARTER" ] && [ -f "$GRBASE" ]; then
  python3 "$ENGINE" ground-rules "$CHARTER" >/dev/null 2>&1; _rc=$?
  [ "$_rc" -eq 0 ] && _pass "CHARTER-COVERED: the harness's own charter resolves all six" \
                   || _fail "CHARTER-COVERED: the harness's own charter is below its own floor (exit $_rc)"
else
  _fail "CHARTER-COVERED: engine, charter or ground rules missing"
fi

# --- ENGINE-CLI-ONLY  [given] charter S2 Hedge ----------------------------------
if [ -f "$ENGINE" ]; then
  assert_contains "$ENGINE" 'ground-rules'
  head -40 "$ENGINE" | grep -qE 'ground-rules' \
    && _pass "ENGINE-CLI-ONLY: the capability is documented in the CLI contract" \
    || _fail "ENGINE-CLI-ONLY: the capability is not in the documented CLI contract"
  head -40 "$ENGINE" | grep -qE '1 = .*incomplete|incomplete coverage' \
    && _pass "ENGINE-CLI-ONLY: the exit contract documents incomplete coverage" \
    || _fail "ENGINE-CLI-ONLY: the exit contract does not document incomplete coverage"
fi

# --- GR-NO-PRESCRIBE  [given] charter S1 Injects --------------------------------
if [ -f "$GRBASE" ]; then
  bash scripts/guards/no-prescribe.sh >/dev/null 2>&1 \
    && _pass "GR-NO-PRESCRIBE: ground-rules.md names no tool/runtime/vendor in prose" \
    || _fail "GR-NO-PRESCRIBE: the guard rejects memory/stack/base/ (a name leaked into prose)"
  prose_only "$GRBASE" | grep -qiE '(^|[^[:alnum:]])(postgres|duckdb|railway|uv|npm|python|bash)([^[:alnum:]]|$)' \
    && _fail "GR-NO-PRESCRIBE: a tool name appears in ground-rules.md prose" \
    || _pass "GR-NO-PRESCRIBE: independent scan of ground-rules.md prose is clean"
fi

# --- HERMETIC-ENV  [given] base/hermetic-tests ----------------------------------
_NET94="(curl|wget|git clone)[^|]*(https?:/""/|git@)"
_AMB94="(/dev""/tty|git checkout ""main|rev-parse ""main)"
grep -qE "$_NET94" tests/check_94_ground_rules.sh \
  && _fail "HERMETIC-ENV: check_94 reaches a remote source" \
  || _pass "HERMETIC-ENV: check_94 reaches no network or remote source"
grep -qE "$_AMB94" tests/check_94_ground_rules.sh \
  && _fail "HERMETIC-ENV: check_94 assumes a terminal or a local main branch" \
  || _pass "HERMETIC-ENV: check_94 assumes no terminal and no local main"
_fx=$(mktemp -d); printf 'x=$(curl https:/''/example.com)\n' > "$_fx/n.sh"
grep -qE "$_NET94" "$_fx/n.sh" && _pass "HERMETIC-ENV: the network pattern is non-vacuous" \
                               || _fail "HERMETIC-ENV: the network pattern matches nothing"
rm -rf "$_fx"
