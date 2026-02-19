## Examples

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.timeZoneName" . | nindent 4 }}
----

{{- define "cpro-common-lib.v1.timeZoneName" -}}
{{- $root := .root -}}
{{- if $root.Values.timeZoneName }}
- name: TZ
  value: {{ $root.Values.timeZoneName }}
{{- else }}
- name: TZ
  value: {{ $root.Values.global.timeZoneName | default "UTC" | quote }}
{{- end }}
{{- end }}
