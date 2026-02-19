{{- define "crdb-redisio.logging.syslog_enabled" -}}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.unifiedLogging.syslog.enabled .Values.global.unifiedLogging.syslog.enabled false) -}}
{{- end -}}
{{- define "crdb-redisio.logging.syslog_protocol" -}}
{{- coalesce .Values.unifiedLogging.syslog.protocol .Values.global.unifiedLogging.syslog.protocol "UDP" -}}
{{- end -}}
{{- define "crdb-redisio.logging.extension" -}}
{{- $result := merge .Values.unifiedLogging.extension .Values.global.unifiedLogging.extension -}}
{{- toJson $result -}}
{{- end -}}
{{- define "crdb-redisio.logging.syslog_timeout" -}}
{{- coalesce .Values.unifiedLogging.syslog.timeout .Values.global.unifiedLogging.syslog.timeout 1000 -}}
{{- end -}}
{{- define "crdb-redisio.logging.syslog_closeReqType" -}}
{{- coalesce .Values.unifiedLogging.syslog.closeReqType .Values.global.unifiedLogging.syslog.closeReqType "GNUTLS_SHUT_RDWR" -}}
{{- end -}}

{{- define "crdb-redisio.logging.vm" -}}
{{- if or (eq (include "crdb-redisio.logging.syslog_enabled" .) "true") (include "crdb-redisio.logging.extension" . | fromJson) }}
- name: flexlog-config
  mountPath: /var/run/flexlog
{{- if and (eq (include "crdb-redisio.logging.syslog_enabled" .) "true") (eq (include "crdb-redisio.logging.syslog_protocol" .) "SSL") }}
- name: flexlog-truststore
  mountPath: /var/run/flexlog-certs/truststore
- name: flexlog-truststore-pass
  mountPath: /var/run/flexlog-certs/truststore-pass
- name: flexlog-keystore
  mountPath: /var/run/flexlog-certs/keystore
- name: flexlog-keystore-pass
  mountPath: /var/run/flexlog-certs/keystore-pass
{{- end }}
{{- end }}
{{- end -}}

{{- define "crdb-redisio.logging.vol" -}}
{{- $top := first . -}}{{- $source := last . -}}
{{- if or (eq (include "crdb-redisio.logging.syslog_enabled" $top) "true") (include "crdb-redisio.logging.extension" $top | fromJson) }}
- name: flexlog-config
  configMap:
    name: {{ include "csf-common-lib.v3.resourceName" (tuple $top "configmap" "flexlog-config") }}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
{{- if and (eq (include "crdb-redisio.logging.syslog_enabled" $top) "true") (eq (include "crdb-redisio.logging.syslog_protocol" $top) "SSL") }}
- name: flexlog-truststore
  secret:
    secretName: {{ coalesce $top.Values.unifiedLogging.syslog.trustStore.secretName $top.Values.global.unifiedLogging.syslog.trustStore.secretName }}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
    items:
    - key: {{ coalesce $top.Values.unifiedLogging.syslog.trustStore.key $top.Values.global.unifiedLogging.syslog.trustStore.key }}
      path: truststore.p12
- name: flexlog-truststore-pass
  secret:
    secretName: {{ coalesce $top.Values.unifiedLogging.syslog.trustStorePassword.secretName $top.Values.global.unifiedLogging.syslog.trustStorePassword.secretName }}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
    items:
    - key: {{ coalesce $top.Values.unifiedLogging.syslog.trustStorePassword.key $top.Values.global.unifiedLogging.syslog.trustStorePassword.key }}
      path: truststore.pass
- name: flexlog-keystore
  secret:
    secretName: {{ coalesce $top.Values.unifiedLogging.syslog.keyStore.secretName $top.Values.global.unifiedLogging.syslog.keyStore.secretName }}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
    items:
    - key: {{ coalesce $top.Values.unifiedLogging.syslog.keyStore.key $top.Values.global.unifiedLogging.syslog.keyStore.key }}
      path: keystore.p12
- name: flexlog-keystore-pass
  secret:
    secretName: {{ coalesce $top.Values.unifiedLogging.syslog.keyStorePassword.secretName $top.Values.global.unifiedLogging.syslog.keyStorePassword.secretName }}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
    items:
    - key: {{ coalesce $top.Values.unifiedLogging.syslog.keyStorePassword.key $top.Values.global.unifiedLogging.syslog.keyStorePassword.key }}
      path: keystore.pass
{{- end }}
{{- end }}
{{- end -}}
