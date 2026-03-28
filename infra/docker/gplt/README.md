# GPLT Stack (Grafana + Prometheus + Loki + Tempo)

This stack is a stable local/dev foundation with production-oriented defaults:

- Pinned image versions (no `latest` drift)
- Persistent volumes for all stateful services
- Log and trace retention configured
- Grafana datasources auto-provisioned
- OpenTelemetry Collector included for app integration

## Services

- Grafana: <http://localhost:3000>
- Prometheus: <http://localhost:9090>
- Loki: <http://localhost:3100>
- Tempo: <http://localhost:3200>
- OTEL Collector:
  - OTLP gRPC: `localhost:4319`
  - OTLP HTTP: `http://localhost:4320`

## Start

```bash
cd infra/docker/gplt
cp .env.example .env
docker compose --env-file .env up -d
```

## Stop

```bash
docker compose down
```

## Integrate Spring Boot

Use OpenTelemetry Java agent (recommended for quick start):

```bash
export OTEL_SERVICE_NAME=my-spring-service
export OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev,service.namespace=backend
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4320
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_TRACES_EXPORTER=otlp
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
```

If you also expose Actuator metrics, Prometheus already has:

- `http://host.docker.internal:8080/actuator/prometheus`

Adjust target in `prometheus/prometheus.yml` if your port/path differs.

## Integrate .NET Web API

Set environment variables:

```bash
OTEL_SERVICE_NAME=my-dotnet-api
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev,service.namespace=backend
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4320
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

In your app, enable OTEL tracing/metrics/logging with OTLP exporter.

If you expose Prometheus endpoint directly from .NET, default target is:

- `http://host.docker.internal:9464/metrics`

## Useful checks

```bash
docker compose ps
docker compose logs -f otel-collector
docker compose logs -f tempo
docker compose logs -f loki
```

## Notes

- Default Grafana credentials come from `.env`.
- This is safe for dev and staging-like environments.
- For internet-facing production: add TLS, authn/authz, secrets manager, object storage for Loki/Tempo, and HA topology.
