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