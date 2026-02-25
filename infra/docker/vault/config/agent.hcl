vault {
  address = "http://vault:8200"
  retry {
    num_retries = 5
  }
}

# AppRole auth — credentials injected via environment or secrets file
auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/vault/agent/role_id"     # Written by init script
      secret_id_file_path = "/vault/agent/secret_id"   # Written by init script
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/vault/agent/token"   # Spring Boot reads this token
      mode = 0640
    }
  }
}

# Optional: template rendering — renders secrets to a .env-style file
template {
  source      = "/vault/config/templates/db-secrets.ctmpl"
  destination = "/vault/agent/db.env"
  perms       = 0640
  command     = "echo 'Secrets refreshed'"
}

log_level = "info"