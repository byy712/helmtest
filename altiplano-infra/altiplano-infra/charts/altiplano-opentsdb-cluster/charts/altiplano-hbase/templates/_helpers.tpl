{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hbase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 47 chars because some Kubernetes name fields are limited to 63 (by the DNS naming spec),
as we append -master or -region to the names
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hbase.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 47 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 47 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Standard Labels from Helm documentation https://helm.sh/docs/chart_best_practices/#labels-and-annotations
*/}}

{{- define "hbase.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
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