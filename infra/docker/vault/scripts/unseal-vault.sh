#!/bin/sh
set -eu

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
INIT_OUTPUT_FILE="${INIT_OUTPUT_FILE:-./vault-init-keys.json}"

if [ ! -f "${INIT_OUTPUT_FILE}" ]; then
  echo "ERROR: ${INIT_OUTPUT_FILE} not found. Run init-vault.sh first."
  exit 1
fi

echo "Unsealing Vault..."
KEYS=$(jq -r '.keys[]' "${INIT_OUTPUT_FILE}" | head -3)

for key in $KEYS; do
  SEALED=$(curl -sf \
    --request POST \
    --data "{\"key\": \"${key}\"}" \
    "${VAULT_ADDR}/v1/sys/unseal" | jq -r '.sealed')
  echo "Sealed: ${SEALED}"
done

echo "Done."