{{/*
Create Certificate object based on input values as defined in a HBP.

## Changelog

### [v4]
#### Changed
* use csf-common-lib.v3.resourceName
* csf-common-lib.v4.certificateValues
* added new optional certificate parameter

### [v3]
#### Changed
* add support for Certificate in v1alpha3 version

### [v2]
#### Changed
* handle empty `nameSuffix` in a workload block

## Parameters

Two parameters are expected.
* . - root
* workload - workload dict block
* certificate - (optional) certificate dict block

All parameters need to be grouped in the one tuple.

Certificate in `v1` apiVersion should be used because it was introduced more than 2 years ago (in cert-manager v1.0.0 in 2020-09-02).
Some of the supported environments still use older (0.15.2) cert-manager that do not have `v1`.
* Due to this fact, support for `v1alpha3` has been added to this template.

## Examples

* Workload (named echoserver)
** code snippet
+
----
{{- $workload := .Values.echoserver }}
{{- if and $workload.tls.enabled (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled true)) "true") }}
  {{- include "csf-common-lib.v4.certificate" (tuple . $workload) }}
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
{{- define "cpro-common-lib.v4.certificate" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $suffix := index . 2 }}
{{- $certificate := $workload.certificate }}
{{- $useV1alpha3 := and ($root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate") (not ($root.Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate")) }}
---
{{- if $useV1alpha3 }}
apiVersion: cert-manager.io/v1alpha3
{{- else }}
apiVersion: cert-manager.io/v1
{{- end }}
kind: Certificate
metadata:
  name: {{ $root.certificateName }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple $root $workload.name) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple $root.Values.global.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple $root.Values.global.annotations) | indent 4 }}
spec:
{{ include "cpro-common-lib.v4.certificateValues" (tuple $root $workload $suffix) | indent 2 }}
{{- end }}
