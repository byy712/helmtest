{{/*
Expand the name of the chart.
*/}}
{{- define "csf-common-lib.v1.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "csf-common-lib.v1.fullname" -}}
{{- $root := index . 0 }}
{{- $limit := 63 }}
{{- if gt (len .) 1 }}
    {{- $limit = index . 1 }}
{{- end }}
{{- if $root.Values.fullnameOverride }}
{{- $root.Values.fullnameOverride | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- $name := default $root.Chart.Name $root.Values.nameOverride }}
{{- if contains $name $root.Release.Name }}
{{- $root.Release.Name | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $root.Release.Name $name | trunc $limit | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}