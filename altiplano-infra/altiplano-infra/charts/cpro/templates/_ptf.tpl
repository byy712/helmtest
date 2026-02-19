{{- define "cpro.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}
- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels: {{- include "cpro.selectorLabels"  (tuple $root $workload.name) | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}


{{- define "cpro.selectorLabels" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
app: {{ template "cpro.prometheus.name" $root }}
release: {{ $root.Release.Name }}
component: {{ $workload }}
{{- end -}}
