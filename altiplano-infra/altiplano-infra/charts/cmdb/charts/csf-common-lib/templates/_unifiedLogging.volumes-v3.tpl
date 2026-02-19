{{/*
This template creates the volumes for mounting, required for unifiedlogging. Such as keystore truststore and the configfile.

## Changelog

### [v3]
#### Fixed
* Changed merge function usage to prevent sideeffects on workload values.

### [v2]
#### Fixed
* v1 used common-test.proxy functions which made it only work in the csf-common-lib.

## Parameters

Two parameters are expected.
* . - root
* workload - workload level under which unifiedlogging is defined
* certManagerEnabled - ( optional ) defines if certmanager is enabled which will create the certificate for the rsyslog.
* certificateSecretName - ( optional ) provide this if your certmanager`s certificate is not in the same workload as the unifiedlogging so the secretname is not known.


## Example

* Workload (named core)
** code snippet
+
----
{{- $workload := .Values.core }}
{{- $certmanEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false)) "true") }}
{{- include "csf-common-lib.v3.unifiedLogging.volumes" (tuple . $workload $certmanEnabled) | indent 8 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v3.unifiedLogging.volumes"}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $certManagerEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) "true") }}
  {{- if gt (len .) 2 }}
    {{- $certManagerEnabled = (index . 2 ) }}
  {{- end }}
{{- $certificateSecretName := (include "csf-common-lib.v3.certificateSecretName" (tuple $root $workload)) }}
  {{- if gt (len .) 3 }}
    {{- $certificateSecretName = (index . 3 ) }}
  {{- end }}
      
{{- $unifloggingStructure := fromYaml (include "csf-common-lib.v1.unifiedLogging.structure" .) }}
{{- $mergedrsyslog := dict -}}
{{- $_ := merge $mergedrsyslog $workload.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog }}

{{- $suffix :="log4cxx" }}
{{- if $workload.nameSuffix }}
  {{- $suffix = printf "log4cxx-%s" $workload.nameSuffix }}
{{- end }}
- name: uniflogging-conf
  configMap:
    name: {{ include "csf-common-lib.v3.resourceName" ( tuple $root "ConfigMap" $suffix ) }}
    items:
    - key: log4cxxproperty
      path: "log4cxx.property"  

{{- if and (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) (or $mergedrsyslog.keyStore.secretName $mergedrsyslog.trustStore.secretName $mergedrsyslog.tls.secretRef.name) }}

{{- $keystoreSecName := $mergedrsyslog.keyStore.secretName }}
{{- $keystoreKey := $mergedrsyslog.keyStore.key }}
{{- $keystorePasswordSecName := $mergedrsyslog.keyStorePassword.secretName }}
{{- $keystorePasswordKey := $mergedrsyslog.keyStorePassword.key }}

{{- $truststoreSecName := $mergedrsyslog.trustStore.secretName }}
{{- $truststoreKey := $mergedrsyslog.trustStore.key }}
{{- $truststorePasswordSecName := $mergedrsyslog.trustStorePassword.secretName }}
{{- $truststorePasswordKey := $mergedrsyslog.trustStorePassword.key }}

{{- $tlsSecretRefName := $mergedrsyslog.tls.secretRef.name }}
    {{- if and $keystoreSecName $keystoreKey $keystorePasswordSecName $keystorePasswordKey }}
- name: uniflogging-secret-keystore
  secret:
    secretName: {{ $keystoreSecName }}
    items:
    - key: {{ $keystoreKey }}
      path: {{ $unifloggingStructure.keystore.filename }}
- name: uniflogging-secret-keystore-password
  secret:
    secretName: {{ $keystorePasswordSecName }}
    items:
    - key: {{ $keystorePasswordKey }}
      path: {{ $unifloggingStructure.keystore.password.filename }}
    {{- end }}
    {{- if and $truststoreSecName $truststoreKey $truststorePasswordSecName $truststorePasswordKey }}
- name: uniflogging-secret-truststore
  secret:
    secretName: {{ $truststoreSecName }}
    items:
    - key: {{ $truststoreKey }}
      path: {{ $unifloggingStructure.truststore.filename }}
- name: uniflogging-secret-truststore-password
  secret:
    secretName: {{ $truststorePasswordSecName }}
    items:
    - key: {{ $truststorePasswordKey }}
      path: {{ $unifloggingStructure.truststore.password.filename }}
    {{- end }}
    {{- if $tlsSecretRefName }}
        {{- if and (not $keystoreSecName) (not $keystorePasswordSecName)}}
- name: uniflogging-secret-keystore
  secret:
    secretName: {{ $tlsSecretRefName }}
    items:
    - key: {{ $mergedrsyslog.tls.secretRef.keyNames.tlsCrt }}
      path: {{ $unifloggingStructure.tls.crtfilename }}
- name: uniflogging-secret-keystore-password
  secret:
    secretName: {{ $tlsSecretRefName }}
    items:
    - key: {{ $mergedrsyslog.tls.secretRef.keyNames.tlsKey }}
      path: {{ $unifloggingStructure.tls.keyfilename }}
        {{- end }}
        {{- if and (not $truststoreSecName) (not $truststorePasswordSecName)}}
- name: uniflogging-secret-truststore
  secret:
    secretName: {{ $tlsSecretRefName }}
    items:
    - key: {{ $mergedrsyslog.tls.secretRef.keyNames.caCrt }}
      path: {{ $unifloggingStructure.tls.cafilename }}
        {{- end }}
    {{- end }}
{{- else if and $certManagerEnabled (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) }}
- name: uniflogging-secret-keystore
  secret:
    secretName: {{ $certificateSecretName }}
    items:
    - key: tls.crt
      path: {{ $unifloggingStructure.tls.crtfilename }}
- name: uniflogging-secret-keystore-password
  secret:
    secretName: {{ $certificateSecretName }}
    items:
    - key: tls.key
      path: {{ $unifloggingStructure.tls.keyfilename }}
- name: uniflogging-secret-truststore
  secret:
    secretName: {{ $certificateSecretName }}
    items:
    - key: ca.crt
      path: {{ $unifloggingStructure.tls.cafilename }}
{{- end }}      
{{- end }}