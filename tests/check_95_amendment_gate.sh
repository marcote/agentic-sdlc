# Sourced by tests/run.sh (lib.sh already loaded). Contract of the amendment-gate:
# gates changes to the pillars/scope sets of the North Star's canonical JSON block.
# Exercises the gate's pure functions via its test CLI against fixtures
# (old/new pairs + added-files list + suite stub) — no git state construction.
# Covers the 10 deterministic criteria from acceptance.md. The 2 real-blocking
# criteria (AMEND-BLOCK-REAL/PUSH) are GitHub config → UAT, not here.
#
# CLI contract that the implementation must satisfy (test mode):
#   scripts/amendment-gate.sh --files OLD NEW --added "f1 f2 …" --suite-cmd CMD
#     --files OLD NEW : two markdown files with a ```json block (old vs new)
#     --added "…"     : space-separated list of ADDED files in the range
#     --suite-cmd CMD : command whose exit 0 = green suite (injectable stub)
#   exit 0 = passes (does not block) · exit ≠0 = blocks, citing the missing condition.

F=tests/fixtures/amendment-gate
GATE=scripts/amendment-gate.sh
ADR="memory/north-star/decisions/0003-nuevo.md"   # a valid new ADR (added)

# --- gate helpers (use _pass/_fail from lib.sh) ---
# LABEL is first: without it these helpers emitted "gate PASSES: <desc>", which cannot be tied
# back to the criterion it satisfies. Nine criteria in this file were untraceable that way, found
# by scripts/nvc.sh at 015's UAT against a suite that had been green since feature 004.
gate_pass(){ # label, desc, args...
  local lbl="$1" desc="$2"; shift 2
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then _pass "$lbl: gate PASSES: $desc"
  else _fail "$lbl: gate should PASS: $desc (exit $?, out: $(head -1 /tmp/ag_out))"; fi
}
gate_block(){ # label, desc, regex, args...
  local lbl="$1" desc="$2" re="$3"; shift 3
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then
    _fail "$lbl: gate should BLOCK: $desc (passed with exit 0)"
  elif grep -qiE "$re" /tmp/ag_out; then _pass "$lbl: gate BLOCKS: $desc (cites /$re/)"
  else _fail "$lbl: gate blocked but without /$re/ message: $desc (out: $(head -1 /tmp/ag_out))"; fi
}

# --- AMEND-BLOCK-NO-ADR: sets change, no new ADR -> blocks citing ADR ---
gate_block "AMEND-BLOCK-NO-ADR" "sets change without ADR" "adr" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "" --suite-cmd true

# --- AMEND-PASS-WITH-ADR: sets change + ADR + schema-valid + green suite -> passes ---
gate_pass "AMEND-PASS-WITH-ADR" "sets change with ADR + schema ok + green suite" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd true

# --- AMEND-NO-ADR-FOR-PROSE: prose only (same block) -> passes without ADR ---
gate_pass "AMEND-NO-ADR-FOR-PROSE" "prose only, no ADR" \
  --files "$F/base.md" "$F/prose-only.md" --added "" --suite-cmd true
# reinforcement: only alignment.threshold changed -> also does not require ADR
gate_pass "AMEND-NO-ADR-FOR-PROSE" "threshold only, no ADR" \
  --files "$F/base.md" "$F/threshold.md" --added "" --suite-cmd true

# --- AMEND-SET-SEMANTICS: reordered/reformatted, same sets -> passes (no false positive) ---
gate_pass "AMEND-SET-SEMANTICS" "reformat without sets change" \
  --files "$F/base.md" "$F/reformatted.md" --added "" --suite-cmd true

# --- AMEND-SCHEMA-VALID: sets change, with ADR, but JSON schema-invalid -> blocks citing schema ---
gate_block "AMEND-SCHEMA-VALID" "sets change schema-invalid (even with ADR)" "schema|invalid" \
  --files "$F/base.md" "$F/set-added-invalid.md" --added "$ADR" --suite-cmd true

# --- AMEND-SUITE-GREEN: sets change, ADR, schema ok, but RED suite -> blocks ---
gate_block "AMEND-SUITE-GREEN" "sets change with red suite" "suite|red" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd false

