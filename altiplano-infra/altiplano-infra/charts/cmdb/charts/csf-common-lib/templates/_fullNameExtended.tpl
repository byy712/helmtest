{{/*
Create fullname based on input values as defined in a HBP.

## Changelog

### [v1]
#### Added
* function `csf-common-lib.v1.fullnameExtended`

## Examples

* Job
** code snippet
+
----
name: {{ include "csf-common-lib.v1.fullnameExtended" (tuple .) }}
----
** code snippet
+
----
name: {{ include "csf-common-lib.v1.fullnameExtended" (tuple . 63 "chartNameRedefined") }}
----
** code snippet
+
----
name: {{ include "csf-common-lib.v1.fullnameExtended" (tuple . 20 "chartNameRedefined") }}
----

*/}}

{{- define "csf-common-lib.v1.fullnameExtended" -}}
{{- $root := index . 0 }}
{{- $limit := 63 }}
{{- if gt (len .) 1 }}
    {{- $limit = index . 1 }}
{{- end }}
{{- $chartName := $root.Chart.Name }}
{{- if gt (len .) 2 }}
    {{- $chartName = index . 2 }}
{{- end }}
{{- if $root.Values.fullnameOverride }}
{{- $root.Values.fullnameOverride | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- $name := default $chartName $root.Values.nameOverride }}
{{- if contains $name $root.Release.Name }}
{{- $root.Release.Name | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $root.Release.Name $name | trunc $limit | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}