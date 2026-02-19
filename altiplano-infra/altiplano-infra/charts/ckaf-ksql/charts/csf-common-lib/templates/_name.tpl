{{/*
Expand the name of the chart.
*/}}
{{- define "csf-common-lib.v1.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.

## Changelog

### [v1]
#### Changed
* implementation in internal version 1.11.0 to remove code duplicaton, but the functionality remains unchanged

*/}}
{{- define "csf-common-lib.v1.fullname" -}}
{{- include "csf-common-lib.v1.fullnameExtended" . -}}
{{- end }}