# Sourced by tests/run.sh (lib.sh already loaded). Contract of the vendoring tool
# (scripts/vendor.sh): copy-once landing of the harness onto an existing repo.
# Exercised hermetically against temp targets (mktemp -d) — dry-run read-only,
# --apply copies KEEP (overwrites), seeds SEED (never clobbers), drops harness-self,
# detects the stack, stamps provenance. Covers 12 deterministic criteria.
#
# CLI contract the implementation must satisfy:
#   scripts/vendor.sh <target>            dry-run: print plan, write nothing
#   scripts/vendor.sh --apply <target>    apply the vendoring

VENDOR=scripts/vendor.sh
mk(){ mktemp -d 2>/dev/null || mktemp -d -t vendor; }
have(){ [ -f "$VENDOR" ]; }

# --- DRYRUN-NOWRITE: dry-run mutates nothing ---
T=$(mk); echo orig > "$T/keepme"
have && bash "$VENDOR" "$T" >/tmp/v_out 2>&1
if have && [ ! -e "$T/.claude" ] && [ "$(cat "$T/keepme" 2>/dev/null)" = "orig" ]; then
  _pass "DRYRUN-NOWRITE: dry-run writes nothing (no .claude, marker intact)"
else
  _fail "DRYRUN-NOWRITE: dry-run wrote to target or vendor.sh absent"
fi
rm -rf "$T"

# --- DRYRUN-PLAN: plan lists KEEP/SEED/DROP + stack + provenance ---
T=$(mk); echo '{}' > "$T/package.json"
have && bash "$VENDOR" "$T" >/tmp/v_out 2>&1
if have && grep -qiE 'KEEP' /tmp/v_out && grep -qiE 'SEED' /tmp/v_out && grep -qiE 'DROP' /tmp/v_out \
   && grep -qiE 'npm test|package\.json' /tmp/v_out && grep -qiE 'provenance' /tmp/v_out; then
  _pass "DRYRUN-PLAN: plan lists keep/seed/drop + detected stack + provenance"
else
  _fail "DRYRUN-PLAN: plan incomplete or vendor.sh absent (out: $(head -1 /tmp/v_out 2>/dev/null))"
fi
rm -rf "$T"

# --- KEEP-COPIED: governance copied verbatim (incl. the 006 engine) ---
T=$(mk)
have && bash "$VENDOR" --apply "$T" >/tmp/v_out 2>&1
if have && [ -f "$T/.claude/commands/align.md" ] && [ -f "$T/scripts/north-star/engine.py" ] \
   && [ -f "$T/memory/constitution/base/principles.md" ]; then
  _pass "KEEP-COPIED: .claude/commands + engine.py + constitution/base present"
else
  _fail "KEEP-COPIED: governance layer missing in target"
fi
rm -rf "$T"

# --- KEEP-OVERWRITE: re-apply overwrites a locally-modified KEEP file ---
T=$(mk)
if have; then
  bash "$VENDOR" --apply "$T" >/dev/null 2>&1
  echo "TAMPERED" > "$T/.claude/commands/align.md"
  bash "$VENDOR" --apply "$T" >/dev/null 2>&1
fi
if have && [ -f "$T/.claude/commands/align.md" ] && ! grep -q "TAMPERED" "$T/.claude/commands/align.md"; then
  _pass "KEEP-OVERWRITE: re-apply restores governance (idempotent, authoritative)"
else
  _fail "KEEP-OVERWRITE: modified KEEP file not overwritten"
fi
rm -rf "$T"

# --- DROP-ABSENT: harness-self content never copied ---
T=$(mk)
have && bash "$VENDOR" --apply "$T" >/dev/null 2>&1
if have && [ ! -e "$T/specs/001-example" ] && [ ! -e "$T/verification/reports" ] \
   && [ ! -e "$T/README.md" ] && [ ! -e "$T/tests" ]; then
  _pass "DROP-ABSENT: specs/001, reports, README.md, tests/ not copied"
else
  _fail "DROP-ABSENT: harness-self content leaked into target"
fi
rm -rf "$T"

