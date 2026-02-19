
## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.tlsValues" ( dict "root" . "context" .Values.core) }}


* root refers to .Values(root) level and context referes to .Values.core(workload) level
----

{{- define "cpro-common-lib.v1.tlsValues" -}}
{{/*
As per HBP, precedence is given to tls defined at workload level over global level.
If tls is enabled at workload level, all tls properties are read from the workload level.
Only if tls is enabled at global level and left empty at workload level, then all tls properties are read from the global level.
*/}}
{{- $root := .root }}
{{- $context := .context }}
{{- if and (hasKey $context "tls") (hasKey $context.tls "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $context.tls.enabled $root.Values.tls.enabled false)) "true") }}
{{- $_ := set $root "tls" $context.tls }}
{{- $_ := set $root "tlsEnabled" "true" }}
{{- else if and (hasKey $root.Values "tls") (hasKey $root.Values.tls "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $context.tls.enabled $root.Values.tls.enabled false)) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $context.tls.enabled ) "true") }}
{{- $_ := set $root "tls" $root.Values.tls }}
{{- $_ := set $root "tlsEnabled" "true" }}
{{- end -}}
{{- end -}}

