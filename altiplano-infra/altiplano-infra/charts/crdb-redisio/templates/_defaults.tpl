{{/* vim: set filetype=mustache: */}}

{{/*
* Merges dynamic default values from defaults.yaml
*/}}
{{- define "crdb-redisio.merge-defaults" -}}
{{- $defaults := .Files.Get "defaults.yaml" -}}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.enableDefaultCpuLimits .Values.global.enableDefaultCpuLimits false)) "true" -}}
{{- $defaults = regexReplaceAll "_cpu:(.*)" $defaults "cpu:${1}" -}}
{{- else -}}
{{- $defaults = regexReplaceAll "_cpu:(.*)" $defaults "" -}}
{{- end -}}
{{- $_ := merge .Values (fromYaml $defaults) -}}
{{- end -}}