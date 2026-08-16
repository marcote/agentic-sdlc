# Replay fixture — 018's ADOPT-REL-RESOLUTION, in the form actually shipped.
#
# Source: `git show 3adc719^:tests/check_98_adoption.sh`. The assertion block below is
# CHARACTER-IDENTICAL to what shipped; only the variables it reads are supplied here, and the
# target is the adopter fixture with its own rule layer removed — the state it was in at 018.
#
# The defect: expected and actual were read from two copies of the SAME tree. `base/` is KEEP, so
# both carried the same six ground rules and cwd-resolution produced byte-identical output. The
# assertion could not discriminate.
#
# The declared mutation is 018's real M1: revert the engine to cwd resolution.
A98_SE=scripts/stack/engine.py
A98_T=$(mktemp -d 2>/dev/null || mktemp -d -t rep18)
cp -R tests/fixtures/adopter/. "$A98_T/" 2>/dev/null
rm -f "$A98_T/memory/stack/ground-rules.md"          # the layer the FIX added; absent at 018
# ...and the decline that answers it. At 018 the fixture charter had neither.
awk '/^### GR7 /{skip=1;next} /^### /{skip=0} !skip' "$A98_T/memory/stack/stack.md" > "$A98_T/c.tmp" \
  && mv "$A98_T/c.tmp" "$A98_T/memory/stack/stack.md"
bash scripts/vendor.sh --apply "$A98_T" >/dev/null 2>&1
A98_GR_IN=$( cd "$A98_T" && python3 scripts/stack/engine.py ground-rules memory/stack/stack.md 2>&1 )

# --- ADOPT-REL-RESOLUTION: companion files resolve from the artifact, not the process cwd ---
# --- [mut$ sed -i.bak 's|^    roots, d = .*|    return [p for p in ["memory/stack/base/ground-rules.md", "memory/stack/ground-rules.md"] if os.path.exists(p)]|' scripts/stack/engine.py $] ---
A98_GR_OUT=$(python3 "$A98_SE" ground-rules "$A98_T/memory/stack/stack.md" 2>&1); a98_grout_rc=$?
A98_GR_EXP=$(python3 "$A98_SE" ground-rules --rules "$A98_T/memory/stack/base/ground-rules.md" \
             "$A98_T/memory/stack/stack.md" 2>&1)
if [ "$a98_grout_rc" -eq 0 ] && [ "$A98_GR_OUT" = "$A98_GR_IN" ] \
   && [ "$A98_GR_EXP" = "$A98_GR_IN" ]; then
  _pass "ADOPT-REL-RESOLUTION: same six verdicts from $PWD as from inside $A98_T; explicit --rules still wins"
else
  _fail "ADOPT-REL-RESOLUTION: rc=$a98_grout_rc from a foreign cwd: $(printf '%s' "$A98_GR_OUT" | head -1)"
fi
rm -rf "$A98_T"
