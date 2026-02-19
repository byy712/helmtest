
## Examples

* Workload (named core)
** code snippet
+
----
 {{- include "cpro-common-lib.v1.resources" ( dict "root" . "workloadresources" .Values.vmutils.resources "defaultcpulimit" "100m") | nindent 10 }}

*  root refers to .Values(root) level workloadresources refers to .Values.workload.resources and defaultcpulimit is the cpu limit of cpu for container
----


{{/*
cpu limits based on enableDefaultCpuLimits flag
The below function will handles if limits is having cpu key it'll take that values else it'll check if enableDefaultCpuLimits is set to true and accordingly update the cpu limits
*/}}

{{- define "cpro-common-lib.v1.resources" -}}
{{- $root := .root -}}
{{- $workloadresources := .workloadresources -}}
{{- $defaultcpulimit := .defaultcpulimit -}}
{{- if hasKey $workloadresources.limits "cpu" }}
  {{- tpl (toYaml $workloadresources) $root }}
{{- else if not (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits false)) "true") }}
  {{- tpl (toYaml $workloadresources) $root }}
{{- else }}
{{ tpl (toYaml $workloadresources) $root | replace "limits:" (include "cpro-common-lib.v1.resources.defaultcpu" (dict "defaultcpulimit" $defaultcpulimit)) }}
{{- end }}
{{- end }}

{{/*
defaultcpu value for limits
*/}}
{{- define "cpro-common-lib.v1.resources.defaultcpu" -}}
{{- $defaultcpulimit := .defaultcpulimit -}}
{{- print "limits:" }}
{{- printf "%s: %s" "cpu" $defaultcpulimit | nindent 2 }}
{{- end }}
