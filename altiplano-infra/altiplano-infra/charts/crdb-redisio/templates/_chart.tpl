{{/* vim: set filetype=mustache: */}}

{{/*
Create chart version for this chart.
This is defined here as a hard-coded value instead of using .Chart.Version
since if chart is used in an unbrella chart, this .Chart.Version may not
reflect the version of the subchart, but a parent chart.  This chart
version is used by upgrade/rollback code to determine if any chart migration
tasks are required for chart upgrade/rollback.
*/}}
{{- define "crdb-redisio.chart-version" -}}
9.0.3
{{- end -}}

