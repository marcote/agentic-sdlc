#!/usr/bin/env bash
# nvc.sh — non-vacuity meta-check (read-only). Answers one question mechanically:
# can this assertion fail, and can its result be traced back to the criterion it claims to cover?
#
#   scripts/nvc.sh declarations <file>...            list FILE<TAB>LABEL for declared criteria
#   scripts/nvc.sh traceability --tests DIR --output LOG [--declarations-only]
#   scripts/nvc.sh duplicates   --tests DIR
#   scripts/nvc.sh selfscan     --tests DIR
#
# Exit: 0 clean · 1 violations found (each named on stdout) · 2 unusable input (nothing claimed).
# Dependency-free: bash/coreutils + awk. No installable toolchain.
#
# ---------------------------------------------------------------------------------------------
# WHAT THIS ENFORCES MECHANICALLY
#   1. traceability  — every declared criterion label emits PASS/FAIL/SKIP in the actual run,
#                      inside ITS OWN file's section of the log. run.sh prints "== <file> ==", so
#                      (file, label) attribution exists and is what makes a result traceable.
#   2. uniqueness    — a label declared twice inside ONE file, where sections cannot disambiguate.
#                      Across files a repeat is legitimate: an inherited [given] criterion is
#                      SUPPOSED to recur in every feature that carries it.
#   3. self-scanning — a scan whose target can include the scanning file must build its pattern
#                      at runtime and declare a self-test, so it cannot match its own source.
#
# WHAT REMAINS WITH REVIEW, and is NOT covered here
#   - Semantic vacuity: whether an assertion's pattern is satisfied by text that was already
#     present, or is too loose to discriminate, requires knowing what the assertion MEANS.
#   - Undeclared criteria: this verifies that everything DECLARED emits. It cannot know about a
#     criterion nobody wrote down. Cross-referencing coverage.md rows would close that and was
#     deliberately deferred — coverage ids across ten features follow no single convention, so it
#     would start noisy, and a check that cries wolf on a known-good suite gets disabled.
#
# A file that implied it covered the whole family would repeat, one level up, the failure this
# check exists to stop. It does not.
#
# CONSTRAINT ON CHECK AUTHORS: the suite must stay re-entrant. `traceability` is fed by a nested
# run, so a check that cannot tolerate being sourced twice will surface here as a traceability
# fault, which is the wrong diagnostic. Considered as a charter pin and rejected — it is local to
# tests/ (see specs/015-non-vacuous-checks/plan.md).
set -u

die(){ echo "nvc: $*" >&2; exit 2; }

TESTS=""; OUTPUT=""; DECL_ONLY=0
CMD="${1:-}"; [ -n "$CMD" ] || die "usage: nvc.sh {declarations|traceability|duplicates|selfscan}"
shift || true

FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --tests)             TESTS="${2:-}"; shift 2 ;;
    --output)            OUTPUT="${2:-}"; shift 2 ;;
    --declarations-only) DECL_ONLY=1; shift ;;
    -*)                  die "unknown argument: $1" ;;
    *)                   FILES+=("$1"); shift ;;
  esac
done

# check_files : the set this run reports on. Named in every diagnostic, because a check that
# reports on a tree without saying which tree returns confident false verdicts (twice on
# 2026-08-09: an empty commit range, and a clone of uncommitted work).
check_files(){
  if [ "${#FILES[@]}" -gt 0 ]; then printf '%s\n' "${FILES[@]}"; return; fi
  [ -n "$TESTS" ] || die "no target: pass files or --tests DIR"
  [ -d "$TESTS" ] || die "not a directory: $TESTS"
  ls "$TESTS"/check_*.sh 2>/dev/null
}

