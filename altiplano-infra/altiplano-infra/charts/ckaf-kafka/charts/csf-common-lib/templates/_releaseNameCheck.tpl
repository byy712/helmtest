{{/*
Verifies that the helm release does not exceed the 43 character limit.
If the limit is exceeded, helm operation will fail.

## Parameters

Two parameters are expected.
* . - root


## Examples

* Create separate file e.g. `templates/input-data-validation.yaml`
** code snippet
+
----
{{- include "csf-common-lib.v1.release_name_check" . }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_name_2 of HBP v3.4.0
****
Helm release names longer than 43 characters should be rejected.
****

*/}}
{{- define "csf-common-lib.v1.release_name_check" -}}
{{- if gt (len .Release.Name) 43 }}
{{- fail (printf "Release name length is %d, which exceeds allowed 43 number of characters." (len .Release.Name)) }}
{{- end }}
{{- end }}