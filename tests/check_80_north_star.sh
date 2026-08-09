# Sourced by tests/run.sh (lib.sh already loaded). Verifies that the North-Star +
# Measurability Gate governance capability is present and wired into the
# harness: base layer, the placeholder north-star.md (extends: base), the
# /align command+skill, the gate wiring in /distill, and the Pillar column in
# the coverage template. Structural/presence only — the concrete deterministic
# engine (schema validation, scope predicates, verdict aggregation) is per-stack
# and is not unit-tested here (see specs/002-north-star-governance/plan.md decision 2;
# poirot-fe scripts/north-star/*.mjs is the reference implementation).
for f in schema.md alignment-rubric.md amendment-protocol.md adr-template.md README.md; do
  assert_file "memory/north-star/base/$f"
done
assert_file memory/north-star/north-star.md
assert_contains memory/north-star/north-star.md "extends: base"
assert_file .claude/commands/align.md
assert_file .claude/skills/align/SKILL.md

# MEAS-GATE: /distill must enforce the gate, not just describe it in another doc.
assert_file .claude/skills/distill/SKILL.md
assert_contains .claude/skills/distill/SKILL.md "alignment.md"
assert_contains .claude/skills/distill/SKILL.md "Measurability Gate"
assert_contains .claude/skills/distill/SKILL.md "aligned"

# COVERAGE-PILLAR: traceability up to the north star.
assert_contains specs/_template/coverage.md "Pillar"

# ================= 016 — North Star integrity =================
# scripts/north-star/engine.py must distinguish UNFILLED (exit 3) from malformed (2) and invalid
# (1), and every pillar must record the ADR that last changed its statement or signal.
ENG80="scripts/north-star/engine.py"
_ns(){ # _ns <file>  -> runs schema-valid, sets NSRC and NSOUT
  NSOUT=$(python3 "$ENG80" schema-valid "$1" 2>&1); NSRC=$?
}
_mkns(){ # _mkns <file> <json>
  { printf -- '---\nextends: base\n---\n\n# North Star\n\n```json\n'; printf '%s\n' "$2"; printf '```\n'; } > "$1"
}
_FX80=$(mktemp -d)
_SEEDED='{
  "mission": "TODO: one sentence — why this product exists",
  "pillars": [ { "id": "todo-pillar", "statement": "TODO: what it means", "signal": "TODO: measurable indicator", "since": "TODO: ADR that introduced it" } ],
  "scope": { "in_scope": ["TODO: what this product does"], "out_of_scope": ["TODO: what it explicitly does not do"] },
  "alignment": { "threshold": 3 }
}'

# --- NS-UNFILLED: a seeded North Star is unfilled, not valid ---
_mkns "$_FX80/seeded.md" "$_SEEDED"
_ns "$_FX80/seeded.md"
if [ "$NSRC" -eq 3 ] && printf '%s' "$NSOUT" | grep -qi "mission"; then
  _pass "NS-UNFILLED: seeded North Star exits 3 and names the seeded fields"
else _fail "NS-UNFILLED: seeded North Star exited $NSRC without naming fields (out: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-UNFILLED-PARTIAL: mission written, pillars still seeded ---
_mkns "$_FX80/partial.md" '{
  "mission": "Diagnose a portfolio of stocks and explain the reasoning",
  "pillars": [ { "id": "todo-pillar", "statement": "TODO: what it means", "signal": "TODO: measurable indicator", "since": "0001" } ],
  "scope": { "in_scope": ["ranking"], "out_of_scope": ["trade execution"] },
  "alignment": { "threshold": 3 }
}'
_ns "$_FX80/partial.md"
if [ "$NSRC" -eq 3 ] && printf '%s' "$NSOUT" | grep -qi "pillar" && ! printf '%s' "$NSOUT" | grep -qi "mission"; then
  _pass "NS-UNFILLED-PARTIAL: names the seeded pillars and not the written mission"
else _fail "NS-UNFILLED-PARTIAL: exited $NSRC, diagnostic wrong (out: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-TODO-NOT-FALSE-POSITIVE: a product whose domain IS to-do lists ---
# The whole risk of this feature. If the discriminator were the bare word TODO, this valid
# North Star would be refused -- worse than the defect, because it blocks real work.
_mkns "$_FX80/todoapp.md" '{
  "mission": "A shared TODO list that never loses an item",
  "pillars": [ { "id": "durability", "statement": "No TODO is ever silently dropped", "signal": "items reconciled after an offline edit", "since": "0001" } ],
  "scope": { "in_scope": ["TODO capture and sync"], "out_of_scope": ["TODO tracking beyond a single workspace"] },
  "alignment": { "threshold": 3 }
}'
_ns "$_FX80/todoapp.md"
if [ "$NSRC" -eq 0 ]; then
  _pass "NS-TODO-NOT-FALSE-POSITIVE: a to-do-domain product with TODO in prose is valid"
else _fail "NS-TODO-NOT-FALSE-POSITIVE: refused a valid North Star (exit $NSRC: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-SEED-TABLE-SYNC: the engine's SEEDED table matches what vendor.sh writes ---
# Two copies of a sentinel that drift apart make the check silently stop catching anything.
_stub=$(mktemp -d); (cd "$_stub" && git init -q .) >/dev/null 2>&1
bash scripts/vendor.sh "$_stub" --apply >/dev/null 2>&1
_sync=1
if [ -f "$_stub/memory/north-star/north-star.md" ] && [ -f "$ENG80" ]; then
  while IFS= read -r _v; do
    [ -n "$_v" ] || continue
    grep -qF "$_v" "$ENG80" || { _sync=0; _miss="$_v"; }
  done <<SYNC
