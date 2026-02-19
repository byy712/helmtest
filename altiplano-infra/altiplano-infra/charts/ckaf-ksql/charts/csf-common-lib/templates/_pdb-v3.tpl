{{/*
Create PodDisruptionBudget object based on input values as defined in a HBP.

## Changelog

### [v3]
#### Changed
* use "csf-common-lib.v2.resourceName" - handle empty suffix and `.global.disablePodNamePrefixRestrictions`

### [v2]
#### Changed
* handle empty `nameSuffix` in a workload block

## Parameters

Two parameters are expected.
* . - root
* workload dict block containing `name`, `nameSuffix` and `pdb` block.

All parameters need to be grouped in the one tuple.


## Examples

* Workload (named core)
** code snippet
+
----
{{- if .Values.core.pdb.enabled }}
{{- include "csf-common-lib.v3.pdb" (tuple . .Values.core) }}
{{- end}}
----

## HBP

This is a helper function for:

.HBP_Helm_PDB_1 of HBP v2.2.0
****
PodDisruptionBudget need to be supported
****

*/}}
{{- define "csf-common-lib.v3.pdb" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
---
{{- if $root.Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
apiVersion: policy/v1
{{- else }}
apiVersion: policy/v1beta1
{{- end }}
kind: PodDisruptionBudget
metadata:
  name: {{ include "csf-common-lib.v2.resourceName" (tuple $root "PodDisruptionBudget" $workload.nameSuffix) }}
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
{{- end -}}