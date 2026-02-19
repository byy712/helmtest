{{/*
**DEPRECATED** - use `csf-common-lib.v1.coalesceBoolean` instead
*/}}
{{- define "csf-common-lib.v1.boolDefaultFalse" -}}
{{- eq (. | toString | lower) "true" -}}
{{- end -}}

{{/*
**DEPRECATED** - use `csf-common-lib.v1.coalesceBoolean` instead
*/}}
{{- define "csf-common-lib.v1.boolDefaultTrue" -}}
{{- not (eq (. | toString | lower) "false") -}}
{{- end -}}

{{/*
**DEPRECATED** - use `csf-common-lib.v1.isEmptyValue` instead
*/}}
{{- define "csf-common-lib.v1.isEmpty" -}}
{{- or (eq (. | toString) "<nil>") (eq (. | toString) "") -}}
{{- end -}}
