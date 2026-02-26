#!/bin/sh
set -eu

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
INIT_OUTPUT_FILE="${INIT_OUTPUT_FILE:-./vault-init-keys.json}"    # STORE THIS SECURELY
AGENT_DIR="${AGENT_DIR:-./vault/agent}"

echo "──────────────────────────────────────────"
echo " Vault Init & Bootstrap"
echo "──────────────────────────────────────────"

# ── 1. Wait for Vault to be reachable ──────────
until curl -sf "${VAULT_ADDR}/v1/sys/health" > /dev/null 2>&1; do
  echo "Waiting for Vault to start..."
  sleep 3
done

# ── 2. Initialise (only if not already initialised) ──
STATUS=$(curl -s "${VAULT_ADDR}/v1/sys/init" | jq -r '.initialized')

if [ "$STATUS" = "false" ]; then
  echo "Initialising Vault..."
  # Try to use vault operator init if available (preferred over raw curl for better output)
  if command -v vault >/dev/null 2>&1; then
    vault operator init -key-shares=5 -key-threshold=3 -format=json > "${INIT_OUTPUT_FILE}"
    cat "${INIT_OUTPUT_FILE}" | jq .
  else
    curl -sf \
      --request POST \
      --data '{"secret_shares": 5, "secret_threshold": 3}' \
      "${VAULT_ADDR}/v1/sys/init" | tee "${INIT_OUTPUT_FILE}" | jq .
  fi

  echo ""
  echo "⚠️  CRITICAL: Unseal keys and root token saved to ${INIT_OUTPUT_FILE}"
  echo "⚠️  Move this file to a secure location NOW. Do NOT commit it to git."
else
  echo "Vault already initialised."
fi

# ── 3. Unseal ────────────────────────────────────
ROOT_TOKEN=$(jq -r '.root_token' "${INIT_OUTPUT_FILE}")
KEYS=$(jq -r '.keys[]' "${INIT_OUTPUT_FILE}" | head -3)  # Need threshold (3) of 5

echo "Unsealing Vault..."
if command -v vault >/dev/null 2>&1; then
  for key in $KEYS; do
    vault operator unseal "$key"
  done
else
  for key in $KEYS; do
    curl -sf \
      --request POST \
      --data "{\"key\": \"${key}\"}" \
      "${VAULT_ADDR}/v1/sys/unseal" | jq '.sealed'
  done
fi

export VAULT_TOKEN="${ROOT_TOKEN}"
export VAULT_ADDR="${VAULT_ADDR}"

# ── 4. Enable audit log ──────────────────────────
echo "Enabling audit log..."
vault audit enable file file_path=/vault/logs/audit.log || true

# ── 5. Enable KV v2 secrets engine ──────────────
echo "Enabling KV v2 secrets engine..."
vault secrets enable -path=secret kv-v2 || true

# ── 6. Write your application secrets ────────────
echo "Writing application secrets..."
vault kv put secret/myapp/database \
  db_name="${POSTGRES_DB:-myapp}" \
  username="${POSTGRES_USER:-appuser}" \
  password="${POSTGRES_PASSWORD:-changeme}"

vault kv put secret/myapp/app \
  jwt_secret="$(openssl rand -hex 32)" \
  api_key="$(openssl rand -hex 16)"

# ── 7. Create Spring Boot policy ─────────────────
echo "Creating Spring Boot policy..."
vault policy write spring-boot-policy /vault/policies/spring-boot-policy.hcl

# ── 8. Enable AppRole auth ───────────────────────
echo "Enabling AppRole auth..."
vault auth enable approle || true

vault write auth/approle/role/spring-boot-role \
  token_policies="spring-boot-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=720h \
  secret_id_num_uses=0          # 0 = unlimited uses

# ── 9. Export AppRole credentials for Vault Agent ──
# Note: AGENT_DIR should have correct permissions (set by vault-data-init)
mkdir -p "${AGENT_DIR}" || true

ROLE_ID=$(vault read -field=role_id auth/approle/role/spring-boot-role/role-id)
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/spring-boot-role/secret-id)

echo "${ROLE_ID}"   > "${AGENT_DIR}/role_id"
echo "${SECRET_ID}" > "${AGENT_DIR}/secret_id"
chmod 600 "${AGENT_DIR}/role_id" "${AGENT_DIR}/secret_id"

echo ""
echo "✅ Vault bootstrap complete."
echo "   UI available at: http://localhost:8200/ui"
echo "   Login with root token from: ${INIT_OUTPUT_FILE}"
echo ""
echo "   AppRole credentials written to ${AGENT_DIR}/"
echo "   Root token (first login only): ${ROOT_TOKEN}"