#!/usr/bin/env bash
# mutate.sh — makes `check-can-fail` executable.
#
# A criterion declares the edit that must break it, in a comment under its header:
#
#   # --- SOME-CRITERION: what it asserts ---
#   # --- [mut$ printf 'BAD\n' > subject.txt $] ---
#
# This runner applies each declared edit in a throwaway copy of the tree, re-runs the check file
# that owns the criterion, and requires that criterion to emit FAIL. A criterion that survives its
# own mutation is reported by name, together with the edit that failed to break it.
#
#   scripts/mutate.sh list     --tests DIR     one line per declaration: FILE:LINE:LABEL
#   scripts/mutate.sh criteria --tests DIR     one line per criterion header: FILE:LINE:LABEL
#   scripts/mutate.sh run      --tests DIR [--only LABEL]
#   scripts/mutate.sh coverage --tests DIR --spec PATH   which criteria of one feature are obliged
#   scripts/mutate.sh coverage --tests DIR --all         the standing debt, re-derived
#
# Exit contract:
#   0 = every declared mutation broke its criterion / every obliged criterion declares one
#   1 = at least one criterion was not proved failable, or declares none (named either way)
#   2 = unusable input: a malformed or unbound declaration, no tests directory, or a coverage row
#       that looks obliged and cannot be resolved
#
# WHY `coverage` EXISTS: 020 made the proving repeatable, not required. 021 measured that the real
# gap was coverage -- seven of 018's sixteen criteria had never declared a mutation -- so the
# obligation is derived from the artifact that already names a feature's criteria, its coverage
# matrix. No branch ref: the trigger "every criterion changed on this branch" is what 019 shipped
# and CI rejected.
#
# Dependency-free: bash + coreutils + python3 (timing only). No installable toolchain.
#
# WHY A SANDBOX RATHER THAN AN IN-PLACE REVERT: `git checkout` cannot restore an untracked file,
# and a mutation may create one. Two fixture harnesses leaked state that way on 2026-08-09.
#
# WHY `git ls-files` RATHER THAN A BRANCH REF: the sandbox must be the code being written, not the
# last commit, and it must work in a shallow detached-HEAD checkout with no local main. 019 shipped
# a check that read `git show main:…`; it was green locally and failed in CI.
set -u

CMD=""; TESTS=""; ONLY=""; SPEC=""; ALL=0
while [ $# -gt 0 ]; do
  case "$1" in
    list|run|criteria|coverage) CMD="$1"; shift ;;
    --tests) TESTS="${2:-}"; shift 2 ;;
    --only)  ONLY="${2:-}"; shift 2 ;;
    --spec)  SPEC="${2:-}"; shift 2 ;;
    --all)   ALL=1; shift ;;
    -h|--help) sed -n '2,29p' "$0"; exit 0 ;;
    *) echo "mutate: unknown argument: $1" >&2; exit 2 ;;
  esac
done
die(){ echo "mutate: $*" >&2; exit 2; }
[ -n "$CMD" ] || die "no subcommand: expected list, criteria or run"
[ -n "$TESTS" ] && [ -d "$TESTS" ] || die "no tests directory: pass --tests DIR"

# strip_heredocs FILE : blank out heredoc BODIES, keeping line numbers.
# Required, not cosmetic: a check file's fixtures are check-shaped, and a heredoc-blind parser
# manufactures declarations belonging to strings. nvc.sh measured that at 110 phantom criteria
# against ~78 real ones.
strip_heredocs(){
  awk -v SQ="'" -v DQ='"' '
    BEGIN { q = "[" SQ DQ "]?" ; open = "<<-?[ \t]*" q "[A-Za-z_][A-Za-z0-9_]*" q }
    !inhd && match($0, open) {
      t = substr($0, RSTART, RLENGTH); gsub(/^<<-?[ \t]*/, "", t); gsub(/['"'"'"]/, "", t)
      inhd = 1; term = t; print ""; next
    }
    inhd { if ($0 ~ "^[ \t]*" term "[ \t]*$") inhd = 0; print ""; next }
    { print }
  ' "$1" 2>/dev/null
}

check_files(){ ls "$TESTS"/check_*.sh 2>/dev/null; }

