{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cpro-grafana.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cpro-grafana.replicas" -}}
{{- if .Values.HA.enabled -}}
{{- print .Values.replicas -}}
{{- else -}}
{{- print 1 -}}
{{- end -}}
{{- end -}}

{{- define "cpro-grafana.timeZoneName" -}}
{{- if .Values.timeZone.timeZoneEnv }}
- name: TZ
  value: {{ .Values.timeZone.timeZoneEnv }}
{{- else if .Values.global.timeZoneEnv -}}
- name: TZ
  value: {{ .Values.global.timeZoneEnv | default "UTC" | quote }}
{{- else if .Values.timeZoneName -}}
- name: TZ
  value: {{ .Values.timeZoneName }}
{{- else }}
- name: TZ
  value: {{ .Values.global.timeZoneName | default "UTC" | quote }}
{{- end }}
{{- end }}

{{/*
timeZone Name env warnings for cpro-grafana
*/}}
{{- define "cpro-grafana.timeZoneEnvName.warnings" -}}
{{- if and (and (not .Values.timeZone.timeZoneEnv) (not .Values.global.timeZoneEnv)) (or (.Values.timeZoneName) (.Values.global.timeZoneName)) -}}
{{- print "\nWARNING! .Values.timeZoneName and .Values.global.timeZoneName are deprecated and will be removed as part next major release. Please configure timeZone.timeZoneEnv or global.timeZoneEnv instead" -}}
{{- end -}}
{{- end -}}

{{/*
Metadata labels
*/}}
{{- define "cpro-grafana.app.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/component: "Fault_and_Performance_Management"
app.kubernetes.io/part-of: {{ .Values.partOf | default .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end -}}

{{/*
New Metadata labels
*/}}
{{- define "cpro-grafana.app.labels-v3" -}}
{{- printf (include "cpro-grafana.common.labels.withOutChartVersion-v3" .) }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ template "cpro-grafana.chart" . }}
{{- end -}}

{{- define "cpro-grafana.common.labels.withOutChartVersion-v3" -}}
{{- printf (include "cpro-grafana.selectorLabels-v3" .) }}
{{- if ( ne ( toString ( .Values.partOf )) "" ) }}
app.kubernetes.io/part-of: {{ .Values.partOf }}
{{- end }}
{{- if ( ne ( toString ( .Values.managedBy )) "" ) }}
app.kubernetes.io/managed-by: {{ .Values.managedBy }}
{{- else }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}
{{- end -}}

{{/*
Note: Do not add version related labels in the selector label
*/}}
{{- define "cpro-grafana.selectorLabels-v3" -}}
app.kubernetes.io/name: {{ template "cpro-grafana.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/component: {{ .Values.grafana.name }}
{{- end -}}


{{/* Grafana terminationMessagePath and policy */}}
{{- define "cpro-grafana.terminationMessage" -}}
terminationMessagePath: {{ .Values.terminationMessagePath }}
terminationMessagePolicy: {{ .Values.terminationMessagePolicy }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cpro-grafana.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "cpro-grafana.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "cpro-grafana.serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
    {{- print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- printf "%s%s" (include "cpro-grafana.fullname" .) (include "cpro-grafana.serviceaccountextension" .) -}}
{{- else -}}
    {{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path for the virtual service.
*/}}
{{- define "cpro-grafana.rooturl" -}}
{{- $path := regexFind "[^/]+$" .Values.grafana_ini.server.root_url -}}
{{- if eq $path "" }}
{{- printf "" -}}
{{- else -}}
{{- printf "%s" $path -}}
{{- end -}}
{{- end -}}

{{/*
Return the probe url.
*/}}
{{- define "cpro-grafana.probe" -}}
{{- $grafurl := splitn "/" 4 .Values.grafana_ini.server.root_url -}}
{{- $path := printf "/%s" $grafurl._3 | trimSuffix "/" -}}
{{- printf "%s" $path -}}
{{- end -}}

{{/* Return the grafana component labels or annotations */}}
{{- define "cpro-grafana.labelsOrAnnotations" -}}
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

{{/*
Return the appropriate apiVersion for serviceEntry
*/}}
{{- define "cpro-grafana.apiVersionNetworkIstioV1Alpha3orV1Beta1" -}}
{{- if eq .Values.global.istioVersion "1.4" -}}
{{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
{{- print "networking.istio.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of delete datasource job
*/}}
{{- define "cpro-grafana.deleteDatasource" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "delete-datasource" -}}
{{- if ne .Values.customResourceNames.deleteDatasourceJobPod.name ""}}
{{- $name = .Values.customResourceNames.deleteDatasourceJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "deldatasource" .Values.customResourceNames.deleteDatasourceJobPod.name ) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of delete datasource container
*/}}
{{- define "cpro-grafana.deleteDatasourceContainer" -}}
{{- $name := printf "%s" "delete-datasource" -}}
{{- if ne .Values.customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer ""}}
{{- $name = .Values.customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
append the name for service accounts
*/}}
{{- define "cpro-grafana.serviceaccountextension" -}}
{{- if and .Values.rbac.enabled .Values.rbac.psp.create -}}
{{- print "" -}}
{{- else -}}
{{- print "-dsbld" -}}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of set datasource job
*/}}
{{- define "cpro-grafana.setDatasource" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "set-datasource" -}}
{{- if ne .Values.customResourceNames.setDatasourceJobPod.name ""}}
{{- $name = .Values.customResourceNames.setDatasourceJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "setdatasource" .Values.customResourceNames.setDatasourceJobPod.name ) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of set datasource container
*/}}
{{- define "cpro-grafana.setDatasourceContainer" -}}
{{- $name := printf "%s" "set-datasource" -}}
{{- if ne .Values.customResourceNames.setDatasourceJobPod.setDatasourceContainer ""}}
{{- $name = .Values.customResourceNames.setDatasourceJobPod.setDatasourceContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the pod name of post upgrade job
*/}}
{{- define "cpro-grafana.postUpgradejob" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "post-upgrade" -}}
{{- if ne .Values.customResourceNames.postUpgradeJobPod.name ""}}
{{- $name = .Values.customResourceNames.postUpgradeJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "postupgrade" .Values.customResourceNames.postUpgradeJobPod.name) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of post upgrade container
*/}}
{{- define "cpro-grafana.postUpgradejobContainer" -}}
{{- $name := printf "%s" "sqlitetomdb-post-upgrade" -}}
{{- if ne .Values.customResourceNames.postUpgradeJobPod.postUpgradeJobContainer ""}}
{{- $name = .Values.customResourceNames.postUpgradeJobPod.postUpgradeJobContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the pod name of post delete job
*/}}
{{- define "cpro-grafana.postDeletejobPod" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "delete-job" -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.name ""}}
{{- $name = .Values.customResourceNames.postDeleteJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "postdeljob" .Values.customResourceNames.postDeleteJobPod.name) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the pod name of post delete secret delete job
*/}}
{{- define "cpro-grafana.postDelSecretDeljobPod" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "del-secret-job" -}}
{{- if ne .Values.customResourceNames.postDeleteSecretJobPod.name ""}}
{{- $name = .Values.customResourceNames.postDeleteSecretJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "delsecret" .Values.customResourceNames.postDeleteSecretJobPod.name) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the pod name of post delete container
*/}}
{{- define "cpro-grafana.deletedbContainer" -}}
{{- $name := printf "%s" "grafana-deletedb" -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.deletedbContainer ""}}
{{- $name = .Values.customResourceNames.postDeleteJobPod.deletedbContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the pod name of post delete container
*/}}
{{- define "cpro-grafana.deletesecretsContainer" -}}
{{- $name := printf "%s" "post-delete-secrets" -}}
{{- if ne .Values.customResourceNames.postDeleteSecretJobPod.deletesecretsContainer ""}}
{{- $name = .Values.customResourceNames.postDeleteSecretJobPod.deletesecretsContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the pod name of import dashboard job
*/}}
{{- define "cpro-grafana.importDashboardjobPod" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "import-dashboard" -}}
{{- if ne .Values.customResourceNames.importDashboardJobPod.name ""}}
{{- $name = .Values.customResourceNames.importDashboardJobPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "impdashboard" .Values.customResourceNames.importDashboardJobPod.name) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the pod name of import dashboard container
*/}}
{{- define "cpro-grafana.importDashboardjobContainer" -}}
{{- $name := printf "%s" "import-dashboard" -}}
{{- if ne .Values.customResourceNames.importDashboardJobPod.importDashboardJobContainer ""}}
{{- $name = .Values.customResourceNames.importDashboardJobPod.importDashboardJobContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the statefulset name
*/}}
{{- define "cpro-grafana.stsName" -}}
{{- if and (not .Values.usePodNamePrefixAlways) (or .Values.nameOverride .Values.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "cpro-grafana.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.grafanaPod.name | default (include "cpro-grafana.fullname" .) -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the grafana init-container changedbschema
*/}}
{{- define "cpro-grafana.changeDbschema" -}}
{{- $name := printf "%s" "change-db-schema" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntChangeDbSchema "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntChangeDbSchema -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the grafana init-container FileMerge
*/}}
{{- define "cpro-grafana.GrafanaFileMerge" -}}
{{- $name := printf "%s" .Values.grafanaFileMerge.name | default "file-merge" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntGrafanaFileMerge "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntGrafanaFileMerge -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana init-container changeMariadbSchema
*/}}
{{- define "cpro-grafana.changeMariadbSchema" -}}
{{- $name := printf "%s" "change-mariadb-schema" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntChangeMariadbSchema "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntChangeMariadbSchema -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana init-container wait-for-mariadb
*/}}
{{- define "cpro-grafana.waitforMariadb" -}}
{{- $name := printf "%s" "wait-for-mariadb" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntWaitforMariadb "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntWaitforMariadb -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana init-container download-dashboard
*/}}
{{- define "cpro-grafana.downloadDashboards" -}}
{{- $name := printf "%s" "download-dashboards" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntDownloadDashboard "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntDownloadDashboard -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana container plugin-sidecar
*/}}
{{- define "cpro-grafana.pluginsidecarContainerName" -}}
{{- $name := printf "%s" "plugins-sidecar" -}}
{{- if ne .Values.customResourceNames.grafanaPod.pluginSidecarContainer "" }}
{{- $name = .Values.customResourceNames.grafanaPod.pluginSidecarContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana container grafana-dashboard
*/}}
{{- define "cpro-grafana.grafanaSidecarDashboard" -}}
{{- $name := printf "%s" "sc-dashboard" -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaSidecarDashboard "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaSidecarDashboard -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana container grafana-sane-authproxy
*/}}
{{- define "cpro-grafana.grafanaSaneAuthProxy" -}}
{{- $name := printf "%s" "sane-authproxy" -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaSaneAuthproxy "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaSaneAuthproxy -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana container grafana-mdb-tool
*/}}
{{- define "cpro-grafana.grafanaMdbtool" -}}
{{- $name := printf "%s" "grafana-mdb-tool" -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaMdbtool "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaMdbtool -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the grafana container grafana-sc-datasources
*/}}
{{- define "cpro-grafana.grafanaDatasource" -}}
{{- $name := printf "%s" "sc-datasources" -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaDatasource "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaDatasource -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/*
Return the Grafana Util debug container name
*/}}
{{- define "cpro-grafana.grafanaUtilContainerName" -}}
{{- $name := printf "%s" .Values.grafanaUtil.name | default "util" -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaUtil "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaUtil -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the grafana container grafanaContainer
*/}}
{{- define "cpro-grafana.grafanaContainer" -}}
{{- $name := printf "%s" .Chart.Name -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaContainer "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}



{{- define "cpro-grafana.finalPodName" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix := $context.Values.global.podNamePrefix | default "" -}}
{{- $result := dict -}}
{{- $_ := set $result "finalName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}

{{/*
Return the configmap dashboard provider name
*/}}
{{- define "cpro-grafana.configDashboards" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "config-dashboards" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the dashboard configmap name
*/}}
{{- define "cpro-grafana.dashboardsConfigmapName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "dashs" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the dashboard json configmap name
*/}}
{{- define "cpro-grafana.dashboardsJsonConfigmapName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "dashboards-json" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana ckey Service Entry name
*/}}
{{- define "cpro-grafana.ckeyServiceEntryName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "ckey-se" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana ckey virtua Service name
*/}}
{{- define "cpro-grafana.ckeyVirtualServiceName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "ckey-vs" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana Istio Destination Rule name
*/}}
{{- define "cpro-grafana.istioDestinationRule" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "scr" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana Istio Destination Rule name
*/}}
{{- define "cpro-grafana.istioGatewayName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "istio-gateway" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the sane ingress name
*/}}
{{- define "cpro-grafana.saneIngressName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "sane" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana Istio Virtual Service name
*/}}
{{- define "cpro-grafana.istioVirtualServiceName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "vs" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Grafana keycloak Secret name
*/}}
{{- define "cpro-grafana.keycloakSecretName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "keycloakcrt" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the post delete job serviceaccount name
*/}}
{{- define "cpro-grafana.postDeleteJobResourceName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "post-del" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the post upgrade job serviceaccount name
*/}}
{{- define "cpro-grafana.postUpgradejobResourceName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "post-upgrade" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the sidecar rolebinding name
*/}}
{{- define "cpro-grafana.sidecarRolebinding" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "rolebinding" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the sidecar role name
*/}}
{{- define "cpro-grafana.sidecarRole" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "role" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the grafana secret name
*/}}
{{- define "cpro-grafana.secretName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "ssl" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the grafana delete datasource name
*/}}
{{- define "cpro-grafana.deletedatasource" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "deletedatasource" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the grafana set dashboard name
*/}}
{{- define "cpro-grafana.setdashboard" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "setdashboard" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the grafana set datasource name
*/}}
{{- define "cpro-grafana.setdatasource" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "setdatasource" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
cert manager secret name
*/}}
{{- define "cpro-grafana.certManager.secretName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "certmanager-%s" (include "cpro-grafana.fullname" .) -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
cert manager resource name
*/}}
{{- define "cpro-grafana.certManager.resourceName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "certmanager-%s" (include "cpro-grafana.fullname" .) -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the grafana testPod name
*/}}
{{- define "cpro-grafana.testPod" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "status-test" -}}
{{- if ne .Values.customResourceNames.grafanaTestPod.name "" }}
{{- $name = .Values.customResourceNames.grafanaTestPod.name -}}
{{- end -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Pod" .Values "statustest" .Values.customResourceNames.grafanaTestPod.name) }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}

{{/*
Return the grafana testContainer name
*/}}
{{- define "cpro-grafana.testContainer" -}}
{{- $name := printf "%s" "test-container" -}}
{{- if ne .Values.customResourceNames.grafanaTestPod.grafanaTestContainer "" }}
{{- $name = .Values.customResourceNames.grafanaTestPod.grafanaTestContainer -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the grafana test resource final name
*/}}
{{- define "cpro-grafana.finalNames" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $result := dict -}}
{{- $_ := set $result "finalName" (printf "%s" $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}

{{/*
Create the name of the service account to use for the grafana test
*/}}
{{- define "cpro-grafana.testServiceAccountName" -}}
{{- $name := print "" -}}
{{- if .Values.serviceAccountName -}}
    {{- $name = print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- $name = print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- $name = printf "%s-%s" (include "cpro-grafana.fullname" .) "test-sa" -}}
{{- else -}}
    {{- $name = print "default" -}}
{{- end -}}
{{ template "cpro-grafana.finalNames" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Create the name of the service account to use for the grafana test
*/}}
{{- define "cpro-grafana.testRole" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "test-role" -}}
{{ template "cpro-grafana.finalNames" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Create the name of the service account to use for the grafana test
*/}}
{{- define "cpro-grafana.testRolebinding" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "test-rb" -}}
{{ template "cpro-grafana.finalNames" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Create the name of the configmap to use for the grafana test
*/}}
{{- define "cpro-grafana.testConfigmap" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "test-configmap" -}}
{{ template "cpro-grafana.finalNames" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Create the name of the job configmap to use for the grafana test
*/}}
{{- define "cpro-grafana.secretConfigmap" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "job" -}}
{{ template "cpro-grafana.finalNames" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the appropriate apiGroup for podsecuritypolicy in role or clusterrole.
*/}}
{{- define "cpro-grafana.apiGroupVersionExtensionsorPolicy" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions" -}}
{{- else -}}
{{- print "policy" -}}
{{- end -}}
{{- end -}}

{{/* Grafana PodDisruptionBudget Minavailable/MaxUnavailable */}}
{{- define "cpro-grafana.pdb.values" -}}
{{- if and (and (hasKey .Values.pdb "minAvailable") (hasKey .Values.pdb "maxUnavailable")) ( and ( not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" )) }}
{{- required "Both the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- else if and (hasKey .Values.pdb "minAvailable") (and (not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) ""))}}
minAvailable: {{ .Values.pdb.minAvailable }}
{{- else if and (hasKey .Values.pdb "maxUnavailable") (and (not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) ""))}}
maxUnavailable: {{ .Values.pdb.maxUnavailable }}
{{- else }}
{{- required "None of the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- end -}}
{{- end -}}


{{/* Grafana securityContext */}}
{{- define "cpro-grafana.securitycontext" -}}
{{- $SecurityContext := .cSecCtx -}}
{{- $root := .ctx -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $SecurityContext "seccompProfile") }}
        {{- $SecurityContext = omit $SecurityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
 {{- end }}
{{- if and ($root.Values.seLinuxOptions.enabled) (hasKey $root.Values.securityContext "seLinuxOptions") }}
{{- required "seLinux is configured at both global and securityContext level. Only One of the values to be set." "" }}
{{- end }}
{{- if eq ( toString ( .cSecCtx.fsGroup )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "fsGroup" -}}
{{- end }}
{{- if eq ( toString ( .cSecCtx.runAsUser )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "runAsUser" -}}
{{- end }}
{{- if $SecurityContext  }}
{{- toYaml $SecurityContext -}}
{{- end }}
{{- end -}}


{{/* Grafana PodAntiAffinity */}}
{{- define "cpro-grafana.podAntiAffinity" }}
podAntiAffinity:
{{- if eq .Values.nodeAntiAffinity "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "cpro-grafana.name" . }}
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
        - {{ template "cpro-grafana.name" . }}
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
          - {{ template "cpro-grafana.name" . }}
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
          - {{ template "cpro-grafana.name" . }}
        - key: release
          operator: In
          values:
          - {{ .Release.Name }}
      topologyKey: "topology.kubernetes.io/zone"
{{- end }}
{{- end }}

{{/*
secret name for cmdb provided by user in values.yaml or pre-created secret (non-certmanager secrets)
*/}}
{{- define "cpro-grafana.cmdb.userSecretName" -}}
{{- if and ( ne .Values.cmdb.certsecret  "certmanager" ) ( ne .Values.cmdb.certsecret  "" ) -}}
    {{- printf .Values.cmdb.certsecret }}
{{- else -}}
    {{- required "When cmdb is configured with ssl_mode either certmanager or certificates secret has to be provided" "" }}
{{- end -}}
{{- end -}}

{{/*
Return the mdb secret name
*/}}
{{- define "cpro-grafana.mdbSecretName" -}}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "mdbsecret" -}}
{{- printf "%s" ($name) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{/*
cermanager wait4Certs2BeConsumed init container name
*/}}
{{- define "cpro-grafana.certmanager.initcontainer" -}}
{{- $name := printf "%s" "file-validator" -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntWait4Certs2BeConsumed "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntWait4Certs2BeConsumed -}}
{{- end -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the grafana cburaSidecar Container  name
*/}}
{{- define "cpro-grafana.cburaSidecarContainerName" -}}
{{- $name := printf "%s" "cbura-sidecar" -}}
{{- if ne .Values.customResourceNames.grafanaPod.cburaSidecarContainer "" }}
{{- $customContainerName := .Values.customResourceNames.grafanaPod.cburaSidecarContainer -}}
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
Grafana utility docker image
*/}}
{{- define "cpro-grafana.utility.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := .container }}
{{- $imageName := .imageName }}
{{- $supportedflavour := list "rocky8" }}
{{- $imagetag := split "-" ( toString $root.Values.image.utility.imageTag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $root.Values.image.utility.imageRepo "internalRegisty" $root.Values.intGrafanaUtilReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}"
imagePullPolicy: "{{ $root.Values.image.utility.imagePullPolicy }}"
{{- end -}}


{{/*
Grafana python docker image
*/}}
{{- define "cpro-grafana.python.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container:=  .container}}
{{- $imageName := .imageName }}
{{- $supportedflavour := list "rocky8-python3.8" }}
{{- $imagetag := split "-" ( toString $root.Values.image.python.imageTag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $root.Values.image.python.imageRepo "internalRegisty" $root.Values.intGrafanaKiwiReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}-{{ $imagetag._2 }}"
imagePullPolicy: "{{ $root.Values.image.python.imagePullPolicy }}"
{{- end -}}

{{/*
Grafana distro docker image
*/}}
{{- define "cpro-grafana.distro.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container:=  .container}}
{{- $imageName := .imageName }}
{{- $supportedflavour := list "distroless" }}
{{- $imagetag := split "-" ( toString $root.Values.image.distro.imageTag ) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $root.Values.image.distro.imageRepo "internalRegisty" $root.Values.intCproGrafanaReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}-{{ $imagetag._2 }}"
imagePullPolicy: "{{ $root.Values.image.distro.imagePullPolicy }}"
{{- end -}}

{{/*
kubectl docker image
*/}}
{{- define "cpro-grafana.kubectl.image" -}}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container:=  .container}}
{{- $imageName := .imageName }}
{{- $supportedflavour := list "rocky8" }}
{{- $imagetag := split "-" ( toString $root.Values.helmDeleteImage.imagerocky.imageTag) }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $root.Values.helmDeleteImage.imagerocky.imageRepo "internalRegisty" $root.Values.intKubectlReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}-{{ $imagetag._2 }}"
imagePullPolicy: "{{ $root.Values.helmDeleteImage.imagerocky.imagePullPolicy }}"
{{- end -}}


{{/*
Pod priorityClassName
*/}}
{{- define "cpro-grafana.pod.pcName" -}}
{{- if .component_pc.priorityClassName -}}
priorityClassName: {{ .component_pc.priorityClassName }}
{{- else if .ctx.Values.global.priorityClassName -}}
priorityClassName: {{ .ctx.Values.global.priorityClassName }}
{{- end -}}
{{- end -}}

{{/*
Grafana Certmanager keysize
*/}}
{{- define "cpro-grafana.certManager.keySize" -}}
{{- if ne (include "cpro-grafana.grafanaApiVersion.certManager" .) "cert-manager.io/v1" -}}
keySize: {{ .Values.certManager.keySize }}
{{- end -}}
{{- end -}}

{{/*
Grafana dual stack ipFamilyPolicy config
*/}}
{{- define "cpro-grafana.dualStack.ipFamilyPolicy.config" -}}
{{- if .Values.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.ipFamilyPolicy }}
{{- else if .Values.global.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.global.ipFamilyPolicy }}
{{- end }}
{{- end }}

{{/*
Grafana dual stack ipFamilies config
*/}}
{{- define "cpro-grafana.dualStack.ipFamilies.config" -}}
{{- if .Values.ipFamilies }}
ipFamilies: {{ .Values.ipFamilies | toYaml | nindent 2 }}
{{- else if .Values.global.ipFamilies }}
ipFamilies: {{ .Values.global.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Grafana service name
*/}}
{{- define "cpro-grafana.service.name" -}}
{{- if ne .Values.service.nameOverride ""}}
{{- printf "%s" .Values.service.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" (include "cpro-grafana.fullname" .) -}}
{{- end -}}
{{- end }}



{{/*
Grafana container security context
*/}}
{{- define "cpro-grafana.containerSecurityContext" -}}
{{- $SecurityContext := .cSecCtx -}}
{{- $root := .ctx -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $SecurityContext "seccompProfile") }}
        {{- $SecurityContext = omit $SecurityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
 {{- end }}
{{- if and ( hasKey $SecurityContext "runAsGroup" ) (eq ( toString ( $SecurityContext.runAsGroup )) "auto") }}
{{- $SecurityContext = omit $SecurityContext "runAsGroup" -}}
{{- end }}
{{- if and ( hasKey $SecurityContext "runAsUser" ) (eq ( toString ( $SecurityContext.runAsUser )) "auto") }}
{{- $SecurityContext = omit $SecurityContext "runAsUser" -}}
{{- end }}
{{- if $SecurityContext  }}
{{- toYaml $SecurityContext -}}
{{- end }}
{{- end -}}


{{/*
pdb suggestion warnings
*/}}
{{- define "cpro-grafana.pdb.warnings" -}}
{{- if and ( not .Values.HA.enabled ) ( .Values.pdb.enabled ) (hasKey .Values.pdb "minAvailable") -}}
{{- print "\nWARNING! It is recommanded to set maxUnavailable=0, when PDB is enabled with 1 replica." -}}
{{- end -}}
{{- if and ( .Values.HA.enabled ) (gt (int .Values.replicas) 1) ( not .Values.pdb.enabled ) -}}
{{- print "\nWARNING! PDB could be enabled with maxUnavailable set to 1, when number of replica > 1." -}}
{{- end -}}
{{- end -}}


{{/*
Ephemeral Storage Validation
*/}}
{{- define "cpro-grafana.ephemeral.storage" -}}
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
    metadata:
      labels:
        {{- include "cpro-grafana.app.labels-v3" $root | nindent 8 }}
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
  sizeLimit: {{ index $root.Values.resources.requests "ephemeral-storage" | quote }}
{{- end }}
{{- else -}}
emptyDir:
  sizeLimit: {{ index $root.Values.resources.requests "ephemeral-storage" | quote }}
{{- end }}
{{- end }}


{{/*
Ephemeral Storage Validation for cbur
*/}}
{{- define "cpro-grafana.cbur.ephemeral.storage" -}}
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
    metadata:
      labels:
        {{- include "cpro-grafana.app.labels-v3" $root | nindent 8 }}
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


{{- define "cpro-grafana.syslog.grafana_ini" -}}
[paths]
  logs = /var/log/grafana
[log]
  mode = console file
[log.file]
  format = json
  log_rotate = true
  max_size_shift = 14
  daily_rotate = false
  max_days = 1
[log.console]
  format = console
{{- end -}}



{{- define "cpro-grafana.syslogValues" -}}
{{/*
As per HBP, precedence is given to syslog defined at workload level over global level.
If syslog is enabled at workload level, all syslog properties are read from the workload level.
Only if syslog is enabled at global level and left empty at workload level, then all syslog properties are read from the global level.
*/}}
{{- if and (hasKey .Values.grafana "unifiedLogging") (hasKey .Values.grafana.unifiedLogging "syslog")  (hasKey .Values.grafana.unifiedLogging.syslog "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.grafana.unifiedLogging.syslog.enabled false)) "true") }}
{{- $_ := set . "syslog" .Values.grafana.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- else if and (hasKey .Values.global "unifiedLogging") (hasKey .Values.global.unifiedLogging "syslog") (hasKey .Values.global.unifiedLogging.syslog "enabled") (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.global.unifiedLogging.syslog.enabled false)) "true") (eq (include "csf-common-lib.v1.isEmptyValue" .Values.grafana.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.global.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- end -}}
{{- end -}}

{{/*
custom container name
*/}}
{{- define "cpro-grafana.containername" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix := $context.Values.global.containerNamePrefix | default "" -}}
{{- $result := dict -}}
{{- $_ := set $result "finalConName" (printf "%s-%s" $prefix $name | trimPrefix "-" |  trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalConName -}}
{{- end -}}


{{/*
Return the fluentd configmap name
*/}}
{{- define "cpro-grafana.fluentdConfigmapName" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $finalname := printf "%s-%s" (include "cpro-grafana.fullname" $context) $name -}}
{{- printf "%s" ($finalname) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- end -}}

{{- define "cpro-grafana.ingressPathPrefix" -}}
{{- $root := .path }}
{{- $pathprefix := splitn "/" 3 $root.Values.ingress.path -}}
{{- $path := printf "/%s" $pathprefix._1 | trimSuffix "/" -}}
{{- printf "%s" $path -}}
{{- end -}}

{{- define "cpro-grafana.hosts" -}}
{{- range .Values.ingress.hosts }}
{{- if empty . }}
{{- printf "0"  }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro-grafana.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}
- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels: {{- include "cpro-grafana.selectorLabels"  (tuple $root $workload.name) | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "cpro-grafana.selectorLabels" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
app: {{ template "cpro-grafana.name" $root }}
release: {{ $root.Release.Name }}
{{- end -}}

{{/*
Return the pod name of delete dashboard job
*/}}
{{- define "cpro-grafana.deleteDashboardjobPod" -}}
{{- $name := printf "%s-%s" (include "cpro-grafana.fullname" .) "del-dash" -}}
{{- if and ( .Values.global.podNamePrefix ) (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "false") -}}
{{ include "cpro-common-lib.podnameprefix" (tuple . "Job" .Values "deldash") }}
{{- else -}}
{{ template "cpro-grafana.finalPodName" ( dict "name" $name "context" . ) }}
{{- end -}}
{{- end -}}


{{/*
Return the pod name of delete dashboard container
*/}}
{{- define "cpro-grafana.deleteDashboardjobContainer" -}}
{{- $name := printf "%s" "del-dash" -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}




{{/*
Update grafana ini for security admin_user and admin_password based on new sensitive data
*/}}
{{- define "cpro-grafana-update-grafanaIniSecurityForSensitiveData" -}}
{{- $key := .key }}
{{- $value := .value }}
{{- $Values := .Values }}
{{- $context := .context }}
{{- $secretPathPrefix := $Values.secretPathPrefix | default "/secrets" }}
{{- $usernameKey := $Values.grafana.security.keyNames.username | default "username" }}
{{- $passwordKey := $Values.grafana.security.keyNames.password | default "password" }}
    [{{ $key }}]
    {{- range $elem, $elemVal := $value }}
      {{- if eq $elem "admin_user" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/graf-security/" $usernameKey }}
      {{- else if eq $elem "admin_password" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/graf-security/" $passwordKey }}
      {{- else }}
        {{- if kindIs "string" $elemVal }}
      {{ $elem }} = {{ tpl $elemVal $context }}
        {{- else }}
      {{ $elem }} = {{ $elemVal }}
        {{- end }}
      {{- end }}
    {{- end -}}
{{- end -}}

{{/*
Update grafana ini for security database credentials based on new sensitive data
*/}}
{{- define "cpro-grafana-update-grafanaIniDatabase" -}}
{{- $key := .key }}
{{- $value := .value }}
{{- $Values := .Values }}
{{- $context := .context }}
{{- $secretPathPrefix := $Values.secretPathPrefix | default "/secrets" }}
{{- $dbuser := $Values.cmdb.auth.keyNames.username | default "username" }}
{{- $dbpass := $Values.cmdb.auth.keyNames.password | default "password" }}
    [{{ $key }}]
    {{- range $elem, $elemVal := $value }}
      {{- if eq $elem "user" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/cmdb-auth/" $dbuser }}
       {{- else if eq $elem "password" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/cmdb-auth/" $dbpass }}
      {{- else }}
        {{- if kindIs "string" $elemVal }}
      {{ $elem }} = {{ tpl $elemVal $context }}
        {{- else }}
      {{ $elem }} = {{ $elemVal }}
        {{- end }}
    {{- end }}
{{- end -}}
{{- end -}}

{{/*
Update grafana ini for oauth client_id and client_secret based on new sensitive data
*/}}
{{- define "cpro-grafana-update-grafanaIniOauth" -}}
{{- $key := .key }}
{{- $value := .value }}
{{- $Values := .Values }}
{{- $context := .context }}
{{- $secretPathPrefix := $Values.secretPathPrefix | default "/secrets" }}
{{- $clientId := $Values.keycloak.auth.keyNames.clientId | default "clientId" }}
{{- $clientSecret := $Values.keycloak.auth.keyNames.clientSecret | default "clientSecret" }}
    [{{ $key }}]
    {{- range $elem, $elemVal := $value }}
      {{- if eq $elem "client_id" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/keycloak-auth/" $clientId }}
      {{- else if eq $elem "client_secret" }}
      {{ $elem }} = {{ printf "$__file{%s%s%s}"  $secretPathPrefix "/keycloak-auth/" $clientSecret }}
      {{- else }}
        {{- if kindIs "string" $elemVal }}
      {{ $elem }} = {{ tpl $elemVal $context }}
        {{- else }}
      {{ $elem }} = {{ $elemVal }}
        {{- end }}
    {{- end }}
{{- end -}}
{{- end -}}


{{/*
Update grafana ini for default security admin_user and admin_password
*/}}
{{- define "cpro-grafana-update-grafanaIniSecurity" -}}
{{- $key := .key }}
{{- $value := .value }}
{{- $Values := .Values }}
{{- $credentialsSet := "false" }}
{{- $context := .context }}
{{- $release := .release }}
    [{{ $key }}]
    {{- range $elem, $elemVal := $value }}
        {{- if kindIs "string" $elemVal }}
          {{- if and (eq $elem "admin_password" ) (eq $elemVal "") }}
      admin_password = {{ printf "$__file{%s}" "/etc/secrets/password" }}
      {{- $credentialsSet = "true" }}
          {{- else if and (eq $elem "admin_user" ) (eq $elemVal "") }}
      admin_user = {{ printf "$__file{%s}" "/etc/secrets/username" }}
      {{- $credentialsSet = "true" }}
          {{- else }}
      {{ $elem }} = {{ tpl $elemVal $context }}
          {{- end }}
        {{- else }}
          {{- if and (eq $elem "admin_password" ) (eq (typeOf $elemVal) "<nil>") }}
      admin_password = {{ printf "$__file{%s}" "/etc/secrets/password" }}
      {{- $credentialsSet = "true" }}
          {{- else if and (eq $elem "admin_user" ) (eq (typeOf $elemVal) "<nil>") }}
      admin_user = {{ printf "$__file{%s}" "/etc/secrets/username" }}
      {{- $credentialsSet = "true" }}
          {{- else }}
      {{ $elem }} = {{ $elemVal }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if and (not $Values.grafana_ini.security.admin_user) (eq $credentialsSet "false") }}
      admin_user = {{ printf "$__file{%s}" "/etc/secrets/username" }}
      {{- end }}
      {{- if and (not $Values.grafana_ini.security.admin_password) (eq $credentialsSet "false") }}
      admin_password = {{ printf "$__file{%s}" "/etc/secrets/password" }}
    {{- end -}}
{{- end -}}

{{/*
Create the name of the ClusterRole to use
*/}}
{{- define "cpro-grafana.clusterRole" -}}
{{ include "csf-common-lib.v1.resourceName" (tuple . "ClusterRole" (printf "%s-grafanacr" .Release.Namespace)) }}
{{- end -}}


{{/*
Self-signed issuer warnings for cpro-grafana
*/}}
{{- define "cpro-grafana.selfSigned.warnings" -}}
{{- if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.grafana.tls.enabled .Values.tls.enabled .Values.global.tls.enabled false)) "true") }}
{{- if (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false)) "true") }}
{{- if (eq (include "csf-common-lib.v1.isEmptyValue" .Values.grafana.tls.secretRef.name) "true") }}
{{- if (.Values.grafana.certificate.enabled) }}
{{- if and (eq (include "csf-common-lib.v1.isEmptyValue" .Values.grafana.certificate.issuerRef.name) "true") (eq (include "csf-common-lib.v1.isEmptyValue" .Values.certManager.issuerRef.name) "true")  (eq (include "csf-common-lib.v1.isEmptyValue" .Values.global.certManager.issuerRef.name) "true") }}
{{- print "\nWARNING! Self-signed certificates are not recommended for production use." }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Return the pre backup container name
*/}}
{{- define "cpro-grafana.cbur.prebackup.container" -}}
{{- $name := printf "%s" "pre-backup" -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}

{{/*
Return the post restore container name
*/}}
{{- define "cpro-grafana.cbur.postrestore.container" -}}
{{- $name := printf "%s" "post-restore" -}}
{{- include "cpro-common-lib.v1.containername" ( dict "name" $name "context" . ) }}
{{- end -}}


{{/* apiversion for BrHook */}}
{{/* "cbur.bcmt.local/v1" and "cbur.csf.nokia.com/v1" are the commonly used api version for brHook  */}}
{{- define "cpro-grafana.apiVersion.brHookapiversion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrHook" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}