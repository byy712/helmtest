{{/* vim: set filetype=mustache: */}}
{{/*
A representation of the secret-file.txt contents
*/}}
{{- define "altiplano-grafana.secret-file.txt" -}}
{{- printf "grafana-admin-user=%s" .Values.global.GRAFANA_ADMIN_USERNAME | trunc 63 -}}
{{- printf "\n" | trunc 63 -}}
{{- printf "grafana-admin-password=%s" .Values.global.GRAFANA_ADMIN_PASSWORD  | trunc 63 -}}
{{- end -}}