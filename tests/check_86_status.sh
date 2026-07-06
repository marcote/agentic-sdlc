# Sourced by tests/run.sh (lib.sh already loaded). Contract of the derived phase-tracker
# (scripts/status.sh): read-only, derives each pipeline phase's done/pending state from a
# feature's artifacts + coverage.md states + report verdicts. Exercised hermetically against
# temp repo fixtures (mini specs/<feat>/ + verification/reports/) at various stages.
# Covers 13 deterministic criteria. Also covers candidate B: the shared assert_dep_free helper.
#
# Output contract the implementation must satisfy (per phase, in pipeline order):
#   "✓ <phase>"  done   ·   "· <phase>"  pending
#   "current: <phase>"  +  "next: <command>"   ·   "feature DONE" when all done
#   "⚠ anomaly" + non-zero exit when a done phase follows a pending one
#   a gaps section listing non-green criteria / orphan rows
#   exit 0 when coherent (incl. WIP); non-zero only on anomaly (or unknown feature)

STATUS="$PWD/scripts/status.sh"
have(){ [ -f "$STATUS" ]; }
REAL='Real filled content, no template markers.'

mkrepo(){ local r; r=$(mktemp -d); mkdir -p "$r/specs/demo" "$r/verification/reports"; echo "$r"; }
fill(){ printf '%s\n' "$REAL" > "$1"; }
align_ok(){ printf '# Alignment\n## Verdict\n**aligned**\n' > "$1"; }
# cov <file> <state>: none-> (skip) | nocontract | red | green | orphan
cov(){ local f="$1" s="$2"
  { echo "# Coverage — demo"
    echo "| Pillar | Obj | Req | Criterion | Origin | Test | Status |"
    echo "|---|---|---|---|---|---|---|"
    case "$s" in
      nocontract) echo "| pillar-a | o | r | C1 | project | t | no contract |" ;;
      red)        echo "| pillar-a | o | r | C1 | project | t | 🔴 red |" ;;
      green)      echo "| pillar-a | o | r | C1 | project | t | ✅ uat |" ;;
      orphan)     echo "| pillar-a | o | r | C1 | project | t | ✅ uat |"
                  echo "|  | o | r | C2 | project | t | 🔴 red |" ;;
    esac
  } > "$f"
}
report(){ printf 'BUILD: %s · TRAJECTORY: ✅ · UAT: %s · coverage: 100%% · retro: %s\n' "$2" "$3" "$4" > "$1"; }
run_status(){ ( cd "$1" && bash "$STATUS" demo ) >/tmp/st_out 2>&1; RC=$?; }

# build a feature staged up to a level. levels add cumulatively.
stage(){ # repo, level, covstate
  local d="$1/specs/demo" r="$1/verification/reports" lvl="$2" cs="${3:-nocontract}"
  fill "$d/brief.md"
  align_ok "$d/alignment.md"
  fill "$d/spec.md"; fill "$d/acceptance.md"; cov "$d/coverage.md" "$cs"
  fill "$d/plan.md"
  fill "$d/tasks.md"
  [ "$lvl" = retro ] && fill "$d/retro.md"
  case "$lvl" in
    verify) report "$r/demo-a.md" "✅" "-" "pending" ;;
    uat)    report "$r/demo-a.md" "✅" "✅" "pending" ;;
    retro)  report "$r/demo-a.md" "✅" "✅" "✅" ;;
  esac
}

# --- PHASE-DERIVE: brief/align/distill/plan filled, rest absent ---
R=$(mkrepo); D="$R/specs/demo"
fill "$D/brief.md"; align_ok "$D/alignment.md"; fill "$D/spec.md"; fill "$D/acceptance.md"; cov "$D/coverage.md" nocontract; fill "$D/plan.md"
have && run_status "$R"
if have && grep -q "✓ brief" /tmp/st_out && grep -q "✓ align" /tmp/st_out && grep -q "✓ distill" /tmp/st_out \
   && grep -q "✓ plan" /tmp/st_out && grep -q "· contract" /tmp/st_out; then
  _pass "PHASE-DERIVE: doc phases done, contract onward pending"
else _fail "PHASE-DERIVE: phase derivation wrong (out: $(head -1 /tmp/st_out 2>/dev/null))"; fi
rm -rf "$R"

# --- NON-PLACEHOLDER: fresh _template scaffold -> all pending ---
R=$(mkrepo); rm -rf "$R/specs/demo"; cp -r "$PWD/specs/_template" "$R/specs/demo"
have && run_status "$R"
if have && grep -q "· brief" /tmp/st_out && ! grep -q "✓ brief" /tmp/st_out; then
  _pass "NON-PLACEHOLDER: template stub reported pending (presence != done)"
else _fail "NON-PLACEHOLDER: placeholder artifact counted as done"; fi
rm -rf "$R"

