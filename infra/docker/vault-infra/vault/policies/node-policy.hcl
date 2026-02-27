path "secret/data/myapp/node" { capabilities = ["read"] }
path "secret/metadata/myapp/node" { capabilities = ["read", "list"] }
path "auth/token/renew-self" { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/revoke-self" { capabilities = ["update"] }