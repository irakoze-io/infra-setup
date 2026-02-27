#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  03-unseal.sh  —  Unseal after a restart
#  NOTE: Replace this with AWS KMS / GCP CKMS auto-unseal
#        for true unattended production operation.
# ══════════════════════════════════════════════════════════════
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
INIT_FILE="./vault-init-keys.json"

export VAULT_ADDR

if [ ! -f "${INIT_FILE}" ]; then
  echo "ERROR: ${INIT_FILE} not found."
  exit 1
fi

echo "▶ Waiting for Vault to start..."
until curl -sf "${VAULT_ADDR}/v1/sys/health" > /dev/null 2>&1; do
  sleep 2
done

SEALED=$(curl -sf "${VAULT_ADDR}/v1/sys/seal-status" | jq -r '.sealed')

if [ "${SEALED}" == "false" ]; then
  echo "✅ Vault is already unsealed."
  exit 0
fi

echo "▶ Unsealing..."
mapfile -t KEYS < <(jq -r '.keys[]' "${INIT_FILE}")

for i in 0 1 2; do   # Apply 3 of the 5 keys (threshold)
  RESULT=$(curl -sf \
    --request POST \
    --data "{\"key\": \"${KEYS[$i]}\"}" \
    "${VAULT_ADDR}/v1/sys/unseal")
  echo "  Key $((i+1))/3 — Sealed: $(echo "${RESULT}" | jq -r '.sealed')"
done

echo "✅ Done."