{{/* vim: set filetype=mustache: */}}

{{/*
* Variables injected into the top-level scope
* NOTE: Cannot be used in _values-compat
*
* .cmgr_enabled     - If cert-manager is enabled
* .syslogCommonIssuer - If a common certManager issuer will be created for syslog
* .is_test_release  - Assumed to be a test release where various checks can be disabled (e.g., lint, test pipelines, etc.)
* .errors           - Error Messages to output (NOTES).  If populated, render will fail
* .warnings         - Warning Messages to output (NOTES).  Render will not fail.
*
*/}}
{{- define "cmdb.variables" -}}
{{- $_ := set . "cmgr_enabled" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled true)) "true") -}}
{{- $_ := set . "is_test_release" (or (and (not $.Release.IsInstall) (not $.Release.IsUpgrade)) (has $.Release.Name (list "test-release" "csf" "RELEASE-NAME" "release-name"))) -}}
{{- $_ := set . "errors" (list) -}}
{{- $_ := set . "warnings" (list) -}}

{{/* determine if a self-signed issuer should be created for syslog tls */}}
{{- $root := . -}}
{{- $_ := set . "syslogCommonIssuer" (and .cmgr_enabled (not (coalesce .Values.global.certManager.issuerRef.name .Values.certManager.issuerRef.name))) -}}
{{- range (list .Values.mariadb ((eq (include "cmdb.has_maxscale" .) "true") | ternary .Values.maxscale nil ) (( ne (.Values.cluster_type) "simplex") | ternary .Values.admin nil )) -}}
  {{- $workload := . -}}
  {{- $_ := set $root "syslogCommonIssuer" (and $root.syslogCommonIssuer (eq (include "cmdb-logging.syslog_enabled" (tuple $root $workload)) "true") (eq (include "cmdb-logging.syslog_protocol" (tuple $root $workload)) "SSL")) -}}
  {{- $_ := set $root "syslogCommonIssuer" (and $root.syslogCommonIssuer (eq (include "cmdb-logging.tks_empty" (tuple $root $workload)) "true")) -}}
  {{- $_ := set $root "syslogCommonIssuer" (and $root.syslogCommonIssuer (not (coalesce $workload.unifiedLogging.syslog.certificate.issuerRef.name $workload.unifiedLogging.syslog.tls.secretRef.name))) -}}
{{- end -}}
{{- end -}}

{{- define "cmdb.init" -}}
{{ include "cmdb.values-compat" . -}}
{{ include "cmdb.variables" . -}}
{{- end -}}
