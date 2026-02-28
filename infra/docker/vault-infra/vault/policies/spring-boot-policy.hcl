# KV v2 — read application secrets
path "secret/data/iown-service/spring" {
  capabilities = ["read"]
}
path "secret/metadata/iown-service/spring" {
  capabilities = ["read", "list"]
}

# Token self-management
path "auth/token/renew-self" { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/revoke-self" { capabilities = ["update"] }