# --- COVERAGE-DERIVED: plan+tasks filled but coverage red -> implement pending ---
R=$(mkrepo); stage "$R" tasks red
have && run_status "$R"
if have && grep -q "✓ tasks" /tmp/st_out && grep -q "· implement" /tmp/st_out; then
  _pass "COVERAGE-DERIVED: implement pending on a red coverage (state overrides doc)"
else _fail "COVERAGE-DERIVED: implement state not derived from coverage"; fi
rm -rf "$R"

# --- CURRENT-NEXT: done up to distill -> current plan, next /plan ---
R=$(mkrepo); D="$R/specs/demo"
fill "$D/brief.md"; align_ok "$D/alignment.md"; fill "$D/spec.md"; fill "$D/acceptance.md"; cov "$D/coverage.md" nocontract
have && run_status "$R"
if have && grep -q "current: plan" /tmp/st_out && grep -q "next: /plan" /tmp/st_out; then
  _pass "CURRENT-NEXT: names current phase + next command"
else _fail "CURRENT-NEXT: current/next wrong"; fi
rm -rf "$R"

# --- DONE-FEATURE: everything done -> DONE + exit 0 ---
R=$(mkrepo); stage "$R" retro green
have && run_status "$R"
if have && grep -qi "feature DONE" /tmp/st_out && [ "${RC:-1}" -eq 0 ]; then
  _pass "DONE-FEATURE: all phases done -> DONE, exit 0"
else _fail "DONE-FEATURE: not reported DONE or exit != 0 (rc=${RC:-?})"; fi
rm -rf "$R"

# --- ANOMALY-FLAG: retro filled but coverage red -> anomaly + non-zero ---
R=$(mkrepo); stage "$R" retro red
have && run_status "$R"
if have && grep -q "⚠" /tmp/st_out && grep -qi "anomaly" /tmp/st_out && [ "${RC:-0}" -ne 0 ]; then
  _pass "ANOMALY-FLAG: out-of-order flagged + non-zero exit"
else _fail "ANOMALY-FLAG: anomaly not flagged or exit 0 (rc=${RC:-?})"; fi
rm -rf "$R"

# --- NORMAL-EXIT0: coherent WIP -> exit 0 ---
R=$(mkrepo); D="$R/specs/demo"
fill "$D/brief.md"; align_ok "$D/alignment.md"; fill "$D/spec.md"; fill "$D/acceptance.md"; cov "$D/coverage.md" nocontract
have && run_status "$R"
if have && [ "${RC:-1}" -eq 0 ]; then _pass "NORMAL-EXIT0: coherent WIP exits 0"
else _fail "NORMAL-EXIT0: WIP feature returned non-zero (rc=${RC:-?})"; fi
rm -rf "$R"

# --- GAPS: red criterion + orphan row surfaced ---
R=$(mkrepo); stage "$R" tasks orphan
have && run_status "$R"
if have && grep -qi "gap" /tmp/st_out && grep -q "C2" /tmp/st_out; then
  _pass "GAPS: surfaces non-green criterion / orphan row"
else _fail "GAPS: coverage gaps not surfaced"; fi
rm -rf "$R"

# --- READONLY: fixture unchanged after run ---
R=$(mkrepo); stage "$R" tasks red
B=$(cd "$R" && find . -type f -exec cksum {} + | sort)
have && run_status "$R"
A=$(cd "$R" && find . -type f -exec cksum {} + | sort)
if have && [ "$B" = "$A" ]; then _pass "READONLY: fixture byte-for-byte unchanged"
else _fail "READONLY: status.sh mutated the fixture"; fi
rm -rf "$R"

# --- UNKNOWN-FEATURE: missing specs/<feature>/ -> error + non-zero ---
R=$(mkrepo)
have && ( cd "$R" && bash "$STATUS" ghost ) >/tmp/st_out 2>&1; RC=$?
if have && [ "$RC" -ne 0 ] && grep -qiE "not found|unknown|no such|does not exist" /tmp/st_out; then
  _pass "UNKNOWN-FEATURE: clear error + non-zero exit"
else _fail "UNKNOWN-FEATURE: no clean error (rc=$RC)"; fi
rm -rf "$R"

# --- DEPFREE: status.sh dep-free, via the shared helper (candidate B) ---
if type assert_dep_free >/dev/null 2>&1 && [ -f "$STATUS" ]; then
  assert_dep_free "$STATUS"
else
  _fail "DEPFREE: assert_dep_free helper or scripts/status.sh missing"
fi

# --- HELPER-SHARED: lib.sh defines assert_dep_free and the checks use it ---
hs=1
grep -q 'assert_dep_free' tests/lib.sh || hs=0
for c in check_82_north_star_engine check_84_vendor check_95_amendment_gate; do
  grep -q 'assert_dep_free' "tests/$c.sh" || hs=0
done
[ "$hs" -eq 1 ] && _pass "HELPER-SHARED: lib.sh helper used by check_82/84/95" \
  || _fail "HELPER-SHARED: shared assert_dep_free missing or not adopted by the checks"

# --- SELF-CHECK: the deliverable exists and is exercised ---
assert_file "$STATUS"
