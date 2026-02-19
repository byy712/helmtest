{{/* vim: set filetype=mustache: */}}
{{- define "cmdb-logging.syslog_enabled" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.unifiedLogging.syslog.enabled $root.Values.global.unifiedLogging.syslog.enabled false) -}}
{{- end -}}

{{- define "cmdb-logging.loglevel" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- coalesce $workload.unifiedLogging.logLevel $root.Values.global.unifiedLogging.logLevel "INFO" -}}
{{- end -}}

{{- define "cmdb-logging.syslog_protocol" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- coalesce $workload.unifiedLogging.syslog.protocol $root.Values.global.unifiedLogging.syslog.protocol "UDP" -}}
{{- end -}}

{{- define "cmdb-logging.syslog_timeout" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- coalesce $workload.unifiedLogging.syslog.timeout $root.Values.global.unifiedLogging.syslog.timeout 1000 -}}
{{- end -}}

{{- define "cmdb-logging.syslog_closeReqType" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- coalesce $workload.unifiedLogging.syslog.closeReqType $root.Values.global.unifiedLogging.syslog.closeReqType "GNUTLS_SHUT_RDWR" -}}
{{- end -}}

{{- define "cmdb-logging.extension" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- $result := merge $workload.unifiedLogging.extension $root.Values.global.unifiedLogging.extension -}}
{{- toJson $result -}}
{{- end -}}

{{/* true if syslog is enabled for SSL with all trustStore/keyStore/secretName are empty */}}
{{- define "cmdb-logging.tks_empty" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- $keystoreSecName := coalesce $workload.unifiedLogging.syslog.keyStore.secretName $root.Values.global.unifiedLogging.syslog.keyStore.secretName -}}
{{- $keystorePasswordSecName := coalesce $workload.unifiedLogging.syslog.keyStorePassword.secretName $root.Values.global.unifiedLogging.syslog.keyStorePassword.secretName -}}
{{- $truststoreSecName := coalesce $workload.unifiedLogging.syslog.trustStore.secretName $root.Values.global.unifiedLogging.syslog.trustStore.secretName -}}
{{- $truststorePasswordSecName := coalesce $workload.unifiedLogging.syslog.trustStorePassword.secretName $root.Values.global.unifiedLogging.syslog.trustStorePassword.secretName -}}
{{- if (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) }}
  {{- if (or $keystoreSecName $keystorePasswordSecName $truststoreSecName $truststorePasswordSecName) -}}
    false
  {{- else -}}
    true
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "cmdb-logging.env" -}}
- name: FLEXLOG_PROP_PATH
  value: "/etc/unified-logging/cpp-api/log4cxx.property"
{{- end -}}

{{- define "cmdb-logging.vm" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- $certmanEnabled := (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) }}
{{- if (include "cmdb-logging.extension" (tuple $root $workload) | fromJson) }}
- name: uniflogging-ext
  mountPath: /var/run/flexlog
{{- end }}
{{- include "csf-common-lib.v2.unifiedLogging.volumeMounts" (tuple $root $workload $certmanEnabled) -}}
{{- end }}

{{- define "cmdb-logging.vol" -}}
{{- $root := (index . 0 ) }}
{{- $workload := (index . 1 ) }}
{{- $optional := (index . 2 ) }}
{{- $certmanEnabled := (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) }}
{{- $certificateSecretName := (include "csf-common-lib.v3.certificateSecretName" (tuple $root $workload.unifiedLogging.syslog))}}
{{/* step 1. generate uniflogging-conf volume with optional support for jobs */}}
{{- $u_vols := include "csf-common-lib.v3.unifiedLogging.volumes" (tuple $root $workload $certmanEnabled $certificateSecretName) | fromYamlArray -}}
{{- range $u_vols -}}
  {{- if eq $optional "true" -}}
    {{- if hasKey . "secret" -}}
      {{- $_ := set .secret "optional" true -}}
    {{- else -}}
      {{- $_ := set .configMap "optional" true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* step 2. generate uniflogging-conf volume */}}
{{- $extvol := dict "name" "uniflogging-ext" "configMap" (dict "name" (include "csf-common-lib.v3.resourceName" ( tuple $root "ConfigMap" (printf "log4cxx-%s" $workload.nameSuffix))) "items" (list (dict "key" "extension" "path" "extension"))) -}}
{{- if eq $optional "true" -}}
  {{- $_ := set $extvol.configMap "optional" true -}}
{{- end -}}
{{/* step 3. output the volumes */}}
{{- if (include "cmdb-logging.extension" (tuple $root $workload) | fromJson) }}
    {{- toYaml ( append $u_vols $extvol ) | nindent 0 -}}
{{- else -}}
    {{- toYaml $u_vols | nindent 0 -}}
 {{- end -}}
{{- end -}}

