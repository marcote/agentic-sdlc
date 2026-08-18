# Fixture: the edit command itself fails. Distinct from an edit that succeeds and does nothing.
# --- BROKEN-ONE: its declaration cannot run at all ---
# --- [mut$ sed -i.bak 's|unterminated' subject.txt $] ---
if grep -q GOOD subject.txt; then _pass "BROKEN-ONE: ok"; else _fail "BROKEN-ONE: no"; fi
