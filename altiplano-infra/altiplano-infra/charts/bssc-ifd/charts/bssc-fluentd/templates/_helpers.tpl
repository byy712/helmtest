{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bssc-fluentd.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "bssc-fluentd.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define pod name prefix value
*/}}

{{- define "bssc-fluentd.podNamePrefix" -}}
{{- $podNamePrefix := ( default "" .Values.global.podNamePrefix) }}
{{- if and (eq (include "bssc-fluentd.v1.coalesceBoolean" (tuple (.Values.disablePodNamePrefixRestrictions) (.Values.global.disablePodNamePrefixRestrictions) false)) "false") (ne $podNamePrefix "" ) -}}
{{- $prefixMaxLength := 30 }}
{{- $podNamePrefix := $podNamePrefix | trunc ($prefixMaxLength | int ) -}}
{{- printf "%s-" $podNamePrefix }}
{{- else -}}
{{- printf "%s" $podNamePrefix }}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.deployment.name" -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "bssc-fluentd.daemonset.name" -}}
{{- printf "%s%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) .Values.fluentd.daemonsetSuffix | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "bssc-fluentd.statefulset.name" -}}
{{- printf "%s%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) .Values.fluentd.statefulsetSuffix | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "bssc-fluentd.deletePvcJob.name" -}}
{{- if .Values.customResourceNames.deletePvcJob.name -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) .Values.customResourceNames.deletePvcJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) -}}
{{- $suffix := "-delpvc" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.scaleInJob.name" -}}
{{- if .Values.customResourceNames.scaleinJob.name -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) .Values.customResourceNames.scaleinJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) -}}
{{- $suffix := "-postscalein" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.preUpgradePvMigrateJob.name" -}}
{{- if .Values.customResourceNames.preUpgradePvMigrateJob.name -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) .Values.customResourceNames.preUpgradePvMigrateJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) -}}
{{- $suffix := "-preupg" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.helmTestPod.name" -}}
{{- $suffixMaxLength := 19 }}
{{- $resourceLimit := 63 }}
{{- if .Values.customResourceNames.helmTestPod.name -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) .Values.customResourceNames.helmTestPod.name | trunc $resourceLimit | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) -}}
{{- $suffix := "ftest" | trunc $suffixMaxLength -}}
{{- $nameMaxLength := sub (sub $resourceLimit (len $suffix)) 1 | int }}
{{- printf "%s-%s" ( $name |trunc $nameMaxLength ) $suffix -}}
{{- end -}}
{{- end -}}

{{/*
This function is referred from csf-common-lib/templates/_containerName.tpl. The difference here is prefixMaxLength and suffixMaxLength are fixed as per requirements and not computed from the csf-common-lib.v1._nameLimits.tpl function.
suffixMaxLength = $containerNameMaxLength - $containerNamePrefixMaxLength - 1
suffixMaxLength = 63 - 34 - 1 = 28
*/}}
{{- define "bssc-fluentd.v1.containerName" -}}
{{- $root := index . 0 -}}
{{- $suffix := index . 1 -}}
{{- $containerNamePrefixMaxLength := 34 }}
{{- $suffixMaxLength := 28 }}
{{- $prefix := (($root.Values.global | default dict).containerNamePrefix | default "") | trunc $containerNamePrefixMaxLength | trimSuffix "-" }}
{{- if gt (len $suffix) $suffixMaxLength }}
{{- fail (print "Container name (" $suffix ") is too long. Limit is " $suffixMaxLength) }}
{{- end }}
{{- if $prefix }}
{{- (print $prefix "-" $suffix) }}
{{- else }}
{{- $suffix }}
{{- end }}
{{- end }}

{{- define "bssc-fluentd.daemonset.container" -}}
{{- $suffix := ( default "fluentd" .Values.customResourceNames.fluentdPod.fluentdContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.deployment.container" -}}
{{- $suffix := ( default "fluentd" .Values.customResourceNames.fluentdPod.fluentdContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.statefulset.container" -}}
{{- $suffix := ( default "fluentd" .Values.customResourceNames.fluentdPod.fluentdContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.init.container" -}}
{{- $suffix := ( default "init" .Values.customResourceNames.fluentdPod.fluentdInitContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.unifiedLoggingContainer.name" -}}
{{- $suffix := ( default "unifiedlogging-sidecar" .Values.customResourceNames.fluentdPod.unifiedLoggingContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.scaleInContainer.name" -}}
{{- $suffix := ( default "postscalein" .Values.customResourceNames.scaleinJob.postscaleinContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.deletePvcContainer.name" -}}
{{- $suffix := ( default "post-delete-pvc" .Values.customResourceNames.deletePvcJob.deletePvcContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.preUpgradePvMigrateContainer.name" -}}
{{- $suffix := ( default "pre-upg-flu-pv-mig" .Values.customResourceNames.preUpgradePvMigrateJob.preUpgradePvMigrateContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.helmTestContainer.name" -}}
{{- $suffix := ( default "ftest" .Values.customResourceNames.helmTestPod.helmTestContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.csf-toolkit-helm.annotations" -}}
{{- $envAll := index . 0 -}}
{{- $global_annotations := $envAll.Values.global.annotations }}
{{- $final_annotations := $global_annotations }}
{{- if gt (len .) 1 -}}
{{- $customized_annotations := index . 1 -}}
{{- $final_annotations = merge $customized_annotations $global_annotations }}
{{- end }}
{{- range $key, $value := $final_annotations }}
{{ $key | quote }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.csf-toolkit-helm.labels" -}}
{{- $envAll := index . 0 -}}
{{- $global_labels := $envAll.Values.global.labels}} 
{{- $final_labels := $global_labels }}
{{- if gt (len .) 1 -}}
{{- $customized_labels := index . 1 -}}
{{- $final_labels = merge $customized_labels $global_labels }}
{{- end }}
{{- range $key, $value := $final_labels }}
{{ $key | quote }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.sensitiveData" -}}
{{- $result := dict -}}
{{- $customized_secret := index . 0 -}}
{{- range $key, $value := $customized_secret -}}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{/*
1. Optional labels: As per HBP: app.kubernetes.io/component , app.kubernetes.io/version, app.kubernetes.io/part-of and helm.sh/chart are optional.
 i. app.kubernetes.io/version and helm.sh/chart -> depends on Chart.AppVersion and Chart.version and so their values would differ with each chart. These two labels are added for all resources except the volumeMounts as they are immutable on upgrades.
ii. app.kubernetes.io/component: name of the workload. As per HBP, for k8s resources associated with a workload, component name should be set with the name of the workload. For common objects or objects not related to any workload, this label is optional.
   For fluentd, all resources are related to fluentd workload only, so this label is set to "fluentd" for all.

2. Helper methods defined:
  - commonLabelsWithoutChartVersion: defines all common labels except version and helm.sh/chart. This helper is used to define labels for volumeMount resources.
  - commonLabels: reuses commonLabelsWithoutChartVersion + adds two labels (version and helm.sh/chart).
    This helper is used to define labels for all resources except volumeMounts.
  - selectorLabels: As per HBP, Kubernetes workload objects should use these 3 labels as label selectors -> app.kubernetes.io/name,app.kubernetes.io/instance,app.kubernetes.io/component.
    This helper is used to defines the values for these three labels. It is referenced in the templates at selectors of services, deployments, PDBs etc.
    Also, it is re-used in the method commonLabelsWithoutChartVersion to define these labels.
*/}}

{{- define "bssc-fluentd.selectorLabels" -}}
{{- $root := index . 0 }}
release: {{ $root.Release.Name }}
{{- $workloadName := index . 1 }}
app.kubernetes.io/name: {{ default $root.Chart.Name $root.Values.nameOverride }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- if not (empty $workloadName ) }}
app.kubernetes.io/component: {{ $workloadName }}
{{- end }}
{{- end }}

{{- define "bssc-fluentd.commonLabelsWithoutChartVersion" -}}
{{/*
$root -> First argument to the method to pass the root context. Mandatory.
$workloadName -> Second argument to the method to pass the name of the workload. Optional. 
*/}}
{{- $root := index . 0 }}
{{- if gt (len .) 1 -}}
{{- $workloadName := index . 1 -}}
{{- include "bssc-fluentd.selectorLabels" (tuple $root $workloadName) }}
{{- else }}
{{- include "bssc-fluentd.selectorLabels" (tuple $root "") }}
{{- end }}
{{- if $root.Values.partOf }}
app.kubernetes.io/part-of: {{ $root.Values.partOf }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Values.managedBy | default $root.Release.Service | quote}}
{{- end }}

{{- define "bssc-fluentd.commonLabels" -}}
{{- $root := index . 0 -}}
{{- if gt (len .) 1 -}}
{{- $workloadName := index . 1 -}}
{{ template "bssc-fluentd.commonLabelsWithoutChartVersion" (tuple $root $workloadName) }}
{{- else }}
{{ template "bssc-fluentd.commonLabelsWithoutChartVersion" (tuple $root "") }}
{{- end }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
helm.sh/chart: "{{ default $root.Chart.Name $root.Values.nameOverride }}-{{ $root.Chart.Version }}"
{{- end }}

{{/*
Return the appropriate apiVersion for extensions/v1beta1 for Deployment,Daemonset and Statefulset.
*/}}
{{- define "bssc-fluentd.apiVersionExtensionsV1Beta1orAppsV1" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1"}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for role/rolebinding.
*/}}
{{- define "bssc-fluentd.apiVersionRbacAuthorizatioK8sIoV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PDB.
*/}}
{{- define "bssc-fluentd.apiVersionPolicyV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" -}}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "bssc-fluentd.serviceAccount.name" -}}
  {{- if .Values.rbac -}}
    {{- if .Values.rbac.enabled -}}
      {{- if .Values.fluentd.enable_root_privilege -}}
        {{- printf "%s-min-sa" (( include "bssc-fluentd.fullname" . ) | trunc ((sub .Values.customResourceNames.resourceNameLimit 7)|int)) -}}
      {{- else -}}
        {{- printf "%s-def-sa" (( include "bssc-fluentd.fullname" . ) | trunc ((sub .Values.customResourceNames.resourceNameLimit 7)|int)) -}}
      {{- end -}}
    {{- else if .Values.serviceAccountName -}}
      {{- .Values.serviceAccountName -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "bssc-fluentd.testServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-test-sa" (( include "bssc-fluentd.fullname" . ) | trunc ((sub .Values.customResourceNames.resourceNameLimit 8)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.delServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-del-sa" (( include "bssc-fluentd.fullname" . ) | trunc ((sub .Values.customResourceNames.resourceNameLimit 7)|int) ) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.scaleServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-scale-sa" (( include "bssc-fluentd.fullname" . ) | trunc ((sub .Values.customResourceNames.resourceNameLimit 9)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.preUpgradePvMigrateServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-preupgpv-sa" ( include "bssc-fluentd.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 10)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-fluentd.deleteJob.container.name" -}}
{{- $suffix := ( default "fcleanup" .Values.customResourceNames.deleteJob.deleteJobContainerName) }}
{{- include "bssc-fluentd.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-fluentd.deleteJob.name" -}}
{{- if .Values.customResourceNames.deleteJob.name -}}
{{- printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) .Values.customResourceNames.deleteJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-fluentd.podNamePrefix" .) (include "bssc-fluentd.fullname" .) -}}
{{- $suffix := "-cleanup" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}


{{- define "bssc-fluentd.PodDisruptionBudgetPolicy" -}}
{{- if .Values.fluentd.pdb.maxUnavailable }}
maxUnavailable: {{ .Values.fluentd.pdb.maxUnavailable }}
{{- end }}
{{- if .Values.fluentd.pdb.minAvailable }}
minAvailable: {{ .Values.fluentd.pdb.minAvailable }}
{{- end }}
{{- if or (and .Values.fluentd.pdb.maxUnavailable .Values.fluentd.pdb.minAvailable) (and (not .Values.fluentd.pdb.maxUnavailable) (not .Values.fluentd.pdb.minAvailable)) }}
{{- required "One of maxUnavailable or minAvailable values need to be set." "" }}
{{- end }}
{{- end }}

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-fluentd.v1.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{- define "bssc-fluentd.v1.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "bssc-fluentd.v1.isEmptyValue" .) "false" }}
        {{- if eq (include "bssc-fluentd.v1.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}

{{/*
Return the appropriate apiVersion for certManager.
*/}}
{{- define "bssc-fluentd.apiVersionCertManager" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else }}
{{- print .Values.fluentd.certManager.apiVersion }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for brPolicy
*/}}
{{- define "bssc-fluentd.apiVersionBrPolicy" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end -}}
{{- end -}}

{{/*
Fluentd svc dual stack config
*/}}
{{- define "bssc-fluentd.dualStack.config" -}}
{{- if or ( .Values.ipFamilyPolicy ) ( .Values.ipFamilies ) }}
{{- if .Values.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.ipFamilyPolicy }}
{{- end }}
{{- if .Values.ipFamilies }}
ipFamilies: {{ .Values.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- else if or ( .Values.global.ipFamilyPolicy ) ( .Values.global.ipFamilies ) }}
{{- if .Values.global.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.global.ipFamilyPolicy }}
{{- end }}
{{- if .Values.global.ipFamilies }}
ipFamilies: {{ .Values.global.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}


{{- define "bssc-fluentd.pod.securityContext" -}}
{{- if .Values.fluentd.securityContext.enabled }}
{{- $securityContext := .Values.fluentd.securityContext -}}
{{- $securityContext = omit $securityContext "enabled" -}}
{{- $securityContext = omit $securityContext "privileged" -}}
{{- if eq ( toString ( .Values.fluentd.securityContext.fsGroup )) "auto" }}
{{- $securityContext = omit $securityContext "fsGroup" -}}
{{- end }}
{{- if eq ( toString ( .Values.fluentd.securityContext.runAsUser )) "auto" }}
{{- $securityContext = omit $securityContext "runAsUser" -}}
{{- end }}
{{- if and (.Capabilities.APIVersions.Has "config.openshift.io/v1") (semverCompare "< 1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- $securityContext = omit $securityContext "seccompProfile" -}}
{{- end }}
{{- if $securityContext  }}
{{ toYaml $securityContext }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "bssc-fluentd.container.securityContext" -}}
{{- if .Values.fluentd.securityContext.enabled }}
{{- $securityContext := .Values.fluentd.containerSecurityContext -}}
{{- $securityContext = omit $securityContext "allowPrivilegeEscalation" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop:
  - ALL
{{- if and (.Capabilities.APIVersions.Has "config.openshift.io/v1") (semverCompare "< 1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- $securityContext = omit $securityContext "seccompProfile" -}}
{{- end }}
{{- if $securityContext }}
{{ toYaml $securityContext }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
Below template function is referred from HBP csf-common-lib/_hpa.tpl and csf-common-lib/_hpaValues.tpl
*/}}
{{- define "bssc-fluentd.hpaValues" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
minReplicas: {{ $workload.hpa.minReplicas }}
maxReplicas: {{ $workload.hpa.maxReplicas }}
metrics:
{{- if $workload.hpa.predefinedMetrics }}
  {{- if $workload.hpa.predefinedMetrics.enabled }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ $workload.hpa.predefinedMetrics.averageCPUThreshold }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ $workload.hpa.predefinedMetrics.averageMemoryThreshold }}
  {{- end }}
{{- end }}
  {{- if $workload.hpa.metrics }}
{{ toYaml $workload.hpa.metrics | indent 2 }}
  {{- end }}

  {{- if $workload.hpa.behavior }}
behavior:
{{ toYaml $workload.hpa.behavior | indent 2 }}
  {{- end }}
{{- end -}}

{{/*
Below template function is referred from HBP csf-common-lib/_isHpaEnabled.tpl
*/}}
{{- define "bssc-fluentd.isHpaEnabled" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $hpaEnabledGlobalScope := and (hasKey $root.Values.global "hpa") (hasKey $root.Values.global.hpa "enabled") $root.Values.global.hpa.enabled }}
{{- $hpaEnabledGlobalScopeDefaultFalse := eq (include "bssc-fluentd.boolDefaultFalse" $hpaEnabledGlobalScope) "true" }}
{{- $hpaEnabledWorkloadScope := and (hasKey $workload "hpa") (hasKey $workload.hpa "enabled") $workload.hpa.enabled }}
{{- $hpaEnabledWorkloadScopeDefaultFalse := eq (include "bssc-fluentd.boolDefaultFalse" $hpaEnabledWorkloadScope) "true" }}
{{- $hpaEnabledWorkloadScopeIsEmpty := eq (include "bssc-fluentd.v1.isEmptyValue" $workload.hpa.enabled) "true" }}
{{- or $hpaEnabledWorkloadScopeDefaultFalse (and $hpaEnabledGlobalScopeDefaultFalse $hpaEnabledWorkloadScopeIsEmpty) }}
{{- end -}}

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-fluentd.boolDefaultFalse" -}}
{{- eq (. | toString | lower) "true" -}}
{{- end -}}

{{- define "bssc-fluentd.syslogValues" -}}
{{/*
As per HBP, precedence is given to syslog defined at workload level over global level.
If syslog is enabled at workload level, all syslog properties are read from the workload level.
Only if syslog is enabled at global level and left empty at workload level, then all syslog properties are read from the global level.
*/}}
{{- if and (hasKey .Values.fluentd "unifiedLogging") (hasKey .Values.fluentd.unifiedLogging "syslog")  (hasKey .Values.fluentd.unifiedLogging.syslog "enabled") (eq (include "bssc-fluentd.boolDefaultFalse" .Values.fluentd.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.fluentd.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- else if and (hasKey .Values.global "unifiedLogging") (hasKey .Values.global.unifiedLogging "syslog") (hasKey .Values.global.unifiedLogging.syslog "enabled") (eq (include "bssc-fluentd.boolDefaultFalse" .Values.global.unifiedLogging.syslog.enabled) "true") (eq (include "bssc-fluentd.v1.isEmptyValue" .Values.fluentd.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.global.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- end -}}
{{- end -}}

{{/*
Below template function is referred from HBP csf-common-lib/_topologySpreadConstraints-v2.tpl. It is modified in the labelselector section as the implementation of selectorLabels in bssc is different from csf-common-lib.
Also,additional label the role key is added to ensure that topologySpreadConstraints will pick the fluentd pods and skip the pods created by jobs.
*/}}
{{- define "bssc-fluentd.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}

- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels: {{- include "bssc-fluentd.selectorLabels" (tuple $root "fluentd") | indent 6 }}
      role: fluentd-logprocessor
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "bssc-fluentd.syslogTlsValues" -}}
{{- include "bssc-fluentd.syslogValues" . }}
{{- if $.syslogEnabled }}
{{- if and (tpl (default "" $.syslog.tls.secretRef.name) .) (tpl (default "" $.syslog.tls.secretRef.keyNames.caCrt) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.tls.secretRef.name) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.tls.secretRef.keyNames.caCrt) .) }}
{{- else if and (tpl (default "" $.syslog.caCrt.secretName) .) (tpl (default "" $.syslog.caCrt.key) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.caCrt.secretName) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.caCrt.key) .) }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "bssc-fluentd.isCertManagerEnable" -}}
{{- if eq (tpl (.Values.fluentd.certManager.enabled | toString ) .) "true" }}
{{- $_ := set . "workloadCertMgr" true }}
{{- else if eq (tpl (.Values.fluentd.certManager.enabled | toString ) .) "false" }}
{{- $_ := set . "workloadCertMgr" false }}
{{- end }}
{{- if (eq (include "bssc-fluentd.v1.coalesceBoolean" (tuple ($.workloadCertMgr) (.Values.certManager.enabled) (.Values.global.certManager.enabled) false)) "true") }}
{{- $_ := set . "isCertManagerEnabled" "true" }}
{{- else -}}
{{- $_ := set . "isCertManagerEnabled" "false" }}
{{- end }}
{{- end }}

{{- define "bssc-fluentd.stakaterReloaderAnnotation" -}}
{{- include "bssc-fluentd.syslogValues" . }}
{{- include "bssc-fluentd.syslogTlsValues" . }}
{{- include "bssc-fluentd.isCertManagerEnable" . }}
{{- $secretList := list }}
{{- if .Values.fluentd.sensitiveInfoInSecret.enabled }}
    {{- $secretList = append $secretList (.Values.fluentd.sensitiveInfoInSecret.credentialNamePassword) }}
    {{- if eq $.isCertManagerEnabled "true" }}
      {{- $secretName := printf "%s-%s" (include "bssc-fluentd.fullname" .) "certmgr" }}
      {{- $secretList = append $secretList $secretName -}}
    {{- else -}}
      {{- $secretList = append $secretList (.Values.fluentd.sensitiveInfoInSecret.credentialNameCert) }}
    {{- end }}
{{- end }}
{{- if $.syslogEnabled }}
  {{- if and (default "" $.syslogSecretName) (default "" $.syslogSecretKey) }}
    {{- $secretList = append $secretList $.syslogSecretName }}
    {{- $secretList = $secretList | uniq }}
  {{- end }}
{{- end }}
{{- if $secretList }}
{{- $secretList = $secretList | join "," -}}
secret.reloader.stakater.com/reload: "{{ $secretList }}"
{{- end }}
{{- end -}}

{{- define "bssc-fluentd.registry" -}}
{{/*
Function to set registry for the image. As per HBP, if global.registry is set, that must be used for all images. If its not set, the image could use an internal registry parameter (for internal testing).
*/}}
{{- $root := index . 0 }}
{{- $internalRegistry := index . 1 }}
{{- if $root.global.registry -}}
    {{- printf "%s" $root.global.registry -}}
{{- else -}}
  {{- printf "%s" $internalRegistry -}}
{{- end -}}
{{- end -}}

{{/*
Below template function is used to determine whether cpu limits are enabled for all the containers.
As per HBP, precedence is given to enableDefaultCpuLimits defined at workload level over global level.
Only if enableDefaultCpuLimits is enabled at global level and left empty at workload level, then cpu limits are defined by the global level.
*/}}
{{- define "bssc-fluentd.defineCpuLimits" -}}
{{- if (eq (include "bssc-fluentd.v1.coalesceBoolean" (tuple (.Values.enableDefaultCpuLimits) (.Values.global.enableDefaultCpuLimits) false)) "true") }}
{{- $_ := set . "enableCpuLimit" "true" }}
{{- else -}}
{{- $_ := set . "enableCpuLimit" "false" }}
{{- end }}
{{- end -}}

{{/*
Below template function is used to define the values that will be set for the cpu limits for all containers.
*/}}
{{- define "bssc-fluentd.resources" -}}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $defaultCpuLimit := index . 2 -}}
{{ include "bssc-fluentd.defineCpuLimits" $root }}
{{- if and (eq $root.enableCpuLimit "true") (not (hasKey $resources.limits "cpu")) }}
{{ $_ := set $resources.limits "cpu" $defaultCpuLimit }}
{{- end }}
{{ toYaml $resources }}
{{- end -}}

{{- define "bssc-fluentd.imageRepositoryPath" -}}
{{/*
This function returns the image repository path. When flatRegistry is enabled, the subpaths in the image repository name (separated by /) would be skipped and only its last part will be returned.
When flatRegistry is disabled, the original path is returned.
*/}}
{{- $finalRepoPath := "" }}
{{- $flatRegistryEnabled := index . 0 -}}
{{- $repoPath := index . 1 -}}
{{- if (eq $flatRegistryEnabled true ) }}
{{- $finalRepoPath = regexSplit "/"  $repoPath -1 | last }}
{{- else }}
{{- $finalRepoPath = $repoPath }}
{{- end }}
{{- $finalRepoPath }}
{{- end }}

{{- define "bssc-fluentd.supportedImageFlavor" -}}
{{/*
This function returns a list of supported imageFlavors for the respective containers. The order of the supported container image flavors must be in descending order, i.e, the first element is taken the default when imageFlavor is empty at all levels.
*/}}
{{- $_ := set . "commonSupportedImageFlavor" (list "rocky8-jre11" "rocky8-jre17") -}}
{{- end -}}

{{- define "bssc-fluentd.imageTag" -}}
{{/*
This function takes the imageTag of the containers/workload as input and checks if the flavor is mentioned within the tag or not.
If the flavor is predefined in the tag by the user, it is taken as it is. Else the imageHelper function is called to check for the flavor to be used according to the respective imageFlavorPolicy mentioned.
*/}}
{{- $imagetag := index . 0 }}
{{- $splits := regexSplit "-" $imagetag 2 }}
{{- $tag := regexSplit "-" (index $splits 1) -1 }}
{{- $openSourceVersion := index $splits 0 }}
{{- $flavor := "" -}}
{{- $releaseTag := "" }}
{{- $foundDigit := false }}
{{- range $_,$tag }}
{{- if ( and ( ge (index $_ 0) 48 ) (le (index $_ 0) 57 ) ) -}}
{{- $foundDigit = true }}
{{- end }}
{{- if $foundDigit }}
{{- $releaseTag = printf "%s-%s" $releaseTag $_ | trimPrefix "-" }}
{{- else if not $foundDigit }}
{{- $flavor = printf "%s-%s" $flavor $_ | trimPrefix "-" }}
{{- end }}
{{- end }}
{{- if eq (include "bssc-fluentd.v1.isEmptyValue" $flavor) "true" }}
{{- $flavor = include "bssc-fluentd.imageHelper" . -}}
{{- end }}
{{- printf "%s-%s-%s" $openSourceVersion $flavor $releaseTag -}}
{{- end }}

{{- define "bssc-fluentd.imageHelper" -}}
{{/*
Below template function is referred from HBP csf-common-lib/_imageHelper-v2.tpl
All the arguments passed to "bssc-dashboards.imageTag" are passed to this function.
This function checks through the imageFlavor and imageFlavorPolicy at container, workload, root and global levels. It calls the imageFlavorOrFail function and returns the most suitable flavor according to the flavorPolicy.
*/}}
{{- $supportedFlavorList := index . 1 }}
{{- $values := index . 2 }}
{{- $workload := index . 3 }}
{{- $container := dict }}
{{- if gt (len .) 4 }}
{{- $container = index . 4 | default dict }}
{{- end }}
{{- $requestedFlavor := coalesce ($container | default dict).flavor $container.imageFlavor $workload.imageFlavor $values.imageFlavor $values.global.imageFlavor (index $supportedFlavorList 0) }}
{{- $requestedFlavorPolicy := coalesce ($container | default dict).flavorPolicy $container.imageFlavorPolicy $workload.imageFlavorPolicy $values.imageFlavorPolicy $values.global.imageFlavorPolicy }}
{{- $finalImageFlavor :=  include "bssc-fluentd.imageFlavorOrFail" (tuple $requestedFlavor $supportedFlavorList $requestedFlavorPolicy) }}
{{- $finalImageFlavor }}
{{- end -}}

{{- define "bssc-fluentd.imageFlavorOrFail" -}}
{{/*
Below template function is referred from HBP csf-common-lib/_imageFlavorOrFail.tpl and taken as it is. This function is unmodified from common libs
*/}}
{{- $requestedFlavor := lower (index . 0)  }}
{{- $containerFlavorsList := index . 1  }}
{{- $supportedFlavorPoliciesList := (list "BestMatch" "Strict") }}
{{- $flavorPolicy := "BestMatch" }}
{{- if gt (len .) 2 }}
{{- $flavorPolicy = index . 2 | default $flavorPolicy }}
{{- if not (has $flavorPolicy $supportedFlavorPoliciesList) }}
{{- fail (print "None of the container image flavor policies " $supportedFlavorPoliciesList " match requested imageFlavorPolicy \"" $flavorPolicy "\".") }}
{{- end }}
{{- end }}
{{- if not $requestedFlavor }}
{{- first $containerFlavorsList }}
{{- else }}
{{- if eq $flavorPolicy "Strict" }}
{{- if has $requestedFlavor $containerFlavorsList }}
{{- $requestedFlavor }}
{{- else }}
{{- fail (print "None of the container image flavors " $containerFlavorsList " match requested imageFlavor \"" $requestedFlavor "\". Consider using \"BestMatch\" imageFlavorPolicy.") }}
{{- end }}
{{- end }}
{{- if eq $flavorPolicy "BestMatch" }}
{{- /* filter by OS */}}
{{- $requestedOsFlavor := first (regexSplit "-" $requestedFlavor -1) }}
{{- $osMatchingContainerFlavorsList := list }}
{{- range $containerFlavor := $containerFlavorsList }}
{{- $containerOsFlavor := first (regexSplit "-" $containerFlavor -1) }}
{{- if or (eq $containerOsFlavor $requestedOsFlavor) (eq $containerOsFlavor "distroless") }}
{{- $osMatchingContainerFlavorsList = append $osMatchingContainerFlavorsList $containerFlavor }}
{{- end }}
{{- end }}
{{- if not $osMatchingContainerFlavorsList }}
{{- fail (print "None of the container image flavors match \"" $requestedOsFlavor "\" OS flavor of requested imageFlavor \"" $requestedFlavor "\". All supported container images: \"" $containerFlavorsList "\".") }}
{{- end }}
{{- /* filter by Runtimes */}}
{{- /* At the moment flavors have no overlapping names, so for simplicity we can just search in strings.
To easy understand the code comments base on the example, where:
- $requestedFlavor is 'centos8-jdk17-python3'
- $containerFlavor is 'centos8-python3.8' */}}
{{- $requestedEnvFlavorsList := rest (regexSplit "-" $requestedFlavor -1) }}
{{- $notMatchingContainerFlavorsList := list }}
{{- range $containerFlavor := $osMatchingContainerFlavorsList }}
{{- $containerEnvFlavorsWithDashes := print "-" (trimPrefix $requestedOsFlavor $containerFlavor | trimPrefix "-") "-" }}
{{- range $requestedEnvFlavor := $requestedEnvFlavorsList }}
{{- $requestedEnvTypeFlavor := regexReplaceAll "[0-9.]*$" $requestedEnvFlavor "" }}
{{- $containerFlavorContainsRequestedEnvType := contains (print "-" $requestedEnvTypeFlavor) $containerEnvFlavorsWithDashes }}
{{- $containerFlavorContainsRequestedEnv := contains (print "-" $requestedEnvFlavor "-") $containerEnvFlavorsWithDashes }}
{{- $containerFlavorContainsRequestedEnvBaseVersion := regexMatch (print "-" $requestedEnvFlavor "[.][0-9.]+-") $containerEnvFlavorsWithDashes }}
{{- if and $containerFlavorContainsRequestedEnvType (not (or $containerFlavorContainsRequestedEnv $containerFlavorContainsRequestedEnvBaseVersion)) }}
{{- $notMatchingContainerFlavorsList = append $notMatchingContainerFlavorsList $containerFlavor }}
{{- end }}
{{- end }}
{{- end }}
{{- /* exclude all $notMatchingContainerFlavorsList items from $osMatchingContainerFlavor */}}
{{- $finalMatchingContainerFlavorsList := list }}
{{- range $_, $osMatchingContainerFlavor := $osMatchingContainerFlavorsList }}
{{- if not (has $osMatchingContainerFlavor $notMatchingContainerFlavorsList) }}
{{- $finalMatchingContainerFlavorsList = append $finalMatchingContainerFlavorsList $osMatchingContainerFlavor }}
{{- end }}
{{- end }}
{{- if $finalMatchingContainerFlavorsList }}
{{- first $finalMatchingContainerFlavorsList }}
{{- else }}
{{- fail (print "None of the container image flavors match requested imageFlavor \"" $requestedFlavor "\". All supported container images: \"" $containerFlavorsList "\".") }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "bssc-fluentd.certificateValues" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $certificate := $workload.certificate }}
{{- $useV1alpha3 := and ($root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate") (not ($root.Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate")) }}
issuerRef:
  name: {{ $certificate.issuerRef.name | default $root.Values.fluentd.certManager.issuerRef.name | quote }}
  kind: {{ $certificate.issuerRef.kind | default $root.Values.fluentd.certManager.issuerRef.kind | quote }}
{{- $issuergroup := $root.Values.fluentd.certManager.issuerRef.group | default "cert-manager.io" }}
  group: {{ $certificate.issuerRef.group | default $issuergroup | quote }}
{{ $duration := $root.Values.fluentd.certManager.duration | default "8760h" }}
duration: {{ $certificate.duration | default $duration | quote }}
{{ $renewBefore := $root.Values.fluentd.certManager.renewBefore | default "360h" }}
renewBefore: {{ $certificate.renewBefore | default $renewBefore | quote }}
  {{- if $certificate.subject }}
subject: {{ $certificate.subject | toYaml | indent 2 }}
  {{- end }}
  {{- if $certificate.commonName }}
commonName: {{ $certificate.commonName | quote }}
  {{- else }}
commonName: "test.com"
  {{- end }}
privateKey:
  {{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).algorithm }}
  algorithm: {{ $certificate.privateKey.algorithm }}
  {{- end }}
  {{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).encoding }}
  encoding: {{ $certificate.privateKey.encoding }}
  {{- end }}
  {{- if and (not $useV1alpha3) ($certificate.privateKey | default (dict)).size }}
  size: {{ $certificate.privateKey.size }}
  {{- end }}
  {{- if ($certificate.privateKey | default (dict)).rotationPolicy }}
  rotationPolicy: {{ $certificate.privateKey.rotationPolicy }}
  {{- else }}
  rotationPolicy: Always
  {{- end }}
  {{- if $useV1alpha3 }}
    {{- if ($certificate.privateKey | default (dict)).algorithm }}
keyAlgorithm: {{ $certificate.privateKey.algorithm | lower }}
    {{- end }}
    {{- if ($certificate.privateKey | default (dict)).encoding }}
keyEncoding: {{ $certificate.privateKey.encoding | lower }}
    {{- end }}
    {{- if ($certificate.privateKey | default (dict)).size }}
keySize: {{ $certificate.privateKey.size }}
    {{- end }}
  {{- end }}
  {{- if $certificate.usages }}
usages:
{{ $certificate.usages | toYaml | indent 2 }}
  {{- else }}
usages:
  - server auth
  - client auth
  {{- end }}
  {{- if $certificate.dnsNames }}
dnsNames:
{{ $certificate.dnsNames | toYaml | indent 2 }}
  {{- end }}
  {{- if $certificate.uris }}
    {{- if $useV1alpha3 }}
uriSANs:
    {{- else }}
uris:
    {{- end }}
{{ $certificate.uris | toYaml | indent 2 }}
  {{- end }}
  {{- if $certificate.ipAddresses }}
ipAddresses:
{{ $certificate.ipAddresses | toYaml | indent 2 }}
  {{- end }}
  {{- if $certificate.secretName }}
secretName: {{ $certificate.secretName }}
  {{- else }}
secretName: {{ template "bssc-fluentd.fullname" $root }}-certmgr
  {{- end }}
  {{- if $root.Capabilities.APIVersions.Has "cert-manager.io/v1" }}
secretTemplate:
  labels:
{{- include "bssc-fluentd.commonLabels" (tuple $root "fluentd" ) | indent 4 }}
{{- include "bssc-fluentd.csf-toolkit-helm.labels" (tuple $root) | nindent 4 }}
  annotations:
{{- include "bssc-fluentd.csf-toolkit-helm.annotations" (tuple $root) | nindent 4}}
  {{- end }}
{{- end }}
