# ── Storage: Raft (integrated, no external dependencies) ──────────
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-01"

  # Retain performance_multiplier at default for single-node
  # Add retry_join blocks here for each peer in a 3/5-node HA cluster
}

# ── Listeners ─────────────────────────────────────────────────────
listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"

  # ── TLS ── (PRODUCTION: uncomment and provide real certs)
  # tls_cert_file      = "/vault/tls/vault.crt"
  # tls_key_file       = "/vault/tls/vault.key"
  # tls_client_ca_file = "/vault/tls/ca.crt"
  # tls_min_version    = "tls13"

  # ── Remove in production when TLS is enabled ──
  tls_disable = "true"

  # Unauthenticated health endpoint (for Docker healthcheck)
  telemetry {
    unauthenticated_metrics_access = false
  }
}

# ── UI ────────────────────────────────────────────────────────────
ui = true

# ── Cluster ───────────────────────────────────────────────────────
api_addr     = "http://vault:8200"     # Use https:// once TLS is live
cluster_addr = "https://vault:8201"

# ── Lease durations ───────────────────────────────────────────────
default_lease_ttl = "168h"    # 7 days
max_lease_ttl     = "720h"    # 30 days

# ── Logging ───────────────────────────────────────────────────────
log_level             = "info"
log_format            = "json"
log_file              = "/vault/logs/vault.log"
log_rotate_bytes      = 104857600   # 100 MB
log_rotate_max_files  = 10

# ── Telemetry ─────────────────────────────────────────────────────
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = false
}

# ── Disable raw endpoint (hardening) ──────────────────────────────
raw_storage_endpoint = false

# ── Disable core dumps ────────────────────────────────────────────
disable_mlock = false    # false = mlock IS enforced (good); needs IPC_LOCK cap
/*
# # ── UI ─────────────────────────────────────────
# ui = true
#
# # Required as of Vault 1.20. In Docker, set true so memory isn't locked (avoids OOM with limited container RAM).
# disable_mlock = true
#
# # ── Storage (Raft — integrated, no external deps) ──
# storage "raft" {
#   path    = "/vault/data"
#   node_id = "vault-node-01"
#
#   # Tuning for a single-node setup (scale to 3/5 nodes for HA)
#   retry_join {
#     leader_api_addr = "http://vault:8200"
#   }
# }
#
# # ── Listener ────────────────────────────────────
# # For production: replace tls_disable with real certs (see TLS note below)
# listener "tcp" {
#   address       = "0.0.0.0:8200"
#   cluster_address = "0.0.0.0:8201"
#
#   # ── TLS (PRODUCTION — uncomment and provide certs) ──────────────
#   # tls_cert_file = "/vault/certs/vault.crt"
#   # tls_key_file  = "/vault/certs/vault.key"
#   # tls_min_version = "tls13"
#
#   # ── Dev/staging only: remove in production ──────────────────────
#   tls_disable = "true"
#
#   # Telemetry UI
#   telemetry {
#     unauthenticated_metrics_access = false
#   }
# }
#
# # ── Cluster ─────────────────────────────────────
# api_addr     = "http://vault:8200"       # Change to https:// when TLS is enabled
# cluster_addr = "https://vault:8201"
#
# # ── Lease TTLs ──────────────────────────────────
# max_lease_ttl     = "768h"     # 32 days max
# default_lease_ttl = "168h"     # 7 days default
#
# # ── Logging ─────────────────────────────────────
# log_level  = "info"
# log_format = "json"
# log_file   = "/vault/logs/vault.log"
# log_rotate_max_files = 5
#
# # ── Audit (REQUIRED in production) ──────────────
# # Enabled via CLI after init — see init-vault.sh
# # audit "file" {
# #   path = "/vault/logs/audit.log"
# # }
#
# # ── Telemetry ────────────────────────────────────
# telemetry {
#   prometheus_retention_time = "30s"
#   disable_hostname          = false
# }
 */