# strip_heredocs FILE : emit the file with every heredoc BODY removed. Shared by declaration
# parsing and the self-scan rule. The first run of selfscan without it flagged check_96 for a
# `grep ... tests/check_*.sh` that lives inside a fixture heredoc -- a false positive produced by
# this very tool, on its own file, in the exact shape it exists to catch.
# Quote characters are built as awk variables rather than escaped inline: the escaping idiom for
# a single quote inside a single-quoted shell string is unreadable enough that getting it wrong
# is likely, and getting it wrong here silently returns ZERO declarations — which every downstream
# assertion would then satisfy vacuously. It did exactly that on the first attempt.
strip_heredocs(){
  awk -v SQ="'" -v DQ='"' '
    BEGIN { q = "[" SQ DQ "]?" ; open = "<<-?[ \t]*" q "[A-Za-z_][A-Za-z0-9_]*" q }
    !inhd && match($0, open) {
      t = substr($0, RSTART, RLENGTH)
      sub(/^<<-?[ \t]*/, "", t); gsub("[" SQ DQ "]", "", t)
      inhd = 1; term = t; print ""; next
    }
    inhd { if ($0 ~ "^[ \t]*" term "[ \t]*$") inhd = 0; print ""; next }
    { print }
  ' "$1" 2>/dev/null
}

