# KV v2 — read application secrets
path "secret/data/myapp/spring" {
  capabilities = ["read"]
}
path "secret/metadata/myapp/spring" {
  capabilities = ["read", "list"]
}

# Token self-management
path "auth/token/renew-self" { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/revoke-self" { capabilities = ["update"] }