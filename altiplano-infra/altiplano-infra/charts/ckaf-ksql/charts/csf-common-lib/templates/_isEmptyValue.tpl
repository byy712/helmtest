{{/*
Returns string "true" for:
- empty value
- empty string
- not existent key
- null|Null|NULL value

Returns string "false" for non empty value, including:
- empty list
- empty dict
- booleans true and false
- integers e.g. 0
*/}}
{{- define "csf-common-lib.v1.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}
