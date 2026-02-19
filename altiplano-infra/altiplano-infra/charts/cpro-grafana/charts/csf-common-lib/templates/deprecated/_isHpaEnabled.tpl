{{/*

**DEPRECATED** - use `csf-common-lib.v1.coalesceBoolean` instead

Check if HPA object should be created for a given workload.

## Parameters

Two parameters are expected.
* . - root
** with global.hpa.enabled - boolean
* workload dict block containing name and hpa block.
** with hpa.enabled - boolean

All parameters need to be grouped in the one tuple.

## Examples

* Workload (named core)
** snippet from a hpa template
+
----
spec:
{{- if eq (include "csf-common-lib.v1.isHpaEnabled" (tuple . .Values.core)) "true" }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_HPA_4 of HBP v3.1.0
****
HorizontalPodAutoscaler feature need to be switchable in the global scope.
****

*/}}
{{- define "csf-common-lib.v1.isHpaEnabled" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}

{{- $hpaEnabledGlobalScope := and (hasKey $root.Values.global "hpa") (hasKey $root.Values.global.hpa "enabled") $root.Values.global.hpa.enabled }}
{{- $hpaEnabledGlobalScopeDefaultFalse := eq (include "csf-common-lib.v1.boolDefaultFalse" $hpaEnabledGlobalScope) "true" }}
{{- $hpaEnabledWorkloadScope := and (hasKey $workload "hpa") (hasKey $workload.hpa "enabled") $workload.hpa.enabled }}
{{- $hpaEnabledWorkloadScopeDefaultFalse := eq (include "csf-common-lib.v1.boolDefaultFalse" $hpaEnabledWorkloadScope) "true" }}
{{- $hpaEnabledWorkloadScopeIsEmpty := eq (include "csf-common-lib.v1.isEmpty" $hpaEnabledWorkloadScope) "true" }}

{{- or $hpaEnabledWorkloadScopeDefaultFalse (and $hpaEnabledGlobalScopeDefaultFalse $hpaEnabledWorkloadScopeIsEmpty) }}
{{- end -}}