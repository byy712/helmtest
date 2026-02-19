{{/*
Create HorizontalPodAutoscaler object based on input values as defined in a HBP.

## Changelog

### [v4]
#### Changed
* use "csf-common-lib.v3.resourceName" - handle `.disablePodNamePrefixRestrictions` at root level
* use "csf-common-lib.v3.workloadName" - handle `.disablePodNamePrefixRestrictions` at root level

### [v3]
#### Changed
* use "csf-common-lib.v2.resourceName"
* use "csf-common-lib.v2.workloadName"

### [v2]
#### Changed
* remove condition "csf-common-lib.v1.isHpaEnabled"
* handle empty `nameSuffix` in a workload block

## Parameters

Two parameters are expected.
* . - root
* workload dict block containing `name`,  `_kind`, `nameSuffix` and `hpa` block.

All parameters need to be grouped in the one tuple.


## Examples

* Workload (named core)
** code snippet
+
----
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.core.hpa.enabled .Values.global.hpa.enabled false)) "true" }}
{{- include "csf-common-lib.v4.hpa" (tuple . .Values.core) }}
{{- end}}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_HPA_1 of HBP v3.1.0
****
HorizontalPodAutoscaler need to be supported.
****

.HBP_Kubernetes_HPA_2 of HBP v3.1.0
****
HorizontalPodAutoscaler `v2beta2`, `v2` need to be supported.
****

.HBP_Kubernetes_HPA_3 of HBP v3.1.0
****
HorizontalPodAutoscaler need to be configurable in `hpa` block. `maxReplicas`, `minReplicas`, `metrics`, `behavior` fields need to be configurable.
****

*/}}
{{- define "csf-common-lib.v4.hpa" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
---
apiVersion: {{ $root.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" | ternary "autoscaling/v2" "autoscaling/v2beta2" }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "csf-common-lib.v3.resourceName" (tuple $root "HorizontalPodAutoscaler" $workload.nameSuffix) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple $root) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple $root.Values.global.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple $root.Values.global.annotations) | indent 4 }}
spec:
  scaleTargetRef:
    apiVersion: {{ $workload._apiVersion | default "apps/v1" }}
    kind: {{ $workload._kind }}
    name: {{ include "csf-common-lib.v3.workloadName" (tuple $root $workload) }}
{{ include "csf-common-lib.v1.hpaValues" $workload.hpa | indent 2 }}
{{- end -}}