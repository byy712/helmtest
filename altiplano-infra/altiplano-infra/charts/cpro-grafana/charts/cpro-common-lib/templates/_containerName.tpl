
## Examples

* Workload (named core)
** code snippet
+
----
{{ template "cpro-common-lib.v1.containername" (dict "name" "fluentd" "context" .) }}

* name is hardcoded to fluentd and context referes to .Values.(root) level
----

* fluentd is name of the container that needs to give 


{{/*
custom container name
*/}}
{{- define "cpro-common-lib.v1.containername" -}}
{{- $context := .context -}}
{{- $name := .name | trunc 28 -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix := $context.Values.global.containerNamePrefix | default "" | trunc ( 34 | int) -}}
{{- $result := dict -}}
{{- $_ := set $result "finalConName" (printf "%s-%s" $prefix $name | trimPrefix "-" | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalConName -}}
{{- end -}}

