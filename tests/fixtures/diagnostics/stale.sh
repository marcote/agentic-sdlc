# Fixture: a declaration whose edit matches nothing. NOT part of the suite.
# --- INERT-ONE: the edit below targets text that is not in the tree ---
# --- [mut$ sed -i.bak 's|NO_SUCH_ANCHOR_ANYWHERE|X|' subject.txt $] ---
if grep -q GOOD subject.txt; then _pass "INERT-ONE: ok"; else _fail "INERT-ONE: no"; fi
