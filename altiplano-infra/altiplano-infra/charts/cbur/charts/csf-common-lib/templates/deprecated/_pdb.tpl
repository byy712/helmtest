{{/*

**DEPRECATED** - use `csf-common-lib.v2.pdb` instead

*/}}
{{- define "csf-common-lib.v1.pdb" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.pdb }}
{{- if $workload.pdb.enabled }}
---
{{- if $root.Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
apiVersion: policy/v1
{{- else }}
apiVersion: policy/v1beta1
{{- end }}
kind: PodDisruptionBudget
metadata:
  name: {{ include "csf-common-lib.v1.objectNameTemplate" (tuple $root $workload) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple $root) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple $root.Values.global.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple $root.Values.global.annotations) | indent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "csf-common-lib.v1.selectorLabels" (tuple $root $workload.name) | indent 6 }}
{{ include "csf-common-lib.v1.pdbValues" $workload.pdb | indent 2 }}
{{- end }}
{{- end -}}
{{- end -}}