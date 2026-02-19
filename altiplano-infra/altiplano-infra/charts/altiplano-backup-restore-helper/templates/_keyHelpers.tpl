{{/* vim: set filetype=mustache: */}}

{{- define "keys.volumes.all-keys-storage" -}}
- name: component-all-keys-storage
  secret:
    secretName:
      {{ .Values.global.externalKeys.secretName | quote}}
{{- end -}}
