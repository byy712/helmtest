{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ckey.chartName" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimAll "-" -}}
{{- end -}}


{{- define "ckey.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{/*
Check the condition to create ocp route successfully
*/}}
{{- define "ckey.checkOcpRouteCondition" -}}
{{- if .Values.ingress.hosts -}}
{{- $ns := lookup "v1" "Namespace" "" .Release.Namespace -}}
{{- if ne (len $ns) 0 -}}
{{- if hasKey $ns.metadata "annotations" -}}
{{- if and (ne (len $ns.metadata.annotations) 0)  (hasKey $ns.metadata.annotations "openshift.io/description") -}}
{{- printf "true" -}}
{{- else }}
{{- printf "false" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}

{{/*
ckey tpl to check if they are not empty, and select the first non-empty value encountered
*/}}
{{/*
The following piece of code snippet is taken from CSF-CHARTS.git/csf-common-lib/templates/_coalesceBoolean.tpl
*/}}
{{- define "ckey.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "ckey.isEmptyValue" .) "false" }}
        {{- if eq (include "ckey.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}


{{/*
Define pod name prefix value.
The if condition below is used to check the boolean value for the disablePodNamePrefixRestrictions flag both in root and global level which determines the truncation of podNamePrefix flag.
*/}}
{{- define "ckey.podNamePrefix" -}}
{{- if eq (include "ckey.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions )) "false" -}}
{{- default "" .Values.global.podNamePrefix | trunc 30 | trimSuffix "-" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Define container name prefix value
*/}}
{{- define "ckey.containerNamePrefix" -}}
{{- default .Values.global.containerNamePrefix "" | trunc 34 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ckey.fullName" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if and .Values.removeChartNameFromResourceName (contains $name .Release.Name) -}}
{{- .Release.Name | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimAll "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Set container timezone according to precedence.
timezone.timeZoneEnv has higher precedence than global.timeZoneEnv
*/}}
{{- define "ckey.timezone" -}}
{{- if .Values.timeZone.timeZoneEnv }}
- name: TZ
  value: {{ .Values.timeZone.timeZoneEnv | quote }}
{{- else if .Values.global.timeZoneEnv }}
- name: TZ
  value: {{ .Values.global.timeZoneEnv | quote }}
{{- else }}
- name: TZ
  value: "UTC"
{{- end }}
{{- end }}

{{/*
Create random default Keycloak admin password
*/}}
{{- define "ckey.generateRandomAdminPassword" }}
{{- if (not .admin_pw) }}
{{- $_ := set . "admin_pw" (randAlphaNum 10 | b64enc) }}
{{- end }}
{{ .admin_pw }}
{{- end -}}

{{/*
Define keycloak admin password
*/}}
{{- define "ckey.getAdminPassword" -}}
{{- if (not .Values.secretCredentials.ckeySecret) }}
{{ .Values.keycloakPassword | default (include "ckey.generateRandomAdminPassword" .) | trimPrefix "\n" }}
{{- else }}
{{- printf "******" }}
{{- end }}
{{- end -}}

{{/*
Define keycloak admin password encoded
*/}}
{{- define "ckey.encodedAdminPassword" -}}
{{ include "ckey.getAdminPassword" . | trimPrefix "\n" | b64enc }}
{{- end -}}

{{- define "ckey.storageClass" -}}
{{- if .Values.secretCredentials.storageClass -}}
{{- .Values.secretCredentials.storageClass -}}
{{- else if .Values.compaas -}}
{{- if .Values.compaas.storageClass -}}
{{- .Values.compaas.storageClass -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create pod name based on ckey.fullName and pod name prefix value
*/}}
{{- define "ckey.keycloak.statefulsetName" -}}
{{- printf "%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) | trunc 63 | trimAll "-" -}}
{{- end -}}


{{/*
Create container name based on ckey.fullName and container name prefix value
*/}}
{{- define "ckey.keycloak.containerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) (include "ckey.fullName" .) | trunc 63 | trimAll "-" -}}
{{- end -}}


{{/*
Create cbur-sidecar container name
*/}}
{{- define "ckey.cburContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "cbura-sidecar" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create test pod name
*/}}
{{- define "ckey.testPodName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-test" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create test container name
*/}}
{{- define "ckey.testContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "test" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create pre-upgrade-job pod name
*/}}
{{- define "ckey.preUpgradeJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-pre-upgrade-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create certificate-job name
*/}}
{{- define "ckey.certificateJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-certificate-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post-restore-hook name
*/}}
{{- define "ckey.postrestoreHookName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-br-postrestore" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create master-realm-configuration-job name
*/}}
{{- define "ckey.masterRealmConfigurationJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-master-realm-configuration-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post-delete-job name
*/}}
{{- define "ckey.postDeleteJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-post-delete-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create Infinispan cache  job name
*/}}
{{- define "ckey.infinispanCacheJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-infinisan-cache-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create Infinispan cache job container name
*/}}
{{- define "ckey.infinispanCacheContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "infinispan-cache-job-pod" | trunc 63 | trimAll "-" -}}
{{- end -}}


{{/*
Create post heal job name
*/}}
{{- define "ckey.postHealJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-ckey-postheal" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post heal container name
*/}}
{{- define "ckey.postHealContainerName" -}}
{{- printf "%s%s%s" (include "ckey.containerNamePrefix" .) .Release.Name "-ckey-postheal" | trunc 63 | trimAll "-" -}}
{{- end -}}

Create resource watcher job name
*/}}
{{- define "ckey.resourceWatcherJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-resource-watcher-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post heal job name
*/}}
{{- define "ckey.preHealJobName" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) .Release.Name "-ckey-preheal" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create pre heal container name
*/}}
{{- define "ckey.preHealContainerName" -}}
{{- printf "%s%s%s" (include "ckey.containerNamePrefix" .) .Release.Name "-ckey-preheal" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post delete secret container name
*/}}
{{- define "ckey.postDeleteSecretContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "post-delete-secrets" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create resource watcher container name
*/}}
{{- define "ckey.resourceWatcherContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "resource-watcher-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create certificate job container name
*/}}
{{- define "ckey.certificateJobContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "certificate-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create master realm configuration job container name
*/}}
{{- define "ckey.masterRealmConfigurationJobContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "master-realm-configuration-job-ckey" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create port restore container name
*/}}
{{- define "ckey.postRestoreContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "ckey-post-restore" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create pre upgrade job container name
*/}}
{{- define "ckey.preUpgradeJobContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "pre-upgrade-job" | trunc 63 | trimAll "-" -}}
{{- end -}}


{{- define "ckey.serviceAccountStateful" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.statefulServiceAccountName)) -}}
        {{- fail "Either ServiceAccountName or statefulServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-stateful-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.statefulServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.statefulServiceAccountName)) -}}
        {{ .Values.global.statefulServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.statefulServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and statefulServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}


{{- define "ckey.serviceAccountSecret" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.createOCPInternalCertificateSecretServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or createOCPInternalCertificateSecretServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-ocp-secret-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.createOCPInternalCertificateSecretServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.createOCPInternalCertificateSecretServiceAccountName)) -}}
        {{ .Values.global.createOCPInternalCertificateSecretServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.createOCPInternalCertificateSecretServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and createOCPInternalCertificateSecretServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountPreUpgrade" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.preUpgradeServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or preUpgradeServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-pre-upgrade-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.preUpgradeServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.preUpgradeServiceAccountName)) -}}
        {{ .Values.global.preUpgradeServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.preUpgradeServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and preUpgradeServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountSecretPopulate" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.populateSecretAdminPasswordServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or populateSecretAdminPasswordServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-populate-secret-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.populateSecretAdminPasswordServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.populateSecretAdminPasswordServiceAccountName)) -}}
        {{ .Values.global.populateSecretAdminPasswordServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.populateSecretAdminPasswordServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and populateSecretAdminPasswordServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountDelete" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.deletionServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or deletionServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-delete-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.deletionServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) ( .Values.global.deletionServiceAccountName)) -}}
        {{ .Values.global.deletionServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.deletionServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and deletionServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountMasterRealm" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.masterRealmServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or masterRealmServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-master-realm-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.masterRealmServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.masterRealmServiceAccountName)) -}}
        {{ .Values.global.masterRealmServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.masterRealmServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and masterRealmServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountHeal" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.healingServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or healingServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-heal-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.healingServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.healingServiceAccountName)) -}}
        {{ .Values.global.healingServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.healingServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and healingServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountBRHook" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.brHookServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or brHookServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-brhook-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.brHookServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.brHookServiceAccountName)) -}}
        {{ .Values.global.brHookServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.brHookServiceAccountName)) -}}
         {{- fail "Both serviceAccountName and brHookServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.serviceAccountResourceWatcher" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.resourceWatcherServiceAccountName)) -}}
        {{- fail "Either serviceAccountName or resourceWatcherServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-resource-watcher-sa
      {{- end }}
      {{- else -}}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.resourceWatcherServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.resourceWatcherServiceAccountName)) -}}
        {{ .Values.global.resourceWatcherServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.resourceWatcherServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and resourceWatcherServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckey.istio.vs.hosts" -}}
{{- if .Values.istio.virtualService.hosts -}}
{{- toYaml ( .Values.istio.virtualService.hosts ) -}}
{{- else -}}
   {{- fail "Virtual Service hosts should be configured when gateway is enabled" -}}
{{- end -}}
{{- end -}}

{{/*
Define Istio version
*/}}
{{- define "ckey.istio.version" -}}
{{- .Values.istio.version | default .Values.global.istioVersion | default "1.12" -}}
{{- end -}}

{{/*
Define SharedHttpGateway for Istio
*/}}
{{- define "ckey.istio.shared_istio_gateway" -}}
{{- if .Values.istio.sharedHttpGateway.name -}}
{{- if .Values.istio.sharedHttpGateway.namespace -}}
{{- printf "%s/%s" .Values.istio.sharedHttpGateway.namespace .Values.istio.sharedHttpGateway.name -}}
{{- else -}}
{{- .Values.istio.sharedHttpGateway.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Quit Istio proxy container
*/}}
{{- define "ckey.istio.quit_proxy_container" -}}
{{- if .Values.istio.enabled -}}
echo "Quiting istio proxy container in the job"
until curl --connect-timeout 5 http://127.0.0.1:15020/quitquitquit -X POST; do
    echo "Waiting for istio proxy to be up ..."
    sleep 2;
done;
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified ingress name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
To maintain the ingress name backward compatibility, ckey.fullName function is not used.
Because for ingress name, Release.Namespace, releaseName and servicePort are being used.
Hence replicated the ckey.fullName function and in the else part ingress name format, which is already present in ckey chart is used.
*/}}
{{- define "ckey.ingress.fullName" -}}
{{- $releaseName := .Release.Name -}}
{{- $servicePort := .Values.ingress.keycloakServicePort -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if and .Values.removeChartNameFromResourceName (contains $name .Release.Name) -}}
{{- .Release.Name | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- printf "%s-%s-%.0f" .Release.Namespace $releaseName $servicePort -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define Keycloak context path
*/}}
{{- define "ckey.ingress.contextPath" -}}
{{- if .Values.httpRelativePath -}}
{{- .Values.httpRelativePath -}}
{{- else -}}
{{- printf "/" -}}
{{- end -}}
{{- end -}}

{{/*
To set the KC_HOSTNAME_URL env variable for the front end.
*/}}
{{- define "ckey.hostnameUrl" -}}
{{- if .Values.frontendURL -}}
{{ .Values.frontendURL }}{{ template "ckey.ingress.contextPath" . }}
{{- end -}}
{{- end -}}

{{/*
Define container resources specification for initBusyBoxContainer
*/}}
{{- define "ckey.keycloak.busybox-container-resources-spec" -}}
requests:
  memory: {{ .Values.initBusyBoxContainer.resources.requests.memory | default "256Mi" | quote }}
  cpu: {{ .Values.initBusyBoxContainer.resources.requests.cpu | default "250m" | quote }}
  {{- if index .Values.initBusyBoxContainer.resources.requests "ephemeral-storage" }}
  ephemeral-storage: {{ index .Values.initBusyBoxContainer.resources.requests "ephemeral-storage" | quote  }}
  {{- end }}
limits:
  memory: {{ .Values.initBusyBoxContainer.resources.limits.memory | default "256Mi" | quote }}
 {{- if eq (include "ckey.coalesceBoolean" (tuple .Values.enableDefaultCpuLimits .Values.global.enableDefaultCpuLimits false)) "true" }}

  cpu: {{ .Values.initBusyBoxContainer.resources.limits.cpu | quote }}
  {{- end }}
  {{- if index .Values.initBusyBoxContainer.resources.limits "ephemeral-storage" }}
  ephemeral-storage: {{ index .Values.initBusyBoxContainer.resources.limits "ephemeral-storage" | quote }}
  {{- end }}
{{- end -}}

{{/*
Create pre upgrade secret populate job name
*/}}
{{- define "ckey.preUpgradeSecretPopulateJob" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-secret-populate-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create pre upgrade secret populate job container name
*/}}
{{- define "ckey.preUpgradeSecretPopulateContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "secret-populate" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Container images
*/}}
{{- define "ckey.container.image" -}}
{{- $root := index . 0}}
{{- $imageInfo := index . 1 }}
{{- $internalRegistry := index . 2 }}
{{- if $root.Values.global.registry -}}
  {{- if eq $root.Values.global.flatRegistry false -}}
    {{- printf "%s/%s/%s:%s" $root.Values.global.registry $imageInfo.imageRepo $imageInfo.imageName $imageInfo.imageTag -}}
  {{- else -}}
    {{- printf "%s/%s:%s" $root.Values.global.registry $imageInfo.imageName $imageInfo.imageTag -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s/%s/%s:%s" $internalRegistry $imageInfo.imageRepo $imageInfo.imageName $imageInfo.imageTag -}}
{{- end -}}
{{- end -}}

{{/*
Define registry to be used with customProviders image
*/}}
{{- define "ckey.customprovider.registry" -}}
{{- if .Values.global.registry -}}
{{- .Values.global.registry -}}
{{- else -}}
{{- .Values.internalCustomProviderRegistry -}}
{{- end -}}
{{- end -}}


{{/*
Define common ckey labels
*/}}
{{- define "ckey.commonLabels" -}}
{{ if .Values.commonLabels }}
app.kubernetes.io/name: {{ template "ckey.fullName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/component: Security
app.kubernetes.io/part-of: {{ .Values.partOf | quote }}
app.kubernetes.io/managed-by: {{ .Values.managedBy | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ end }}
{{- end -}}

{{/*
Define template for Keycloak pods security context
*/}}
{{- define "ckey.keycloak.securitycontext" -}}
{{- if .Values.securityContext }}
{{- $securityContext :=  .Values.securityContext -}}
{{- if  .Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" .Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $securityContext "seccompProfile") }}
        {{- $securityContext = omit $securityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
{{- end }}
{{- if and (hasKey .Values.securityContext "runAsUser") (eq (toString .Values.securityContext.runAsUser) "auto") -}}
{{- $securityContext = omit $securityContext "runAsUser" -}}
{{- end -}}
{{- if and (hasKey .Values.securityContext "runAsGroup") (eq (toString .Values.securityContext.runAsGroup) "auto") -}}
{{- $securityContext = omit $securityContext "runAsGroup" -}}
{{- end -}}
{{- if and (hasKey .Values.securityContext "fsGroup") (eq (toString .Values.securityContext.fsGroup) "auto") -}}
{{- $securityContext = omit $securityContext "fsGroup" -}}
{{- end -}}
{{- toYaml $securityContext -}}
{{- end -}}
{{- end -}}

{{/*
Define template for Keycloak container security context
*/}}
{{- define "ckey.container.securitycontext" -}}
{{- if .Values.containerSecurityContext }}
{{- toYaml .Values.containerSecurityContext -}}
{{- end -}}
{{- end -}}

{{/*
Define template for CBUR pods security context
*/}}
{{- define "ckey.cbur.securitycontext" -}}
{{- if .Values.cbur.securityContext }}
{{- $securityContext :=  .Values.cbur.securityContext -}}
{{- if  .Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" .Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $securityContext "seccompProfile") }}
        {{- $securityContext = omit $securityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
{{- end }}
{{- if and (hasKey .Values.cbur.securityContext "runAsUser") (eq (toString .Values.cbur.securityContext.runAsUser) "auto") -}}
{{- $securityContext = omit $securityContext "runAsUser" -}}
{{- end -}}
{{- if and (hasKey .Values.cbur.securityContext "runAsGroup") (eq (toString .Values.cbur.securityContext.runAsGroup) "auto") -}}
{{- $securityContext = omit $securityContext "runAsGroup" -}}
{{- end -}}
{{- if and (hasKey .Values.cbur.securityContext "fsGroup") (eq (toString .Values.cbur.securityContext.fsGroup) "auto") -}}
{{- $securityContext = omit $securityContext "fsGroup" -}}
{{- end -}}
{{- toYaml $securityContext -}}
{{- end -}}
{{- end -}}


{{- define "ckey.certificateVersion" -}}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1") }}
{{- print "cert-manager.io/v1" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") }}
{{- print "cert-manager.io/v1beta1" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3") }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") }}
{{- print "cert-manager.io/v1alpha2" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha1") }}
{{- print "cert-manager.io/v1alpha1" }}
{{- else }}
{{- print "cert-manager.io/v1" }}
{{- end }}
{{- end -}}

{{/*
   Check certificate api version from cert manager
  */}}
{{- define "ckey.certAPIexist" -}}
{{- if or (.Capabilities.APIVersions.Has "cert-manager.io/v1") (or (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") ( or (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha1") (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3"))) }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}

{{/*
Headless service name
*/}}
{{- define "ckey.headlessService" -}}
{{- if .Values.kcJgroupsDnsQuery | quote -}}
{{- printf "%s" .Values.kcJgroupsDnsQuery -}}
{{- else -}}
{{- printf "%s%s%s%s%s" (include "ckey.fullName" .) "-headless." .Release.Namespace ".svc." .Values.clusterDomain  | quote -}}
{{- end }}
{{- end -}}

{{/*
CKEY Horizontal Pod Autoscale functions
*/}}

{{- define "ckey.boolDefaultFalse" -}}
{{- eq (. | toString | lower) "true" -}}
{{- end -}}

{{- define "ckey.isEmpty" -}}
{{- or (eq (. | toString) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{- define "ckey.isHpaEnabled" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $hpaEnabledGlobalScope := and (hasKey $root.Values.global "hpa") (hasKey $root.Values.global.hpa "enabled") $root.Values.global.hpa.enabled }}
{{- $hpaEnabledGlobalScopeDefaultFalse := eq (include "ckey.boolDefaultFalse" $hpaEnabledGlobalScope) "true" }}
{{- $hpaEnabledWorkloadScope := and (hasKey $workload "hpa") (hasKey $workload.hpa "enabled") $workload.hpa.enabled }}
{{- $hpaEnabledWorkloadScopeDefaultFalse := eq (include "ckey.boolDefaultFalse" $hpaEnabledWorkloadScope) "true" }}
{{- $hpaEnabledWorkloadScopeIsEmpty := eq (include "ckey.isEmpty" $hpaEnabledWorkloadScope) "true" }}
{{- or $hpaEnabledWorkloadScopeDefaultFalse (and $hpaEnabledGlobalScopeDefaultFalse $hpaEnabledWorkloadScopeIsEmpty) }}
{{- end -}}

{{- define "ckey.hpaValues" -}}
minReplicas: {{ .minReplicas }}
maxReplicas: {{ .maxReplicas }}
metrics:
{{- if .predefinedMetrics }}
{{- if .predefinedMetrics.enabled }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .predefinedMetrics.averageCPUThreshold }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .predefinedMetrics.averageMemoryThreshold }}
{{- end }}
{{- end }}
  {{- if .metrics }}
{{ toYaml .metrics | indent 2 }}
  {{- end }}

{{- if .behavior }}
behavior:
{{ toYaml .behavior | indent 2 }}
{{- end }}
{{- end -}}

{{/*
Derive the image name from three different parameters for fnms-keycloak-radius-plugin
*/}}
{{- define "radiusImage.fullname" -}}

    {{- if not (empty .Values.radiusImage.registry) -}}
        {{- if not (eq "-" .Values.radiusImage.registry) -}} {{ .Values.radiusImage.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}

    {{- if .Values.radiusImage.repository -}}
        {{- if not (empty .Values.radiusImage.registry) -}}
            {{- if not (eq "-" .Values.radiusImage.registry) -}}/{{- end -}}
        {{- else if .Values.global.registry -}}/
        {{- end -}}
    {{ .Values.radiusImage.repository }}
    {{- end -}}

    {{- if .Values.radiusImage.tag -}}
        {{- if .Values.radiusImage.repository -}}:
        {{- else -}}
            {{- if not (empty .Values.radiusImage.registry) -}}
                {{- if not (eq "-" .Values.radiusImage.registry) -}}:{{- end -}}
            {{- else if .Values.global.registry -}}:
            {{- end -}}
        {{- end -}}
    {{ .Values.radiusImage.tag }}
    {{- end -}}

{{- end -}}

{{- define "custom-user-realm-config-secret" -}}
{{- printf "%s%s" (include "ckey.fullName" .) "-custom-user-realm-config-secret" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ckey.pdbValue" -}}
{{- if and ( and ( not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" )) }}
{{- required "Both of the values (maxUnavailable/minAvailable) are set. Only one of the values need to be set." "" }}
{{- else if and (not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" ) }}
minAvailable: {{ .minAvailable }}
{{- else if and (not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" ) }}
maxUnavailable: {{ .maxUnavailable }}
{{- else }}
{{- required "None of the values (maxUnavailable/minAvailable) are set. Only one of the values need to be set." "" }}
{{- end }}
{{- end -}}

{{/*
ISU Functions
*/}}

{{/*
Define common ckey job annotations
*/}}
{{- define "ckey.commonAnnotations" -}}
{{ if .Values.istio.enabled }}
sidecar.istio.io/inject: "true"
{{ else }}
sidecar.istio.io/inject: "false"
{{ end }}
{{- end -}}

{{/*
Define common ckey job annotations
*/}}
{{- define "ckey.common.k8s-client-pod.annotations" -}}
{{- include "ckey.commonAnnotations" . -}}
{{ if .Values.istio.enabled }}
traffic.sidecar.istio.io/excludeInboundPorts: "443"
traffic.sidecar.istio.io/excludeOutboundPorts: "443"
{{ end }}
{{- end -}}

{{- define "ckey.serviceAccountISU" }}
      {{- if .Values.rbac.enabled }}
      {{- if (or .Values.global.serviceAccountName (.Values.global.isuServiceAccountName)) -}}
        {{- fail "Either ServiceAccountName or isuServiceAccountName should not be specified in values.yaml when .Values.rbac.enabled is true." -}}
      {{- else -}}
        {{ template "ckey.fullName" . }}-isu-sa
      {{- end }}
      {{ else }}
      {{- if (and .Values.global.serviceAccountName (not .Values.global.isuServiceAccountName)) -}}
        {{ .Values.global.serviceAccountName }}
      {{- else if (and (not .Values.global.serviceAccountName) (.Values.global.isuServiceAccountName)) -}}
        {{ .Values.global.isuServiceAccountName }}
      {{- else if (and .Values.global.serviceAccountName (.Values.global.isuServiceAccountName)) -}}
        {{- fail "Both serviceAccountName and isuServiceAccountName have been specified in values.yaml. Please specify either one" -}}
      {{- end }}
      {{- end }}
{{- end -}}

{{/*
Create ISU statefulset name
*/}}
{{- define "ckey.keycloak.isuStatefulsetName" -}}
{{- printf "%s%s" (include "ckey.keycloak.statefulsetName" .) "-isu-upgrade" | trunc 63 -}}
{{- end -}}

{{/*
Create pre upgrade ISU job name
*/}}
{{- define "ckey.keycloak.preUpgradeIsuJob" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-isu-pre-upgrade-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create pre rollback ISU job name
*/}}
{{- define "ckey.keycloak.preIsuRollbackJob" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-isu-pre-rollback-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post rollback ISU job name
*/}}
{{- define "ckey.keycloak.postIsuRollbackJob" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-isu-post-rollback-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Create post upgrade ISU job name
*/}}
{{- define "ckey.keycloak.postUpgradeIsuJob" -}}
{{- printf "%s%s%s" (include "ckey.podNamePrefix" .) (include "ckey.fullName" .) "-isu-post-upgrade-job" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{- define "ckey.keycloak.isuUpgradeContainerName" -}}
{{- printf "%s%s" (include "ckey.containerNamePrefix" .) "isu-container" | trunc 63 | trimAll "-" -}}
{{- end -}}

{{/*
Define MySQL client pod namespace
*/}}
{{- define "ckey.keycloak.isu.mysql-client.pod.namespace" }}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Define common rollback container specification for ISU pod
*/}}
{{- define "ckey.keycloak.isu.rollback-container-spec" -}}
{{- include "ckey.keycloak.isu.common-container-spec" . }}
  - name: BACKUP_ID
    valueFrom:
        configMapKeyRef:
            name: {{ template "ckey.fullName" . }}-isu-rollback
            key: backup-id
            optional: true
{{- end -}}

{{/*
Define common ISU pod specifications
*/}}
{{- define "ckey.keycloak.isu.common-pod-spec" -}}
restartPolicy: Never
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ template "ckey.serviceAccountISU" . }}
{{- end }}
automountServiceAccountToken: true
securityContext:
{{ include "ckey.keycloak.securitycontext" . | indent 2 }}
volumes:
- name: isu-common
  configMap:
    name: {{ template "ckey.fullName" . }}-isu
- name: ckey-secret
  projected:
    sources:
    - secret:
        {{ if .Values.secretCredentials.dbSecret }}
        name: {{ .Values.secretCredentials.dbSecret }}
        {{ else }}
        name:  {{ template "ckey.fullName" . }}-db-secret
        {{ end }}
        optional: true
{{- end -}}

{{/*
Define common container specification for ISU pod
*/}}
{{- define "ckey.keycloak.isu.common-container-spec" -}}
imagePullPolicy: "{{ .Values.images.pullPolicy }}"
securityContext:
{{ include "ckey.container.securitycontext" . | indent 2 }}
resources:
  requests:
    memory: {{ .Values.initBusyBoxContainer.resources.requests.memory | default "256Mi" | quote }}
    cpu: {{ .Values.initBusyBoxContainer.resources.requests.cpu | default "250m" | quote }}
    {{- if index .Values.initBusyBoxContainer.resources.requests "ephemeral-storage" }}
    ephemeral-storage: {{ index .Values.initBusyBoxContainer.resources.requests "ephemeral-storage" | quote  }}
    {{- end }}
  limits:
    memory: {{ .Values.initBusyBoxContainer.resources.limits.memory | default "256Mi" | quote }}
    {{- if eq (include "ckey.coalesceBoolean" (tuple .Values.enableDefaultCpuLimits .Values.global.enableDefaultCpuLimits false)) "true" }}
    cpu: {{ .Values.initBusyBoxContainer.resources.limits.cpu | quote }}
    {{ end }}
    {{- if index .Values.initBusyBoxContainer.resources.limits "ephemeral-storage" }}
    ephemeral-storage: {{ index .Values.initBusyBoxContainer.resources.limits "ephemeral-storage" | quote }}
    {{- end }}
volumeMounts:
  - name: isu-common
    mountPath: /opt/keycloak/isu-common
  - name: ckey-secret
    mountPath: /ckey-secret
env:
  {{ $cburPwSecret := .Values.isuUpgrade.cbur.passwordSecret }}
  {{ if and $cburPwSecret.name $cburPwSecret.attribute }}
  - name: CBUR_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ $cburPwSecret.name }}
        key: {{ $cburPwSecret.attribute }}
  {{ end }}
{{- end -}}

{{/*
* Define topology spread constraints
*/}}
{{- define "ckey.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $a := $root.Release.Name }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}

- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels:
      app.kubernetes.io/name: {{ template "ckey.fullName" $root }}
      app.kubernetes.io/instance: {{ $a }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Utility template for imagePullSecrets
*/}}
{{- define "ckey.imagePullSecrets" -}}
{{- $Values := index (first .) "Values" -}}
{{- $image := index (index $Values "images") (index . 1) -}}
{{- with (default $Values.global.imagePullSecrets $image.imagePullSecrets) }}
imagePullSecrets: {{- toYaml . | nindent 0 }}
{{- end -}}
{{- end }}

{{/*
Merge any number of dicts. All parameters need to be grouped in the one tuple.
*/}}
{{- define "ckey.mergeDicts" -}}
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
Custom labels function merges any number of dicts.
*/}}
{{- define "ckey.customLabels" -}}
{{- include "ckey.mergeDicts" . }}
{{- end -}}

{{/*
Custom annotations function merges any number of dicts.
*/}}
{{- define "ckey.customAnnotations" -}}
{{- include "ckey.mergeDicts" . }}
{{- end -}}

{{/*
Setting KC_HOSTNAME
*/}}
{{- define "ckey.kcHostName" -}}
{{- if eq (.Values.kcHostName) "K8S_INTERNAL_SERVICE" }}
{{- printf "%s.%s.svc.%s" (include "ckey.fullName" .) .Release.Namespace .Values.clusterDomain  | quote -}}
{{- else if .Values.kcHostname | quote -}}
{{- printf "%s" .Values.kcHostName }}
{{- end }}
{{- end -}}

ckey dual stack ipFamilyPolicy config
*/}}
{{- define "ckey.dualStack.ipFamilyPolicy.config" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- if $context.ipFamilyPolicy }}
ipFamilyPolicy: {{ $context.ipFamilyPolicy }}
{{- else if $root.Values.global.ipFamilyPolicy }}
ipFamilyPolicy: {{ $root.Values.global.ipFamilyPolicy }}
{{- end }}
{{- end }}

{{/*
ckey dual stack ipFamilies config
*/}}
{{- define "ckey.dualStack.ipFamilies.config" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- if $context.ipFamilies }}
ipFamilies: {{ $context.ipFamilies | toYaml | nindent 2 }}
{{- else if $root.Values.global.ipFamilies }}
ipFamilies: {{ $root.Values.global.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
ckey dual stack ipFamilies
*/}}
{{- define "ckey.dualStack.ipFamilies" -}}
{{- $root := .root -}}
{{- $context := .context -}}
{{- if $context.ipFamilies -}}
{{ $a := $context.ipFamilies }}
{{- range $key, $value := $a -}}
{{- $value -}}
{{- end -}}
{{- else if $root.Values.global.ipFamilies -}}
{{ $b := $root.Values.global.ipFamilies }}
{{- range $key, $value := $b -}}
{{- $value -}}
{{- end -}}
{{- end }}
{{- end }}

{{/*
ckey istio proxy container resources
*/}}
{{- define "ckey.istio.resources" -}}
{{- if .Values.istio.resources.requests.cpu -}}
{{- print "sidecar.istio.io/proxyCPU: " .Values.istio.resources.requests.cpu | nindent 8 }}
{{- end -}}
{{- if .Values.istio.resources.requests.memory -}}
{{- print "sidecar.istio.io/proxyMemory: " .Values.istio.resources.requests.memory | nindent 8 }}
{{- end -}}
{{- if .Values.istio.resources.limits.cpu -}}
{{- print "sidecar.istio.io/proxyCPULimit: " .Values.istio.resources.limits.cpu | nindent 8 }}
{{- end -}}
{{- if .Values.istio.resources.limits.memory -}}
{{- print "sidecar.istio.io/proxyMemoryLimit: " .Values.istio.resources.limits.memory | nindent 8 }}
{{- end -}}
{{- end }}




{{/*
ckey certManager priority
"According to HBP if workload specific enable flag is not set, there will be no effect of root-level or global level certmanager enabled flag. However, if workload specific certmanager flag is enabled to true, then the root-level certmanager gets higher priority over global level certmanager enabling flag. Note that name of our workload specific certmanager enable flag is not HBP 3.4.0 compliant. This will be taken care along with HBP 3.7.0 changes."
*/}}
{{- define "ckey.certManagerCheck" -}}
{{- if eq .Values.tls.certManager.enabled false -}}
{{- print "false" -}}
{{- else -}}
{{- printf "%s" (include "ckey.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled)) -}}
{{- end -}}
{{- end -}}


{{/* 
Istio configurations check
*/}}
{{- define "ckey.istio.configurationCheck" -}}
{{ $isDedicatedGwInPassThrough := "" }}
{{ $firstGateway := (first .Values.istio.gateways) }}
{{ $isDedicatedGwInPassThrough:= and ($firstGateway.enabled) (eq $firstGateway.tls.mode "PASSTHROUGH") }}
{{- if and $isDedicatedGwInPassThrough (not .Values.istio.sharedHttpGateway.name ) (.Values.istio.isVirtualServiceRequiredForHTTP) -}}
{{- fail "Dedicated Gateway is in Passthrough mode so HTTP based virtual service routing is not allowed due to security concern" -}}
{{- end -}}
{{- if and (.Values.istio.isVirtualServiceRequiredForHTTP) (.Values.istio.isVirtualServiceRequiredForHTTPS) -}}
{{- fail "Either HTTP virtual service should be enabled or HTTPS based virtual service should be enabled in values.yaml" -}}
{{- end -}}
{{- if and ($firstGateway.enabled) (.Values.istio.sharedHttpGateway.name) -}}
{{- fail "Either Dedicated gateway or Shared Gateway should be enabled, both cannot be enabled at same time" -}}
{{- end -}}
{{- if gt (len .Values.istio.gateways) 1 -}}
{{- fail "Currently Chart supports a Single Dedicated Gateway configuration" -}}
{{- end -}}
{{- end }}


{{/*
CKEY https port enablement check
*/}}
{{- define "ckey.httpsPort.check" -}}
{{- if empty .Values.httpsPort -}}
{{- fail ".Values.httpsPort cannot be blank as master-realm configuration job internally uses https port" -}}
{{- end -}}
{{- end }}

{{/*
Probes configuration check
*/}}
{{- define "ckey.probes.configurationCheck" -}}
{{- if gt .Values.probeDelays.startupProbeTimeoutSeconds .Values.probeDelays.startupProbePeriodSeconds -}}
{{- fail "Startupprobe timeout should be lesser than Startupprobe period seconds" -}}
{{- end -}}
{{- if gt .Values.probeDelays.readinessProbeTimeoutSeconds .Values.probeDelays.readinessProbePeriodSeconds -}}
{{- fail "Readinessprobe timeout should be lesser than Readinessprobe period seconds" -}}
{{- end -}}
{{- if gt .Values.probeDelays.livenessProbeTimeoutSeconds .Values.probeDelays.livenessProbePeriodSeconds -}}
{{- fail "Liveness Probe timeout should be lesser than Livenessprobe period seconds" -}}
{{- end -}}
{{- end }}

{{/*
Infinispan and Geo ports configuration check
*/}}
{{- define "ckey.geoPorts.configurationCheck" -}}
{{- if gt .Values.jgroupsTCPBindPort .Values.jgroupsFDPort -}}
{{- fail ".Values.jgroupsTCPBindPort should be lesser than .Values.jgroupsFDPort" -}}
{{- end -}}
{{- if eq .Values.geoRedundancy.service.jgroupsTCPPort (or .Values.jgroupsTCPBindPort .Values.jgroupsFDPort) -}}
{{- fail "GeoRedundancy service jgroupsTCPPort must not be same as .Values.jgroupsTCPBindPort or .Values.jgroupsFDPort" -}}
{{- end -}}
{{- end }}

{{/*
isTlsExternalCertViaCertManager configuration check
*/}}
{{- define "ckey.isTlsExternalCertViaCertManager" -}}
{{- if and (eq .Values.tls.certManager.isTlsExternalCertViaCertManager true)  (eq (include "ckey.certManagerCheck" . ) "false") -}}
{{- fail "If isTlsExternalCertViaCertManager is set to true then .Values.tls.certManager.enabled and .Values.certManager must be true" -}}
{{- end -}}
{{- if and (eq .Values.tls.certManager.isTlsExternalCertViaCertManager true) (eq .Values.kcProxy "passthrough") -}}
{{- fail "If isTlsExternalCertViaCertManager is set to true then .Values.tls.certManager.enabled and .Values.certManager  must be true and kcProxy should not be passthrough" -}}
{{- end -}}
{{- end -}}

{{/*
pushEventListenerData check
*/}}
{{- define "ckey.pushEventcheck" -}}
{{- if and .Values.pushEventListenerData.pushConfigMapName .Values.pushEventListenerData.notificationReceiverList -}}
{{- fail "Both .Values.pushEventListenerData.pushConfigMapName .Values.pushEventListenerData.notificationReceiverList cannot be set at the same time" -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}


{{/*
Common affinity and anti-affinity rules
*/}}
{{- define "ckey.common.affinity" -}}
{{- if (or .Values.nodeAffinity.enabled .Values.nodeAntiAffinity.enabled .Values.podAntiAffinity)}}
affinity:
{{ end }}
{{- if .Values.nodeAffinity.enabled }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ .Values.nodeAffinity.key }}
          operator: In
          values:
          - {{ quote .Values.nodeAffinity.value }}
{{ end }}
{{- if .Values.podAntiAffinity }}
{{- $zoneType := .Values.podAntiAffinity.zone.type | default "none" }}
{{- $zoneTopologyKey := .Values.podAntiAffinity.zone.topologyKey | default "topology.kubernetes.io/zone" }}
{{- $nodeType := .Values.podAntiAffinity.node.type | default "none" }}
{{- $nodeTopologyKey := .Values.podAntiAffinity.node.topologyKey | default "kubernetes.io/hostname" }}
{{- $prefferedList := list }}
{{- $requiredList := list }}
{{- range $index, $rule := .Values.podAntiAffinity.customRules }}
    {{- $type := $rule.type | default "soft" }}
    {{- $weight := $rule.weight | default 100 }}
    {{- $labels := list}}
    {{- if $rule.labelSelector }}
        {{- range $index, $selector := $rule.labelSelector.matchLabels }}
            {{- $key := index $selector "key" }}
            {{- $operator := index $selector "operator" }}
            {{- $values := index $selector "values" }}
            {{- $selectorResult := dict "key" $key "operator" $operator "values" $values }}
            {{- $labels = append $labels $selectorResult }}
	    {{- end -}}
    {{- else if $rule.autoGenerateLabelSelector}}
        {{- $selectorResult := dict "key" "app" "operator" "In" "values" (list "ckey") }}
        {{- $labels = merge $labels $selectorResult }}
    {{- end }}
    {{- if eq $type "hard" }}
      {{- $newElement := dict "topologyKey" $rule.topologyKey "labelSelector" (dict "matchExpressions" $labels) }}
      {{- $requiredList = append $requiredList $newElement }}
    {{- else if eq $type "soft" }}
      {{- $newElement := dict "weight" $weight "podAffinityTerm" (dict "topologyKey" $rule.topologyKey "labelSelector" (dict "matchExpressions" $labels)) }}
      {{- $prefferedList = append $prefferedList $newElement }}
    {{- else if eq $type "none" }}
    {{- else if $type }}
      {{ fail (printf "Invalid type [%s] specified" $type) }}
    {{- end }}
{{- end }}
  podAntiAffinity:
{{- if or (eq $zoneType "hard")  (eq $nodeType "hard") (gt (len $requiredList) 0)  }}
    requiredDuringSchedulingIgnoredDuringExecution:
{{- if (eq $zoneType "hard") }}
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - {{ template "ckey.chartName" . }}
        topologyKey: {{ $zoneTopologyKey }}
{{- end -}}
{{- if (eq $nodeType "hard") }}
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - {{ template "ckey.chartName" . }}
        topologyKey: {{ $nodeTopologyKey }}
{{- end -}}
{{- if gt (len $requiredList) 0  }}
{{- $requiredList | toYaml | nindent 6 }}
{{- end -}}
{{- end -}}
{{- if or (eq $zoneType "soft")  (eq $nodeType "soft") (gt (len $prefferedList) 0) }}
    preferredDuringSchedulingIgnoredDuringExecution:
{{- if (eq $zoneType "soft") }}
      - weight: 50
        podAffinityTerm:
          topologyKey: {{ $zoneTopologyKey }}
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - {{ template "ckey.chartName" . }}
{{- end -}}
{{- if (eq $nodeType "soft") }}
      - weight: 100
        podAffinityTerm:
          topologyKey: {{ $nodeTopologyKey }}
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - {{ template "ckey.chartName" . }}
{{- end -}}
{{- if gt (len $prefferedList) 0 }}
{{- $prefferedList | toYaml | nindent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
