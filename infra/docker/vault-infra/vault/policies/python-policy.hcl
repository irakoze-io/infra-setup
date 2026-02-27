path "secret/data/myapp/python" { capabilities = ["read"] }
path "secret/metadata/myapp/python" { capabilities = ["read", "list"] }
path "auth/token/renew-self" { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/revoke-self" { capabilities = ["update"] }