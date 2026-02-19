{{- define "cbur.proxy.imageTag" -}}
{{- include "csf-common-lib.v2.imageTag" . -}}
{{- end }}

{{- define "cbur.proxy.coalesceBoolean" -}}
{{- include "csf-common-lib.v1.coalesceBoolean" . -}}
{{- end }}

{{- define "cbur.proxy.resourceName" -}}
{{- include "csf-common-lib.v3.resourceName" . -}}
{{- end }}

{{- define "cbur.proxy.containerName" -}}
{{- include "csf-common-lib.v1.containerName" . -}}
{{- end }}

{{- define "cbur.proxy.isEmptyValue" -}}
{{- include "csf-common-lib.v1.isEmptyValue" . -}}
{{- end }}

{{- define "cbur.proxy.podAntiAffinity" -}}
{{- include "csf-common-lib.v2.podAntiAffinity" . -}}
{{- end }}

{{- define "cbur.proxy.commonLabels" -}}
{{- include "csf-common-lib.v1.commonLabels" . -}}
{{- end }}
