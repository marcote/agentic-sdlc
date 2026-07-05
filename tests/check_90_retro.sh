# Sourced by tests/run.sh (lib.sh already loaded). Enforcea el retro gate: la
# mitad trasera de la Measurability Gate. Template + wiring del contrato DONE +
# cierre por-feature. "Cerrado" = su verification/reports/<NNN>-*.md muestra el
# veredicto DONE (BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%). Feature
# cerrado ⟹ specs/<NNN>-*/retro.md completo. Sin hardcode: un feature sin
# reporte DONE está "en vuelo" y se saltea (regla uniforme).

# --- Template: estructura de 3 caras (Capa 1+2) ---
assert_file specs/_template/retro.md
for h in "Cara A" "Cara B" "Cara C" "Evidencia" "deriv"; do
  assert_contains specs/_template/retro.md "$h"
done

# --- Wiring del contrato DONE ---
assert_contains CLAUDE.md "retro ✅"
assert_contains docs/workflow.md "retro ✅"
assert_contains verification/verification-report.md "retro ✅"

# --- Cierre por-feature (regla uniforme) ---
# "Cerrado" = el report tiene BUILD ✅ y UAT ✅ y coverage 100% (tres greps
# independientes: robusto al layout de línea y evita precedencia ||/&& frágil).
closed_seen=0
for report in verification/reports/*.md; do
  [ -f "$report" ] || continue
  grep -qE "BUILD:[[:space:]]*✅"   "$report" || continue
  grep -qE "UAT:[[:space:]]*✅"     "$report" || continue
  grep -qE "coverage:[[:space:]]*100%" "$report" || continue
  closed_seen=1
  nnn=$(basename "$report" | grep -oE '^[0-9]+')
  featdir=$(ls -d specs/${nnn}-*/ 2>/dev/null | head -1)
  if [ -z "$featdir" ]; then _fail "report $report DONE pero no hay specs/${nnn}-*"; continue; fi
  retro="${featdir}retro.md"
  if [ ! -f "$retro" ]; then _fail "feature $nnn DONE pero falta $retro"; continue; fi
  _pass "feature $nnn DONE tiene $retro"
  # Sin placeholders sin llenar
  if grep -qE '_\(…\)_|<[^ >][^>]*>' "$retro"; then _fail "$retro tiene placeholders sin llenar"; else _pass "$retro sin placeholders"; fi
  # Veredicto de misión válido
  if grep -qE 'Veredicto de misión:[*[:space:]]*(confirmed|refuted|pending-observation|n/a)' "$retro"; then
    _pass "$retro veredicto de misión válido"
  else
    _fail "$retro sin veredicto de misión válido"
  fi
  # n/a exige razón (Capa: anti-escape)
  if grep -qE 'Veredicto de misión:[*[:space:]]*n/a' "$retro"; then
    if grep -qiE 'raz[oó]n' "$retro"; then _pass "$retro n/a con razón"; else _fail "$retro n/a sin razón"; fi
  fi
  # Cada campo de Cara B con [deriv:] (Capa 1)
  if [ "$(grep -cE '\[deriv:' "$retro")" -ge 4 ]; then _pass "$retro Cara B con deriv (≥4)"; else _fail "$retro Cara B con <4 [deriv:] (campos derivables sin locator)"; fi
done
[ "$closed_seen" -eq 1 ] && _pass "loop de cierre ejercitado" || _pass "sin features cerrados aún (vacuo)"
