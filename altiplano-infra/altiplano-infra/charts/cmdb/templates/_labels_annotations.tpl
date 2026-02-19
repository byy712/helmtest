{{/* vim: set filetype=mustache: */}}

{{/*
Common set of labels for all resources for immutable objects (i.e., pvc ).
The app, release and heritage labels are deprecated  and can be removed in the next major release.
*/}}
{{- define "cmdb-common.labels" -}}
app: {{ include "cmdb.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: cmdb
cmdb-dbtype: mariadb
{{- end -}}

{{/*
Labels for various subcomponents

*** IMPORTANT: Changing any .selector_labels contents will break upgradability
               of a release due to K8s rejecting changes to portions of STS
               specs (volumeClaimTemplates, etc.)

The .selector_labels templates should be used anywhere the labels cannot be
changed via upgrade, otherwise, .labels templates should be used.

.selector_labels templates take a standard scope argument.
.labels templates take a tuple argument (<scope> <types>... ) used for pulling
in various possible custom labels from Values.
*/}}
{{/*
    Selector Labels
*/}}
{{- define "cmdb-mariadb.selector_labels" -}}
{{ include "cmdb-common.labels" . }}
csf-subcomponent: mariadb
{{- end -}}

{{- define "cmdb-maxscale.selector_labels" -}}
{{ include "cmdb-common.labels" . }}
csf-subcomponent: maxscale
{{- end -}}

{{- define "cmdb-admin.selector_labels" -}}
{{ include "cmdb-common.labels" . }}
csf-subcomponent: admin
altiplano-role: {{ toYaml .Values.admin.accessRoleLabel }}
{{- end -}}

{{- define "cmdb-test.selector_labels" -}}
{{ include "cmdb-common.labels" . }}
csf-subcomponent: test
{{- end -}}

{{/*
    Resource Labels

Arg: (tuple <scope> <types>...)
*/}}
{{- define "cmdb-mariadb.labels" -}}
{{ include "cmdb-mariadb.selector_labels" (first .) }}
{{ include "csf-common-lib.v1.commonLabels" (tuple (first .) "mariadb") }}
{{ include "cmdb.get_custom" (tuple (first .) "labels" "mariadb" (rest .)) -}}
{{- end -}}

{{- define "cmdb-maxscale.labels" -}}
{{ include "cmdb-maxscale.selector_labels" (first .) }}
{{ include "csf-common-lib.v1.commonLabels" (tuple (first .) "maxscale") }}
{{ include "cmdb.get_custom" (tuple (first .) "labels" "maxscale" (rest .)) -}}
{{- end -}}

{{- define "cmdb-admin.labels" -}}
{{ include "cmdb-admin.selector_labels" (first .) }}
{{ include "csf-common-lib.v1.commonLabels" (tuple (first .) "admin") }}
{{ include "cmdb.get_custom" (tuple (first .) "labels" "admin" (rest .)) -}}
{{- end -}}

{{- define "cmdb-test.labels" -}}
{{ include "cmdb-test.selector_labels" (first .) }}
{{ include "csf-common-lib.v1.commonLabels" (tuple (first .) "test") }}
{{ include "cmdb.get_custom" (tuple (first .) "labels" "test" (rest .)) -}}
{{- end -}}

{{/*
    Resource Annotations

Arg: (tuple <scope> <types>...)
*/}}
{{- define "cmdb-mariadb.annotations" -}}
{{- include "cmdb.get_custom" (tuple (first .) "annotations" "mariadb" (rest .)) -}}
{{- end -}}

{{- define "cmdb-maxscale.annotations" -}}
{{- include "cmdb.get_custom" (tuple (first .) "annotations" "maxscale" (rest .)) -}}
{{- end -}}

{{- define "cmdb-admin.annotations" -}}
{{- include "cmdb.get_custom" (tuple (first .) "annotations" "admin" (rest .)) -}}
{{- end -}}

{{- define "cmdb-test.annotations" -}}
{{- include "cmdb.get_custom" (tuple (first .) "annotations" "test" (rest .)) -}}
{{- end -}}

{{/* Istio Annotations */}}
{{- define "cmdb.istio-annotation" -}}
{{- if .Values.istio.enabled }}
sidecar.istio.io/inject: "true"
{{- else }}
sidecar.istio.io/inject: "false"
{{- end }}
{{- end }}
