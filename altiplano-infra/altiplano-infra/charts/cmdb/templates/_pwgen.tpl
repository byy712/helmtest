{{/* vim: set filetype=mustache: */}}
{{/*
A set of generated passwords, designed to be used for initial deployment only.
If a particular password is passed in via values, these are not used.

Regardless, after deployment, a password change must be done.  The assumption
is that passwords stored in the release of the helm chart are not necessarily
secure.  The only way to avoid this is to change passwords after deployment,
without passing the new passwords through helm.
*/}}

{{- define "cmdb.pwgen.root" -}}
{{- if (not .root_pw) }}
{{- $_ := set . "root_pw" (randAlphaNum 16 | b64enc) }}
{{- end }}
{{ .root_pw }}
{{- end -}}

{{- define "cmdb.pwgen.repl" -}}
{{- if (not .repl_pw) }}
{{- $_ := set . "repl_pw" (randAlphaNum 16 | b64enc) }}
{{- end }}
{{ .repl_pw }}
{{- end -}}

{{- define "cmdb.pwgen.mariadb_metrics" -}}
{{- if (not .mariadb_metrics_pw) }}
{{- $_ := set . "mariadb_metrics_pw" (randAlphaNum 16 | b64enc) }}
{{- end }}
{{ .mariadb_metrics_pw }}
{{- end -}}

{{- define "cmdb.pwgen.maxscale" -}}
{{- if (not .maxscale_pw) }}
{{- $_ := set . "maxscale_pw" (randAlphaNum 16 | b64enc) }}
{{- end }}
{{ .maxscale_pw }}
{{- end -}}

{{- define "cmdb.pwgen.maxscale_metrics" -}}
{{- if (not .maxscale_metrics_pw) }}
{{- $_ := set . "maxscale_metrics_pw" (randAlphaNum 16 | b64enc) }}
{{- end }}
{{ .maxscale_metrics_pw }}
{{- end -}}
