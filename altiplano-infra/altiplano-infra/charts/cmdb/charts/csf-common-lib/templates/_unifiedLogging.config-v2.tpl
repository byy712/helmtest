{{/*
This template configures the logging parameters for unified logging and syslog SSL.
It uses "csf-common-lib.v1.unifiedLogging.structure" template and gets the variables and utilizes them to generate configurations for Log4cxx.

## Changelog

### [v2]
#### Fixed
* Changed merge function usage to prevent sideeffects on workload values.

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
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "csf-common-lib.v3.resourceName" ( tuple . "ConfigMap" "log4cxx" ) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.core.name) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple .Values.core.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.core.annotations) | indent 4 }}
data:
  log4cxx.property:
{{- toYaml (include "csf-common-lib.v2.unifiedLogging.config" (tuple . .Values.core (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false)))) | indent 4 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v2.unifiedLogging.config" -}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $certManagerEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) "true") }}
  {{- if gt (len .) 2 }}
    {{- $certManagerEnabled = (index . 2 ) }}
  {{- end }}
{{- $unifloggingStructure := fromYaml (include "csf-common-lib.v1.unifiedLogging.structure" .) }}

{{- $mergedrsyslog := dict -}}
{{- $_ := merge $mergedrsyslog $workload.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog }}

{{- $loglevel := coalesce $workload.unifiedLogging.logLevel $root.Values.global.unifiedLogging.logLevel "INFO" }}
log4j.rootLogger={{ $loglevel }}, consoleAppender{{ if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.unifiedLogging.syslog.enabled $root.Values.global.unifiedLogging.syslog.enabled false)) "true") }}, rootsyslogAppender{{ end }}
log4j.appender.consoleAppender=org.apache.log4j.ConsoleAppender
log4j.appender.consoleAppender.layout.type=org.apache.log4j.JsonLayout
log4j.appender.consoleAppender.layout.encoding=UTF-8
{{- if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.unifiedLogging.syslog.enabled $root.Values.global.unifiedLogging.syslog.enabled false)) "true") }}
log4j.appender.rootsyslogAppender=org.apache.log4j.net.SyslogAppender
log4j.appender.rootsyslogAppender.Facility={{ $mergedrsyslog.facility }}
log4j.appender.rootsyslogAppender.syslogHost={{ $mergedrsyslog.host }}
log4j.appender.rootsyslogAppender.syslogPort={{ $mergedrsyslog.port }}
log4j.appender.rootsyslogAppender.protocol={{ $mergedrsyslog.protocol }}
log4j.appender.rootsyslogAppender.layout.encoding=UTF-8
    {{- if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload.unifiedLogging.syslog.rfc.enabled $root.Values.global.unifiedLogging.syslog.rfc.enabled false)) "true") }}
log4j.appender.rootsyslogAppender.layout.type=org.apache.log4j.Rfc5424Layout
log4j.appender.rootsyslogAppender.layout.appName={{ $mergedrsyslog.rfc.appName }}
log4j.appender.rootsyslogAppender.layout.procId={{ $mergedrsyslog.rfc.procId }}
log4j.appender.rootsyslogAppender.layout.msgId={{ $mergedrsyslog.rfc.msgId }}
log4j.appender.rootsyslogAppender.layout.version={{ $mergedrsyslog.rfc.version }}
    {{- else }}
log4j.appender.rootsyslogAppender.layout.Type=org.apache.log4j.SyslogLayout
    {{- end }}
    {{- if and (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) (or $mergedrsyslog.keyStore.secretName $mergedrsyslog.trustStore.secretName $mergedrsyslog.tls.secretRef.name) }}
        {{- if and $mergedrsyslog.keyStore.secretName $mergedrsyslog.keyStorePassword.secretName }}
log4j.appender.rootSyslogAppender.Ssl.KeyStore.type=PKCS12
log4j.appender.rootsyslogAppender.Ssl.KeyStore.location={{ $unifloggingStructure.keystore.dirName }}/{{ $unifloggingStructure.keystore.filename }}
log4j.appender.rootsyslogAppender.Ssl.KeyStore.passwordFile={{ $unifloggingStructure.keystore.password.dirName }}/{{ $unifloggingStructure.keystore.password.filename }}
        {{- end }}
        {{- if and $mergedrsyslog.trustStore.secretName $mergedrsyslog.trustStorePassword.secretName }}
log4j.appender.rootSyslogAppender.Ssl.TrustStore.type=PKCS12
log4j.appender.rootsyslogAppender.Ssl.TrustStore.location={{ $unifloggingStructure.truststore.dirName }}/{{ $unifloggingStructure.truststore.filename }}
log4j.appender.rootsyslogAppender.Ssl.TrustStore.passwordFile={{ $unifloggingStructure.truststore.password.dirName }}/{{ $unifloggingStructure.truststore.password.filename }}
        {{- end }}
        {{- if $mergedrsyslog.tls.secretRef.name }}
            {{- if and (not $mergedrsyslog.keyStore.secretName) (not $mergedrsyslog.keyStorePassword.secretName) }}
log4j.appender.rootsyslogAppender.SSL.KeyStore.type=RAW
log4j.appender.rootsyslogAppender.Ssl.KeyStore.location={{ $unifloggingStructure.keystore.password.dirName }}/{{ $unifloggingStructure.tls.keyfilename }}
log4j.appender.rootsyslogAppender.SSL.CertStore.type=RAW
log4j.appender.rootsyslogAppender.SSL.CertStore.location={{ $unifloggingStructure.keystore.dirName }}/{{ $unifloggingStructure.tls.crtfilename }}
            {{- end }}
            {{- if and (not $mergedrsyslog.trustStore.secretName) (not $mergedrsyslog.trustStorePassword.secretName) }}
log4j.appender.rootsyslogAppender.SSL.TrustStore.type=RAW
log4j.appender.rootsyslogAppender.SSL.TrustStore.location={{ $unifloggingStructure.truststore.dirName }}/{{ $unifloggingStructure.tls.cafilename }}
            {{- end }}
        {{- end }}
    {{- else if and $certManagerEnabled (include "csf-common-lib.v1.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) }}
log4j.appender.rootsyslogAppender.SSL.KeyStore.type=RAW
log4j.appender.rootsyslogAppender.Ssl.KeyStore.location={{ $unifloggingStructure.keystore.password.dirName }}/{{ $unifloggingStructure.tls.keyfilename }}
log4j.appender.rootsyslogAppender.SSL.CertStore.type=RAW
log4j.appender.rootsyslogAppender.SSL.CertStore.location={{ $unifloggingStructure.keystore.dirName }}/{{ $unifloggingStructure.tls.crtfilename }}
log4j.appender.rootsyslogAppender.SSL.TrustStore.type=RAW
log4j.appender.rootsyslogAppender.SSL.TrustStore.location={{ $unifloggingStructure.truststore.dirName }}/{{ $unifloggingStructure.tls.cafilename }}
    {{- end }}
{{- end -}}
{{- end }}