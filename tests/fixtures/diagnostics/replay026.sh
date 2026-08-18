# Fixture: 026's declaration VERBATIM, against the code as it stood.
# It was reported as `survived its own mutation` — which says the criterion is weak. It was not.
# --- REPLAY-026: 026's own stale declaration, unedited ---
# --- [mut$ sed -i.bak 's|^_mx_crit=0$|_mx_crit=5|' tests/fixtures/diagnostics/matrix_as_shipped.sh $] ---
if grep -q '_mx_crit=0' tests/fixtures/diagnostics/matrix_as_shipped.sh; then
  _pass "REPLAY-026: ok"
else
  _fail "REPLAY-026: no"
fi
