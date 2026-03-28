#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# register-runner.sh
# Run this AFTER GitLab is healthy to register the bundled gitlab-runner.
#
# Steps:
#   1. Open http://localhost:8929 → Admin → CI/CD → Runners → New instance runner
#   2. Copy the registration token shown in the UI
#   3. Run:  bash register-runner.sh <TOKEN>
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

TOKEN="${1:-}"
if [[ -z "${TOKEN}" ]]; then
  echo "Usage: bash register-runner.sh <REGISTRATION_TOKEN>"
  echo ""
  echo "Get the token from:"
  echo "  Admin → CI/CD → Runners → New instance runner"
  exit 1
fi

# Load vars
# Load vars
source .env
GITLAB_HTTP_PORT="${GITLAB_HTTP_PORT:-8929}"
# Use the container name 'gitlab' for internal network communication
GITLAB_CONTAINER_NAME="gitlab"

docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://${GITLAB_CONTAINER_NAME}:${GITLAB_HTTP_PORT}" \
  --token "${TOKEN}" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --description "local-docker-runner" \
  --docker-network-mode "gitlab-net" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"


echo ""
echo "✓ Runner registered. Verify in Admin → CI/CD → Runners."