# scan FILE MODE : emit "LINE<TAB>LABEL<TAB>COMMAND" per declaration (MODE=decl)
#                  or "LINE<TAB>LABEL" per criterion header (MODE=crit).
# A declaration binds to the criterion header ABOVE it. Binding by position rather than by a label
# repeated inside the declaration: two copies of a label drift, and then the runner proves a
# criterion that is no longer there.
scan(){
  local f="$1" mode="$2"
  strip_heredocs "$f" | awk -v mode="$mode" -v file="$f" '
    /^# --- \[mut\$/ {
      if (mode == "decl") {
        line = $0
        sub(/^# --- \[mut\$[ \t]*/, "", line)
        # last "$]" on the line, so a command containing the terminator still parses whole
        i = 0; p = index(line, "$]")
        while (p > 0) { i += p; rest = substr(line, i + 2); p = index(rest, "$]"); if (p > 0) i += 2 }
        if (i == 0) { print "ERR\tunterminated declaration\t" NR; next }
        cmd = substr(line, 1, i - 1)
        sub(/[ \t]+$/, "", cmd)
        if (label == "") { print "ERR\tunbound declaration (no criterion header above it)\t" NR; next }
        print NR "\t" label "\t" cmd
      }
      next
    }
    # A header naming several criteria is UNBINDABLE: a declaration binds to the header above it,
    # and one edit cannot be the negative of two different assertions. nvc.sh reads both labels of
    # such a header; this read NEITHER, so both criteria vanished from the coverage count and
    # neither could carry a mutation. Rejected by name -- silence is how they vanished.
    /^# --- [A-Z][A-Z0-9-]+[ \t]*·/ { print "ERR\tmulti-label criterion header (two criteria cannot share one header, so neither is bindable)\t" NR; next }
    /^# --- [A-Z][A-Z0-9-]+: / {
      l = $0; sub(/^# --- /, "", l); sub(/:.*/, "", l)
      label = l
      if (mode == "crit") print NR "\t" label
      next
    }
  '
}

collect(){ # MODE -> "FILE\tLINE\tLABEL\tCMD"; exits 2 on any ERR row
  local f rc=0
  for f in $(check_files); do
    while IFS=$'\t' read -r a b c; do
      [ -n "$a" ] || continue
      if [ "$a" = "ERR" ]; then echo "mutate: $f:$c: $b" >&2; rc=2; continue; fi
      printf '%s\t%s\t%s\t%s\n' "$f" "$a" "$b" "${c:-}"
    done <<EOF
$(scan "$f" "$1")
EOF
  done
  return $rc
}

now(){ python3 -c 'import time; print("%.2f" % time.time())' 2>/dev/null || echo 0; }
elapsed(){ python3 -c "print('%.2fs' % ($2 - $1))" 2>/dev/null || echo "?"; }

# --- coverage: which criteria are OBLIGED to declare, and do they ---
#
# A row is obliged when all three hold. Each condition removes a row that owns no assertion to
# break, so obliging it would demand a mutation for nothing:
#   1. origin is `project`   -- a [given] row is inherited and asserted by whatever it routed to
#   2. status is 🔴/🟢/✅     -- a 📋 case row is judged, a deferred row is justified as absent
#   3. the linked-test cell resolves to a check file that exists
#
# Condition 3 carries the whole B11 risk. An earlier form required the literal `tests/check_`; it
# reported 47 undeclared instead of 137, because sixteen matrices written over six weeks are not
# uniform -- they hold bare filenames, prefixed paths, parentheticals and compounds. A predicate
# that DISCARDS what it cannot parse reports a smaller, cleaner, wrong number, and the failure
# renders identically to the success. So non-resolution is never silence:
#   a check_*.sh token that does not exist        -> UNRESOLVED, exit 2
#   no check_*.sh but the cell names something.sh -> UNRESOLVED, exit 2  (the typo path)
#   no script named at all                        -> excluded, and COUNTED
COV_GAP=1
COV_UNRESOLVED=2
COV_SH_FALLBACK='[.]sh'

