#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  01-init.sh  —  Initialise Vault (run ONCE, never again)
# ══════════════════════════════════════════════════════════════
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
OUTPUT_FILE="./vault-init-keys.json"

export VAULT_ADDR

echo "▶ Waiting for Vault to be reachable..."
until curl -sf "${VAULT_ADDR}/v1/sys/health" > /dev/null 2>&1; do
  sleep 2
done

INITIALISED=$(curl -sf "${VAULT_ADDR}/v1/sys/init" | jq -r '.initialized')

if [ "${INITIALISED}" == "true" ]; then
  echo "⚠  Vault is already initialised. Skipping."
  exit 0
fi

echo "▶ Initialising Vault..."
curl -sf \
  --request POST \
  --data '{
    "secret_shares": 5,
    "secret_threshold": 3
  }' \
  "${VAULT_ADDR}/v1/sys/init" \
  | tee "${OUTPUT_FILE}" \
  | jq '{ root_token: .root_token, key_count: (.keys | length) }'

echo ""
echo "════════════════════════════════════════════════════"
echo "  ⚠  CRITICAL — READ THIS"
echo "════════════════════════════════════════════════════"
echo "  Unseal keys and root token saved to: ${OUTPUT_FILE}"
echo ""
echo "  DO THIS NOW:"
echo "  1. Copy the 5 unseal keys to separate, secure locations"
echo "     (password manager, encrypted USB, HSM, etc.)"
echo "  2. Store the root token in a break-glass secrets vault"
echo "  3. Delete ${OUTPUT_FILE} from this machine"
echo "  4. NEVER commit this file to git"
echo "════════════════════════════════════════════════════"