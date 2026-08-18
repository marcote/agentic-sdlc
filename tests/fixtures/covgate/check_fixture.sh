# Fixture check file for the coverage gate. NOT part of the suite — it lives under
# tests/fixtures/, so `ls tests/check_*.sh` never reaches it.
#
# Two criteria declare a mutation and one deliberately does not, so the gate has both outcomes
# to find in a single file.

# --- FIXTURE-DECLARED: obliged, and declares its edit ---
# --- [mut$ printf 'BAD\n' > subject.txt $] ---
_pass "FIXTURE-DECLARED: ok"

# --- FIXTURE-IDEM: obliged through an idem cell, and declares its edit ---
# --- [mut$ printf 'BAD\n' > subject.txt $] ---
_pass "FIXTURE-IDEM: ok"

# --- FIXTURE-BARE: obliged and declares nothing — the gap the gate must name ---
_pass "FIXTURE-BARE: ok"