# cov_rows FILE : emit "STATE<TAB>LABEL<TAB>CELL" per criterion row, resolving `idem` to the row
# above. STATE is `ex` for a row excluded by rule and `ok` for one that reaches resolution.
#
# Excluded rows are EMITTED, not filtered. The first form filtered them in awk and reported
# `0 excluded` on a fixture holding three -- exclusion had become a silence, which is the family
# this file exists to close. COV-NOT-OBLIGED-COUNTED caught it.
#
# The label pattern is spelled out rather than using {3,}: BSD awk silently ignores interval
# quantifiers, so `{3,}` matches nothing on macOS and the sweep returns one row per file.
cov_rows(){
  awk -F'|' 'NF>6 {
      t = $7; if (t ~ /idem/) t = prev; else prev = t
      l = $5; gsub(/[ `]/, "", l)
      if (l !~ /^[A-Za-z][A-Za-z0-9-][A-Za-z0-9-][A-Za-z0-9-]+$/) next
      if ($6 !~ /project/ || $8 !~ /red|green|uat/) { print "ex\t" l "\t" t; next }
      print "ok\t" l "\t" t
    }' "$1" 2>/dev/null
}

# cov_resolve CELL : echo the check file path, or "" if none is named, or "!TOKEN" if one is
# named and unusable. Tried as written first (a cell may carry a real path), then under --tests.
cov_resolve(){
  local cell="$1" tok base
  tok=$(printf '%s' "$cell" | tr -d '`' | grep -oE '[A-Za-z0-9_./-]*check_[0-9a-z_]+\.sh' | head -1)
  if [ -z "$tok" ]; then
    printf '%s' "$cell" | grep -qE "$COV_SH_FALLBACK" && { echo "!$(printf '%s' "$cell" | tr -d '`|' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"; return; }
    echo ""; return
  fi
  [ -f "$tok" ] && { echo "$tok"; return; }
  base=$(basename "$tok")
  [ -f "$TESTS/$base" ] && { echo "$TESTS/$base"; return; }
  echo "!$tok"
}

# cov_one FILE : print findings; echo "obliged undeclared excluded unresolved" on the last line.
cov_one(){
  local cf="$1" st lab cell res ob=0 un=0 ex=0 nr=0
  while IFS=$'\t' read -r st lab cell; do
    [ -n "$lab" ] || continue
    if [ "$st" = "ex" ]; then ex=$((ex+1)); continue; fi
    res=$(cov_resolve "$cell")
    case "$res" in
      "")  ex=$((ex+1)) ;;
      !*)  nr=$((nr+1))
           echo "UNRESOLVED  $lab ($cf) — linked test ${res#!} names no check file that exists" ;;
      *)   ob=$((ob+1))
           if scan "$res" decl | cut -f2 | grep -qx "$lab"; then :; else
             un=$((un+1))
             echo "UNDECLARED  $lab ($cf) — obliged by its row, no [mut\$ … \$] in $res"
           fi ;;
    esac
  done <<EOF
$(cov_rows "$cf")
EOF
  echo "COUNTS $ob $un $ex $nr"
}

if [ "$CMD" = "coverage" ]; then
  T_C0=$(now)
  if [ "$ALL" -eq 1 ]; then
    tob=0; tun=0; tex=0; tnr=0
    for cf in specs/*/coverage.md; do
      [ -f "$cf" ] || continue
      out=$(cov_one "$cf"); counts=${out##*COUNTS }
      set -- $counts
      printf '%-46s %3d obliged, %3d undeclared, %2d excluded\n' "$cf" "$1" "$2" "$3"
      printf '%s\n' "$out" | grep -v '^COUNTS ' | sed 's/^/  /' | grep . || true
      tob=$((tob+$1)); tun=$((tun+$2)); tex=$((tex+$3)); tnr=$((tnr+$4))
    done
    T_C1=$(now)
    COV_TOTAL_LINE="TOTAL over specs/*/coverage.md: $tob obliged, $tun undeclared, $tex excluded, $tnr unresolvable — total elapsed $(elapsed "$T_C0" "$T_C1")"
    echo "---"
    echo "$COV_TOTAL_LINE"
    [ "$tnr" -eq 0 ] || exit "$COV_UNRESOLVED"
    exit 0
  fi
  [ -n "$SPEC" ] || die "coverage: pass --spec PATH or --all"
  CF="$SPEC"; [ -d "$SPEC" ] && CF="$SPEC/coverage.md"
  [ -f "$CF" ] || die "coverage: no coverage matrix at $CF"
  out=$(cov_one "$CF"); counts=${out##*COUNTS }
  set -- $counts
  printf '%s\n' "$out" | grep -v '^COUNTS ' | grep . || true
  T_C1=$(now)
  COV_OK_MSG="coverage: $CF — $1 obliged, $2 undeclared, $3 excluded, $4 unresolvable — total elapsed $(elapsed "$T_C0" "$T_C1")"
  echo "$COV_OK_MSG"
  [ "$4" -eq 0 ] || exit "$COV_UNRESOLVED"
  [ "$2" -eq 0 ] || exit "$COV_GAP"
  exit 0
fi

case "$CMD" in
  list)
    collect decl | while IFS=$'\t' read -r f l lab cmd; do echo "$f:$l:$lab"; done
    exit ${PIPESTATUS[0]:-0}
    ;;
  criteria)
    collect crit | while IFS=$'\t' read -r f l lab _; do echo "$f:$l:$lab"; done
    exit ${PIPESTATUS[0]:-0}
    ;;
