#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
#  02-bootstrap.sh  —  Configure Vault (run ONCE after 01-init.sh)
# ══════════════════════════════════════════════════════════════════
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
INIT_FILE="./vault-init-keys.json"
CREDS_DIR="./vault-agent-creds"             # Will be mounted into vault_agent_creds volume

export VAULT_ADDR

if [ ! -f "${INIT_FILE}" ]; then
  echo "ERROR: ${INIT_FILE} not found. Run 01-init.sh first."
  exit 1
fi

# ── 1. Unseal ────────────────────────────────────────────────────
echo "▶ Unsealing Vault..."
mapfile -t KEYS < <(jq -r '.keys[]' "${INIT_FILE}")
THRESHOLD=3

for i in $(seq 0 $((THRESHOLD - 1))); do
  RESULT=$(curl -sf \
    --request POST \
    --data "{\"key\": \"${KEYS[$i]}\"}" \
    "${VAULT_ADDR}/v1/sys/unseal")
  SEALED=$(echo "${RESULT}" | jq -r '.sealed')
  echo "  Key $((i+1))/${THRESHOLD} applied — Sealed: ${SEALED}"
done

ROOT_TOKEN=$(jq -r '.root_token' "${INIT_FILE}")
export VAULT_TOKEN="${ROOT_TOKEN}"

# ── 2. Enable audit log ──────────────────────────────────────────
echo "▶ Enabling audit log..."
vault audit enable file file_path=/vault/logs/audit.log \
  log_raw=false \
  format=json \
  || echo "  (audit already enabled)"

# ── 3. Enable KV v2 secrets engine ──────────────────────────────
echo "▶ Enabling KV v2 at path 'secret'..."
vault secrets enable -path=secret kv-v2 \
  || echo "  (already enabled)"

# ── 4. Write initial secrets ─────────────────────────────────────
echo "▶ Writing initial secrets..."

vault kv put secret/iown-service/spring \
  db_name="nirva" \
  db_username="postgres" \
  db_password="18fc6b68bb51f081436ddeaf9107d91c745d01f9" \
  jwt_secret="$(openssl rand -hex 32)" \
  external_api_key="$(openssl rand -hex 16)"

vault kv put secret/myapp/python \
  db_name="python_db" \
  db_username="python_user" \
  db_password="$(openssl rand -hex 20)" \
  redis_password="$(openssl rand -hex 16)" \
  s3_secret_key="$(openssl rand -hex 24)"

vault kv put secret/myapp/node \
  db_name="node_db" \
  db_username="node_user" \
  db_password="$(openssl rand -hex 20)" \
  session_secret="$(openssl rand -hex 32)" \
  stripe_key="sk_live_placeholder_replace_me"

# ── 5. Write policies ────────────────────────────────────────────
echo "▶ Writing policies..."
vault policy write spring-boot-policy ../policies/spring-boot-policy.hcl
vault policy write python-policy      ../policies/python-policy.hcl
vault policy write node-policy        ../policies/node-policy.hcl

# ── 6. Enable AppRole auth ───────────────────────────────────────
echo "▶ Enabling AppRole auth method..."
vault auth enable approle || echo "  (already enabled)"

# ── 7. Create AppRole roles ──────────────────────────────────────
echo "▶ Creating AppRole roles..."

vault write auth/approle/role/spring-boot-role \
  token_policies="spring-boot-policy" \
  token_ttl="1h" \
  token_max_ttl="4h" \
  token_num_uses=0 \
  secret_id_ttl="8760h" \
  secret_id_num_uses=0

vault write auth/approle/role/python-role \
  token_policies="python-policy" \
  token_ttl="1h" \
  token_max_ttl="4h" \
  token_num_uses=0 \
  secret_id_ttl="8760h" \
  secret_id_num_uses=0

vault write auth/approle/role/node-role \
  token_policies="node-policy" \
  token_ttl="1h" \
  token_max_ttl="4h" \
  token_num_uses=0 \
  secret_id_ttl="8760h" \
  secret_id_num_uses=0

# ── 8. Export AppRole credentials for the Vault Agent ─────────────
# The agent uses ONE role to render ALL service templates.
# In high-security setups, run one agent per service with its own role.
echo "▶ Exporting agent credentials..."

mkdir -p "${CREDS_DIR}"

# We use spring-boot-role for the agent (adjust to a dedicated agent role in real prod)
ROLE_ID=$(vault read -field=role_id auth/approle/role/spring-boot-role/role-id)
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/spring-boot-role/secret-id)

echo "${ROLE_ID}"   > "${CREDS_DIR}/role_id"
echo "${SECRET_ID}" > "${CREDS_DIR}/secret_id"
chmod 600 "${CREDS_DIR}/role_id" "${CREDS_DIR}/secret_id"

echo ""
echo "▶ Copying creds to Docker volume..."
# Copy into the named Docker volume so the agent container picks them up
docker run --rm \
  -v vault_agent_creds:/target \
  -v "$(pwd)/${CREDS_DIR}:/source:ro" \
  busybox sh -c "cp /source/role_id /target/role_id && cp /source/secret_id /target/secret_id"

# ── 9. Revoke root token ──────────────────────────────────────────
#echo ""
#echo "════════════════════════════════════════════════"
#echo "  ▶ Revoking root token (production hardening)"
#echo "════════════════════════════════════════════════"
#vault token revoke "${ROOT_TOKEN}"
#unset VAULT_TOKEN
#echo "  Root token revoked. Use AppRole or operator"
#echo "  break-glass procedure to re-establish access."

echo ""
echo "✅ Bootstrap complete."
echo "   UI → http://localhost:8200/ui"
echo "   Agent creds → ${CREDS_DIR}/"