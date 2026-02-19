{{/*
Merge any number of dicts.
All parameters need to be grouped in the one tuple.

## Parameters

Any number of dicts with string key and a string value.
All parameters need to be grouped in the one tuple.

## Examples

* Pass one dict
+
----
{{- include "csf-common-lib.v1.mergeDicts" (tuple .Values.global.annotations) | indent 4 }}
----
* Pass two dicts
+
----
{{- include "csf-common-lib.v1.mergeDicts" (tuple .Values.global.annotations .Values.core.annotations) | indent 4 }}
----

*/}}
{{- define "csf-common-lib.v1.mergeDicts" -}}
{{- $finalDict := dict }}
{{- range $map := . }}
{{- if not (empty $map) }}
{{- $finalDict := merge $finalDict $map }}
{{- end }}
{{- end }}
{{- range $key, $value := $finalDict }}
{{ $key | quote }}: {{ $value | quote }}
{{- end }}
{{- end -}}
