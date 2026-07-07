#!/usr/bin/env bash
# bootstrap.sh — one-command, from-zero adoption of the Agentic SDLC harness.
# A thin wrapper over scripts/vendor.sh (feature 007): it FETCHES the harness, shows the
# vendoring PLAN, asks for CONFIRMATION, APPLIES, and CLEANS UP after itself. The motor
# (vendor.sh / engine.py) is untouched. Dependency-free: git + bash/coreutils only.
#
#   curl -fsSL <raw>/bootstrap.sh | bash              # interactive: plan + [y/N] via /dev/tty
#   curl -fsSL <raw>/bootstrap.sh | bash -s -- --yes  # CI: plan + auto-apply
#   ./bootstrap.sh [--yes|-y] [target]                # local; target default '.'
#
# env HARNESS_REPO  clone source (default: canonical HTTPS — a curl|bash newcomer has no SSH key)
# env HARNESS_REF   branch/ref to clone (default: main). Env seams for forks + hermetic tests;
#                   no user-facing --ref (out of scope, tracks main; provenance SHA is the record).
set -u

HARNESS_REPO="${HARNESS_REPO:-https://github.com/marcote/agentic-sdlc.git}"
HARNESS_REF="${HARNESS_REF:-main}"

# --- Parse args: [--yes|-y] [target] ---
ASSUME_YES=0; TARGET="."
while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help) echo "usage: bootstrap.sh [--yes|-y] [target]"; exit 0 ;;
    -*) echo "bootstrap: unknown option $1" >&2; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done

# --- Fail-closed precondition: git required (before any clone; uses only builtins) ---
if ! command -v git >/dev/null 2>&1; then
  echo "bootstrap: git is required (not found on PATH). Install git and retry. Nothing written." >&2
  exit 1
fi

# --- Consent gate (before any clone, so an abort leaves nothing to clean up) ---
# --yes → apply. Else read [y/N] from /dev/tty (stdin is taken by the curl|bash pipe).
# No controlling terminal and no --yes → abort; never write blind.
consent() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  if [ -r /dev/tty ]; then
    local ans=""
    printf 'Apply the harness to %s? [y/N] ' "$TARGET" > /dev/tty
    read -r ans < /dev/tty || return 1
    case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
  fi
  return 1  # no TTY, no --yes
}

# The plan is shown before consent (below), so we clone first — but preconditions above have
# already gated git + the no-TTY-no-yes case, so a bare non-interactive run never reaches here.
if [ "$ASSUME_YES" -eq 0 ] && [ ! -r /dev/tty ]; then
  echo "bootstrap: no terminal to confirm on and no --yes given — aborting (nothing written)." >&2
  echo "  re-run with --yes to apply non-interactively (CI), or from an interactive terminal." >&2
  exit 1
fi

# --- Fetch: shallow clone into a temp dir; trap guarantees cleanup on every exit path ---
tmp="$(mktemp -d 2>/dev/null || mktemp -d -t harness)"
trap 'rm -rf "$tmp"' EXIT INT TERM
echo "bootstrap: fetching harness ($HARNESS_REF) …"
if ! git clone --depth 1 --branch "$HARNESS_REF" "$HARNESS_REPO" "$tmp" >/dev/null 2>&1; then
  echo "bootstrap: git clone failed ($HARNESS_REPO @ $HARNESS_REF). Nothing written." >&2
  exit 1
fi

VENDOR="$tmp/scripts/vendor.sh"
[ -f "$VENDOR" ] || { echo "bootstrap: fetched harness has no scripts/vendor.sh. Nothing written." >&2; exit 1; }

# --- Plan first (007 dry-run is read-only), then confirm, then apply ---
bash "$VENDOR" "$TARGET"

if consent; then
  echo "bootstrap: applying …"
  bash "$VENDOR" --apply "$TARGET"
else
  echo "bootstrap: aborted — nothing written to $TARGET."
  exit 1
fi
