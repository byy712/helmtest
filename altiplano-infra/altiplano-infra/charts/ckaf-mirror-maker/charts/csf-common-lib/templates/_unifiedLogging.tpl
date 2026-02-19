{{/*
This template creates a dictionary structure for unified logging.
It has path for keystore, truststore and tls.

## Example

* Workload (named core)
** code snippet
+
----
{{- $unifloggingStructure := fromYaml (include "csf-common-lib.v1.unifiedLogging.structure" .) }}

- name: uniflogging-secret-keystore
  secret:
    secretName: certmanagerSecretName
    items:
    - key: tls.crt
      path: {{ $unifloggingStructure.tls.crtfilename }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.structure" -}}
keystore:
  dirName: "/var/clog-conf/keyStore"
  filename: "keystore.p12"
  password:
    dirName: "/var/clog-conf/keyStorePassword"
    filename: "keystorepassword"
truststore:
  dirName: "/var/clog-conf/trustStore"
  filename: "truststore.p12"
  password:
    dirName: "/var/clog-conf/trustStorePassword"
    filename: "truststorepassword"
tls:
  cafilename: "ca.crt"
  crtfilename: "tls.crt"
  keyfilename: "tls.key"
{{- end -}}


{{/*
This template checks if the syslog is enabled or not.
The unifiedlogging can be added at the global or workload level.
It checks at the provided workload level and if not found, it checks at the global level.
If protocol is not empty and syslog is enabled, it checks if protocol is SSL or not.
Returns none-empty string for success and empty for failure
## Parameters

Two parameters are expected.
* . - root
* workload - workload level under which unifiedlogging is defined

## Example

* Workload (named core)
** code snippet
+
----
{{- $workload := .Values.core }}
{{- if (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple . $workload)) }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" -}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $protocol := (coalesce $workload.unifiedLogging.syslog.protocol $root.Values.global.unifiedLogging.syslog.protocol) }}
    {{- if $protocol }}
        {{- if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.unifiedLogging.syslog.enabled $root.Values.global.unifiedLogging.syslog.enabled false)) "true") }}
            {{- if (eq $protocol "SSL") }}
            true
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}