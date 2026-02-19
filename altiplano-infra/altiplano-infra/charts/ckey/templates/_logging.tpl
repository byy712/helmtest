{{/* vim: set filetype=mustache: */}}
{{- define "ckey.syslogEnabled" -}}
{{- (and (hasKey .Values.unifiedLogging.syslog "enabled") (kindIs "bool" .Values.unifiedLogging.syslog.enabled)) | ternary .Values.unifiedLogging.syslog.enabled (.Values.global.unifiedLogging.syslog.enabled | default false) -}}
{{- end -}}

{{- define "ckey.syslogProtocol" -}}
{{- coalesce .Values.unifiedLogging.syslog.protocol .Values.global.unifiedLogging.syslog.protocol "UDP" -}}
{{- end -}}

{{- define "ckey.syslogVolumeMount" -}}
{{- if and (eq (include "ckey.syslogEnabled" .) "true") (eq (include "ckey.syslogProtocol" .) "SSL") }}
{{- if or (.Values.unifiedLogging.syslog.trustStore.secretName) (.Values.global.unifiedLogging.syslog.trustStore.secretName) }}
- name: syslog-truststore
  mountPath: /tmp/syslog-certs/truststore
- name: syslog-truststore-pass
  mountPath: /tmp/syslog-certs/truststore-pass
{{- end }}
{{- if or (.Values.unifiedLogging.syslog.keyStore.secretName) (.Values.global.unifiedLogging.syslog.keyStore.secretName) }}
- name: syslog-keystore
  mountPath: /tmp/syslog-certs/keystore
- name: syslog-keystore-pass
  mountPath: /tmp/syslog-certs/keystore-pass
{{- end }}
{{- end }}
{{- end -}}

{{- define "ckey.syslogVolume" -}}
{{- if and (eq (include "ckey.syslogEnabled" .) "true") (eq (include "ckey.syslogProtocol" .) "SSL") }}
{{- if or (.Values.unifiedLogging.syslog.trustStore.secretName) (.Values.global.unifiedLogging.syslog.trustStore.secretName) }}
- name: syslog-truststore
  secret:
    secretName: {{ coalesce .Values.unifiedLogging.syslog.trustStore.secretName .Values.global.unifiedLogging.syslog.trustStore.secretName }}
    items:
    - key: {{ coalesce .Values.unifiedLogging.syslog.trustStore.key .Values.global.unifiedLogging.syslog.trustStore.key }}
      path: truststore.jks
- name: syslog-truststore-pass
  secret:
    secretName: {{ coalesce .Values.unifiedLogging.syslog.trustStorePassword.secretName .Values.global.unifiedLogging.syslog.trustStorePassword.secretName }}
    items:
    - key: {{ coalesce .Values.unifiedLogging.syslog.trustStorePassword.key .Values.global.unifiedLogging.syslog.trustStorePassword.key }}
      path: truststore.pass
{{- end }}
{{- if or (.Values.unifiedLogging.syslog.keyStore.secretName) (.Values.global.unifiedLogging.syslog.keyStore.secretName) }}
- name: syslog-keystore
  secret:
    secretName: {{ coalesce .Values.unifiedLogging.syslog.keyStore.secretName .Values.global.unifiedLogging.syslog.keyStore.secretName }}
    items:
    - key: {{ coalesce .Values.unifiedLogging.syslog.keyStore.key .Values.global.unifiedLogging.syslog.keyStore.key }}
      path: keystore.jks
- name: syslog-keystore-pass
  secret:
    secretName: {{ coalesce .Values.unifiedLogging.syslog.keyStorePassword.secretName .Values.global.unifiedLogging.syslog.keyStorePassword.secretName }}
    items:
    - key: {{ coalesce .Values.unifiedLogging.syslog.keyStorePassword.key .Values.global.unifiedLogging.syslog.keyStorePassword.key }}
      path: keystore.pass
{{- end }}
{{- end }}
{{- end -}}
