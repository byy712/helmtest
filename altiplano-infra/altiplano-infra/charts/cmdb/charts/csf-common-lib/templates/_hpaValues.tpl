{{/*
Create HorizontalPodAutoscaler parameters based on input values as defined in a HBP.

## Parameters

One dict parameter expected with keys:
* enabled - boolean
* minReplicas (required) - int - HPA minReplicas
* maxReplicas (required) - int - HPA minReplicas
* predefinedMetrics (optional) - dict
** enabled - boolean
** averageCPUThreshold (required) - int - CPU metric added to HPA metrics dict
** averageMemoryThreshold (required) - int - memory metric added to HPA metrics dict
* behavior (optional) - HPA behavior dict
* metrics (optional) - HPA behavior dict

## Examples

* Workload (named core) common labels
** values.yaml
+
----
core:
  pdb:
    enabled: True
    maxUnavailable: 50%
----
** snippet from a hpa template
+
----
spec:
{{ include "csf-common-lib.v1.hpaValues" .Values.core.hpa | indent 2 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_HPA_1 of HBP v3.1.0
****
HorizontalPodAutoscaler need to be supported.
****

.HBP_Kubernetes_HPA_3 of HBP v3.1.0
****
HorizontalPodAutoscaler need to be configurable in `hpa` block. `maxReplicas`, `minReplicas`, `metrics`, `behavior` fields need to be configurable.
****

*/}}
{{- define "csf-common-lib.v1.hpaValues" -}}
minReplicas: {{ .minReplicas }}
maxReplicas: {{ .maxReplicas }}
metrics:
{{- if .predefinedMetrics }}
{{- if .predefinedMetrics.enabled }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .predefinedMetrics.averageCPUThreshold }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .predefinedMetrics.averageMemoryThreshold }}
{{- end }}
{{- end }}
  {{- if .metrics }}
{{ toYaml .metrics | indent 2 }}
  {{- end }}

{{- if .behavior }}
behavior:
{{ toYaml .behavior | indent 2 }}
{{- end }}
{{- end -}}
