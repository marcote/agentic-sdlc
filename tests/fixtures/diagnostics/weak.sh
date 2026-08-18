# Fixture: an edit that DOES change bytes and still leaves the criterion passing.
# --- WEAK-ONE: asserts a thing the edit does not touch ---
# --- [mut$ printf 'IRRELEVANT\n' >> subject.txt $] ---
if grep -q GOOD subject.txt; then _pass "WEAK-ONE: ok"; else _fail "WEAK-ONE: no"; fi
