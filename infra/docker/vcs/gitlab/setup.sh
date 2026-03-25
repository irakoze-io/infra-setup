#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# GitLab Local Docker – One-shot Setup Helper
# Run this once before your first `docker compose up -d`.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── 1. Load variables from .env ───────────────────────────────────────────────
if [[ ! -f .env ]]; then
  echo "ERROR: .env file not found. Run this script from the directory that"
  echo "       contains .env and docker-compose.yml."
  exit 1
fi
# shellcheck disable=SC1091
source .env
GITLAB_HOME="${GITLAB_HOME:-/srv/gitlab}"

# ── 2. Create persistent directories ─────────────────────────────────────────
echo "→ Creating GitLab data directories under ${GITLAB_HOME} …"
sudo mkdir -p "${GITLAB_HOME}/config"
sudo mkdir -p "${GITLAB_HOME}/logs"
sudo mkdir -p "${GITLAB_HOME}/data"
sudo mkdir -p "${GITLAB_HOME}/runner/config"
echo "  ✓ Directories created."

# ── 3. Persist GITLAB_HOME for future shell sessions ──────────────────────────
PROFILE_FILE="${HOME}/.bash_profile"
if ! grep -q "GITLAB_HOME" "${PROFILE_FILE}" 2>/dev/null; then
  echo "" >> "${PROFILE_FILE}"
  echo "# GitLab Docker" >> "${PROFILE_FILE}"
  echo "export GITLAB_HOME=${GITLAB_HOME}" >> "${PROFILE_FILE}"
  echo "  ✓ GITLAB_HOME exported in ${PROFILE_FILE}"
fi

# ── 4. Bring up the stack ─────────────────────────────────────────────────────
echo ""
echo "→ Starting GitLab (this will pull images if not cached) …"
docker compose up -d

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitLab is starting up."
echo "  First boot can take 3–5 minutes. Watch progress with:"
echo ""
echo "    docker compose logs -f gitlab"
echo ""
echo "  When healthy, open:"
echo "    http://localhost:${GITLAB_HTTP_PORT:-8929}"
echo ""
echo "  Retrieve the initial root password with:"
echo "    docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password"
echo ""
echo "  ⚠  That password file is auto-deleted 24 hours after first start."
echo "     Change the root password immediately in the UI."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"