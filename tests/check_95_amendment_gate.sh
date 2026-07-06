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
gate_pass(){ # desc, args...
  local desc="$1"; shift
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then _pass "gate PASSES: $desc"
  else _fail "gate should PASS: $desc (exit $?, out: $(head -1 /tmp/ag_out))"; fi
}
gate_block(){ # desc, regex, args...
  local desc="$1" re="$2"; shift 2
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then
    _fail "gate should BLOCK: $desc (passed with exit 0)"
  elif grep -qiE "$re" /tmp/ag_out; then _pass "gate BLOCKS: $desc (cites /$re/)"
  else _fail "gate blocked but without /$re/ message: $desc (out: $(head -1 /tmp/ag_out))"; fi
}

# --- AMEND-BLOCK-NO-ADR: sets change, no new ADR -> blocks citing ADR ---
gate_block "sets change without ADR" "adr" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "" --suite-cmd true

# --- AMEND-PASS-WITH-ADR: sets change + ADR + schema-valid + green suite -> passes ---
gate_pass "sets change with ADR + schema ok + green suite" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd true

# --- AMEND-NO-ADR-FOR-PROSE: prose only (same block) -> passes without ADR ---
gate_pass "prose only, no ADR" \
  --files "$F/base.md" "$F/prose-only.md" --added "" --suite-cmd true
# reinforcement: only alignment.threshold changed -> also does not require ADR
gate_pass "threshold only, no ADR" \
  --files "$F/base.md" "$F/threshold.md" --added "" --suite-cmd true

# --- AMEND-SET-SEMANTICS: reordered/reformatted, same sets -> passes (no false positive) ---
gate_pass "reformat without sets change" \
  --files "$F/base.md" "$F/reformatted.md" --added "" --suite-cmd true

# --- AMEND-SCHEMA-VALID: sets change, with ADR, but JSON schema-invalid -> blocks citing schema ---
gate_block "sets change schema-invalid (even with ADR)" "schema|invalid" \
  --files "$F/base.md" "$F/set-added-invalid.md" --added "$ADR" --suite-cmd true

# --- AMEND-SUITE-GREEN: sets change, ADR, schema ok, but RED suite -> blocks ---
gate_block "sets change with red suite" "suite|red" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd false

# --- DEV-UNBLOCKED: diff does not touch sets (normal work) -> passes (preserves Principle 4) ---
gate_pass "normal work, does not touch sets (base==base)" \
  --files "$F/base.md" "$F/base.md" --added "src/algo.ts" --suite-cmd true

# --- CONST-EXCEPTION: the project constitution records the narrow Principle 4 exception ---
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "amendment-gate"
assert_contains memory/constitution/constitution.md "[Pp]rinciple 4"
assert_contains memory/constitution/constitution.md "pillars/scope"

# --- DEP-FREE: the new layer (gate) is dependency-free ---
# (a) tied to the deliverable: cannot verify dep-freeness of a gate that
#     does not exist -> RED until the impl creates the script. And when it exists, it must
#     not invoke any installable toolchain (only bash/coreutils + python3 stdlib).
assert_file "$GATE"
assert_dep_free "$GATE"   # shared helper (feature 008, candidate B)
# (b) repo guardrail: the feature does not introduce installable manifests
dep_free=1
for d in package.json package-lock.json pnpm-lock.yaml yarn.lock node_modules uv.lock requirements.txt; do
  [ -e "$d" ] && { _fail "DEP-FREE: $d appeared (installable dependency)"; dep_free=0; }
done
[ "$dep_free" -eq 1 ] && _pass "DEP-FREE: repo without installable package manifests"

# --- SELF-CHECK: wiring — the gate script and workflow exist and are wired ---
assert_file "$GATE"
assert_file .github/workflows/amendment-gate.yml
assert_contains .github/workflows/amendment-gate.yml "amendment-gate.sh"
