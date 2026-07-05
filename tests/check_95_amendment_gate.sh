# Sourced by tests/run.sh (lib.sh ya cargado). Contrato del amendment-gate:
# gatea cambios de los sets pillars/scope del bloque JSON canónico del North Star.
# Ejercita las funciones puras del gate vía su CLI de test contra fixtures
# (pares old/new + lista de added-files + stub de suite) — sin construir estados
# de git. Cubre los 10 criterios deterministas de acceptance.md. Los 2 criterios
# de bloqueo real (AMEND-BLOCK-REAL/PUSH) son config de GitHub → UAT, no acá.
#
# Contrato de la CLI que la implementación debe satisfacer (modo test):
#   scripts/amendment-gate.sh --files OLD NEW --added "f1 f2 …" --suite-cmd CMD
#     --files OLD NEW : dos archivos markdown con bloque ```json (old vs new)
#     --added "…"     : lista space-separated de archivos AGREGADOS en el rango
#     --suite-cmd CMD : comando cuyo exit 0 = suite verde (stub inyectable)
#   exit 0 = pasa (no bloquea) · exit ≠0 = bloquea, citando la condición faltante.

F=tests/fixtures/amendment-gate
GATE=scripts/amendment-gate.sh
ADR="memory/north-star/decisions/0003-nuevo.md"   # un ADR nuevo válido (added)

# --- helpers de gate (usan _pass/_fail de lib.sh) ---
gate_pass(){ # desc, args...
  local desc="$1"; shift
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then _pass "gate PASA: $desc"
  else _fail "gate debería PASAR: $desc (exit $?, out: $(head -1 /tmp/ag_out))"; fi
}
gate_block(){ # desc, regex, args...
  local desc="$1" re="$2"; shift 2
  if bash "$GATE" "$@" >/tmp/ag_out 2>&1; then
    _fail "gate debería BLOQUEAR: $desc (pasó con exit 0)"
  elif grep -qiE "$re" /tmp/ag_out; then _pass "gate BLOQUEA: $desc (cita /$re/)"
  else _fail "gate bloqueó pero sin mensaje /$re/: $desc (out: $(head -1 /tmp/ag_out))"; fi
}

# --- AMEND-BLOCK-NO-ADR: cambia sets, sin ADR nuevo -> bloquea citando ADR ---
gate_block "cambio de sets sin ADR" "adr" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "" --suite-cmd true

# --- AMEND-PASS-WITH-ADR: cambia sets + ADR + schema-válido + suite verde -> pasa ---
gate_pass "cambio de sets con ADR + schema ok + suite verde" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd true

# --- AMEND-NO-ADR-FOR-PROSE: solo prosa (mismo bloque) -> pasa sin ADR ---
gate_pass "solo prosa, sin ADR" \
  --files "$F/base.md" "$F/prose-only.md" --added "" --suite-cmd true
# refuerzo: solo alignment.threshold cambió -> tampoco exige ADR
gate_pass "solo threshold, sin ADR" \
  --files "$F/base.md" "$F/threshold.md" --added "" --suite-cmd true

# --- AMEND-SET-SEMANTICS: reordenado/reformateado, mismos sets -> pasa (sin falso positivo) ---
gate_pass "reformateo sin cambio de sets" \
  --files "$F/base.md" "$F/reformatted.md" --added "" --suite-cmd true

# --- AMEND-SCHEMA-VALID: cambia sets, con ADR, pero JSON schema-inválido -> bloquea citando schema ---
gate_block "cambio de sets schema-inválido (aun con ADR)" "schema|inv[aá]lid" \
  --files "$F/base.md" "$F/set-added-invalid.md" --added "$ADR" --suite-cmd true

# --- AMEND-SUITE-GREEN: cambia sets, ADR, schema ok, pero suite ROJA -> bloquea ---
gate_block "cambio de sets con suite roja" "suite|verde|red|roj" \
  --files "$F/base.md" "$F/set-added-valid.md" --added "$ADR" --suite-cmd false

# --- DEV-UNBLOCKED: diff no toca sets (trabajo normal) -> pasa (preserva principio 4) ---
gate_pass "trabajo normal, no toca sets (base==base)" \
  --files "$F/base.md" "$F/base.md" --added "src/algo.ts" --suite-cmd true

# --- CONST-EXCEPTION: la constitution del proyecto registra la excepción angosta al principio 4 ---
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "amendment-gate"
assert_contains memory/constitution/constitution.md "[Pp]rincipio 4"
assert_contains memory/constitution/constitution.md "pillars/scope"

# --- DEP-FREE: ni package.json/lock/node_modules ni toolchain instalable (uv/pip) ---
dep_free=1
for d in package.json package-lock.json pnpm-lock.yaml yarn.lock node_modules uv.lock requirements.txt; do
  [ -e "$d" ] && { _fail "DEP-FREE: apareció $d (dependencia instalable)"; dep_free=0; }
done
[ "$dep_free" -eq 1 ] && _pass "DEP-FREE: sin package manifests ni toolchain instalable"

# --- SELF-CHECK: wiring — el script del gate y el workflow existen y están cableados ---
assert_file "$GATE"
assert_file .github/workflows/amendment-gate.yml
assert_contains .github/workflows/amendment-gate.yml "amendment-gate.sh"
