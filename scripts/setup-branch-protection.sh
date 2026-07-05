#!/usr/bin/env bash
# setup-branch-protection — hace REQUIRED el status-check "amendment-gate" en la rama
# protegida (default: main) y prohíbe bypass, de modo que un amendment inválido del North
# Star (cambio de sets pillars/scope sin ADR/schema/suite) no sea mergeable por PR ni
# pusheable directo. Lo corre el OWNER del repo UNA vez (requiere permisos de admin); el
# token del runner de CI no lo aplica. Dependency-free salvo la CLI `gh` (GitHub CLI).
#
# Uso:  scripts/setup-branch-protection.sh [OWNER/REPO] [BRANCH]
#   OWNER/REPO  default: el repo del directorio actual (via `gh repo view`)
#   BRANCH      default: main
set -euo pipefail

command -v gh >/dev/null 2>&1 || { echo "requiere GitHub CLI (gh) autenticada con admin" >&2; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
BRANCH="${2:-main}"
CHECK="amendment-gate"

echo "→ Exigiendo el status-check '$CHECK' en $REPO@$BRANCH (bypass prohibido)…"

# strict=true: la rama debe estar al día con base antes de mergear → el gate corre sobre el
# estado real. enforce_admins=true: ni los admins bypassean (prohíbe push directo saltando el gate).
gh api -X PUT "repos/$REPO/branches/$BRANCH/protection" \
  --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["$CHECK"] },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
JSON

echo "✅ Branch protection aplicada. '$CHECK' es required y enforce_admins=true en $BRANCH."
