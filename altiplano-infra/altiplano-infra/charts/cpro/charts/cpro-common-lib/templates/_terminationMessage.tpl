
## Examples

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.terminationMessage" . | nindent 2 }}
----


{{/* terminationMessagePath and policy */}}
{{- define "cpro-common-lib.v1.terminationMessage" -}}
{{- $root := .root -}}
terminationMessagePath: {{ .Values.terminationMessagePath }}
terminationMessagePolicy: {{ .Values.terminationMessagePolicy }}
{{- end -}}