# --- declaration parsing -----------------------------------------------------------------------
# A criterion label is [A-Z][A-Z0-9-]* declared as either a `# --- LABEL:` section header or an
# emitting call `_pass|_fail|_skip "LABEL:`. Heredoc BODIES are skipped: this suite writes
# check-shaped text into fixtures, and parsing that as declarations would manufacture phantom
# criteria that can never emit.
declarations_of(){
  strip_heredocs "$1" | awk '
    function label(s){ return (s ~ /^[A-Z][A-Z0-9-]*$/) }
    /^#[ \t]*---[ \t]*[A-Z][A-Z0-9-]*:/ {
      s = $0; sub(/^#[ \t]*---[ \t]*/, "", s); sub(/:.*$/, "", s)
      if (label(s)) print s
      next
    }
    match($0, /_(pass|fail|skip)[ \t]+"[A-Z][A-Z0-9-]*:/) {
      s = substr($0, RSTART, RLENGTH); sub(/^_[a-z]+[ \t]+"/, "", s); sub(/:$/, "", s)
      if (label(s)) print s
    }
  ' | sort -u
}

# section_of LOG FILE : the slice of the run log belonging to one check file. run.sh prints
# "== <file> ==" before sourcing each one, so (file, label) attribution already exists. Using it
# is what makes a result traceable; requiring globally unique labels instead was the frozen R4,
# and it fired four times on a known-good suite where the recurrence was legitimate.
section_of(){
  awk -v want="$2" '
    /^== / { insec = ($2 == want); next }
    insec { print }
  ' "$1" 2>/dev/null
}

cmd_declarations(){
  local f n=0
  while read -r f; do
    [ -n "$f" ] || continue
    local l
    while read -r l; do
      [ -n "$l" ] || continue
      printf '%s\t%s\n' "$f" "$l"; n=$((n+1))
    done <<EOF_DECL
$(declarations_of "$f")
EOF_DECL
  done <<EOF_FILES
$(check_files)
EOF_FILES
  [ "$n" -gt 0 ] || return 1
  return 0
}

# --- traceability ------------------------------------------------------------------------------
cmd_traceability(){
  if [ "$DECL_ONLY" -eq 1 ]; then cmd_declarations; return $?; fi
  [ -n "$OUTPUT" ] || die "traceability needs --output LOG"
  [ -f "$OUTPUT" ] || die "run log not found: $OUTPUT"
  # Fail closed on an unusable run: a missing label and an aborted check look identical from
  # here, and reporting one as the other is a confident false verdict. Claim nothing.
  if [ ! -s "$OUTPUT" ]; then
    echo "nvc: run log is empty and therefore unusable: $OUTPUT" >&2
    echo "nvc: no traceability verdict emitted for any label" >&2
    exit 2
  fi
  if ! grep -qE '^[[:space:]]*(PASS|FAIL|SKIP):' "$OUTPUT"; then
    echo "nvc: run log contains no PASS/FAIL/SKIP lines, so it is unusable: $OUTPUT" >&2
    echo "nvc: no traceability verdict emitted for any label" >&2
    exit 2
  fi
  local bad=0 f l sec
  while IFS="$(printf '\t')" read -r f l; do
    [ -n "${l:-}" ] || continue
    sec=$(section_of "$OUTPUT" "$f")
    if [ -z "$sec" ]; then
      echo "unattributed: $OUTPUT has no section for $f (expected a '== $f ==' line)"
      bad=$((bad+1)); continue
    fi
    if ! printf '%s\n' "$sec" | grep -qE "(PASS|FAIL|SKIP): ${l}:"; then
      echo "untraceable: $f declares $l but no result for it appears in that file's section of $OUTPUT"
      bad=$((bad+1))
    fi
  done <<EOF_TR
$(cmd_declarations)
EOF_TR
  [ "$bad" -eq 0 ] || { echo "nvc: $bad untraceable criterion(s) across $(check_files | wc -l | tr -d ' ') file(s) in $OUTPUT"; return 1; }
  return 0
}

# --- duplicate labels --------------------------------------------------------------------------
cmd_duplicates(){
  # Same-FILE duplicates only. Across files a repeated label is legitimate and expected: an
  # inherited [given] criterion recurs in every feature that carries it, and the run log's per-file
  # sections disambiguate them. Within one file nothing can.
  local bad=0 f n l
  while read -r f; do
    [ -n "$f" ] || continue
    while read -r n l; do
      [ -n "${l:-}" ] || continue
      [ "${n:-0}" -gt 1 ] || continue
      echo "duplicate label: $l declared $n times inside $f"
      bad=$((bad+1))
    done <<EOF_DUP
$(strip_heredocs "$f" | grep -oE '^#[ \t]*---[ \t]*[A-Z][A-Z0-9-]*:' | sed 's/^#[ \t]*---[ \t]*//;s/:$//' | sort | uniq -c)
EOF_DUP
  done <<EOF_DF
$(check_files)
EOF_DF
  [ "$bad" -eq 0 ] || { echo "nvc: $bad label(s) declared more than once inside a single file, where sections cannot disambiguate"; return 1; }
  return 0
}

# --- self-scan rule ----------------------------------------------------------------------------
# Trigger is the TARGET SET, not the presence of a scan. A scan whose target is a glob or a
# directory that can contain the scanning file must (a) pass a runtime-assembled variable rather
# than an inline literal and (b) declare a self-test. A closed, explicitly named target set that
# excludes the scanner is not flagged -- that is the false positive this rule is designed to avoid.
cmd_selfscan(){
  local bad=0 f
  while read -r f; do
    [ -n "$f" ] || continue
    # candidate lines: grep/awk/sed whose target contains a glob over check files
    local hits
    hits=$(strip_heredocs "$f" | grep -nE '(grep|awk|sed)[^|;]*(check_\*|check_\[|\*\.sh)' \
           | grep -vE '^[0-9]+:[[:space:]]*#')
    [ -n "$hits" ] || continue
    local lit
    lit=$(echo "$hits" | grep -oE '(grep|egrep)[ \t]+-[a-zA-Z]*[ \t]+"[^"$]+"' \
          | grep -oE '"[^"$]+"' | tr -d '"' | head -1)
    if [ -n "$lit" ]; then
      echo "self-scan: $f scans a target that can include itself with the inline literal \"$lit\""
      echo "self-scan: assemble it at runtime so the scan cannot match its own source"
      bad=$((bad+1)); continue
    fi
    if ! declarations_of "$f" | grep -qE 'SELF'; then
      echo "self-scan: $f scans a target that can include itself but declares no self-test"
      echo "self-scan: add a criterion proving the assembled pattern matches a genuine occurrence"
      bad=$((bad+1))
    fi
  done <<EOF_SS
$(check_files)
EOF_SS
  [ "$bad" -eq 0 ] || { echo "nvc: $bad self-scan violation(s)"; return 1; }
  return 0
}

case "$CMD" in
  declarations)  cmd_declarations ;;
  traceability)  cmd_traceability ;;
  duplicates)    cmd_duplicates ;;
  selfscan)      cmd_selfscan ;;
  *)             die "unknown command: $CMD" ;;
esac
