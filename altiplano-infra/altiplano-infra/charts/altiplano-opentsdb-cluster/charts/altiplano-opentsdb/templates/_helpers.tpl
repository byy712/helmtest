{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "altiplano-opentsdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "altiplano-opentsdb.fullname" -}}
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
{{- define "altiplano-opentsdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Derive the image name from three different parameters.
*/}}
{{- define "image.fullname" -}}

    {{- if not (empty .Values.image.registry) -}}
        {{- if not (eq "-" .Values.image.registry) -}} {{ .Values.image.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}

    {{- if .Values.image.repository -}}
        {{- if not (empty .Values.image.registry) -}}
            {{- if not (eq "-" .Values.image.registry) -}}/{{- end -}}
        {{- else if .Values.global.registry -}}/
        {{- end -}}
    {{ .Values.image.repository }}
    {{- end -}}

    {{- if .Values.image.tag -}}
        {{- if .Values.image.repository -}}:
        {{- else -}}
            {{- if not (empty .Values.image.registry) -}}
                {{- if not (eq "-" .Values.image.registry) -}}:{{- end -}}
            {{- else if .Values.global.registry -}}:
            {{- end -}}
        {{- end -}}
    {{ .Values.image.tag }}
    {{- end -}}
{{- end -}}

{{- define "cbura.image.fullname" -}}
    {{- if not (empty .Values.image.registry) -}}
        {{- if not (eq "-" .Values.image.registry) -}} {{ .Values.image.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}
    /{{ .Values.cbur.cbura.imageRepo }}:{{ .Values.cbur.cbura.imageTag }}
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