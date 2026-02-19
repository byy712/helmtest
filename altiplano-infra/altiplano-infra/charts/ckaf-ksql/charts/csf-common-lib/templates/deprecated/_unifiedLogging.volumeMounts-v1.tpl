{{/*
This template defines volume mounts for unified logging.
It uses "csf-common-lib.v1.unifiedLogging.structure" template and gets the variables and utilizes them to determine volume mounts for keystore and truststore and the config file.

## Parameters

Two parameters are expected.
* . - root
* workload - workload level under which unifiedlogging is defined
* certManagerEnabled - ( optional ) defines if certmanager is enabled which will create the certificate for the rsyslog.

## Example

* Workload (named core)
** code snippet
+
----
volumeMounts:
  {{- include "csf-common-lib.v1.unifiedLogging.volumeMounts" (tuple . .Values.core (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false))) | indent 8 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.volumeMounts"}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $certManagerEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) "true") }}
  {{- if gt (len .) 2 }}
    {{- $certManagerEnabled = (index . 2 ) }}
  {{- end }}
{{- $unifloggingStructure := fromYaml (include "csf-common-lib.v1.unifiedLogging.structure" .) }}
{{- $mergedrsyslog := merge $workload.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog }}

- name: uniflogging-conf
  mountPath: "/etc/unified-logging/cpp-api"

  {{- if (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) }}
    {{- if and (not $certManagerEnabled) (not $mergedrsyslog.tls.secretRef.name) (or (not $mergedrsyslog.keyStore.secretName) (not $mergedrsyslog.keyStorePassword.secretName) (not $mergedrsyslog.trustStore.secretName) (not $mergedrsyslog.trustStorePassword.secretName))}}
      {{- fail "Please fill out either the keystore, truststore or the tls secret name in unifiedlogging. Or turn on certmanager." }}
    {{- end }}
- name: uniflogging-secret-keystore
  mountPath: {{ $unifloggingStructure.keystore.dirName }}
  readOnly: true
- name: uniflogging-secret-keystore-password
  mountPath: {{ $unifloggingStructure.keystore.password.dirName }}
  readOnly: true
- name: uniflogging-secret-truststore
  mountPath: {{ $unifloggingStructure.truststore.dirName }}
  readOnly: true
      {{- if and (coalesce $mergedrsyslog.trustStorePassword.secretName) }}
- name: uniflogging-secret-truststore-password
  mountPath: {{ $unifloggingStructure.truststore.password.dirName }}
  readOnly: true
      {{- end }}
  {{- end }}
{{- end }}