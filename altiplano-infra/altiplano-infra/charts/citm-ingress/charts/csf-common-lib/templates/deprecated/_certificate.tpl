{{/*

**DEPRECATED** - use `csf-common-lib.v4.certificate` instead

Create Certificate object based on input values as defined in a HBP.

## Parameters

Two parameters are expected.
* . - root
* workload - workload dict block

All parameters need to be grouped in the one tuple.

Certificate in v1 apiVersion was introduced more than 2 years ago (in cert-manager v1.0.0 in 2020-09-02).
* Due to this fact support to earlier versions (e.g. v1alpha2 v1alpha3 v1beta1) are skipped here.

## Examples

* Workload (named echoserver)
** code snippet
+
----
{{- $workload := .Values.echoserver }}
{{- if and $workload.tls.enabled (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled true)) "true") }}
  {{- include "csf-common-lib.v1.certificate" (tuple . $workload) }}
{{- end }}
----

## HBP

This is a helper function for:

.HBP_Security_cert_4 of HBP v3.4.0
****
 `Certificate` resource need to be configurable in `certificate` block in `values.yaml`.

 * `v1` resource version  need to be supported.
****

*/}}
{{- define "csf-common-lib.v1.certificate" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ include "csf-common-lib.v1.resourceName" (tuple $root "Certificate" $workload.nameSuffix) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple $root $workload.name) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple $root.Values.global.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple $root.Values.global.annotations) | indent 4 }}
spec:
{{ include "csf-common-lib.v1.certificateValues" (tuple $root $workload.certificate $workload) | indent 2 }}
{{- end }}
