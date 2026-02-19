{{/*

**DEPRECATED** - use `csf-common-lib.v4.certificateValues` instead

Create Certificate parameters based on input values as defined in a HBP.

## Changelog

### [v3]
#### Changed
* add support for Certificate in v1alpha3 version

### [v2]
#### Changed
* handle empty `nameSuffix` in a workload block

## Parameters

Three parameters are expected.
* . - root
* certificate - certificate dict block
* workload - workload dict block

All parameters need to be grouped in the one tuple.

Certificate block, contains 1 to 1 mapping of parameters available from cert-manager v1.0.0:

* issuerRef
** name
** kind - default "Issuer"
** group - default "cert-manager.io"
* duration - default 8760h # 1 year
* renewBefore - default 360h # 15 days
* subject
* commonName
* usages
* dnsNames
* uris
* ipAddresses
* privateKey
** algorithm
** encoding
** size
** rotationPolicy - default Always

Defaults are good enough for internal certificate used for TLS
* If certificate is used for different purpose appropriate fields should be overwritten

Use as much as possible configurable fields

* Over time, the following fields have been added to the v1 version of the Certificate CRD:
** additionalOutputFormats/encodeUsagesInRequest/literalSubject/revisionHistoryLimit/secretTemplate
* It is not possible to detect in 'helm install' phase if additional fields are supported by Certificate.
   When they are not in CRD the validation fails.
** Due to this fact, better to not use them.

The use of the common name field has been deprecated since 2000 and is discouraged from being used.
* By default not set. `dnsNames` set instead (https://datatracker.ietf.org/doc/html/rfc2818#section-3.1)
** "If a subjectAltName extension of type dNSName is present, that MUST be used as the identity."
* It is configurable just in case.

## Examples

* Workload (named core) common labels
** values.yaml
+
----
echoserver:
  certificate:
    issuerRef:
      # If the `Issuer` name is not specified, a self-signed `Issuer` will be created automatically.
      name:
      kind: "Issuer"
      group: "cert-manager.io"
    duration: 8760h # 1 year
    renewBefore: 360h # 15 days
    # Not needed in internall communication
    subject:
    # It has been deprecated since 2000 and is discouraged from being used. `dnsNames` are used instead.
    commonName:
    # If `usages` is not specified, the following will be used:
    # - server auth
    # - client auth
    usages:
    # If `dnsNames` is not specified then the following internal names will be used:
    # - localhost
    # - <service name>.<namespace>
    # - <service name>.<namespace>.svc
    # - <service name>.<namespace>.svc.<cluster domain>
    # If ssl passthrough is used on the Ingress object,
    # then dnsNames should be set to external DNS names.
    dnsNames:
    uris:
    # If ipAddresses not specified then the following internal local IPs will be used:
    # - "127.0.0.1"
    # - "::1"
    ipAddresses:
    privateKey:
      algorithm:
      encoding:
      size:
      # Rotation of a key pair, when certificate is refreshed is recommended from a security point of view
      rotationPolicy: Always

----
** snippet from a certificate template
+
----
spec:
{{ include "csf-common-lib.v3.certificateValues" (tuple . .Values.echoserver.certificate .Values.echoserver) | indent 2 }}
----

## HBP

This is a helper function for:

.HBP_Security_cert_4 of HBP v3.4.0
****
 `Certificate` resource need to be configurable in `certificate` block in `values.yaml`.

 * `v1` resource version  need to be supported.
****

*/}}
{{- define "csf-common-lib.v3.certificateValues" -}}
{{- $root := index . 0 }}
{{- $certificate := index . 1 }}
{{- $workload := index . 2 }}
{{- $useV1alpha3 := and ($root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate") (not ($root.Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate")) }}
{{- $defaultIssuerName := include "csf-common-lib.v2.resourceName" (tuple $root "Issuer" $workload.nameSuffix) }}
secretName: {{ include "csf-common-lib.v2.certificateSecretName" (tuple $root $certificate) }}
issuerRef:
  name: {{ ($certificate.issuerRef | default (dict)).name | default $defaultIssuerName | quote }}
  kind: {{ ($certificate.issuerRef | default (dict)).kind | default "Issuer" | quote }}
  group: {{ ($certificate.issuerRef | default (dict)).group | default "cert-manager.io" | quote }}
{{- if $certificate.duration }}
duration: {{ $certificate.duration | quote }}
{{- else }}
duration: 8760h # 1year
{{- end }}
{{- if $certificate.renewBefore }}
renewBefore: {{ $certificate.renewBefore | quote }}
{{- else }}
renewBefore: 360h # 15d
{{- end }}
{{- if $certificate.subject }}
subject: {{ $certificate.subject | toYaml | indent 2 }}
{{- end }}
{{- if $certificate.commonName }}
commonName: {{ $certificate.commonName | quote }}
{{- end }}
privateKey:
{{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).algorithm }}
  algorithm: {{ $certificate.privateKey.algorithm }}
{{- end }}
{{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).encoding }}
  encoding: {{ $certificate.privateKey.encoding }}
{{- end }}
{{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).size }}
  size: {{ $certificate.privateKey.size }}
{{- end }}
{{- if ($certificate.privateKey | default (dict)).rotationPolicy }}
  rotationPolicy: {{ $certificate.privateKey.rotationPolicy }}
{{- else }}
  rotationPolicy: Always
{{- end }}
{{- if $useV1alpha3 }}
  {{- if ($certificate.privateKey | default (dict)).algorithm }}
keyAlgorithm: {{ $certificate.privateKey.algorithm | lower }}
  {{- end }}
  {{- if ($certificate.privateKey | default (dict)).encoding }}
keyEncoding: {{ $certificate.privateKey.encoding | lower }}
  {{- end }}
  {{- if ($certificate.privateKey | default (dict)).size }}
keySize: {{ $certificate.privateKey.size }}
  {{- end }}
{{- end }}
{{- if $certificate.usages }}
usages:
{{ $certificate.usages | toYaml | indent 2 }}
{{- else }}
usages:
  - server auth
  - client auth
{{- end }}
{{- if $certificate.dnsNames }}
dnsNames:
{{ $certificate.dnsNames | toYaml | indent 2 }}
{{- else }}
dnsNames:
  - localhost
  - {{ include "csf-common-lib.v2.resourceName" (tuple $root "Service" $workload.nameSuffix) }}.{{ $root.Release.Namespace }}
  - {{ include "csf-common-lib.v2.resourceName" (tuple $root "Service" $workload.nameSuffix) }}.{{ $root.Release.Namespace }}.svc
  - {{ include "csf-common-lib.v2.resourceName" (tuple $root "Service" $workload.nameSuffix) }}.{{ $root.Release.Namespace }}.svc.{{ $root.Values.clusterDomain | default "cluster.local" }}
{{- end }}
{{- if $certificate.uris }}
{{- if $useV1alpha3 }}
uriSANs:
{{- else }}
uris:
{{- end }}
{{ $certificate.uris | toYaml | indent 2 }}
{{- end }}
ipAddresses:
{{- if $certificate.ipAddresses }}
{{ $certificate.ipAddresses | toYaml | indent 2 }}
{{- else }}
  - "127.0.0.1"
  - "::1"
{{- end }}
{{- end }}
