{{/* vim: set filetype=mustache: */}}

{{- /* Utilities for dealing with TLS certs */ -}}

{{- /* Cert path utils */ -}}
{{- define "crdb-redisio.tls.dir" -}}/var/run/certs{{- end -}}
{{- define "crdb-redisio.tls.dir.ca" -}}{{- include "crdb-redisio.tls.dir" . -}}/cacerts{{- end -}}

{{- define "crdb-redisio.tls.dir.server" -}}{{- include "crdb-redisio.tls.dir" . -}}/server{{- end -}}
{{- define "crdb-redisio.tls.cert.server" -}}{{- include "crdb-redisio.tls.dir.server" . -}}/tls.crt{{- end -}}
{{- define "crdb-redisio.tls.key.server" -}}{{- include "crdb-redisio.tls.dir.server" . -}}/tls.key{{- end -}}

{{- define "crdb-redisio.tls.dir.client" -}}{{- include "crdb-redisio.tls.dir" . -}}/client{{- end -}}
{{- define "crdb-redisio.tls.cert.client" -}}{{- include "crdb-redisio.tls.dir.client" . -}}/tls.crt{{- end -}}
{{- define "crdb-redisio.tls.key.client" -}}{{- include "crdb-redisio.tls.dir.client" . -}}/tls.key{{- end -}}

{{- /* TLS volumes */ -}}
{{- define "crdb-redisio.tls.vol" -}}
{{- $top := first . -}}
{{- $source := last . -}}
{{/* server and sentinel server-side cert Secrets */}}
{{- range ($top.sentinel_enabled | ternary (list $top.Values.server $top.Values.sentinel) (list $top.Values.server)) -}}
{{- if and $top.server_tls (ne (toString .tls.enabled) "false") }}
- name: {{ .nameSuffix }}-cert
  secret:
    secretName: {{ coalesce .tls.secretRef.name (include "csf-common-lib.v1.certificateSecretName" (tuple $top .certificate)) }}
    items:
    - key: {{ .tls.secretRef.keyNames.tlsKey }}
      path: tls.key
    - key: {{ .tls.secretRef.keyNames.tlsCrt }}
      path: tls.crt
    {{/* optional needed for upgrade/rollback Jobs */}}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
{{- end }}
{{- end }}
{{/* client-side cert Secrets */}}
{{- if and $top.server_tls $top.client_tls -}}
{{- with $top.Values.clients.internal -}}
- name: {{ .nameSuffix }}-cert
  secret:
    secretName: {{ coalesce .tls.secretRef.name (include "csf-common-lib.v1.certificateSecretName" (tuple $top .certificate)) }}
    items:
    - key: {{ .tls.secretRef.keyNames.tlsKey }}
      path: tls.key
    - key: {{ .tls.secretRef.keyNames.tlsCrt }}
      path: tls.crt
    {{/* optional needed for upgrade/rollback Jobs */}}
    {{- if eq $source "job" }}
    optional: true
    {{- end }}
{{- end }}
{{- end }}
{{/* CA volumes (projected) */}}
{{- if $top.server_tls -}}
- name: cacerts
  projected:
    sources:
    {{- range (ternary (list $top.Values.server $top.Values.sentinel) (list $top.Values.server) $top.sentinel_enabled) -}}
    {{- if ne (toString .tls.enabled) "false" }}
    - secret:
        name: {{ coalesce .tls.secretRef.name (include "csf-common-lib.v1.certificateSecretName" (tuple $top .certificate)) }}
        items:
        - key: {{ .tls.secretRef.keyNames.caCrt }}
          path: {{ .nameSuffix }}-ca.crt
        {{/* optional needed for upgrade/rollback Jobs */}}
        {{- if eq $source "job" }}
        optional: true
        {{- end }}
    {{- end -}}
    {{- end -}}
    {{- if $top.client_tls -}}
    {{- range $_n, $_v := $top.Values.clients }}
    - secret:
        name: {{ coalesce $_v.tls.secretRef.name (include "csf-common-lib.v1.certificateSecretName" (tuple $top $_v.certificate)) }}
        items:
        - key: {{ $_v.tls.secretRef.keyNames.caCrt }}
          path: {{ $_v.nameSuffix | default $_n }}-ca.crt
        {{/* optional needed for upgrade/rollback Jobs */}}
        {{- if eq $source "job" }}
        optional: true
        {{- end }}
    {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- /* TLS volumeMounts - CAs */ -}}
{{- define "crdb-redisio.tls.vm.cacerts" -}}
{{- if .server_tls -}}
- name: cacerts
  mountPath: {{ include "crdb-redisio.tls.dir.ca" . }}
  readOnly: true
{{- end -}}
{{- end -}}

{{- /* TLS volumeMount - server */ -}}
{{- define "crdb-redisio.tls.vm.server" -}}
{{- if .server_tls -}}
- name: {{ .Values.server.nameSuffix }}-cert
  mountPath: {{ include "crdb-redisio.tls.dir.server" . }}
  readOnly: true
{{- end -}}
{{- end -}}

{{- /* TLS volumeMount - sentinel */ -}}
{{- define "crdb-redisio.tls.vm.sentinel" -}}
{{- if and .sentinel_enabled .sentinel_tls -}}
- name: {{ .Values.sentinel.nameSuffix }}-cert
  mountPath: {{ include "crdb-redisio.tls.dir.server" . }}
  readOnly: true
{{- end -}}
{{- end -}}

{{- /* TLS volumeMount - client-internal */ -}}
{{- define "crdb-redisio.tls.vm.client" -}}
{{- if and .server_tls .client_tls -}}
- name: {{ .Values.clients.internal.nameSuffix }}-cert
  mountPath: {{ include "crdb-redisio.tls.dir.client" . }}
  readOnly: true
{{- end -}}
{{- end -}}
