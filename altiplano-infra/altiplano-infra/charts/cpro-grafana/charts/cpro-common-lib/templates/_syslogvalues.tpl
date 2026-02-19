
## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.syslogValues" ( dict "root" . "context" .Values.core) }}


* root refers to .Values(root) level and context referes to .Values.core(workload) level
----

{{- define "cpro-common-lib.v1.syslogValues" -}}
{{/*
As per HBP, precedence is given to syslog defined at workload level over global level.
If syslog is enabled at workload level, all syslog properties are read from the workload level.
Only if syslog is enabled at global level and left empty at workload level, then all syslog properties are read from the global level.
*/}}
{{- $root := .root }}
{{- $context := .context }}
{{- if and (hasKey $context "unifiedLogging") (hasKey $context.unifiedLogging "syslog")  (hasKey $context.unifiedLogging.syslog "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $context.unifiedLogging.syslog.enabled false)) "true") }}
{{- $_ := set $root "syslog" $context.unifiedLogging.syslog }}
{{- $_ := set $root "syslogEnabled" "true" }}
{{- else if and (hasKey $root.Values.global "unifiedLogging") (hasKey $root.Values.global.unifiedLogging "syslog") (hasKey $root.Values.global.unifiedLogging.syslog "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.global.unifiedLogging.syslog.enabled false)) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $context.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set $root "syslog" $root.Values.global.unifiedLogging.syslog }}
{{- $_ := set $root "syslogEnabled" "true" }}
{{- end -}}
{{- end -}}

