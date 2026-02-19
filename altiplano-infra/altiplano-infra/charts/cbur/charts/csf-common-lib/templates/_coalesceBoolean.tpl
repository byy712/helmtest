{{/*

Function takes first not empty value and interprets it as a boolean.
Returns string "true" or "false"

Official helm `coalesce` treats false values as an empty values, so it cannot be used for boolean values.

## Parameters

Multiple parameters are expected.
* . - boolean parameter, can be empty

All parameters need to be grouped in the one tuple.

Note:
If all parameters are empty then "" will be returned but this can be treated as a developer bug.
Last parameter should be a default value, true or false.

## Examples

----
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.echoserver.hpa.enabled .Values.global.hpa.enabled false)) }}
----

| .echoserver.hpa.enabled | .global.hpa.enabled | "csf-common-lib.v1.coalesceBoolean" |
|-------------------------|---------------------|-------------------------------------|
|                         |                     |           "false"                   |
|       true              |                     |           "true"                    |
|                         |       true          |           "true"                    |
|       false             |                     |           "false"                   |
|                         |       false         |           "false"                   |
|       false             |       true          |           "false"                   |
|       true              |       false         |           "true"                    |


## Example usage

* Workload
** values.yaml
+
----
global:
  hpa:
    enabled:
echoserver:
  hpa:
    enabled:
----
** snippet from a hpa template
+
----
{{- $workload := .Values.echoserver }}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.hpa.enabled .Values.global.hpa.enabled false)) "true" }}
...
----
*/}}
{{- define "csf-common-lib.v1.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" .) "false" }}
        {{- if eq (include "csf-common-lib.v1.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}