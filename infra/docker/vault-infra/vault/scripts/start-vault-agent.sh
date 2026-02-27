#!/bin/sh
set -eu

AGENT_DIR="${AGENT_DIR:-/vault/agent}"
ROLE_ID_FILE="${ROLE_ID_FILE:-${AGENT_DIR}/role_id}"
SECRET_ID_FILE="${SECRET_ID_FILE:-${AGENT_DIR}/secret_id}"
WAIT_INTERVAL_SECONDS="${WAIT_INTERVAL_SECONDS:-5}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-0}" # 0 = wait forever

mkdir -p "${AGENT_DIR}"

hydrate_from_env() {
  # Allow env-based injection for platforms where init job cannot share files.
  if [ ! -s "${ROLE_ID_FILE}" ] && [ -n "${VAULT_ROLE_ID:-}" ]; then
    printf '%s\n' "${VAULT_ROLE_ID}" > "${ROLE_ID_FILE}"
  fi

  if [ ! -s "${SECRET_ID_FILE}" ] && [ -n "${VAULT_SECRET_ID:-}" ]; then
    printf '%s\n' "${VAULT_SECRET_ID}" > "${SECRET_ID_FILE}"
  fi

  chmod 600 "${ROLE_ID_FILE}" "${SECRET_ID_FILE}" 2>/dev/null || true
  chown 100:1000 "${ROLE_ID_FILE}" "${SECRET_ID_FILE}" 2>/dev/null || true
}

waited=0
hydrate_from_env
while [ ! -s "${ROLE_ID_FILE}" ] || [ ! -s "${SECRET_ID_FILE}" ]; do
  if [ "${waited}" -eq 0 ]; then
    echo "WARN: AppRole files not ready. Waiting for ${ROLE_ID_FILE} and ${SECRET_ID_FILE}, or env vars VAULT_ROLE_ID/VAULT_SECRET_ID." >&2
  fi

  if [ "${WAIT_TIMEOUT_SECONDS}" -gt 0 ] && [ "${waited}" -ge "${WAIT_TIMEOUT_SECONDS}" ]; then
    echo "ERROR: timed out waiting ${WAIT_TIMEOUT_SECONDS}s for AppRole credentials." >&2
    exit 1
  fi

  sleep "${WAIT_INTERVAL_SECONDS}"
  waited=$((waited + WAIT_INTERVAL_SECONDS))
  hydrate_from_env
done

exec vault agent -config=/vault/config/agent.hcl
