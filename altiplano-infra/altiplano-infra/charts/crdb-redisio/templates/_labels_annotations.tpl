{{/* vim: set filetype=mustache: */}}
{{/*
Common set of labels for all resources and any selectors
*/}}
{{- define "crdb-redisio.common_labels" -}}
app: {{ include "crdb-redisio.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: crdb
crdb-dbtype: redisio
{{- end -}}

{{/*
Additional set of labels for resources (not used for selectors)

Note:
app.kuebrnetes.io/component - conditionally set if one of our "workloads" is the
first type specified, otherwise that label is omitted.  Per HBP_Helm_Labels_1

Arg: (tuple <scope> <types>...)
*/}}
{{- define "crdb-redisio.addl_labels" -}}
{{- $top := first . -}}
{{- $types := rest . -}}
{{- $workload := has (first $types) (list "admin" "server" "sentinel") | ternary (first $types) "" -}}
{{- /* app.kubernetes.io labels */ -}}
app.kubernetes.io/name: {{ include "crdb-redisio.name" $top }}
app.kubernetes.io/instance: {{ $top.Release.Name | quote }}
{{- if $top.Chart.AppVersion }}
app.kubernetes.io/version: {{ $top.Chart.AppVersion | quote }}
{{- end }}
{{- if $workload }}
app.kubernetes.io/component: {{ $workload }}
{{- end }}
{{- if $top.Values.partOf }}
app.kubernetes.io/part-of: {{ $top.Values.partOf | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $top.Values.managedBy | default $top.Release.Service | quote }}
{{- /* helm.sh labels */}}
helm.sh/chart: {{ $top.Chart.Name }}-{{ $top.Chart.Version | replace "+" "_" }}
{{- include "crdb-redisio.get_custom" (tuple $top "labels" $types) -}}
{{- end }}

{{/*
Labels for various subcomponents

*** IMPORTANT: Changing any .selector_labels contents will break upgradability
               of a release due to K8s rejecting changes to portions of STS
               specs (volumeClaimTemplates, etc.)

The .selector_labels templates should be used anywhere the labels cannot be changed
via upgrade, otherwise, .labels templates should be used.

.selector_labels templates take a standard scope argument.
.labels templates take a tuple argument (<scope> <types>... ) used for pulling in
    various possible custom labels from Values.
*/}}
{{- define "crdb-redisio.selector_labels" -}}
{{ include "crdb-redisio.common_labels" . }}
csf-subcomponent: redisio
{{- end -}}

{{- define "crdb-redisio.admin.selector_labels" -}}
{{ include "crdb-redisio.common_labels" . }}
csf-subcomponent: redisio-admin
altiplano-role: {{ toYaml .Values.custom.admin.accessRoleLabel }}
{{- end -}}

{{/* Arg: (tuple <scope> <types>...) */}}
{{- define "crdb-redisio.labels" -}}
{{ include "crdb-redisio.selector_labels" (first .) }}
{{ include "crdb-redisio.addl_labels" . }}
{{- end -}}

{{/* Arg: (tuple <scope> <types>...) */}}
{{- define "crdb-redisio.admin.labels" -}}
{{ include "crdb-redisio.admin.selector_labels" (first .) }}
{{ include "crdb-redisio.addl_labels" . }}
{{- end -}}

{{/*
Annotations for resources

Arg: (tuple <scope> <types>...)
*/}}
{{- define "crdb-redisio.annotations" -}}
{{- $top := first . -}}
{{- $types := rest . -}}
{{- include "crdb-redisio.get_custom" (tuple $top "annotations" $types) -}}
{{- end -}}

{{/* Gets the metrics usePodServices config
Used to determine if the admin pod needs to reset to pickup
service changes as a result of enabling/disabling metrics/usePodServices
*/}}
{{- define "crdb-redisio.metrics.config" -}}
{{- with .Values.server.metrics -}}
{{- cat .enabled .usePodServices -}}
{{- end -}}
{{- with .Values.sentinel.metrics -}}
{{- cat .enabled .usePodServices -}}
{{- end -}}
{{- end }}
