# ── UI ─────────────────────────────────────────
ui = true

# ── Storage (Raft — integrated, no external deps) ──
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-01"

  # Tuning for a single-node setup (scale to 3/5 nodes for HA)
  retry_join {
    leader_api_addr = "http://vault:8200"
  }
}

# ── Listener ────────────────────────────────────
# For production: replace tls_disable with real certs (see TLS note below)
listener "tcp" {
  address       = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"

  # ── TLS (PRODUCTION — uncomment and provide certs) ──────────────
  # tls_cert_file = "/vault/certs/vault.crt"
  # tls_key_file  = "/vault/certs/vault.key"
  # tls_min_version = "tls13"

  # ── Dev/staging only: remove in production ──────────────────────
  tls_disable = "true"

  # Telemetry UI
  telemetry {
    unauthenticated_metrics_access = false
  }
}

# ── Cluster ─────────────────────────────────────
api_addr     = "http://vault:8200"       # Change to https:// when TLS is enabled
cluster_addr = "https://vault:8201"

# ── Lease TTLs ──────────────────────────────────
max_lease_ttl     = "768h"     # 32 days max
default_lease_ttl = "168h"     # 7 days default

# ── Logging ─────────────────────────────────────
log_level  = "info"
log_format = "json"
log_file   = "/vault/logs/vault.log"
log_rotate_max_files = 5

# ── Audit (REQUIRED in production) ──────────────
# Enabled via CLI after init — see init-vault.sh
# audit "file" {
#   path = "/vault/logs/audit.log"
# }

# ── Telemetry ────────────────────────────────────
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = false
}