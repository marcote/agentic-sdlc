# Dependency-free assertion helpers. No frameworks.
FAILS=0; PASSES=0
_pass(){ PASSES=$((PASSES+1)); echo "  PASS: $1"; }
_fail(){ FAILS=$((FAILS+1)); echo "  FAIL: $1"; }
assert_file(){ if [ -f "$1" ]; then _pass "file $1"; else _fail "missing file $1"; fi; }
assert_dir(){ if [ -d "$1" ]; then _pass "dir $1"; else _fail "missing dir $1"; fi; }
assert_contains(){ if grep -qE "$2" "$1" 2>/dev/null; then _pass "$1 =~ /$2/"; else _fail "$1 missing /$2/"; fi; }
# assert_dep_free FILE : the file invokes no installable toolchain. Invocation-aware —
# excludes comment (#…) and echo lines so a script may legitimately NAME a toolchain as
# data (e.g. vendor.sh seeds "npm test") without failing. (feature 008, candidate B.)
# assert_dep_free FILE [LABEL] : optional LABEL prefixes the result so it can be traced
# back to a coverage row. Without it the criterion runs but its output cannot be tied to
# the row it satisfies -- which is not a dead assertion, but an unauditable one.
assert_dep_free(){
  local _l="${2:+$2: }"
  if [ ! -f "$1" ]; then _fail "${_l}dep-free: missing $1"; return; fi
  if grep -vE '^[[:space:]]*#|echo' "$1" \
     | grep -qiE '(^|[^[:alnum:]-])(npm|npx|node|uv|pip3?|pnpm|yarn)([^[:alnum:]-]|$)'; then
    _fail "${_l}dep-free: $1 invokes an installable toolchain"
  else
    _pass "${_l}dep-free: $1 (bash/coreutils + python3, no toolchain)"
  fi
}
# has_placeholder FILE : true (exit 0) if the file still has an UNFILLED template marker
# (`_(...)_` or `<...>`). Strips backtick code spans first, so a doc that legitimately
# *documents* a marker (e.g. a retro discussing placeholder detection) is not a false
# positive — the same blind-spot fix status.sh's filled() carries (feature 008 retro).
has_placeholder(){ sed 's/`[^`]*`//g' "$1" 2>/dev/null | grep -qE '_\([^)]*\)_|<[^ >][^>]*>'; }
# prose_only FILE : emit the file with every fenced block AND inline code span removed,
# so a scan matches only what the document *asserts in prose* — not what it *illustrates*
# in an example. Required by NO-PRESCRIBE (feature 013): the pin template necessarily names
# real tools (DuckDB, Postgres, Railway) inside fenced example pins, and a naive grep would
# fail against the harness's own documentation. Same blind spot has_placeholder carries.
prose_only(){
  awk '/^[[:space:]]*```/{f=!f; next} !f' "$1" 2>/dev/null | sed 's/`[^`]*`//g'
}
summary(){ echo "---"; echo "TOTAL PASS=$PASSES FAIL=$FAILS"; [ "$FAILS" -eq 0 ]; }