# --- SEED-STUB: absent SEED files created as extends:base stubs ---
T=$(mk)
have && bash "$VENDOR" --apply "$T" >/dev/null 2>&1
if have && grep -qs "extends: base" "$T/memory/north-star/north-star.md" \
   && grep -qs "extends: base" "$T/memory/constitution/constitution.md" \
   && [ -f "$T/CLAUDE.md" ]; then
  _pass "SEED-STUB: north-star + constitution stubs (extends: base) + CLAUDE.md created"
else
  _fail "SEED-STUB: SEED stubs not created"
fi
rm -rf "$T"

# --- SEED-NOCLOBBER: existing SEED file preserved; .harness-new written ---
T=$(mk); printf 'MINE\n' > "$T/CLAUDE.md"
have && bash "$VENDOR" --apply "$T" >/tmp/v_out 2>&1
if have && [ "$(cat "$T/CLAUDE.md" 2>/dev/null)" = "MINE" ] && [ -f "$T/CLAUDE.md.harness-new" ] \
   && grep -qiE 'harness-new|merge' /tmp/v_out; then
  _pass "SEED-NOCLOBBER: existing CLAUDE.md intact, CLAUDE.md.harness-new written + reported"
else
  _fail "SEED-NOCLOBBER: existing SEED clobbered or .harness-new missing"
fi
rm -rf "$T"

# --- STACK-DETECT: pyproject -> pytest; unknown -> explicit TODO ---
T=$(mk); : > "$T/pyproject.toml"
have && bash "$VENDOR" --apply "$T" >/dev/null 2>&1
py_ok=1; have && grep -qs "pytest" "$T/scripts/test.sh" || py_ok=0
rm -rf "$T"
T=$(mk)   # no known manifest
have && bash "$VENDOR" --apply "$T" >/dev/null 2>&1
todo_ok=1; have && grep -qsiE "TODO" "$T/scripts/test.sh" || todo_ok=0
rm -rf "$T"
if have && [ "$py_ok" -eq 1 ] && [ "$todo_ok" -eq 1 ]; then
  _pass "STACK-DETECT: pyproject -> pytest, unknown -> TODO in scripts/test.sh"
else
  _fail "STACK-DETECT: stack detection / test.sh seeding wrong"
fi

# --- PROVENANCE: .harness-provenance stamped with SHA-or-non-git + date ---
T=$(mk)
have && bash "$VENDOR" --apply "$T" >/dev/null 2>&1
if have && [ -f "$T/.harness-provenance" ] \
   && grep -qiE '[0-9a-f]{7,}|non-git' "$T/.harness-provenance" \
   && grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$T/.harness-provenance"; then
  _pass "PROVENANCE: .harness-provenance has SHA-or-non-git + date"
else
  _fail "PROVENANCE: provenance file missing or incomplete"
fi
rm -rf "$T"

# --- DEPFREE: vendor.sh uses no installable toolchain (tied to deliverable) ---
# Distinguish INVOCATION from string DATA: vendor.sh legitimately names test commands
# ("npm test", "pytest", …) as the defaults it SEEDS into scripts/test.sh. Those are data,
# not dependencies. So exclude comment and echo lines (data) before checking for a real
# toolchain invocation.
assert_file "$VENDOR"
if have; then
  if grep -vE '^[[:space:]]*#|echo' "$VENDOR" \
     | grep -qiE '(^|[^[:alnum:]-])(npm|npx|node|uv|pip3?|pnpm|yarn)([^[:alnum:]-]|$)'; then
    _fail "DEPFREE: $VENDOR invokes an installable toolchain"
  else
    _pass "DEPFREE: $VENDOR bash/coreutils + git + python3 only (test commands are seeded data)"
  fi
fi

# --- HANDOFF: docs/vendoring.md documents buckets, plugs, first step ---
DOC=docs/vendoring.md
if [ -f "$DOC" ] && grep -qiE 'KEEP' "$DOC" && grep -qiE 'SEED' "$DOC" && grep -qiE 'DROP' "$DOC" \
   && grep -qE '/constitution' "$DOC"; then
  _pass "HANDOFF: docs/vendoring.md documents buckets + /constitution first step"
else
  _fail "HANDOFF: docs/vendoring.md missing or incomplete"
fi

# --- SELF-CHECK: the deliverable exists and is exercised by this suite ---
assert_file "$VENDOR"