# --- DEV-UNBLOCKED: diff does not touch sets (normal work) -> passes (preserves Principle 4) ---
gate_pass "DEV-UNBLOCKED" "normal work, does not touch sets (base==base)" \
  --files "$F/base.md" "$F/base.md" --added "src/algo.ts" --suite-cmd true

# --- CONST-EXCEPTION: the project constitution records the narrow Principle 4 exception ---
ce=1
for pat in "amendment-gate" "[Pp]rinciple 4" "pillars/scope"; do
  grep -qE "$pat" memory/constitution/constitution.md 2>/dev/null || ce=0
done
[ "$ce" -eq 1 ] && _pass "CONST-EXCEPTION: constitution records the narrow Principle 4 exception" \
  || _fail "CONST-EXCEPTION: constitution does not record the narrow Principle 4 exception"

# --- DEP-FREE: the new layer (gate) is dependency-free ---
# (a) tied to the deliverable: cannot verify dep-freeness of a gate that
#     does not exist -> RED until the impl creates the script. And when it exists, it must
#     not invoke any installable toolchain (only bash/coreutils + python3 stdlib).
assert_file "$GATE"
assert_dep_free "$GATE" "DEP-FREE"   # labelled so the result ties to the criterion (015)
# (b) repo guardrail: the feature does not introduce installable manifests
dep_free=1
for d in package.json package-lock.json pnpm-lock.yaml yarn.lock node_modules uv.lock requirements.txt; do
  [ -e "$d" ] && { _fail "DEP-FREE: $d appeared (installable dependency)"; dep_free=0; }
done
[ "$dep_free" -eq 1 ] && _pass "DEP-FREE: repo without installable package manifests"

# --- SELF-CHECK: wiring — the gate script and workflow exist and are wired ---
if [ -f "$GATE" ] && [ -f .github/workflows/amendment-gate.yml ] \
   && grep -q "amendment-gate.sh" .github/workflows/amendment-gate.yml 2>/dev/null; then
  _pass "SELF-CHECK: gate script and workflow exist and are wired"
else _fail "SELF-CHECK: gate script or workflow missing or not wired"; fi

# --- AMEND-PROV-STALE / AMEND-PROV-ONLY (016) ---
# Provenance is metadata: changing `since` alone is NOT an amendment (otherwise recording that ADR
# 0005 changed a signal would itself need ADR 0006, forever). The gate gains the INVERSE check —
# a governed field moving while `since` stays put is rejected. Both directions, because one
# without the other is half a rule: STALE alone would pass against a gate that blocks everything.
_P=$(mktemp -d)
_mkp(){ # _mkp <file> <signal> <since>
  { printf -- '---\nextends: base\n---\n\n```json\n'
    printf '{ "mission": "m", "pillars": [ { "id": "p1", "statement": "s", "signal": "%s", "since": "%s" } ], "scope": { "in_scope": ["a"], "out_of_scope": ["b"] }, "alignment": { "threshold": 3 } }\n' "$2" "$3"
    printf '```\n'; } > "$1"
}
_mkp "$_P/old.md"       "original signal" "0001"
_mkp "$_P/stale.md"     "REWORDED signal" "0001"
_mkp "$_P/provonly.md"  "original signal" "0002"
_out=$(bash "$GATE" --files "$_P/old.md" "$_P/stale.md" --added "memory/north-star/decisions/0002-x.md" --suite-cmd true 2>&1); _rc=$?
if [ "$_rc" -ne 0 ] && printf '%s' "$_out" | grep -q "p1"; then
  _pass "AMEND-PROV-STALE: a governed field moving with stale provenance is blocked, citing the pillar"
else _fail "AMEND-PROV-STALE: stale provenance passed (exit $_rc, out: $(printf '%s' "$_out" | head -1))"; fi
_out=$(bash "$GATE" --files "$_P/old.md" "$_P/provonly.md" --added "" --suite-cmd true 2>&1); _rc=$?
if [ "$_rc" -eq 0 ]; then
  _pass "AMEND-PROV-ONLY: provenance changing alone is not an amendment"
else _fail "AMEND-PROV-ONLY: a provenance-only edit was treated as an amendment (exit $_rc, out: $(printf '%s' "$_out" | head -1))"; fi
rm -rf "$_P"
