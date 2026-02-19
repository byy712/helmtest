{{- define "csf-common-lib.v1.objectNameTemplate" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload._objectNameTemplate -}}
{{ tpl $workload._objectNameTemplate $root }}
{{- else -}}
{{- $fullnameNamedTemplate := printf "%s.fullname" $root.Chart.Name -}}
{{ include $fullnameNamedTemplate $root }}
{{- end -}}
{{- end -}}