esac

# --- run ---
DECLS=$(collect decl) || exit 2
[ -n "$DECLS" ] || { echo "mutate: no declarations under $TESTS"; exit 0; }

ROOT=$(pwd)
# Per-invocation scratch. A shared /tmp path is not safe here: the check file this runner executes
# may itself invoke this runner, and the inner run then clobbers the outer run's captured output.
# That happened, and it produced a WRONG diagnostic -- a criterion that passed under its mutation
# was reported as "emitted no result", which reads like a broken check rather than a vacuous one.
SCRATCH=$(mktemp -d 2>/dev/null || mktemp -d -t mutscratch)
trap 'rm -rf "$SCRATCH"' EXIT
FAILED=0; N=0
T_ALL0=$(now)

while IFS=$'\t' read -r file line label cmd; do
  [ -n "$label" ] || continue
  [ -z "$ONLY" ] || [ "$ONLY" = "$label" ] || continue
  N=$((N+1))
  T0=$(now)
  SB=$(mktemp -d 2>/dev/null || mktemp -d -t mutsb)
  # tracked files only, from the WORKING TREE — no .git, no branch ref, no untracked noise
  ( cd "$ROOT" && git ls-files -z 2>/dev/null | tar -cf - --null -T - 2>/dev/null ) | tar -xf - -C "$SB" 2>/dev/null

  if ! ( cd "$SB" && eval "$cmd" ) >"$SCRATCH/apply" 2>&1; then
    echo "NOT PROVED  $label ($file:$line) — the mutation could not be applied: $cmd"
    echo "            $(head -1 "$SCRATCH/apply" 2>/dev/null)"
    FAILED=$((FAILED+1)); rm -rf "$SB"; continue
  fi

  ( cd "$SB" && bash -c ". tests/lib.sh; . $file" ) >"$SCRATCH/run" 2>&1

  # A criterion is proved failable only when it emits FAIL and emits no PASS. Not "some FAIL":
  # a criterion emitting from a loop can do both, and then it was not really broken.
  got_fail=0; got_pass=0
  grep -qE "^[[:space:]]*FAIL: $label(:|[[:space:]])" "$SCRATCH/run" && got_fail=1
  grep -qE "^[[:space:]]*PASS: $label(:|[[:space:]])" "$SCRATCH/run" && got_pass=1
  T1=$(now)

  if [ "$got_fail" -eq 1 ] && [ "$got_pass" -eq 0 ]; then
    echo "proved      $label ($file:$line) — $(elapsed "$T0" "$T1")"
  elif [ "$got_fail" -eq 0 ] && [ "$got_pass" -eq 0 ]; then
    # Absent is its own outcome. Silence and failure look identical from outside, which is the
    # whole family this runner exists to catch — so it must never be read as success.
    echo "NOT PROVED  $label ($file:$line) — emitted no result under its mutation: $cmd"
    FAILED=$((FAILED+1))
  else
    echo "NOT PROVED  $label ($file:$line) — survived its own mutation: $cmd"
    FAILED=$((FAILED+1))
  fi
  rm -rf "$SB"
done <<EOF
$DECLS
EOF

T_ALL1=$(now)
echo "---"
echo "mutate: $N mutation(s) under $TESTS, $FAILED not proved, total elapsed $(elapsed "$T_ALL0" "$T_ALL1")"
[ "$FAILED" -eq 0 ] || exit 1
exit 0
