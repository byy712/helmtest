{{/* vim: set filetype=mustache: */}}

{{/*
Create the volumes for the all-certs
This should be used in the volumes sectio-n of the pods
use suitable indentation
*/}}
{{- define "nokia-component.certificates.volumes.all-certs-storage" -}}
- name: component-all-certs-storage
  secret:
    secretName: {{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "all" ) | quote }}
{{- end -}}
{{- define "nokia-component.certificates.volumes.ca-certs-storage" -}}
- name: component-ca-certs-storage
  secret:
    secretName: {{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "ca" ) | quote }}
{{- end -}}
{{- define "nokia-component.certificates.volumes.client-certs-storage" -}}
- name: component-client-certs-storage
  secret:
    secretName: {{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "client" ) | quote }}
{{- end -}}
{{- define "nokia-component.certificates.volumes.server-certs-storage" -}}
- name: component-server-certs-storage
  secret:
    secretName: {{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "server" ) | quote }}
{{- end -}}
{{- define "nokia-component.certificates.volumes.trustchain-certs-storage" -}}
- name: component-trustchain-certs-storage
  secret:
    secretName: {{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "trustchain" ) | quote }}
{{- end -}}


{{/*
Extract various information from the Certificates
We need to pass extra parameters to this template
Usage Examples are
This means that from the certificates it will return the value of the secretName of all, typically server-key.pem
{{ include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.global.externalCertificates  "secretNames" "all") } }
This means that from the certificates it will return the value of the fileName of server_key, typically server-key.pem
{{ include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.global.externalCertificates  "fileNames" "server_key") } }
This means that from the certificates it will return the value of the password of server_key_pass, typically serverpass
{{ include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.global.externalCertificates  "passwords" "server_key_pass") } }
*/}}
{{- define "nokia-component.certificates.extractInfo" -}}
  {{- $infoToFetch    := (keys (omit . "Certificates") | first) }}
  {{- $infoValToFetch := (pluck $infoToFetch . | first) }}
  {{- $extractedInfo  := (pluck $infoValToFetch (index .Certificates $infoToFetch) | first) }}
  {{- $extractedInfo }}
{{- end -}}

{{- define "nokia-component.certificates.extractInfo.withDefaultSecretNames" -}}
  {{- $infoToFetch    := (keys (omit . "rootContext" "Certificates") | first) }}
  {{- $infoValToFetch := (pluck $infoToFetch . | first) }}
  {{- $extractedInfo  := (pluck $infoValToFetch (index .Certificates $infoToFetch) | first) }}
  {{- $extractedInfo }}
  {{- if empty $extractedInfo }}
     {{- include "nokia-component.fullname" .rootContext }}
     {{- if (eq "all" $infoValToFetch) -}}-all-certs
     {{- else if (eq "ca" $infoValToFetch) -}}-ca-certs
     {{- else if (eq "client" $infoValToFetch) -}}-client-certs
     {{- else if (eq "server" $infoValToFetch) -}}-server-certs
     {{- else if (eq "trustchain" $infoValToFetch) -}}-trustchain-certs
     {{- else -}}-UNKNOWN
     {{- end }}
  {{- end }}
{{- end -}}


{{/*
Extract various information about Certificates from the Values
We need to pass extra parameters to this template
Usage examples
Below one means that from the certificates it will return the value of the secretName of all, the one passed from the command line or via the values.yaml, the default will be RELEASENAME-altiplano-keycloak-proxy-all-certs
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "all" ) }}
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "ca" ) }}
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "client" ) }}
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "server" ) }}
Below one means that from the certificates it will return the value of the secretName of trustchain, the one passed from the command line or via the values.yaml, the default will be RELEASENAME-altiplano-keycloak-proxy-trustchain-certs
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "trustchain" ) }}
{{include "nokia-component.certificates.info" (dict "rootContext" . "secretNames" "xyz" ) }}
{{include "nokia-component.certificates.info" (dict "rootContext" . "fileNames" "server_key" ) }}
Below one means that from the certificates it will return the value of the secretName of all, typically server-key.pem
{{include "nokia-component.certificates.info" (dict "rootContext" . "passwords" "server_jks_type" ) }}
Below one means that from the certificates it will return the value of the password of server_key_pass, typically serverpass
{{include "nokia-component.certificates.info" (dict "rootContext" . "passwords" "server_key_pass" ) }}
*/}}
{{- define "nokia-component.certificates.info" -}}
  {{- $infoToFetch    := (keys (omit . "rootContext") | first) }}
  {{- $infoValToFetch := (pluck $infoToFetch . | first) }}
  {{- with .rootContext }}
  {{- if .Values.externalCertificates.enabled }}
    {{- if and .Values.global.externalCertificates.enabled (not .Values.externalCertificates.overrideGlobal) }}
      {{- include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.global.externalCertificates $infoToFetch $infoValToFetch) }}
    {{- else }}
      {{- include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.externalCertificates $infoToFetch $infoValToFetch) }}
    {{- end }}
  {{- else if .Values.global.externalCertificates.enabled }}
    {{- include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.global.externalCertificates $infoToFetch $infoValToFetch) }}
  {{- else if (eq "secretNames" $infoToFetch) }}
    {{- include "nokia-component.certificates.extractInfo.withDefaultSecretNames" (dict "rootContext" . "Certificates" .Values.certificates $infoToFetch $infoValToFetch) }}
  {{- else }}
    {{- include "nokia-component.certificates.extractInfo" (dict "Certificates" .Values.certificates $infoToFetch $infoValToFetch) }}
  {{- end }}
  {{- end }}
{{- end -}}