$(grep -oE '"(TODO: [^"]*|todo-pillar)"' "$_stub/memory/north-star/north-star.md" | tr -d '"' | sort -u)
SYNC
else _sync=2; fi
[ "$_sync" -eq 1 ] && _pass "NS-SEED-TABLE-SYNC: every seeded value in the stub appears in the engine's SEEDED table" \
  || _fail "NS-SEED-TABLE-SYNC: table drifted from the stub (code $_sync${_miss:+, missing: $_miss}) — the check would pass forever"

# --- NS-VENDORED-STUB-REJECTED: against a REAL vendored target, not a fixture ---
if [ -f "$_stub/memory/north-star/north-star.md" ]; then
  _ns "$_stub/memory/north-star/north-star.md"
  [ "$NSRC" -eq 3 ] && _pass "NS-VENDORED-STUB-REJECTED: a freshly vendored North Star exits 3" \
    || _fail "NS-VENDORED-STUB-REJECTED: freshly vendored stub exited $NSRC (0 = /align would score a placeholder)"
else _fail "NS-VENDORED-STUB-REJECTED: vendoring produced no North Star"; fi
rm -rf "$_stub"

# --- NS-SINCE-REQUIRED: a pillar without provenance is invalid ---
_mkns "$_FX80/nosince.md" '{
  "mission": "Diagnose a portfolio of stocks",
  "pillars": [ { "id": "explainability", "statement": "Every call shows its reasoning", "signal": "share of calls with a cited source" } ],
  "scope": { "in_scope": ["ranking"], "out_of_scope": ["execution"] },
  "alignment": { "threshold": 3 }
}'
_ns "$_FX80/nosince.md"
if [ "$NSRC" -eq 1 ] && printf '%s' "$NSOUT" | grep -q "explainability"; then
  _pass "NS-SINCE-REQUIRED: a pillar without since is invalid, naming the pillar"
else _fail "NS-SINCE-REQUIRED: exited $NSRC without naming the pillar (out: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-SINCE-RESOLVES: an unresolvable ADR id is rejected BY NAME ---
_mkns "$_FX80/badsince.md" '{
  "mission": "Diagnose a portfolio of stocks",
  "pillars": [ { "id": "explainability", "statement": "Every call shows its reasoning", "signal": "share of calls with a cited source", "since": "0099" } ],
  "scope": { "in_scope": ["ranking"], "out_of_scope": ["execution"] },
  "alignment": { "threshold": 3 }
}'
_ns "$_FX80/badsince.md"
if [ "$NSRC" -ne 0 ] && printf '%s' "$NSOUT" | grep -q "0099" && printf '%s' "$NSOUT" | grep -q "explainability"; then
  _pass "NS-SINCE-RESOLVES: an unresolved ADR id is rejected, naming pillar and id"
else _fail "NS-SINCE-RESOLVES: exited $NSRC without naming both (out: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-UNFILLED-BEFORE-SINCE: order of diagnostics on a seeded file ---
_ns "$_FX80/seeded.md"
if [ "$NSRC" -eq 3 ] && ! printf '%s' "$NSOUT" | grep -qiE "adr|unresolved"; then
  _pass "NS-UNFILLED-BEFORE-SINCE: says seed it, never reports an unresolved ADR id"
else _fail "NS-UNFILLED-BEFORE-SINCE: a seeded file reported an ADR problem (out: $(printf '%s' "$NSOUT" | head -1))"; fi

# --- NS-OWN-MIGRATED: this repository's own North Star (D3 reflexive dogfood) ---
_ns memory/north-star/north-star.md
_own=1
[ "$NSRC" -eq 0 ] || _own=0
python3 - <<'OWN' || _own=0
import json,re,sys
s=open('memory/north-star/north-star.md').read()
m=re.search(r'```json\n(.*?)\n```',s,re.S)
d=json.loads(m.group(1))
want={'real-enforcement':'0001','agnostic-portability':'0001','measurable-impact':'0002','frictionless-adoption':'0004'}
got={p['id']:p.get('since') for p in d['pillars']}
sys.exit(0 if got==want else 1)
OWN
[ "$_own" -eq 1 ] && _pass "NS-OWN-MIGRATED: own pillars record 0001/0001/0002/0004 and never 0003" \
  || _fail "NS-OWN-MIGRATED: own North Star not migrated to the ADRs that actually changed each pillar"

# --- NS-ENGINE-CLI-ONLY: S2's Hedge -- shell CLI only, exit contract documented ---
if [ -f "$ENG80" ] && head -40 "$ENG80" | grep -qE '3 = unfilled' \
   && ! grep -qE '^\s*from\s+engine\s+import|^\s*import\s+engine' scripts/*.sh scripts/*/*.py 2>/dev/null; then
  _pass "NS-ENGINE-CLI-ONLY: exit 3 documented in the module docstring, no importable API"
else _fail "NS-ENGINE-CLI-ONLY: S2's hedge unpaid — undocumented exit contract or an import-based caller"; fi

# --- HERMETIC-ENV-80: assembled at runtime so this scan cannot match its own line ---
_T80='/dev'; _T80="$_T80/t""ty"
if ! grep -q "$_T80" "$ENG80" 2>/dev/null; then _pass "HERMETIC-ENV-80: engine assumes no terminal"
else _fail "HERMETIC-ENV-80: engine reads a terminal"; fi
# --- HERMETIC-ENV-80-SELF: the assembled pattern is not vacuous ---
printf 'read x < %s\n' "$_T80" > "$_FX80/tty.sh"
grep -q "$_T80" "$_FX80/tty.sh" && _pass "HERMETIC-ENV-80-SELF: pattern matches a genuine occurrence" \
  || _fail "HERMETIC-ENV-80-SELF: assembled pattern is vacuous"
rm -rf "$_FX80"
