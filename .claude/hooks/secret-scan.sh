#!/usr/bin/env bash
# Advisory secret scanner. Two modes:
#   --scan-text : read stdin, exit 1 if a secret pattern is found (pure, testable).
#   (no args)   : Claude Code PreToolUse hook. No-op unless the tool call is a git commit.
set -u

PATTERNS='(AKIA[0-9A-Z]{16})|(BEGIN [A-Z ]*PRIVATE KEY)|([Pp]assword[[:space:]]*=[[:space:]]*["'\''][^"'\'']+["'\''])|([Aa][Pp][Ii][_-]?[Kk][Ee][Yy][[:space:]]*[=:])'

scan_text(){ grep -qE "$PATTERNS"; }

if [ "${1:-}" = "--scan-text" ]; then
  if scan_text; then exit 1; else exit 0; fi
fi

# Hook mode: stdin is the tool-call JSON. Only act on git commit.
# NOTE: the "git commit" match is intentionally a loose substring (advisory,
# bash-only, no jq). It may over-match; that only costs one warning, never a
# blocked commit. Tighten per-project if needed (constitution extends: base).
INPUT="$(cat)"
case "$INPUT" in
  *"git commit"*) : ;;
  *) exit 0 ;;                       # not a commit → silent, zero friction
esac

if git diff --cached 2>/dev/null | scan_text; then
  echo "secret-scan: possible secret in staged changes." >&2
  if [ "${SECRET_SCAN_BLOCK:-0}" = "1" ]; then exit 2; fi   # block only when opted-in
fi
exit 0                              # advisory by default
