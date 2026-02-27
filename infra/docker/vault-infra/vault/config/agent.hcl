# Vault Server Connection
vault {
  address = "http://vault:8200"

  retry {
    num_retries = 5
  }
}

# Authentication: AppRole
# The bootstrap script writes role_id and secret_id to these paths.
auto_auth {
  method "approle" {
    config = {
      role_id_file_path                   = "/vault/agent/creds/role_id"
      secret_id_file_path                 = "/vault/agent/creds/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  # Primary token sink — Spring Boot reads this if using Spring Cloud Vault
  sink "file" {
    config = {
      path = "/vault/agent/sinks/token"
      mode = 0640
    }
  }
}

# Caching
# Agent caches tokens and leases so services don't hit Vault directly.
cache {
  use_auto_auth_token = true
}

# Start a local proxy so services can call http://vault-agent:8100
# instead of Vault directly.
listener "tcp" {
  address     = "0.0.0.0:8100"
  tls_disable = true
}

# Template: Spring Boot secrets
template {
  source      = "/vault/templates/spring-app-secrets.ctmpl"
  destination = "/vault/agent/sinks/spring/secrets.env"
  perms       = 0640

  # Restart or signal your app here if you want hot-reload on rotation.
  # command = "curl -s -X POST http://spring-app:8080/actuator/refresh"

  error_on_missing_key = true
}

# Template: Python secrets
template {
  source      = "/vault/templates/python-secrets.ctmpl"
  destination = "/vault/agent/sinks/python/secrets.env"
  perms       = 0640

  error_on_missing_key = true
}

# Template: Node.js secrets
template {
  source      = "/vault/templates/node-secrets.ctmpl"
  destination = "/vault/agent/sinks/node/secrets.env"
  perms       = 0640

  error_on_missing_key = true
}

log_level = "info"
log_file  = "/vault/logs/agent.log"

# vault {
#   address = "http://vault:8200"
#   retry {
#     num_retries = 5
#   }
# }
#
# # AppRole auth — credentials injected via environment or secrets file
# auto_auth {
#   method "approle" {
#     config = {
#       role_id_file_path   = "/vault/agent/role_id"     # Written by init script
#       secret_id_file_path = "/vault/agent/secret_id"   # Written by init script
#       remove_secret_id_file_after_reading = false
#     }
#   }
#
#   sink "file" {
#     config = {
#       path = "/vault/agent/token"   # Spring Boot reads this token
#       mode = 0640
#     }
#   }
# }
#
# # Optional: template rendering — renders secrets to a .env-style file
# template {
#   source      = "/vault/config/templates/db-secrets.ctmpl"
#   destination = "/vault/agent/db.env"
#   perms       = 0640
#   command     = "echo 'Secrets refreshed'"
# }
#
# log_level = "info"