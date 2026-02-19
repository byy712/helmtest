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

{{/*
This template creates the volumes for mounting, required for unifiedlogging. Such as keystore truststore and the configfile.

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
{{- include "csf-common-lib.v1.unifiedLogging.volumes" (tuple . $workload $certmanEnabled) | indent 8 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.volumes"}}
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
{{- $mergedrsyslog := merge $workload.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog }}

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
{{- else if and $certManagerEnabled (include "csf-common-test.proxy.unifiedLogging.isSyslogSSLEnabled" (tuple $root $workload)) }}
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


{{/*
This template configures the logging parameters for unified logging and syslog SSL.
It uses "csf-common-lib.v1.unifiedLogging.structure" template and gets the variables and utilizes them to generate configurations for Log4cxx.

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
{{- toYaml (include "csf-common-lib.v1.unifiedLogging.config" (tuple . .Values.core (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false)))) | indent 4 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.config" -}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $certManagerEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) "true") }}
  {{- if gt (len .) 2 }}
    {{- $certManagerEnabled = (index . 2 ) }}
  {{- end }}
{{- $unifloggingStructure := fromYaml (include "csf-common-lib.v1.unifiedLogging.structure" .) }}

{{- $mergedrsyslog := merge $workload.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog }}
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

{{/*
This template is used to generate the whole configmap with correct name and other parameters which will be mounted by the unifiedlogging templates.

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
{{- include "csf-common-lib.v1.unifiedLogging.configMap" (tuple . .Values.core) }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Log_3 of HBP v3.8.0

*/}}
{{- define "csf-common-lib.v1.unifiedLogging.configMap" -}}
{{- $root     := (index . 0 ) }}
{{- $workload     := (index . 1 ) }}
{{- $certManagerEnabled := (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.certManager.enabled $root.Values.global.certManager.enabled false)) "true") }}
  {{- if gt (len .) 2 }}
    {{- $certManagerEnabled = (index . 2 ) }}
  {{- end }}
{{- $suffix := "log4cxx" }}
{{- if $workload.nameSuffix }}
  {{- $suffix = printf "log4cxx-%s" $workload.nameSuffix }}
{{- end }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "csf-common-lib.v3.resourceName" ( tuple $root "ConfigMap" $suffix ) }}
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple $root $workload.name) | indent 4 }}
    {{- include "csf-common-lib.v1.customLabels" (tuple $workload.labels $root.Values.global.labels) | indent 4 }}
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple $workload.annotations $root.Values.global.annotations) | indent 4 }}
data:
  log4cxxproperty:
{{- (include "csf-common-test.proxy.unifiedLogging.config" (tuple $root $workload $certManagerEnabled)) | quote | indent 4 }}
{{- end }}
