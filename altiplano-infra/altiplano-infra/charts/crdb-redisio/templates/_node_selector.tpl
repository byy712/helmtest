{{/* vim: set filetype=mustache: */}}
{{/*
nodeSelector handler to allow for dict or list, e.g.,
admin.nodeSelector:
  somekey: somevalue

or

admin.nodeSelector:
- key: somekey
  value: somevalue

  Arg: (tuple <scope> <subcomponent>)

  E.g
  {{- include "crdb-redisio.node-selector" (tuple . "admin") | nindent 6 -}}
*/}}
{{- define "crdb-redisio.node-selector" -}}
{{- $g := first . -}}
{{- $subcomp := index . 1 -}}
{{- $Values := index $g "Values" $subcomp -}}
{{- with $Values.nodeSelector }}
nodeSelector:
  {{- if kindIs "slice" . -}}
    {{- $err := printf "list-based %s.nodeSelector Value missing %%s" $subcomp -}}
    {{- range . -}}
        {{- required (printf $err "key") .key | nindent 2 }}: {{ required (printf $err "value") .value | quote }}
    {{- end }}
  {{- else }}
    {{ toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end -}}