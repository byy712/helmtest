{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "altiplano-webdav.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "altiplano-webdav.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "altiplano-webdav.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vault-secrets-connection" -}}
{{- printf "%s%s" (include "altiplano-webdav.fullname" .) "-vault-connection" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "vault-secrets-data" -}}
{{- printf "%s%s" (include "altiplano-webdav.fullname" .) "-vault-data" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the ingress component resource annotations
*/}}
{{- define "custom-annotations" -}}
{{- $custom_annotations := index . 0 -}}
{{- range $key, $value := $custom_annotations }}
{{ $key }}: "{{ $value }}"
{{- end -}}
{{- end -}}