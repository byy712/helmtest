## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.imagePullSecrets" ( dict "root" . "workloadName" .Values.core) }}


* root refers to .Values(root) level and workloadName referes to .Values.core(workload) level
----


{{- define "cpro-common-lib.imagePullSecrets" -}}
{{- $root := .root -}}
{{- $workloadName := .workloadName -}}
{{- if $workloadName.imagePullSecrets }}
imagePullSecrets: {{- toYaml $workloadName.imagePullSecrets | nindent 2 -}}
{{- else }}
{{- if $root.Values.global.imagePullSecrets }}
imagePullSecrets: {{- toYaml $root.Values.global.imagePullSecrets | nindent 2 -}}
{{- end }}
{{- end }}
{{- end -}}
