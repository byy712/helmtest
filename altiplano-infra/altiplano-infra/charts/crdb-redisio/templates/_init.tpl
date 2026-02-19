{{/*
* Common Init function to use at the beginning of each file
* (See csf-common-lib/unit-tests/csf-common-test/templates/_helpers.tpl)
*/}}
{{- define "crdb-redisio.init" -}}
{{ include "crdb-redisio.merge-defaults" . -}}
{{ include "crdb-redisio.values-compat" . -}}
{{ include "crdb-redisio.variables" . -}}
{{- end -}}