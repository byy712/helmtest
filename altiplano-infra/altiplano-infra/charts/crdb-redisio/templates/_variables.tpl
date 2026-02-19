{{/*
* Variables injected into the top-level scope
* NOTE: Cannot be used in _values-compat
*
* .sentinel_enabled - If sentinel is enabled
* .redis_cluster    - If using Redis Cluster (topology)
*
* .server_tls       - If TLS is enabled for the (Redis) server workload
* .sentinel_tls     - If TLS is enabled for the (Redis) sentinel workload
* .client_tls       - If mTLS is enabled for (Redis) clients
*
* .cmgr_enabled     - If cert-manager is enabled
*
*/}}
{{- define "crdb-redisio.variables" -}}
{{- $_ := set . "sentinel_enabled" (and .Values.sentinel.enabled (gt (int .Values.server.count) 1)) -}}
{{- $_ := set . "redis_cluster" .Values.cluster.enabled -}}
{{- $_ := set . "server_tls" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") -}}
{{- $_ := set . "sentinel_tls" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.sentinel.tls.enabled .server_tls false)) "true") -}}
{{- $_ := set . "client_tls" .Values.tls.authClients -}}
{{- $_ := set . "cmgr_enabled" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled true)) "true") -}}
{{- end -}}