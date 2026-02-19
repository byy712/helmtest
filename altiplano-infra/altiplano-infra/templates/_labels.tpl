{{/* vim: set filetype=mustache: */}}
{{/*

Common set of labels for all redis resources

*/}}
{{- define "crdb-redisio.common_labels" }}
app: {{ .Release.Name }}-altiplano-redis
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: crdb
csf-subcomponent: redisio
crdb-dbtype: redisio
{{- end -}}


