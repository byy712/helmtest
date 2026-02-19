{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cpro.prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "cpro.server.replicas" -}}
{{- if .Values.ha.enabled -}}
{{- print .Values.server.replicaCount -}}
{{- else -}}
{{- print 1 -}}
{{- end -}}
{{- end -}}

{{- define "cpro.alertmanager.replicas" -}}
{{- if .Values.ha.enabled -}}
{{- print .Values.alertmanager.replicaCount -}}
{{- else -}}
{{- print 1 -}}
{{- end -}}
{{- end -}}

{{- define "cpro.getTimeZone" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{-  print .Values.timeZone.timeZoneEnv }}
{{- else if .Values.global.timeZoneEnv -}}
{{- print .Values.global.timeZoneEnv | default "UTC" | quote }}
{{- else if .Values.timeZoneName -}}
{{- print .Values.timeZoneName }}
{{- else }}
{{- print .Values.global.timeZoneName | default "UTC" | quote }}
{{- end }}
{{- end }}

{{- define "cpro.timeZoneEnvName" }}
- name: TZ
  value:  {{include "cpro.timeZoneEnvNameWithoutQuote" .}}
{{- end }}

{{- define "cpro.timeZoneEnvNameWithoutQuote" }}
{{- include "cpro.getTimeZone" . | replace "\"" "" }}
{{- end }}


{{/* cpro terminationMessagePath and policy */}}
{{- define "cpro.terminationMessage" -}}
terminationMessagePath: {{ .Values.terminationMessagePath }}
terminationMessagePolicy: {{ .Values.terminationMessagePolicy }}
{{- end -}}

{{- define "cpro.common.labels.withOutChartVersion" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/component: "Fault_and_Performance_Management"
app.kubernetes.io/part-of: {{ .Values.partOf | default .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified alertmanager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "cpro.prometheus.alertmanager.fullname" -}}
{{- if .Values.alertmanager.fullnameOverride -}}
{{- .Values.alertmanager.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}



{{/*
Create a fully qualified kube-state-metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.fullname" -}}
{{- if .Values.kubeStateMetrics.fullnameOverride -}}
{{- .Values.kubeStateMetrics.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified node-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.nodeExporter.fullname" -}}
{{- if .Values.nodeExporter.fullnameOverride -}}
{{- .Values.nodeExporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified node-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.nodeExporter.fullnameHeadless" -}}
{{- if .Values.nodeExporter.fullnameOverride -}}
{{- printf "%s-%s" "scr" .Values.nodeExporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s-%s" "scr" .Release.Name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s-%s" "scr" .Release.Name $name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Create a fully qualified name for migrate.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.migrate.fullname" -}}
{{- if .Values.server.migrate.fullnameOverride -}}
{{- .Values.server.migrate.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.migrate.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.migrate.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}



{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified pushgateway name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.pushgateway.fullname" -}}
{{- if .Values.pushgateway.fullnameOverride -}}
{{- .Values.pushgateway.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.pushgateway.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.pushgateway.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified webhook4fluentd name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.webhook4fluentd.fullname" -}}
{{- if .Values.webhook4fluentd.fullnameOverride -}}
{{- .Values.webhook4fluentd.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.webhook4fluentd.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.webhook4fluentd.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified restserver name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.restserver.fullname" -}}
{{- if .Values.restserver.fullnameOverride -}}
{{- .Values.restserver.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.restserver.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.restserver.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
append the name for service accounts
*/}}
{{- define "cpro.prometheus.serviceaccountextension" -}}
{{- if ( and  .Values.rbac.enabled ( or .Values.rbac.psp.create .Values.rbac.scc.create )) -}}
{{- print "" -}}
{{- else -}}
{{- print "-dsbld" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified name for serviceAccount for alertmanager, kubeStateMetrics, pushgateway, server,
webhook4fluentd, restserver and migrate components
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.serviceAccount.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s%s" .Release.Name (include "cpro.prometheus.serviceaccountextension" .) -}}
{{- else -}}
{{- printf "%s-%s%s" .Release.Name $name (include "cpro.prometheus.serviceaccountextension" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified name for serviceAccount for nodeExporter component.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.exporters.serviceAccount.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for alertmanager, kubeStateMetrics, pushgateway, server,
webhook4fluentd, restserver and migrate components
*/}}
{{- define "cpro.prometheus.serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
    {{- print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- print (include "cpro.prometheus.serviceAccount.fullname" .) -}}
{{- else -}}
    {{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the nodeExporter components
*/}}
{{- define "cpro.prometheus.node.serviceAccountName" -}}
{{- if .Values.exportersServiceAccountName -}}
    {{ default "default" .Values.exportersServiceAccountName }}
{{- else if .Values.rbac.enabled -}}
    {{ printf "%s-node%s" (include "cpro.prometheus.exporters.serviceAccount.fullname" .) (include "cpro.prometheus.serviceaccountextension" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}
{{- end -}}



{{/* Return the cpro component labels or annotations */}}
{{- define "cpro.labelsOrAnnotations" -}}
{{- $finalDict := dict }}
{{- range $map := . }}
{{- if not (empty $map) }}
{{- $finalDict := merge $finalDict $map }}
{{- end }}
{{- end }}
{{- range $key, $value := $finalDict }}
{{ $key | quote }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{/* Return the cpro ingress extra labels */}}
{{- define "cpro.extraLabels" -}}
{{- $finalDict := dict }}
{{- range $map := . }}
{{- if not (empty $map) }}
{{- $finalDict := merge $finalDict $map }}
{{- end }}
{{- end }}
{{- range $key, $value := $finalDict }}
{{ $key }}: {{ $value }}
{{- end }}
{{- end -}}

{{/*
Create the name for the uri route-prefix
*/}}
{{- define "cpro.pushgateway.routePrefixURL" -}}
{{- if ne .Values.pushgateway.prefixURL "" }}
{{- printf "/%s" .Values.pushgateway.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.pushgateway.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name for the uri route-prefix
*/}}
{{- define "cpro.alertmanager.routePrefixURL" -}}
{{- if ne .Values.alertmanager.prefixURL "" }}
{{- printf "/%s" .Values.alertmanager.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.alertmanager.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
cert manager config secret name
*/}}
{{- define "cpro.certManagerConfig.secretName" -}}
{{- printf "etcdcerts-%s-%s" .Release.Name (include "cpro.prometheus.name" .) -}}
{{- end -}}

{{/*
cert manager config resource name
*/}}
{{- define "cpro.certManagerConfig.resourceName" -}}
{{- printf "etcdcerts-%s-%s" .Release.Name (include "cpro.prometheus.name" .) -}}
{{- end -}}


{{/*
Create the name for the uri route-prefix
*/}}
{{- define "cpro.server.routePrefixURL" -}}
{{- if ne .Values.server.prefixURL "" }}
{{- printf "/%s" .Values.server.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.server.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the deployment name
*/}}
{{- define "cpro.prometheus.restserver.deploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.restServerPod.name -}}
{{- $name := .Values.customResourceNames.restServerPod.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.restserver "restserver" .Values.customResourceNames.restServerPod.name) }}
{{- else -}}
{{- $name := .Values.customResourceNames.restServerPod.name | default (include "cpro.prometheus.restserver.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the helm test deployment name
*/}}
{{- define "cpro.prometheus.restserver.helmTestDeploymentName" -}}
{{- $name := printf "%s-%s-%s" .Release.Name .Chart.Name "restapi-test" -}}
{{- if ne .Values.customResourceNames.restServerHelmTestPod.name ""}}
{{- $name = .Values.customResourceNames.restServerHelmTestPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.restserver "restapitest" .Values.customResourceNames.restServerHelmTestPod.name) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the restserver helm test container name
*/}}
{{- define "cpro.prometheus.restserver.helmTestRestServerContainerName" -}}
{{- $name := printf "%s" "restapi-test" -}}
{{- if ne .Values.customResourceNames.restServerHelmTestPod.testContainer "" }}
{{- $name = .Values.customResourceNames.restServerHelmTestPod.testContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return restserver init container name
*/}}
{{- define "cpro.prometheus.restserver.initToolsContainerName" -}}
{{- $name := printf "%s" "restapi-init" -}}
{{- if ne .Values.customResourceNames.toolsPod.initContainer "" }}
{{- $name = .Values.customResourceNames.toolsPod.initContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the restserver container name
*/}}
{{- define "cpro.prometheus.restserver.restServerContainerName" -}}
{{- $name := printf "%s" .Values.restserver.name -}}
{{- if ne .Values.customResourceNames.restServerPod.restServerContainer "" }}
{{- $name = .Values.customResourceNames.restServerPod.restServerContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the configmap container name
*/}}
{{- define "cpro.prometheus.restserver.configmapReloadContainerName" -}}
{{- $contName := (tpl .Values.restserver.configmapReload.name $ )}}
{{- $name := printf "%s" $contName -}}
{{- if ne .Values.customResourceNames.restServerPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.restServerPod.configMapReloadContainer -}}
{{- end -}}
{{- printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ))}}
{{- end -}}


{{/*
Return the alertmanager statefulSet name
*/}}
{{- define "cpro.prometheus.alertmanager.StsName" -}}
{{- if and (not .Values.usePodNamePrefixAlways) (or .Values.nameOverride .Values.alertmanager.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.alertManagerPod.name | default (include "cpro.prometheus.alertmanager.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the alertmanager deployment name
*/}}
{{- define "cpro.prometheus.alertmanager.DeploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.alertManagerPod.name -}}
{{- $name := .Values.customResourceNames.alertManagerPod.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.alertmanager "alertmanager" .Values.customResourceNames.alertManagerPod.name) }}
{{- else -}}
{{- $name := .Values.customResourceNames.alertManagerPod.name | default (include "cpro.prometheus.alertmanager.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the alertmanager container name
*/}}
{{- define "cpro.prometheus.alertmanager.alertmanagerContainerName" -}}
{{- $name := printf "%s" .Values.alertmanager.name -}}
{{- if ne .Values.customResourceNames.alertManagerPod.alertManagerContainer "" }}
{{- $name = .Values.customResourceNames.alertManagerPod.alertManagerContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the alertmanager configmap preload container name
*/}}
{{- define "cpro.prometheus.alertmanager.alertmanagerReloadContainerName" -}}
{{- $contName := (tpl .Values.alertmanager.configmapReload.name $ )}}
{{- $name := printf "%s" $contName -}}
{{- if ne .Values.customResourceNames.alertManagerPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.alertManagerPod.configMapReloadContainer -}}
{{- end -}}
{{- printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" .)) }}
{{- end -}}


{{/*
Return the server deployment name
*/}}
{{- define "cpro.prometheus.server.DeploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.serverPod.name -}}
{{- $name := .Values.customResourceNames.serverPod.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.server "server" .Values.customResourceNames.serverPod.name) }}
{{- else -}}
{{- $name :=.Values.customResourceNames.serverPod.name | default (include "cpro.prometheus.server.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the server statefulSet name
*/}}
{{- define "cpro.prometheus.server.StsName" -}}
{{- if and (not .Values.usePodNamePrefixAlways) (or .Values.nameOverride .Values.server.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "cpro.prometheus.server.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name :=.Values.customResourceNames.serverPod.name | default (include "cpro.prometheus.server.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the InitConfigFileContainer name
*/}}
{{- define "cpro.prometheus.server.initConfigFileContainerName" -}}
{{- $name := printf "%s" .Values.initConfigFile.name -}}
{{- if ne .Values.customResourceNames.serverPod.inCntInitConfigFile "" }}
{{- $name = .Values.customResourceNames.serverPod.inCntInitConfigFile -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}




{{/*
Return the server cburaSidecar Container  name
*/}}


{{- define "cpro.prometheus.server.cburaSidecarContainerName" -}}
{{- $name := printf "%s" "cbura-sidecar" -}}
{{- if ne .Values.customResourceNames.serverPod.cburaSidecarContainer "" }}
{{- $customContainerName := .Values.customResourceNames.serverPod.cburaSidecarContainer -}}
{{- if gt (len $customContainerName) 28 }}
{{- $truncatedName := printf "%s" (printf "%s" $customContainerName | trunc 14) -}}
{{- $name = printf "%s-cbura-sidecar" $truncatedName -}}
{{- else }}
{{- $name = printf "%s" $customContainerName -}}
{{- end }}
{{- end -}}
{{- $finalContainerName := printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . )) -}}
{{- if ne (trunc -13 $finalContainerName) "cbura-sidecar"  }}
{{- required "cbur sidecar container name should end with cbura-sidecar" "" }}
{{- else -}}
{{- $finalContainerName -}}
{{- end -}}
{{- end -}}

{{/*
Return the server configmap reload container name
*/}}
{{- define "cpro.prometheus.server.configmapReloadContainerName" -}}
{{- $contName := (tpl .Values.server.configmapReload.name $ )}}
{{- $name := printf "%s" $contName -}}
{{- if ne .Values.customResourceNames.serverPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.serverPod.configMapReloadContainer -}}
{{- end -}}
{{- printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . )) }}
{{- end -}}

{{/*
Return the monitoring container name
*/}}
{{- define "cpro.prometheus.server.monitoringContainerName" -}}
{{- $name := printf "%s" .Values.server.monitoringContainer.name -}}
{{- if ne .Values.customResourceNames.serverPod.monitoringContainer "" }}
{{- $name = .Values.customResourceNames.serverPod.monitoringContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the prometheus server container name
*/}}
{{- define "cpro.prometheus.server.prometheusContainerName" -}}
{{- $name := printf "%s" .Values.server.name -}}
{{- if ne .Values.customResourceNames.serverPod.serverContainer "" }}
{{- $name = .Values.customResourceNames.serverPod.serverContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the Cpro Util debug container name
*/}}
{{- define "cpro.prometheus.server.cproUtilContainerName" -}}
{{- $contName := (tpl .Values.server.cproUtil.name $ )}}
{{- $name := printf "%s" $contName -}}
{{- if ne .Values.customResourceNames.serverPod.cproUtil "" }}
{{- $name = .Values.customResourceNames.serverPod.cproUtil -}}
{{- end -}}
{{- printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . )) }}
{{- end -}}

{{/*
Return the alertmanager Util debug container name
*/}}
{{- define "cpro.prometheus.alertmanager.alertMgrUtilContainerName" -}}
{{- $contName := (tpl .Values.alertmanager.cproUtil.name $ )}}
{{- $name := printf "%s" $contName -}}
{{- if ne .Values.customResourceNames.alertManagerPod.cproUtil "" }}
{{- $name = .Values.customResourceNames.alertManagerPod.cproUtil -}}
{{- end -}}
{{- printf "%s" (include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . )) }}
{{- end -}}

{{/*
Return the pushgateway deployment name
*/}}
{{- define "cpro.prometheus.pushgateway.deploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.pushGatewayPod.name -}}
{{- $name := .Values.customResourceNames.pushGatewayPod.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.pushgateway "push" .Values.customResourceNames.pushGatewayPod.name) }}
{{- else -}}
{{- $name :=.Values.customResourceNames.pushGatewayPod.name | default (include "cpro.prometheus.pushgateway.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pushgateway container name
*/}}
{{- define "cpro.prometheus.pushgateway.ContainerName" -}}
{{- $name := printf "%s" .Values.pushgateway.name -}}
{{- if ne .Values.customResourceNames.pushGatewayPod.pushGatewayContainer "" }}
{{- $name = .Values.customResourceNames.pushGatewayPod.pushGatewayContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the kubeStateMetrics deployment name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.deploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.kubeStateMetricsPod.name -}}
{{- $name := .Values.customResourceNames.kubeStateMetricsPod.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.kubeStateMetrics "kubestate" .Values.customResourceNames.kubeStateMetricsPod.name) }}
{{- else -}}
{{- $name :=.Values.customResourceNames.kubeStateMetricsPod.name | default (include "cpro.prometheus.kubeStateMetrics.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the kubeStateMetrics container name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.ContainerName" -}}
{{- $name := printf "%s" .Values.kubeStateMetrics.name -}}
{{- if ne .Values.customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer "" }}
{{- $name = .Values.customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the hooks job name
*/}}
{{- define "cpro.prometheus.hooks.preDeleteDepName" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.alertmanager.fullname" .) "pre-del-jobs" -}}
{{- if ne .Values.customResourceNames.hooks.preDeleteJobName ""}}
{{- $name = .Values.customResourceNames.hooks.preDeleteJobName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.alertmanager "hookalert" .Values.customResourceNames.hooks.preDeleteJobName) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the hooks container name
*/}}
{{- define "cpro.prometheus.hooks.preDeleteContainerName" -}}
{{- $name := printf "%s" "pre-delete-job" -}}
{{- if ne .Values.customResourceNames.hooks.preDeleteContainer "" }}
{{- $name = .Values.customResourceNames.hooks.preDeleteContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the hooks job name
*/}}
{{- define "cpro.prometheus.hooks.postDeleteDepName" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.server.fullname" .) "delete-jobs" -}}
{{- if ne .Values.customResourceNames.hooks.postDeleteJobName ""}}
{{- $name = .Values.customResourceNames.hooks.postDeleteJobName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.server "hookserver" .Values.customResourceNames.hooks.postDeleteJobName) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the hooks container name
*/}}
{{- define "cpro.prometheus.hooks.containerName" -}}
{{- $name := printf "%s" "post-delete-job" -}}
{{- if ne .Values.customResourceNames.hooks.postDeleteContainer "" }}
{{- $name = .Values.customResourceNames.hooks.postDeleteContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the webhook4fluentd deployment name
*/}}
{{- define "cpro.prometheus.webhook4fluentd.deploymentName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.webhook4fluentd.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.webhook4fluentd.name -}}
{{- $name := .Values.customResourceNames.webhook4fluentd.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.webhook4fluentd "webhook" .Values.customResourceNames.webhook4fluentd.name) }}
{{- else -}}
{{- $name := .Values.customResourceNames.webhook4fluentd.name | default (include "cpro.prometheus.webhook4fluentd.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the webhook4fluentd container name
*/}}
{{- define "cpro.prometheus.webhook4fluentd.ContainerName" -}}
{{- $name := printf "%s" .Values.webhook4fluentd.name -}}
{{- if ne .Values.customResourceNames.webhook4fluentd.webhookContainer "" }}
{{- $name = .Values.customResourceNames.webhook4fluentd.webhookContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}



{{/*
Return the node exporter daemonset name
*/}}
{{- define "cpro.prometheus.nodeExporter.daemonSetName" -}}
{{- $name := printf "%s" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- if .Values.customResourceNames.nodeExporter.name -}}
{{- $name := .Values.customResourceNames.nodeExporter.name -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "DaemonSet" .Values.nodeExporter "nodeexp" .Values.customResourceNames.nodeExporter.name) }}
{{- else -}}
{{- $name := .Values.customResourceNames.nodeExporter.name | default (include "cpro.prometheus.nodeExporter.fullname" .) -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the node exporter container name
*/}}
{{- define "cpro.prometheus.nodeExporter.ContainerName" -}}
{{- $name := printf "%s" .Values.nodeExporter.name -}}
{{- if ne .Values.customResourceNames.nodeExporter.nodeExporterContainer "" }}
{{- $name = .Values.customResourceNames.nodeExporter.nodeExporterContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}



{{/*
Return the pre-upgrade job name
*/}}
{{- define "cpro.prometheus.migrate.preUpgradeJobName" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.migrate.fullname" .) "pre" -}}
{{- if ne .Values.customResourceNames.migrate.preUpgradeJobName ""}}
{{- $name = .Values.customResourceNames.migrate.preUpgradeJobName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.server "preupserver" .Values.customResourceNames.migrate.preUpgradeJobName) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the pre-upgrade container name
*/}}
{{- define "cpro.prometheus.migrate.preUpgradeContainer" -}}
{{- $name := printf "%s" "cpro-server" -}}
{{- if ne .Values.customResourceNames.migrate.preUpgradeContainer "" }}
{{- $name = .Values.customResourceNames.migrate.preUpgradeContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the post-upgrade job name
*/}}
{{- define "cpro.prometheus.migrate.postUpgradePodName" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.migrate.fullname" .) "post" -}}
{{- if ne .Values.customResourceNames.migrate.postUpgradePodName ""}}
{{- $name = .Values.customResourceNames.migrate.postUpgradePodName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.server "postupserver" .Values.customResourceNames.migrate.postUpgradePodName) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the post-upgrade container name
*/}}
{{- define "cpro.prometheus.migrate.postUpgradeContainer" -}}
{{- $name := printf "%s" "post-delete" -}}
{{- if ne .Values.customResourceNames.migrate.postUpgradeContainer "" }}
{{- $name = .Values.customResourceNames.migrate.postUpgradeContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the server helm test deployment name
*/}}
{{- define "cpro.prometheus.server.serverHelmTestPod" -}}
{{- $name := printf "%s-%s-%s" .Release.Name .Chart.Name "status-test" -}}
{{- if ne .Values.customResourceNames.serverHelmTestPod.name ""}}
{{- $name = .Values.customResourceNames.serverHelmTestPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Deployment" .Values.server "servertest" .Values.customResourceNames.serverHelmTestPod.name) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the server helm test container name
*/}}
{{- define "cpro.prometheus.server.serverHelmTestContainer" -}}
{{- $name := printf "%s" "status-test" -}}
{{- if ne .Values.customResourceNames.serverHelmTestPod.testContainer "" }}
{{- $name = .Values.customResourceNames.serverHelmTestPod.testContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{- define "cpro.prometheus.finalPodName" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix := $context.Values.global.podNamePrefix | default "" -}}
{{- $result := dict -}}
{{- $_ := set $result "finalName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}


{{/*
Create a fully qualified alertmanager name for helmtest.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.alertmanager.fullname.helmtest" -}}
{{- if .Values.ha.enabled -}}
{{ template "cpro.prometheus.alertmanager.fullname" . }}-ext
{{- else -}}
{{ template "cpro.prometheus.alertmanager.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name for helmtest.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.server.fullname.helmtest" -}}
{{- if .Values.ha.enabled -}}
{{ template "cpro.prometheus.server.fullname" . }}-ext
{{- else -}}
{{ template "cpro.prometheus.server.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "cpro.configure.progressDeadlineSeconds" -}}
{{- $compPDSValue := .compPDSValue -}}
{{- $key := "progressDeadlineSeconds" -}}
{{- $context := .context -}}
{{- if ($compPDSValue) -}}
{{- printf "%s: %d" $key ($compPDSValue |int) -}}
{{- else if $context.Values.progressDeadlineSeconds -}}
{{- printf "%s: %d" $key ($context.Values.progressDeadlineSeconds |int) -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified pvc name for server.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.server.pvc.name" -}}
{{- if .Values.ha.enabled -}}
{{- printf "%s-%s" "storage-volume" (include "cpro.prometheus.server.fullname" .) | trunc 61 | trimSuffix "-" -}}-[0-9]*
{{- else -}}
{{ template "cpro.prometheus.server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified pvc name for cbur.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.cbur.pvc.name" -}}
{{- if .Values.ha.enabled -}}
{{- printf "%s-%s" "cbur-storage-volume" (include "cpro.prometheus.server.fullname" .) | trunc 61 | trimSuffix "-" -}}-[0-9]*
{{- else -}}
{{- printf "%s-%s" (include "cpro.prometheus.server.fullname" .) "br" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
kubeStateMetrics client cert manager secret name
*/}}
{{- define "cpro.kubeStateMetrics.client.secret" -}}
{{- if (eq .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.kubeStateMetrics.certificate.secretName ) "true") }}
     {{- printf "client-%s" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.kubeStateMetrics.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
kubeStateMetrics client cert manager resource name
*/}}
{{- define "cpro.kubeStateMetrics.client.resourceName" -}}
{{- if (eq .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret "") }}
{{- printf "client-%s" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
kubeStateMetrics server cert manager secret name
*/}}
{{- define "cpro.kubeStateMetrics.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.kubeStateMetrics.tls.secretRef.name ) "true") }}
{{- printf .Values.kubeStateMetrics.tls.secretRef.name -}}
{{- else if (eq .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.kubeStateMetrics.certificate.secretName ) "true") }}
     {{- printf "server-%s" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.kubeStateMetrics.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
kubeStateMetrics server cert manager resource name
*/}}
{{- define "cpro.kubeStateMetrics.server.resourceName" -}}
{{- if (eq .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret "") }}
{{- printf "server-%s" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.kubeStateMetrics.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
nodeexporter client cert manager secret name
*/}}
{{- define "cpro.nodeexporter.client.secret" -}}
{{- if (eq .Values.nodeExporter.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.nodeExporter.certificate.secretName ) "true") }}
     {{- printf "client-%s" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.nodeExporter.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.nodeExporter.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
nodeexporter client cert manager resource name
*/}}
{{- define "cpro.nodeexporter.client.resourceName" -}}
{{- if (eq .Values.nodeExporter.tls_auth_config.tls.externalSecret "") }}
{{- printf "client-%s" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.nodeExporter.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
nodeexporter server cert manager secret name
*/}}
{{- define "cpro.nodeexporter.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.nodeExporter.tls.secretRef.name ) "true") }}
{{- printf .Values.nodeExporter.tls.secretRef.name -}}
{{- else if (eq .Values.nodeExporter.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.nodeExporter.certificate.secretName ) "true") }}
     {{- printf "server-%s" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.nodeExporter.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.nodeExporter.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
nodeexporter server cert manager resource name
*/}}
{{- define "cpro.nodeexporter.server.resourceName" -}}
{{- if (eq .Values.nodeExporter.tls_auth_config.tls.externalSecret "") }}
{{- printf "server-%s" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.nodeExporter.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
restserver client cert manager secret name
*/}}
{{- define "cpro.restserver.client.secret" -}}
{{- if (eq .Values.restserver.certificateSecret "certmanager") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.restserver.certificate.secretName ) "true") }}
     {{- printf "client-%s" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.restserver.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.restserver.certificateSecret -}}
{{- end -}}
{{- end -}}

{{/*
restserver client cert manager resource name
*/}}
{{- define "cpro.restserver.client.resourceName" -}}
{{- if (eq .Values.restserver.certificateSecret "certmanager") }}
{{- printf "client-%s" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.restserver.certificateSecret -}}
{{- end -}}
{{- end -}}

{{/*
restserver server cert manager secret name
*/}}
{{- define "cpro.restserver.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.restserver.tls.secretRef.name ) "true") }}
{{- printf .Values.restserver.tls.secretRef.name -}}
{{- else if (eq .Values.restserver.certificateSecret "certmanager") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.restserver.certificate.secretName ) "true") }}
     {{- printf "server-%s" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.restserver.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.restserver.certificateSecret -}}
{{- end -}}
{{- end -}}


{{/*
restserver server cert manager resource name
*/}}
{{- define "cpro.restserver.server.resourceName" -}}
{{- if (eq .Values.restserver.certificateSecret "certmanager") }}
{{- printf "server-%s" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.restserver.certificateSecret -}}
{{- end -}}
{{- end -}}

{{/*
pushgateway client cert manager secret name
*/}}
{{- define "cpro.pushgateway.client.secret" -}}
{{- if (eq .Values.pushgateway.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.pushgateway.certificate.secretName ) "true") }}
     {{- printf "client-%s" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.pushgateway.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.pushgateway.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
pushgateway client cert manager resource name
*/}}
{{- define "cpro.pushgateway.client.resourceName" -}}
{{- if (eq .Values.pushgateway.tls_auth_config.tls.externalSecret "") }}
{{- printf "client-%s" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.pushgateway.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
pushgateway server cert manager secret name
*/}}
{{- define "cpro.pushgateway.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.pushgateway.tls.secretRef.name ) "true") }}
{{- printf .Values.pushgateway.tls.secretRef.name -}}
{{- else if (eq .Values.pushgateway.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.pushgateway.certificate.secretName ) "true") }}
     {{- printf "server-%s" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.pushgateway.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.pushgateway.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
pushgateway server cert manager resource name
*/}}
{{- define "cpro.pushgateway.server.resourceName" -}}
{{- if (eq .Values.pushgateway.tls_auth_config.tls.externalSecret "") }}
{{- printf "server-%s" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.pushgateway.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
alertmanager client cert manager secret name
*/}}
{{- define "cpro.alertmanager.client.secret" -}}
{{- if (eq .Values.alertmanager.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.alertmanager.certificate.secretName ) "true") }}
    {{- printf "client-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.alertmanager.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.alertmanager.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
alertmanager client cert manager resource name
*/}}
{{- define "cpro.alertmanager.client.resourceName" -}}
{{- if (eq .Values.alertmanager.tls_auth_config.tls.externalSecret "") }}
{{- printf "client-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.alertmanager.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
alertmanager server cert manager secret name
*/}}
{{- define "cpro.alertmanager.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.alertmanager.tls.secretRef.name ) "true") }}
{{- printf (toString .Values.alertmanager.tls.secretRef.name) -}}
{{- else if (eq .Values.alertmanager.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.alertmanager.certificate.secretName ) "true") }}
    {{- printf "server-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.alertmanager.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.alertmanager.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
alertmanager server cert manager resource name
*/}}
{{- define "cpro.alertmanager.server.resourceName" -}}
{{- if (eq .Values.alertmanager.tls_auth_config.tls.externalSecret "") }}
{{- printf "server-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.alertmanager.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
server client cert manager secret name
*/}}
{{- define "cpro.server.client.secret" -}}
{{- if (eq .Values.server.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.server.certificate.secretName ) "true") }}
    {{- printf "client-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.server.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.server.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
server client cert manager resource name
*/}}
{{- define "cpro.server.client.resourceName" -}}
{{- if (eq .Values.server.tls_auth_config.tls.externalSecret "") }}
{{- printf "client-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.server.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
server server cert manager secret name
*/}}
{{- define "cpro.server.server.secret" -}}
{{- if (ne (include "csf-common-lib.v1.isEmptyValue" .Values.server.tls.secretRef.name ) "true") }}
{{- printf .Values.server.tls.secretRef.name -}}
{{- else if (eq .Values.server.tls_auth_config.tls.externalSecret "") }}
  {{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.server.certificate.secretName ) "true") }}
    {{- printf "server-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf (toString .Values.server.certificate.secretName) -}}
  {{- end }}
{{- else -}}
{{- printf .Values.server.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}

{{/*
server server cert manager resource name
*/}}
{{- define "cpro.server.server.resourceName" -}}
{{- if (eq .Values.server.tls_auth_config.tls.externalSecret "") }}
{{- printf "server-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf .Values.server.tls_auth_config.tls.externalSecret -}}
{{- end -}}
{{- end -}}


{{/*
prometheus server role name
*/}}
{{- define "cpro.prometheus.server.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus server cluster role name
*/}}
{{- define "cpro.prometheus.server.clusterrole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-servercr" .Release.Namespace)) }}
{{- end -}}

{{/*
prometheus server psp/scc name
*/}}
{{- define "cpro.prometheus.server.psporsccname" -}}
{{- if ( and .Values.rbac.psp.create .Values.rbac.scc.create ) -}}
{{- required "Either psp or scc has to be set to true not both at a time." "" -}}
{{- else -}}
{{- if and .Values.rbac.enabled .Values.rbac.psp.create -}}
{{- printf "%s-psp" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if and .Values.rbac.enabled .Values.rbac.scc.create -}}
{{- printf "%s-scc" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
prometheus server cluster role binding name
*/}}
{{- define "cpro.prometheus.server.clusterrolebinding" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRoleBinding" (printf "%s-servercrb" .Release.Namespace)) }} 
{{- end -}}

{{/*
prometheus server role binding name
*/}}
{{- define "cpro.prometheus.server.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus alertmanager psp name
*/}}
{{- define "cpro.prometheus.alertmanager.psp" -}}
{{- printf "%s-psp" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus alertmanager cluster role name
*/}}
{{- define "cpro.prometheus.alertmanager.clusterrole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-alertmgrcr" .Release.Namespace)) }}
{{- end -}}

{{/*
prometheus alertmanager role name
*/}}
{{- define "cpro.prometheus.alertmanager.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
kubestate metrics cluster role name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.clusterrole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-ksmcr" .Release.Namespace)) }}
{{- end -}}

{{/*
kubestate metrics role name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
kubestate metrics psp name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.psp" -}}
{{- printf "%s-psp" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
pushgateway cluster role name
*/}}
{{- define "cpro.prometheus.pushgateway.clusterrole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-pushgwcr" .Release.Namespace)) }}
{{- end -}}

{{/*
pushgateway role name
*/}}
{{- define "cpro.prometheus.pushgateway.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
prometheus pushgateway psp name
*/}}
{{- define "cpro.prometheus.pushgateway.psp" -}}
{{- printf "%s-psp" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apigroup for podsecuritypolicy in role or clusterrole
*/}}
{{- define "cpro.prometheus.apiGroupVersionExtensionsorPolicy" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions" -}}
{{- else -}}
{{- print "policy" -}}
{{- end -}}
{{- end -}}


{{/*
restserver cluster role name
*/}}
{{- define "cpro.prometheus.restserver.clusterrole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-restcr" .Release.Namespace)) }}
{{- end -}}

{{/*
restserver role name
*/}}
{{- define "cpro.prometheus.restserver.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
prometheus restserver psp name
*/}}
{{- define "cpro.prometheus.restserver.psp" -}}
{{- printf "%s-psp" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
node exporter role name
*/}}
{{- define "cpro.prometheus.nodeExporter.role" -}}
{{- printf "%s-role" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{/*
prometheus alertmanager role binding name
*/}}
{{- define "cpro.prometheus.alertmanager.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus kubeStateMetrics role binding name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.kubeStateMetrics.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
prometheus nodeExporter role binding name
*/}}
{{- define "cpro.prometheus.nodeExporter.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.nodeExporter.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus pushgatway role binding name
*/}}
{{- define "cpro.prometheus.pushgateway.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.pushgateway.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
prometheus restserver role binding name
*/}}
{{- define "cpro.prometheus.restserver.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.restserver.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
kubeStateMetrics cluster role binding name
*/}}
{{- define "cpro.prometheus.kubeStateMetrics.clusterrolebinding" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRoleBinding" (printf "%s-ksmcrb" .Release.Namespace)) }} 
{{- end -}}

{{/*
restserver cluster role binding name
*/}}
{{- define "cpro.prometheus.restserver.clusterrolebinding" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRoleBinding" (printf "%s-restcrb" .Release.Namespace)) }} 
{{- end -}}

{{/*
prometheus webhook4fluentd role binding name
*/}}
{{- define "cpro.prometheus.webhook4fluentd.rolebinding" -}}
{{- printf "%s-rolebinding" (include "cpro.prometheus.webhook4fluentd.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
*/}}

{{/*
cproconfigmapReload registry path
*/}}
{{- define "cpro.configmap.reload.imagepath" -}}
{{- printf "%s/%s:%s" .Values.global.registry1 (tpl .Values.configmapReload.distroImage.imageRepo $) (tpl .Values.configmapReload.distroImage.imageTag $) -}}
{{- end -}}

{{/*
Create a fully qualified name for psp/scc for nodeExporter component.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cpro.prometheus.exporters.psporscc.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Create the name of the psp/scc to use for the nodeExporter component
*/}}
{{- define "cpro.prometheus.nodeexporter.psporsccname" -}}
{{- if ( and .Values.rbac.psp.create .Values.rbac.scc.create ) -}}
{{- required "Either psp or scc has to be set to true not both at a time." "" -}}
{{- else -}}
{{- if and .Values.rbac.enabled .Values.rbac.psp.create -}}
    {{- printf "%s-node-psp" (include "cpro.prometheus.exporters.psporscc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if and .Values.rbac.enabled .Values.rbac.scc.create -}}
    {{- printf "%s-node-scc" (include "cpro.prometheus.exporters.psporscc.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ .Values.exportersPspName }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
When mvno is enabled, add alert_relabel_configs rule so that mvno label is added for all alerts
*/}}
{{- define "cpro.prometheus.server.alerting.mvno.label.add" -}}
{{- $context := .context -}}
{{- if $context.Values.server.mvno.enable }}
{{- if ne $context.Values.server.mvno.labelName "enterprise" }}
{{ printf "- source_labels: [enterprise]" | indent 6 }}
{{ printf "  target_label: cpro_mvno_temp_label" | indent 6 }}
{{ printf "  regex: ''" | indent 6 }}
{{ printf "  replacement: empty" | indent 6 }}
{{ printf "- source_labels: [cpro_mvno_temp_label, %s]" ($context.Values.server.mvno.labelName) | indent 6 }}
{{ printf "  target_label: enterprise" | indent 6 }}
{{ printf "  regex: empty;(.*)" | indent 6 }}
{{ printf "  replacement: $1" | indent 6 }}
{{ printf "- regex: 'cpro_mvno_temp_label'" | indent 6 }}
{{ printf "  action: labeldrop" | indent 6 }}
{{- else }}
{{ printf "- source_labels: [enterprise]" | indent 6 }}
{{ printf "  target_label: enterprise" | indent 6 }}
{{ printf "  regex: ''" | indent 6 }}
{{ printf "  replacement: \"%s\"" ($context.Values.server.mvno.defaultLabelValue) | indent 6 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Add metric_relabel_configs rule under scrape_configs
case 1: When mvno is enabled and labelValueToBeReplaced is set: if value of mvno.labelName is matching with labelValueToBeReplaced then replace it with mvno.defaultLabelValue followed by add rule to insert mvno.defaultLabelValue if mvno.labelName label itself was missing
case 2: When mvno is enabled and labelValueToBeReplaced is empty: Add rule to insert mvno.defaultLabelValue if mvno.labelName label itself was missing
case 3: When mvno is disabled and labelValueToBeReplaced is set: drop label mvno.labelName
case 4: When mvno is disabled and labelValueToBeReplaced is empty: No action done
*/}}
{{- define "cpro.prometheus.server.scrape.config.mvno.label.add" -}}
{{- $context := .context -}}
{{ printf "metric_relabel_configs:" }}
{{- if $context.Values.server.mvno.enable }}
{{- if ne $context.Values.server.mvno.labelValueToBeReplaced "" }}
{{ printf "- action: replace" | indent 6 }}
{{ printf "  regex: '%s'" ($context.Values.server.mvno.labelValueToBeReplaced) | indent 6 }}
{{ printf "  replacement: \"%s\"" ($context.Values.server.mvno.defaultLabelValue) | indent 6 }}
{{ printf "  source_labels: [%s]" ($context.Values.server.mvno.labelName) | indent 6 }}
{{ printf "  target_label: %s" ($context.Values.server.mvno.labelName) | indent 6 }}
{{ end }}
{{ printf "- source_labels: [%s]" ($context.Values.server.mvno.labelName) | indent 6 }}
{{ printf "  target_label: %s" ($context.Values.server.mvno.labelName) | indent 6 }}
{{ printf "  regex: ''" | indent 6 }}
{{ printf "  replacement: \"%s\"" ($context.Values.server.mvno.defaultLabelValue) | indent 6 }}
{{ else }}
{{- if ne $context.Values.server.mvno.labelValueToBeReplaced "" }}
{{ printf "- action: labeldrop" | indent 6 }}
{{ printf "  regex: '%s'" ($context.Values.server.mvno.labelName) | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Return the cpro-server Istio Gateway name
*/}}
{{- define "cpro.server.istioGatewayName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.server.fullname" .) "istio-gateway" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the cpro-alertmanager Istio Gateway name
*/}}
{{- define "cpro.alertmanager.istioGatewayName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.alertmanager.fullname" .) "istio-gateway" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the cpro-restserver Istio Gateway name
*/}}
{{- define "cpro.restserver.istioGatewayName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.restserver.fullname" .) "istio-gateway" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the cpro-pushgateway Istio Gateway name
*/}}
{{- define "cpro.pushgateway.istioGatewayName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.pushgateway.fullname" .) "istio-gateway" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{- define "cpro.prometheus.server.probe" -}}
{{- if semverCompare ">=1.18.0-0" .Capabilities.KubeVersion.GitVersion }}
startupProbe:
  httpGet:
{{- if .Values.server.useReadyInStartupProbe }}
    path: {{ template "cpro.server.routePrefixURL" . }}/-/ready
{{ else }}
    path: {{ template "cpro.server.routePrefixURL" . }}/-/healthy
{{- end }}
    port: tcp-metrics
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.server.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.server.startupProbe | indent 2 }}
{{- end }}
readinessProbe:
  httpGet:
    path: {{ template "cpro.server.routePrefixURL" . }}/-/ready
    port: tcp-metrics
{{- if  or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.server.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.server.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: {{ template "cpro.server.routePrefixURL" . }}/-/healthy
    port: tcp-metrics
{{- if  or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.server.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.server.livenessProbe | indent 2 }}
{{- end -}}

{{- define "cpro.prometheus.alertmanager.probe" }}
readinessProbe:
  httpGet:
    path: {{ template "cpro.alertmanager.routePrefixURL" . }}/#/status
    port: tcp-webport
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.alertmanager.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.alertmanager.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.alertmanager.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: {{ template "cpro.alertmanager.routePrefixURL" . }}/#/status
    port: tcp-webport
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.alertmanager.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.alertmanager.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.alertmanager.livenessProbe | indent 2 }}
{{- end -}}

{{- define "cpro.prometheus.pushgateway.probe" }}
readinessProbe:
  httpGet:
    path: {{ template "cpro.pushgateway.routePrefixURL" . }}/#/status
    port: tcp-metrics
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.pushgateway.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true")  .Values.pushgateway.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.pushgateway.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: {{ template "cpro.pushgateway.routePrefixURL" . }}/#/ready
    port: tcp-metrics
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.pushgateway.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true")  .Values.pushgateway.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.pushgateway.livenessProbe | indent 2 }}
{{- end -}}


{{- define "cpro.prometheus.kubeStateMetrics.probe" }}
readinessProbe:
  httpGet:
    path: /
    port: tcp-metrics
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.kubeStateMetrics.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.kubeStateMetrics.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.kubeStateMetrics.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: /healthz
    port: tcp-metrics
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.kubeStateMetrics.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.kubeStateMetrics.tls_auth_config.tls.enabled }}
    scheme: HTTPS
{{- end }}
{{ toYaml .Values.kubeStateMetrics.livenessProbe | indent 2 }}
{{- end -}}

{{- define "cpro.prometheus.nodeExporter.probe" }}
readinessProbe:
  tcpSocket:
    port: tcp-metrics
{{ toYaml .Values.nodeExporter.readinessProbe | indent 2 }}
livenessProbe:
  tcpSocket:
    port: tcp-metrics
{{ toYaml .Values.nodeExporter.livenessProbe | indent 2 }}
{{- end -}}

{{- define "cpro.prometheus.webhook4fluentd.probe" }}
readinessProbe:
  httpGet:
    path: /
    port: tcp-receiver
    {{- if or .Values.webhook4fluentd.tls.enabled (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.webhook4fluentd.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") }}
    scheme: HTTPS
    {{- end }}
{{ toYaml .Values.webhook4fluentd.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: /
    port: tcp-receiver
    {{- if or .Values.webhook4fluentd.tls.enabled (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.webhook4fluentd.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") }}
    scheme: HTTPS
    {{- end }}
{{ toYaml .Values.webhook4fluentd.livenessProbe | indent 2 }}
{{- end -}}


{{- define "cpro.prometheus.restserver.probe" }}
readinessProbe:
  httpGet:
    path: /cpro/v1/health
    port: tcp-health
{{ toYaml .Values.restserver.readinessProbe | indent 2 }}
livenessProbe:
  httpGet:
    path: /cpro/v1/health
    port: tcp-health
{{ toYaml .Values.restserver.livenessProbe | indent 2 }}
{{- end -}}

{{/* Cpro Alertmanager PodAntiAffinity */}}
{{- define "cpro.alertmanager.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.alertmanager.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.alertmanager.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.alertmanager.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.alertmanager.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.alertmanager.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/* Cpro webhook4fluentd PodAntiAffinity */}}
{{- define "cpro.webhook4fluentd.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.webhook4fluentd.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.webhook4fluentd.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.webhook4fluentd.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.webhook4fluentd.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.webhook4fluentd.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/* Cpro server PodAntiAffinity */}}
{{- define "cpro.server.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.server.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.server.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.server.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.server.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.server.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/* Cpro pushgateway PodAntiAffinity */}}
{{- define "cpro.pushgateway.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.pushgateway.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.pushgateway.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.pushgateway.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.pushgateway.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.pushgateway.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/* Cpro restserver PodAntiAffinity */}}
{{- define "cpro.restserver.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.restserver.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.restserver.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.restserver.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.restserver.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.restserver.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/* Cpro kubeStateMetrics PodAntiAffinity */}}
{{- define "cpro.kubeStateMetrics.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.kubeStateMetrics.antiAffinityMode "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.kubeStateMetrics.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro.prometheus.name" . }}
      - key: component
        operator: In
        values:
        - {{ .Values.kubeStateMetrics.name }}
      - key: release
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "topology.kubernetes.io/zone"
{{- else }}
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.kubeStateMetrics.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "kubernetes.io/hostname"
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "cpro.prometheus.name" . }}
        - key: component
          operator: In
          values:
          - {{ .Values.kubeStateMetrics.name }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/*
Prometheus Server post delete role name
*/}}
{{- define "cpro.prometheus.server.postDelete.role" -}}
{{- printf "post-del-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Prometheus Server post delete rolebinding name
*/}}
{{- define "cpro.prometheus.server.postDelete.roleBinding" -}}
{{- printf "post-del-%s" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Prometheus Server post delete service account name
*/}}
{{- define "cpro.prometheus.server.postDelete.serviceAccount" -}}
{{- printf "post-del-%s" (include "cpro.prometheus.serviceAccount.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Alert manager pre upgrade role name
*/}}
{{- define "cpro.prometheus.alertmanager.preUpgrade.role" -}}
{{- printf "pre-upg-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Alert manager pre upgrade rolebinding name
*/}}
{{- define "cpro.prometheus.alertmanager.preUpgrade.roleBinding" -}}
{{- printf "pre-upg-%s" (include "cpro.prometheus.alertmanager.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Alert manager pre upgrade service account name
*/}}
{{- define "cpro.prometheus.alertmanager.preUpgrade.serviceAccount" -}}
{{- printf "pre-upg-%s" (include "cpro.prometheus.serviceAccount.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the post restore job name
*/}}
{{- define "cpro.prometheus.cbur.postrestore.job" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.server.fullname" .) "post-restore" -}}
{{- if ne .Values.customResourceNames.postRestore.postRestoreJobName ""}}
{{- $name = .Values.customResourceNames.postRestore.postRestoreJobName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.server "postrestore" .Values.customResourceNames.postRestore.postRestoreJobName) }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pre-backup job name
*/}}
{{- define "cpro.prometheus.cbur.prebackup.job" -}}
{{- $name := printf "%s-%s" (include "cpro.prometheus.server.fullname" .) "pre-backup" -}}
{{- if ne .Values.customResourceNames.preBackup.preBackupJobName ""}}
{{- $name = .Values.customResourceNames.preBackup.preBackupJobName -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values.server "prebackserver") }}
{{- else -}}
{{ template "cpro.prometheus.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the post restore container name
*/}}
{{- define "cpro.prometheus.cbur.postrestore.container" -}}
{{- $name := printf "%s" "post-restore" -}}
{{- if ne .Values.customResourceNames.postRestore.postRestoreContainerName "" }}
{{- $name = .Values.customResourceNames.postRestore.postRestoreContainerName -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the post restore container name
*/}}
{{- define "cpro.prometheus.cbur.postbackup.container" -}}
{{- $name := printf "%s" "post-backup" -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the pre backup container name
*/}}
{{- define "cpro.prometheus.cbur.prebackup.container" -}}
{{- $name := printf "%s" "pre-backup" -}}
{{- if ne .Values.customResourceNames.preBackup.preBackupContainerName "" }}
{{- $name = .Values.customResourceNames.preBackup.preBackupContainerName -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
scheme for ksm
*/}}
{{- define "cpro.prometheus.ksm.scheme" -}}
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.kubeStateMetrics.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.kubeStateMetrics.tls_auth_config.tls.enabled -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
scheme for nodeexporter
*/}}
{{- define "cpro.prometheus.nodeExporter.scheme" -}}
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.nodeExporter.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.nodeExporter.tls_auth_config.tls.enabled -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
scheme for pushgateway
*/}}
{{- define "cpro.prometheus.pushgateway.scheme" -}}
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.pushgateway.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.pushgateway.tls_auth_config.tls.enabled -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
scheme for alertmanager
*/}}
{{- define "cpro.prometheus.alertmanager.scheme" -}}
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.alertmanager.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.alertmanager.tls_auth_config.tls.enabled -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
scheme for server
*/}}
{{- define "cpro.prometheus.server.scheme" -}}
{{- if or (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.server.tls_auth_config.tls.enabled -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
cermanager inCntWait4Certs2BeConsumed container
*/}}
{{- define "cpro.prometheus.certmanager.initcontainer" -}}
{{- $name := printf "%s" .Values.certManagerConfig.wait4Certs2BeConsumed.name -}}
{{- if ne .Values.customResourceNames.serverPod.inCntWait4Certs2BeConsumed "" }}
{{- $name = .Values.customResourceNames.serverPod.inCntWait4Certs2BeConsumed -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*PodDisruptionBudget Minavailable/MaxUnavailable */}}
{{- define "cpro.pdb-values" -}}
{{- if and ( and ( not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" )) }}
{{- required "Both the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- else if and (not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" ) }}
minAvailable: {{ .minAvailable }}
{{- else if and (not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" ) }}
maxUnavailable: {{ .maxUnavailable }}
{{- else }}
{{- required "None of the values(maxUnavailable/minAvailable) are set for pdb.Only One of the values to be set." "" }}
{{- end }}
{{- end -}}



{{/*
Prometheus python docker image
*/}}
{{- define "cpro.prometheus.python.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := .container }}
{{- $supportedflavour := list "rocky8-python3.8" }}
{{- $imageName := $root.Values.image.python }}
{{- $imagetag := split "-" ( toString $imageName.tag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $imageName.repo "internalRegisty" $root.Values.intPromUtilReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}"
imagePullPolicy: "{{ $imageName.imagePullPolicy }}"
{{- end -}}



{{/*
prometheus distro docker image
*/}}
{{- define "cpro.prometheus.distro.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := .container }}
{{- $supportedflavour := list "distroless" }}
{{- $imageName := $root.Values.image.distro }}
{{- $imagetag := split "-" ( toString $imageName.tag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $imageName.repo "internalRegisty" $root.Values.intPromMetricsReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}"
imagePullPolicy: "{{ $imageName.imagePullPolicy }}"
{{- end -}}


{{/*
helm delete docker image
*/}}
{{- define "cpro.helm.delete.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := .container }}
{{- $supportedflavour := list "rocky8" }}
{{- $imageName := $root.Values.helmDeleteImage.image }}
{{- $imagetag := split "-" ( toString $imageName.imageTag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $imageName.imageRepo "internalRegisty" $root.Values.intKubectlReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}-{{ $imagetag._2 }}"
imagePullPolicy: "{{ $imageName.imagePullPolicy }}"
{{- end -}}

{{/*
cbur docker image
*/}}
{{- define "cpro.helm.cbur.image" -}}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" . "imageInfo" .Values.server.cbur.image.imageRepo "internalRegisty" .Values.intCburReg ) }}:{{ .Values.server.cbur.image.imageTag }}"
imagePullPolicy: "{{ .Values.server.cbur.image.imagePullPolicy }}"
{{- end -}}


{{/*
Pod priorityClassName
*/}}
{{- define "cpro.pod.priority.classname" -}}
{{- if .component_pc.priorityClassName -}}
priorityClassName: {{ .component_pc.priorityClassName }}
{{- else if .ctx.Values.global.priorityClassName -}}
priorityClassName: {{ .ctx.Values.global.priorityClassName }}
{{- end -}}
{{- end -}}

{{/*
Prometheus Certmanager keysize
*/}}
{{- define "cpro.prometheus.certManagerConfig.keySize" -}}
{{- if ne (include "cpro.apiVersion.certManagerApiversion" .) "cert-manager.io/v1" -}}
keySize: {{ .Values.certManagerConfig.keySize }}
{{- end -}}
{{- end -}}

{{/*
Return the prometheus server cbur configmap name
*/}}
{{- define "cpro.prometheus.server.cbur.configmapName" -}}
{{ printf "%s-%s" "cbur" (include "cpro.prometheus.server.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}



{{/*
Rest server docker image
*/}}
{{- define "cpro.rest.server.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := .container }}
{{- $supportedflavour := list "distroless-jre17" }}
{{- $imageName := $root.Values.restserver.image.restapi }}
{{- $imagetag := split "-" ( toString $imageName.imageTag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $imageName.imageRepo "internalRegisty" $root.Values.intRestapiReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour) }}-{{ $imagetag._1 }}-{{ $imagetag._2 }}"
imagePullPolicy: "{{ $imageName.imagePullPolicy }}"
{{- end -}}

{{/*
CPRO dual stack ipFamilyPolicy config
*/}}
{{- define "cpro.dualStack.ipFamilyPolicy.config" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- if $context.ipFamilyPolicy }}
ipFamilyPolicy: {{ $context.ipFamilyPolicy }}
{{- else if $root.Values.global.ipFamilyPolicy }}
ipFamilyPolicy: {{ $root.Values.global.ipFamilyPolicy }}
{{- end }}
{{- end }}

{{/*
CPRO dual stack ipFamilies config
*/}}
{{- define "cpro.dualStack.ipFamilies.config" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- if $context.ipFamilies }}
ipFamilies: {{ $context.ipFamilies | toYaml | nindent 2 }}
{{- else if $root.Values.global.ipFamilies }}
ipFamilies: {{ $root.Values.global.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Metadata labels construction.
*/}}
{{- define "cpro.app.labels.v3" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- printf (include "cpro.common.labels.withOutChartVersion.v3" ( dict "root" $root "context" $context )) }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" $root.Chart.Name $root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the cpro common labels
*/}}
{{- define "cpro.common.labels.withOutChartVersion.v3" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- $name := $context.name -}}
{{- printf (include "cpro.selectorlabels.v3" ( dict "root" $root "context" $context )) }}
{{- if ( ne ( toString ( $root.Values.partOf )) "" ) }}
app.kubernetes.io/part-of: {{ $root.Values.partOf }}
{{- end }}
{{- if ( ne ( toString ( $root.Values.managedBy )) "" ) }}
app.kubernetes.io/managed-by: {{ $root.Values.managedBy }}
{{- else }}
app.kubernetes.io/managed-by: {{ $root.Release.Service | quote }}
{{- end }}
{{- end -}}

{{/*
Print cpro selector labels.
Note: These are the selector labels and do not add any version related labels in the selector labels
*/}}
{{- define "cpro.selectorlabels.v3" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- $name := $context.name -}}
app.kubernetes.io/instance: {{ $root.Release.Name | quote }}
app.kubernetes.io/name: {{ template "cpro.name" ( dict "root" $root "context" $context ) }}
app.kubernetes.io/component: {{ printf "%s" $name }}
{{- end -}}

{{/*
Create a cpro name.
*/}}
{{- define "cpro.name" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- default $root.Chart.Name $context.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
pdb suggestion warnings for alertmanager
*/}}
{{- define "cpro.alertmanager.pdb.warnings" -}}
{{- if and ( not .Values.ha.enabled ) ( .Values.alertmanager.pdb.enabled ) (hasKey .Values.alertmanager.pdb "minAvailable") -}}
{{- print "\nWARNING! Alertmanager: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and ( .Values.ha.enabled ) (gt (int .Values.alertmanager.replicaCount) 1) ( not .Values.alertmanager.pdb.enabled ) -}}
{{- print "\nWARNING! Alertmanager: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}

{{/*
timeZone Name env warnings for cpro
*/}}
{{- define "cpro.timeZoneEnvName.warnings" -}}
{{- if and (and (not .Values.timeZone.timeZoneEnv) (not .Values.global.timeZoneEnv)) (or (.Values.timeZoneName) (.Values.global.timeZoneName)) -}}
{{- print "\nWARNING! .Values.timeZoneName and .Values.global.timeZoneName are deprecated and will be removed as part next major release. Please configure timeZone.timeZoneEnv or global.timeZoneEnv instead" -}}
{{- end -}}
{{- end -}}

{{/*
pdb suggestion warnings for ksm
*/}}
{{- define "cpro.kubeStateMetrics.pdb.warnings" -}}
{{- if and (eq (int .Values.kubeStateMetrics.replicaCount) 1) ( .Values.kubeStateMetrics.pdb.enabled ) (hasKey .Values.kubeStateMetrics.pdb "minAvailable") -}}
{{- print "\nWARNING! KubeStateMetrics: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and (gt (int .Values.kubeStateMetrics.replicaCount) 1) ( not .Values.kubeStateMetrics.pdb.enabled ) -}}
{{- print "\nWARNING! KubeStateMetrics: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}

{{/*
pdb suggestion warnings for server
*/}}
{{- define "cpro.server.pdb.warnings" -}}
{{- if and ( not .Values.ha.enabled ) ( .Values.server.pdb.enabled ) (hasKey .Values.server.pdb "minAvailable") -}}
{{- print "\nWARNING! Server: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and ( .Values.ha.enabled ) (gt (int .Values.server.replicaCount) 1) ( not .Values.server.pdb.enabled ) -}}
{{- print "\nWARNING! Server: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}

{{/*
pdb suggestion warnings for pushgateway
*/}}
{{- define "cpro.pushgateway.pdb.warnings" -}}
{{- if and (eq (int .Values.pushgateway.replicaCount) 1) ( .Values.pushgateway.pdb.enabled ) (hasKey .Values.pushgateway.pdb "minAvailable") -}}
{{- print "\nWARNING! Pushgateway: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and (gt (int .Values.pushgateway.replicaCount) 1) ( not .Values.pushgateway.pdb.enabled ) -}}
{{- print "\nWARNING! Pushgateway: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}

{{/*
pdb suggestion warnings for webhook4fluentd
*/}}
{{- define "cpro.webhook4fluentd.pdb.warnings" -}}
{{- if and (eq (int .Values.webhook4fluentd.replicaCount) 1) ( .Values.webhook4fluentd.pdb.enabled ) (hasKey .Values.webhook4fluentd.pdb "minAvailable") -}}
{{- print "\nWARNING! Webhook4fluentd: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and  (gt (int .Values.webhook4fluentd.replicaCount) 1) ( not .Values.webhook4fluentd.pdb.enabled ) -}}
{{- print "\nWARNING! Webhook4fluentd: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}

{{/*
pdb suggestion warnings for restserver
*/}}
{{- define "cpro.restserver.pdb.warnings" -}}
{{- if and (eq (int .Values.restserver.replicaCount) 1) ( .Values.restserver.pdb.enabled ) (hasKey .Values.restserver.pdb "minAvailable") -}}
{{- print "\nWARNING! Restserver: It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and (gt (int .Values.restserver.replicaCount) 1) ( not .Values.restserver.pdb.enabled ) -}}
{{- print "\nWARNING! Restserver: PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}


{{/*
Ephemeral Storage Validation
*/}}
{{- define "cpro.ephemeral.storage" -}}
{{- $ephemeralstorage := .ephvol -}}
{{- $root := .eph -}}
{{- if  (semverCompare ">=1.19-0" $root.Capabilities.KubeVersion.GitVersion) -}}
{{- if and (hasKey $ephemeralstorage "ephemeralVolume") (hasKey $ephemeralstorage.ephemeralVolume "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $ephemeralstorage.ephemeralVolume.enabled false)) "true") }}
{{- $_ := set . "e1" $ephemeralstorage.ephemeralVolume }}
{{- $_ := set . "e2" "true" }}
{{- else if and (hasKey $root.Values.global "ephemeralVolume") (hasKey $root.Values.global.ephemeralVolume "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.global.ephemeralVolume.enabled false)) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $ephemeralstorage.ephemeralVolume.enabled ) "true") }}
{{- $_ := set . "e1" $root.Values.global.ephemeralVolume }}
{{- $_ := set . "e2" "true" }}
{{- end -}}
{{- if $.e2 }}
ephemeral:
  volumeClaimTemplate:
    spec:
      accessModes: {{ $ephemeralstorage.ephemeralVolume.volumedata.accessmodes }}
{{- if $ephemeralstorage.ephemeralVolume.volumedata.storageClass }}
{{- if (eq "-" $ephemeralstorage.ephemeralVolume.volumedata.storageClass) }}
      storageClassName:
{{- else }}
      storageClassName: "{{ $ephemeralstorage.ephemeralVolume.volumedata.storageClass }}"
{{- end }}
{{- end }}
      resources:
        requests:
          storage: {{ $ephemeralstorage.ephemeralVolume.volumedata.storageSize }}
{{- else -}}
emptyDir:
  sizeLimit: {{ index $ephemeralstorage.resources.requests "ephemeral-storage" | quote }}
{{- end }}
{{- else -}}
emptyDir:
  sizeLimit: {{ index $ephemeralstorage.resources.requests "ephemeral-storage" | quote }}
{{- end }}
{{- end }}

{{- define "cpro.helmtest.imagePullSecrets" -}}
{{- if or .Values.server.imagePullSecrets .Values.alertmanager.imagePullSecrets .Values.nodeExporter.imagePullSecrets .Values.kubeStateMetrics.imagePullSecrets .Values.pushgateway.imagePullSecrets }}
{{- $ips := concat .Values.server.imagePullSecrets .Values.alertmanager.imagePullSecrets .Values.nodeExporter.imagePullSecrets .Values.kubeStateMetrics.imagePullSecrets .Values.pushgateway.imagePullSecrets }}
{{- $ips := $ips | uniq }}
imagePullSecrets: {{- toYaml $ips | nindent 2 }}
{{- else if .Values.global.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "cpro.hooks.imagePullSecrets" -}}
{{- if or .Values.server.imagePullSecrets .Values.alertmanager.imagePullSecrets }}
{{- $ips := concat .Values.server.imagePullSecrets .Values.alertmanager.imagePullSecrets }}
{{- $ips := $ips | uniq }}
imagePullSecrets: {{- toYaml $ips | nindent 2 }}
{{- else if .Values.global.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- end }}
{{- end }}



{{/*
webhook4fluetd client cert manager secret name
*/}}
{{- define "cpro.webhook4fluentd.client.secretcertificate" -}}
{{- printf "client-%s" (include "cpro.prometheus.webhook4fluentd.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
webhook4fluetd server cert manager secret name
*/}}
{{- define "cpro.webhook4fluentd.server.secretcertificate" -}}
{{- printf "server-%s" (include "cpro.prometheus.webhook4fluentd.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}



*/}}
{{- define "cpro.prometheus.alertmanager.receiverconfig" -}}
{{- $context := .context -}}
{{- $port:=  $context.Values.webhook4fluentd.service.servicePort | toString -}}
{{ printf "- name: webhook" }}
{{ printf "  webhook_configs:" | indent 4 }}
{{- if or $context.Values.webhook4fluentd.tls.enabled $context.Values.tls.enabled }}
{{ printf "- url: https://%s.%s.svc.%s:%s" (include "cpro.prometheus.webhook4fluentd.fullname" $context )  ( $context.Release.Namespace ) ( $context.Values.clusterDomain ) $port | indent 6 }}
{{ printf "http_config:" | indent 8 }}
{{ printf "tls_config:" | indent 10 }}
{{ printf "ca_file: %s/ca.crt" ( $context.Values.webhook4fluentd.secretMountPath ) | indent 12 }}
{{ printf "cert_file: %s/tls.crt" ( $context.Values.webhook4fluentd.secretMountPath ) | indent 12 }}
{{ printf "key_file: %s/tls.key" ( $context.Values.webhook4fluentd.secretMountPath ) | indent 12 }}
{{- else }}
{{ printf "- url: http://%s.%s.svc.%s:%s" (include "cpro.prometheus.webhook4fluentd.fullname" $context )  ( $context.Release.Namespace ) ( $context.Values.clusterDomain ) $port | indent 6 }}
{{- end -}}
{{- end -}}


{{/*
Replaces __TPL_INCLUDE_NS__ with the list of namespaces in server.namespaceList
*/}}
{{- define "cpro.prometheus.server.scrape.config.includeNS" -}}
{{- $context := .context -}}
{{ printf "names:" }}
{{- if $context.Values.restrictedToNamespace }}
{{ range $key := $context.Values.server.namespaceList }}
{{ if not (has $key $context.Values.server.nsToExcludeFromCommonJobs )  }}
{{ printf "- %s" $key | nindent 12 }}
{{ end }}
{{ end }}
{{ if not (has $context.Release.Namespace $context.Values.server.namespaceList )  }}
{{- printf "- %s" $context.Release.Namespace | indent 12 -}}
{{ end }}
{{ end }}
{{ end }}

{{- define "cpro.createSelfSignedIssuer" -}}
{{- $result := "false" }}
{{- $root := index . 0 }}
{{- if and (eq (include "csf-common-lib.v1.isEmptyValue" $root.Values.certManager.issuerRef.name ) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $root.Values.global.certManager.issuerRef.name ) "true") }}
{{- $components := list $root.Values.alertmanager $root.Values.kubeStateMetrics $root.Values.nodeExporter $root.Values.pushgateway $root.Values.restserver $root.Values.server $root.Values.webhook4fluentd}}
{{- range $component := $components }}
{{- if and ( ( eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $component.tls.enabled $root.Values.tls.enabled $root.Values.global.tls.enabled false)) "true" )) ($component.certificate.enabled) }}
{{- if (eq (include "csf-common-lib.v1.isEmptyValue" $component.certificate.issuerRef.name) "true") }}
{{- $result = "true" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $result }}
{{- end -}}
