# The code as it stood in scripts/lib/matrix.sh when 026's declaration was written.
# Reproduced so the replay runs against the real shape: the identifier is INDENTED and lives
# inside a quoted awk program, which is exactly why a shell-shaped anchor matched nothing.
_mx_scan(){
  awk -F'|' '
    !found && prev != "" && /^[[:space:]]*\|[-|: \t]*\|[[:space:]]*$/ {
      n = split(prev, hdr, "|")
      _mx_crit=0; _mx_crit = idx("criterion")
      st = idx("status")
    }
  ' "$1" 2>/dev/null
}
