# matrix.sh — the single reader for a coverage matrix. Sourced, never executed.
#
#   . scripts/lib/matrix.sh
#   matrix_header FILE   -> "PILLAR CRIT ORIGIN LINK STATUS FIRST LAST" (1-based; 0 = absent)
#                           empty output and non-zero when no table in FILE qualifies
#   matrix_rows   FILE   -> one tab-separated line per data row of THAT table:
#                           LABEL <TAB> ORIGIN <TAB> LINK <TAB> STATUS <TAB> PILLAR
#
# LABEL is first and PILLAR last, deliberately. `read` with IFS=tab still treats tab as IFS
# WHITESPACE and strips leading ones, so a leading empty field silently shifts every column in the
# consumer. LABEL is never empty -- rows without one are skipped -- so leading it removes the class.
#
# PILLAR is 0 when the matrix has no such column, which specs/001-example does not. status.sh's
# orphan test is "a row with no pillar" -- against a six-column matrix that would flag EVERY row.
# The seventh field was added during the third port; the first two were re-run against their
# baselines afterwards rather than assumed still correct.
#
# WHY THIS EXISTS: three tools grew three parsers, months apart, each indexing columns by position.
# Split on the pipe, a six-column row and a seven-column row yield the SAME field count -- so a
# fixed-index reader never fails. It reads a different column and reports confidently. Measured on
# main before this file existed:
#   · status.sh printed specs/001-example's Origin cell as the criterion name (wrong since 008)
#   · status.sh read 022's trailing measurement table as criteria and invented an unnamed orphan row
#   · mutate.sh coverage and cases.sh were right only because the cell they mistook for Status was
#     empty, so every row failed the status test and dropped out
#
# TWO RULES, and both defects above violate one of them:
#   1. columns are located by HEADER NAME, never by position
#   2. rows come from the qualifying table's own RANGE -- a second table below is out of range by
#      construction, not filtered out afterwards. Filtering means anticipating every other table.

# _mx_scan FILE : emit "crit origin link status first last" for the first qualifying table.
# Qualifying = a header row followed by a |---|---| separator whose cells name both a criterion and
# a status column. `first` is the line after the separator; `last` is the final consecutive row.
_mx_scan(){
  awk -F'|' '
    function idx(c,  i, h) {
      for (i = 1; i <= n; i++) { h = tolower(hdr[i]); gsub(/^[ \t]+|[ \t]+$/, "", h)
        if (h ~ c) return i }
      return 0
    }
    !found && prev != "" && /^[[:space:]]*\|[-|: \t]*\|[[:space:]]*$/ {
      n = split(prev, hdr, "|")
      _mx_crit=0; _mx_crit = idx("criterion")
      st = idx("status")
      if (_mx_crit && st) {
        found = 1
        pil  = idx("pillar")
        org  = idx("origin")
        link = idx("linked"); if (!link) link = idx("test/eval")
        _mx_first = NR + 1
        next
      }
    }
    found && !_mx_last {
      # the table ends at the first line that is not a data row
      if ($0 !~ /^[[:space:]]*\|/) { _mx_last = NR - 1 }
    }
    { prev = $0; total = NR }
    END {
      if (!found) exit 1
      if (!_mx_last) _mx_last = total
      print pil+0, _mx_crit, org, link, st, _mx_first, _mx_last
    }
  ' "$1" 2>/dev/null
}

matrix_header(){
  [ -f "${1:-}" ] || return 1
  local out; out=$(_mx_scan "$1") || return 1
  [ -n "$out" ] || return 1
  printf '%s\n' "$out"
}

# matrix_rows FILE : LABEL <TAB> ORIGIN <TAB> LINK <TAB> STATUS, for the qualifying table only.
#
# `idem` in the linked cell inherits from the row above -- WITHIN this table. _mx_prev is reset per
# call, so a later table's `idem` can never inherit from the matrix.
#
# The label is TRIMMED, never stripped. 023 deleted every space because this harness names criteria
# UPPER-KEBAB, and specs/001-example's criterion is the prose "message clarity"; the binding check
# then reported UNBOUND against a file that was correct.
matrix_rows(){
  local cols pi ci oi li si lo hi
  cols=$(matrix_header "${1:-}") || return 1
  # `read` rather than `set -- $cols`: this file is sourced, and zsh does not word-split an
  # unquoted parameter. Under zsh the six indices arrive as one word and every column is garbage --
  # silently, because awk accepts a non-numeric field index as 0. Split explicitly.
  IFS=' ' read -r pi ci oi li si lo hi <<EOF
$cols
EOF
  set -- "$1" "$pi" "$ci" "$oi" "$li" "$si" "$lo" "$hi"
  awk -F'|' -v pi="$2" -v ci="$3" -v oi="$4" -v li="$5" -v si="$6" -v lo="$7" -v hi="$8" '
    function cell(i,  v) { v = (i ? $i : ""); gsub(/`/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); return v }
    NR < lo || NR > hi { next }
    /^[[:space:]]*\|[-|: \t]*\|[[:space:]]*$/ { next }
    {
      l = cell(ci)
      if (l == "" || l ~ /^-+$/) next
      link = cell(li)
      # EXACT match. `~ /idem/` is what mutate.sh and cases.sh both shipped, and
      # specs/001-example links `idempotency.feature` -- a real filename that begins with "idem".
      # It was silently inheriting the row above.
      if (link == "idem") link = _mx_prev; else if (link != "") _mx_prev = link
      print l "\t" cell(oi) "\t" link "\t" cell(si) "\t" cell(pi)
    }
  ' "$1"
}
