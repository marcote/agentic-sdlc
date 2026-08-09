assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
# Invariant criterion rule (refines principle 2 test-first): do not accept
# green-by-construction as RED; tie the invariant to a deliverable.
assert_contains memory/constitution/base/principles.md "invariant"
assert_contains memory/constitution/base/principles.md "green-by-construction"
# Interactive-IO exception (candidate from 009 retro): a real /dev/tty prompt has no
# hermetic RED → UAT-observed, excluded from the /contract RED set (its neighbors stay in).
assert_contains memory/constitution/base/principles.md "Interactive-IO exception"
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
# D3 (candidate from 008 retro): workflow tooling must be run against its own in-flight
# feature before closing (reflexive dogfood) — harness-specific project delta.
assert_contains memory/constitution/constitution.md "Reflexive dogfood"
# D4 (candidate carried from 013 + 014 retros, third occurrence): a feature that introduces
# a gate is exempt from being BLOCKED by it, never from RUNNING it. The four conditions are
# the rule; asserting only the heading would pass against a heading with no conditions.
assert_contains memory/constitution/constitution.md "Gate bootstrap"
assert_contains memory/constitution/constitution.md "from being blocked, never from being run"
assert_contains memory/constitution/constitution.md "real verdict"
# --- PROSE-CAP (D5): sentences in artifact prose stay under the cap ---
# The rule and its enforcement are asserted together. A delta describing a cap that nothing runs is
# the shape OVERRIDE-LIVE exists to prevent one section above.
assert_contains memory/constitution/constitution.md "One sentence, one idea"
if [ -x scripts/prose.sh ] && bash scripts/prose.sh >/tmp/prose_out 2>&1; then
  _pass "PROSE-CAP: no sentence over the cap across specs, memory, docs"
else _fail "PROSE-CAP: $(tail -1 /tmp/prose_out 2>/dev/null || echo 'scripts/prose.sh missing or not executable')"; fi
# self-test: the checker must actually reject a long sentence, or PROSE-CAP passes on an empty scan
_pfx=$(mktemp -d); mkdir -p "$_pfx/d"
python3 -c "print('word ' * 60)" > "$_pfx/d/long.md"
if bash scripts/prose.sh "$_pfx/d" >/dev/null 2>&1; then
  _fail "PROSE-CAP-SELF: the checker accepted a 60-word sentence, so the scan above proves nothing"
else _pass "PROSE-CAP-SELF: the checker rejects a 60-word sentence"; fi
printf 'Short and clear.\n' > "$_pfx/d/long.md"
bash scripts/prose.sh "$_pfx/d" >/dev/null 2>&1 \
  && _pass "PROSE-CAP-SELF-NEG: it accepts short prose, so it is not simply always failing" \
  || _fail "PROSE-CAP-SELF-NEG: the checker rejects even short prose"
rm -rf "$_pfx"
assert_dep_free scripts/prose.sh "PROSE-CAP-DEPFREE"

assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency hermetic-tests non-vacuous-checks; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Injected criteria"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
# non-vacuous-checks (candidate carried from 013 + 014 retros; 11 occurrences). The eval
# names ARE the contract /distill injects into coverage.md, so assert each one by name:
# "Injected criteria" + one "[given]" above is satisfied by a stub, which is precisely the
# vacuity this pattern exists to forbid. Each name must also carry its *Prevents:* line —
# an unjustified mandatory step is the defect ADR 0004's amended signal measures.
NVC=memory/constitution/base/patterns/non-vacuous-checks.md
for e in check-can-fail check-traceable check-rejects-by-diagnostic \
         check-no-self-match check-names-its-tree; do
  assert_contains "$NVC" "eval: $e"
done
if [ "$(grep -cE '^[[:space:]]*\*Prevents:\*' "$NVC" 2>/dev/null)" -eq 5 ]; then
  _pass "NVC-JUSTIFIED: all 5 injected criteria carry a Prevents: line"
else
  _fail "NVC-JUSTIFIED: expected 5 Prevents: lines, got $(grep -cE '^[[:space:]]*\*Prevents:\*' "$NVC" 2>/dev/null)"
fi
# The pattern must state what it does NOT cover. One that implied full coverage would
# repeat, one level up, the failure mode it is named after.
assert_contains "$NVC" "Semantic vacuity stays a review concern"

# --- OVERRIDE-LIVE: the project override cannot outlive the gate it depends on ---
# constitution.md stops injecting check-traceable and check-no-self-match per feature BECAUSE
# check_96 enforces them on every run, over the whole tree. If that gate goes away the override
# silently becomes a hole -- a rule nobody enforces and nobody injects. Assert the pairing, not
# the prose: the override text alone would be satisfied by a comment.
_ovr=0
grep -q 'non-vacuous-checks.md` — two of five rows discharged' memory/constitution/constitution.md || _ovr=1
[ -f tests/check_96_non_vacuous.sh ] || _ovr=2
[ -f scripts/nvc.sh ] || _ovr=3
grep -q 'check_96_non_vacuous.sh' <(ls tests/) || _ovr=4
if [ "$_ovr" -eq 0 ]; then
  _pass "OVERRIDE-LIVE: the two discharged rows are paired with a gate that exists and runs"
else _fail "OVERRIDE-LIVE: override present without its enforcing gate (code $_ovr) — the rule is now unenforced AND uninjected"; fi
# self-test: the pairing check can actually fail — it must not be satisfied by prose alone
if ! grep -q 'this-file-does-not-exist-nvc' memory/constitution/constitution.md; then
  _pass "OVERRIDE-LIVE-SELF: the pairing reads real paths, not only the override's own words"
else _fail "OVERRIDE-LIVE-SELF: pairing check is satisfied by text"; fi
