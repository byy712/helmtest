{{/* vim: set filetype=mustache: */}}

{{/*
Create chart version for this CMDB chart.
This is defined here as a hard-coded value instead of using .Chart.Version
since if CMDB is used in an unbrella chart, this .Chart.Version may not
reflect the version of the CMDB chart, but a parent chart.  This chart
version is used by upgrade/rollback code to determine if any chart migration
tasks are required for chart upgrade/rollback.
*/}}
{{- define "cmdb.chart-version" -}}
9.2.1
{{- end -}}

