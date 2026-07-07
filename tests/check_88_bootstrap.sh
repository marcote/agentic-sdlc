# Sourced by tests/run.sh (lib.sh already loaded). Contract of the from-zero bootstrap
# (bootstrap.sh, repo root): fetch the harness → print the vendor.sh plan → confirm →
# apply → clean up. A thin wrapper over scripts/vendor.sh (feature 007), motor untouched.
# Exercised hermetically: the fetch runs against a LOCAL checkout via HARNESS_REPO (no
# network); consent is driven non-interactively (--yes to apply, no /dev/tty to abort);
# cleanup is checked via a sandboxed TMPDIR. Covers 10 deterministic criteria
# (CONFIRM-TTY is UAT-only — a real terminal prompt has no honest hermetic RED).
#
# CLI contract the implementation must satisfy:
#   bootstrap.sh [--yes|-y] [target]      target default '.'
#   env HARNESS_REPO  (default https://github.com/marcote/agentic-sdlc.git) — clone source
#   env HARNESS_REF   (default main) — branch/ref to clone

BOOT=bootstrap.sh
VENDOR=scripts/vendor.sh
have(){ [ -f "$BOOT" ]; }
mk(){ mktemp -d 2>/dev/null || mktemp -d -t boot; }
BASH_BIN=$(command -v bash)
# Hermetic clone source with a real `main` branch. Can't use $(pwd) directly: CI checkouts are
# detached / lack a local `main`, so `git clone --branch main` would fail there. Export the
# committed HEAD tree (includes vendor.sh + engine + the DROP edit) into a throwaway repo on main.
SRC=$(mk)
if have; then
  git -C "$SRC" init -q 2>/dev/null
  git archive HEAD 2>/dev/null | tar -x -C "$SRC" 2>/dev/null
  git -C "$SRC" add -A 2>/dev/null
  git -C "$SRC" -c user.email=t@t -c user.name=t commit -q -m snapshot 2>/dev/null
  git -C "$SRC" branch -M main 2>/dev/null
fi

# run bootstrap into a fresh target with a sandboxed TMPDIR, no controlling stdin.
# echoes: "<target>|<sandbox>" ; caller inspects then cleans.
run_boot(){ # args: extra flags (e.g. --yes)
  local T S; T=$(mk); S=$(mk)
  have && HARNESS_REPO="$SRC" TMPDIR="$S" "$BASH_BIN" "$BOOT" "$@" "$T" </dev/null >/tmp/b_out 2>&1
  echo "$T|$S"
}

