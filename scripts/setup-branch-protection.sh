#!/usr/bin/env bash
# setup-branch-protection — makes the "amendment-gate" status-check REQUIRED on the
# protected branch (default: main) and prohibits bypass, so that an invalid North Star
# amendment (pillars/scope sets change without ADR/schema/suite) is neither mergeable
# via PR nor pushable directly. Run once by the repo OWNER (requires admin permissions);
# the CI runner token does not apply it. Dependency-free except for the `gh` CLI (GitHub CLI).
#
# Usage:  scripts/setup-branch-protection.sh [OWNER/REPO] [BRANCH]
#   OWNER/REPO  default: current directory's repo (via `gh repo view`)
#   BRANCH      default: main
set -euo pipefail

command -v gh >/dev/null 2>&1 || { echo "requires authenticated GitHub CLI (gh) with admin" >&2; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
BRANCH="${2:-main}"
CHECK="amendment-gate"

echo "→ Making status-check '$CHECK' required on $REPO@$BRANCH (bypass prohibited)…"

# strict=true: branch must be up to date with base before merging → gate runs on the
# real state. enforce_admins=true: even admins cannot bypass (prevents direct pushes skipping the gate).
gh api -X PUT "repos/$REPO/branches/$BRANCH/protection" \
  --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["$CHECK"] },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
JSON

echo "✅ Branch protection applied. '$CHECK' is required and enforce_admins=true on $BRANCH."
