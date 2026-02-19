{{/* vim: set filetype=mustache: */}}
{{/*
This file ussing for craete altiplano-grafana-secrets
*/}}
{{- define "altiplano-grafana.secrets" -}}
apiVersion: v1
kind: Secret
metadata:
{{- if .Values.global.vault.enabled }}
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade, pre-rollback
    "helm.sh/hook-delete-policy": before-hook-creation
    "helm.sh/hook-weight": "-10"
{{- end }}
  name: altiplano-grafana-secrets
  labels:
    app: {{ .Release.Name }}-altiplano-grafana
    release: {{ .Release.Name | quote }}
    heritage: {{ .Release.Service | quote }}
type: Opaque
data:
  grafana_secret.yaml: {{ include "altiplano-grafana.secret-file.txt" . | b64enc }}
{{- end -}}