# --- FETCH: clones the harness (no manual clone) → governance appears in an empty target ---
r=$(run_boot --yes); T=${r%|*}; S=${r#*|}
if have && [ -f "$T/scripts/north-star/engine.py" ] && [ -f "$T/.claude/commands/align.md" ]; then
  _pass "FETCH: bootstrap cloned the harness (engine + commands landed in a bare target)"
else
  _fail "FETCH: harness not fetched/landed (bootstrap.sh absent or clone failed)"
fi
rm -rf "$T" "$S"

# --- PLAN-FIRST: the vendor.sh plan (KEEP/SEED/DROP + stack + provenance) is printed ---
r=$(run_boot --yes); T=${r%|*}; S=${r#*|}
if have && grep -qiE 'KEEP' /tmp/b_out && grep -qiE 'SEED' /tmp/b_out \
   && grep -qiE 'DROP' /tmp/b_out && grep -qiE 'provenance' /tmp/b_out; then
  _pass "PLAN-FIRST: vendor.sh plan (keep/seed/drop + provenance) printed before apply"
else
  _fail "PLAN-FIRST: plan not surfaced by bootstrap"
fi
rm -rf "$T" "$S"

# --- APPLY-YES: --yes result == a direct vendor.sh --apply (governance + provenance) ---
r=$(run_boot --yes); T=${r%|*}; S=${r#*|}
if have && [ -f "$T/.claude/commands/align.md" ] && [ -f "$T/scripts/north-star/engine.py" ] \
   && [ -f "$T/.harness-provenance" ]; then
  _pass "APPLY-YES: --yes lands governance + stamps .harness-provenance (== vendor.sh --apply)"
else
  _fail "APPLY-YES: --yes did not produce a vendored target"
fi
rm -rf "$T" "$S"

# --- NOTTY-ABORT: no TTY + no --yes → abort, target byte-for-byte unchanged ---
# (run under </dev/null; with no controlling terminal /dev/tty is unopenable → must abort)
r=$(run_boot); T=${r%|*}; S=${r#*|}
if have && [ ! -e "$T/.claude" ] && [ ! -e "$T/.harness-provenance" ] \
   && grep -qiE 'abort|no tty|--yes|confirm' /tmp/b_out; then
  _pass "NOTTY-ABORT: no TTY + no --yes aborts, writes nothing"
else
  _fail "NOTTY-ABORT: wrote to target or did not abort without a TTY"
fi
rm -rf "$T" "$S"

# --- CLEANUP: the temp clone is removed on both apply and abort paths ---
r=$(run_boot --yes); T=${r%|*}; S=${r#*|}
apply_clean=1; [ -z "$(ls -A "$S" 2>/dev/null)" ] || apply_clean=0
rm -rf "$T" "$S"
r=$(run_boot); T=${r%|*}; S=${r#*|}
abort_clean=1; [ -z "$(ls -A "$S" 2>/dev/null)" ] || abort_clean=0
rm -rf "$T" "$S"
if have && [ "$apply_clean" -eq 1 ] && [ "$abort_clean" -eq 1 ]; then
  _pass "CLEANUP: temp clone removed on apply and abort (sandboxed TMPDIR empty)"
else
  _fail "CLEANUP: leftover temp clone (apply_clean=$apply_clean abort_clean=$abort_clean)"
fi

# --- GIT-REQUIRED: git absent (empty PATH) → clear error, nothing written ---
T=$(mk)
have && PATH= "$BASH_BIN" "$BOOT" --yes "$T" </dev/null >/tmp/b_out 2>&1
if have && [ ! -e "$T/.claude" ] && grep -qiE 'git' /tmp/b_out; then
  _pass "GIT-REQUIRED: git absent → aborts with a git message, writes nothing"
else
  _fail "GIT-REQUIRED: did not fail closed when git is unavailable"
fi
rm -rf "$T"

# --- DROP-SELF: vendor.sh dry-run plan lists bootstrap.sh as DROP (not vendored) ---
# Tests the one-line edit to the LOCAL working-tree vendor.sh (bootstrap.sh added to DROP).
T=$(mk)
[ -f "$VENDOR" ] && bash "$VENDOR" "$T" >/tmp/b_plan 2>&1
if [ -f "$VENDOR" ] && grep -qiE '(^|[^[:alnum:]])bootstrap\.sh' /tmp/b_plan \
   && grep -iE 'bootstrap\.sh' /tmp/b_plan | grep -qiE 'DROP'; then
  _pass "DROP-SELF: vendor.sh plan classifies bootstrap.sh as DROP"
else
  _fail "DROP-SELF: bootstrap.sh not marked DROP in vendor.sh plan"
fi
rm -rf "$T"

# --- DEPFREE: bootstrap.sh invokes no installable toolchain (invariant tied to deliverable) ---
assert_file "$BOOT"
have && assert_dep_free "$BOOT"

# --- HANDOFF-DOC: the curl one-liner (+ --yes) documented in README + docs/vendoring.md ---
readme_ok=0; vend_ok=0
if [ -f README.md ] && grep -qiE 'bootstrap\.sh' README.md \
   && grep -qiE 'curl' README.md && grep -qiE '\-\-yes' README.md; then readme_ok=1; fi
if [ -f docs/vendoring.md ] && grep -qiE 'bootstrap\.sh' docs/vendoring.md; then vend_ok=1; fi
if [ "$readme_ok" -eq 1 ] && [ "$vend_ok" -eq 1 ]; then
  _pass "HANDOFF-DOC: README documents curl|bash one-liner (+ --yes); vendoring.md cross-refs bootstrap"
else
  _fail "HANDOFF-DOC: one-liner not documented (readme=$readme_ok vendoring=$vend_ok)"
fi

# --- SELF-CHECK: the deliverable exists and is exercised by this suite ---
assert_file "$BOOT"

rm -rf "$SRC"
