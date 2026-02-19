{{/*
Create Certificate parameters based on input values as defined in a HBP.

## Changelog

### [v3]
#### Changed
* Use "csf-common-lib.v3.resourceName"
* Changed parameters:
  * Certificate make optional and move to 3rd position
  * Added workload parameter
* Build name based on Certificate name logic and add certificate.nameSuffix as suffix

### [v2]
#### Changed
* Use "csf-common-lib.v2.resourceName"

## Parameters

Three parameters are expected.
* . - root
* workload - workload dict block
* certificate - (optional) certificate dict block

All parameters need to be grouped in the one tuple.

## Examples

* Workload (named echoserver)
** code snippet for ingress object
+
----
    nginx.ingress.kubernetes.io/proxy-ssl-secret: '{{ .Release.Namespace }}/{{ tpl (coalesce (default (default .Values.echoserver.tls dict).secretRef dict).name (include "csf-common-lib.v3.certificateSecretName" (tuple . .Values.echoserver .Values.echoserver.certificate))) . }}'
----
*/}}
{{- define "csf-common-lib.v3.certificateSecretName" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $certificate := $workload.certificate }}
{{- if gt (len .) 2 }}
    {{- $certificate = index . 2 }}
{{- end }}
{{- $suffix := $certificate.nameSuffix | default "cert" }}
{{- if $workload.nameSuffix }}
    {{- $suffix = print $workload.nameSuffix "-" $suffix }}
{{- end }}
{{- $certificate.secretName | default (include "csf-common-lib.v3.resourceName" (tuple $root "Certificate" $suffix)) }}
{{- end }}