
## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.syslog" ( dict "root" . "context" .Values.core) }}


* root refers to .Values(root) level and context referes to .Values.core(workload) level
----

{{- define "cpro-common-lib.v1.syslog" -}}
{{- $root := .root }}
{{- $context := .context }}
{{- if $context.unifiedLogging.syslog.enabled }}
{{- $_ := set $root "syslog" $context.unifiedLogging.syslog }}
{{- else }}
{{- $_ := set $root "syslog" $root.Values.global.unifiedLogging.syslog }}
{{- end }}
{{- end }}
