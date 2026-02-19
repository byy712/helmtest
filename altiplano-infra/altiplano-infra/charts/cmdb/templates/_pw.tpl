{{/* vim: set filetype=mustache: */}}
{{/*
A set of templates, which provide a particular built-in user password
based on if one was passed in as a value or not (and thus generated).

Provide a simple "interface" so that every location doesn't have to 
detect generated vs not.

Each template has an .enc and .dec variant which provides the b64 encoded
or decoded password.
*/}}

{{- define "cmdb.pw.root.enc" -}}
{{ .Values.users.root.password | default (include "cmdb.pwgen.root" .) }}
{{- end -}}
{{- define "cmdb.pw.root.dec" -}}
{{ include "cmdb.pw.root.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.repl.enc" -}}
{{ .Values.users.replication.password | default (include "cmdb.pwgen.repl" .) }}
{{- end -}}
{{- define "cmdb.pw.repl.dec" -}}
{{ include "cmdb.pw.repl.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.mariadb_metrics.enc" -}}
{{ .Values.users.mariadbMetrics.password | default (include "cmdb.pwgen.mariadb_metrics" .) }}
{{- end -}}
{{- define "cmdb.pw.mariadb_metrics.dec" -}}
{{ include "cmdb.pw.mariadb_metrics.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.maxscale.enc" -}}
{{ .Values.users.maxscale.password | default (include "cmdb.pwgen.maxscale" .) }}
{{- end -}}
{{- define "cmdb.pw.maxscale.dec" -}}
{{ include "cmdb.pw.maxscale.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.maxscale_metrics.enc" -}}
{{ .Values.users.maxscaleMetrics.password | default (include "cmdb.pwgen.maxscale_metrics" .) }}
{{- end -}}
{{- define "cmdb.pw.maxscale_metrics.dec" -}}
{{ include "cmdb.pw.maxscale_metrics.enc" . | b64dec }}
{{- end -}}
