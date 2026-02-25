# Read-only access to application secrets
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

# Allow reading secret metadata
path "secret/metadata/myapp/*" {
  capabilities = ["read", "list"]
}

# Allow the app to renew its own token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow the app to look up its own token info
path "auth/token/lookup-self" {
  capabilities = ["read"]
}