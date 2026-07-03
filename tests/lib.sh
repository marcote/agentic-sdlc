# Dependency-free assertion helpers. No frameworks.
FAILS=0; PASSES=0
_pass(){ PASSES=$((PASSES+1)); echo "  PASS: $1"; }
_fail(){ FAILS=$((FAILS+1)); echo "  FAIL: $1"; }
assert_file(){ if [ -f "$1" ]; then _pass "file $1"; else _fail "missing file $1"; fi; }
assert_dir(){ if [ -d "$1" ]; then _pass "dir $1"; else _fail "missing dir $1"; fi; }
assert_contains(){ if grep -qE "$2" "$1" 2>/dev/null; then _pass "$1 =~ /$2/"; else _fail "$1 missing /$2/"; fi; }
summary(){ echo "---"; echo "TOTAL PASS=$PASSES FAIL=$FAILS"; [ "$FAILS" -eq 0 ]; }
