{{/*
* Construct CBUR Master Service URL
*/}}
{{- define "crdb-redisio.cburm.url" -}}
{{- with .Values.cbur.service -}}
{{ .url | default ( printf "%s://%s.%s.svc.%s" .protocol .name .namespace $.Values.clusterDomain ) }}
{{- end -}}
{{- end }}

{{/*
* Job env snippet for CBUR params
*/}}
{{- define "crdb-redisio.cbur.env" -}}
- name: CBURM_URL
  value: {{ include "crdb-redisio.cburm.url" . | quote }}
{{- if .Values.cbur.service.connectTimeout }}
- name: CBUR_CONNECT_TIMEOUT
  value: {{ .Values.cbur.service.connectTimeout | quote }}
{{- end }}
{{- if .Values.cbur.service.authSecret }}
- name: CBUR_AUTH_SECRET
  value: {{ .Values.cbur.service.authSecret }}
{{- end }}
- name: CBUR_BACKUP_TIMEOUT
  value: {{ .Values.cbur.backup.timeout | default 900 | quote }}
{{- end }}