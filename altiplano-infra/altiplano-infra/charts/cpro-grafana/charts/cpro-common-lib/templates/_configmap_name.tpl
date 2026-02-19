{{/*
Return the configmap name
*/}}
{{- define "cpro-common-lib-v1.ConfigmapName" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $truncLen := $root.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $finalname := printf "%s-%s-%s"  $root.Release.Name $root.Chart.Name $name -}}
{{- printf "%s" ($finalname) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}
