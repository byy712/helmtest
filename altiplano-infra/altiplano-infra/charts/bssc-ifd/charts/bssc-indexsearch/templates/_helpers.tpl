{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bssc-indexsearch.name" -}}
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
{{- define "bssc-indexsearch.fullname" -}}
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

{{- define "bssc-indexsearch.podNamePrefix" -}}
{{/*
$root -> First argument to the method to pass the root context. Mandatory.
$workloadDisablePodPrefixRestrictions -> Second argument to the method to pass the value of the workload disablePodNamePrefixRestrictions. Optional. 
*/}}
{{- $root := index . 0 -}}
{{- if gt (len .) 1 -}}
{{- $workloadDisablePodPrefixRestrictions := index . 1 -}}
{{- include "bssc-indexsearch.disablePodNamePrefixRestrictions" (tuple $root $workloadDisablePodPrefixRestrictions ) -}}
{{- else -}}
{{- include "bssc-indexsearch.disablePodNamePrefixRestrictions" (tuple $root "" ) -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.disablePodNamePrefixRestrictions" -}}
{{/*
$root -> First argument to the method to pass the root context. Mandatory.
$workloadDisablePodPrefixRestrictions -> Second argument to the method to pass the value of the workload disablePodNamePrefixRestrictions. Optional. 
*/}}
{{- $root := index . 0 -}}
{{- $workloadDisablePodPrefixRestrictions := index . 1 -}}
{{- $podNamePrefix := ( default "" $root.Values.global.podNamePrefix) }}
{{- if and (eq (include "bssc-indexsearch.v1.coalesceBoolean" (tuple ($workloadDisablePodPrefixRestrictions) ($root.Values.disablePodNamePrefixRestrictions) ($root.Values.global.disablePodNamePrefixRestrictions) false)) "false") (ne $podNamePrefix "" ) -}}
{{- $prefixMaxLength := 30 }}
{{- $podNamePrefix := $podNamePrefix | trunc ($prefixMaxLength | int ) -}}
{{- printf "%s-" $podNamePrefix }}
{{- else -}}
{{- printf "%s" $podNamePrefix }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified manager name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "bssc-indexsearch.manager.fullname" -}}
{{- printf "%s%s-%s" (include "bssc-indexsearch.podNamePrefix" (tuple . .Values.manager.disablePodNamePrefixRestrictions)) ( include "bssc-indexsearch.fullname" .) .Values.manager.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified client name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "bssc-indexsearch.client.fullname" -}}
{{- printf "%s%s-%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) ( include "bssc-indexsearch.fullname" .) .Values.client.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified data name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "bssc-indexsearch.data.fullname" -}}
{{- printf "%s%s-%s" (include "bssc-indexsearch.podNamePrefix" (tuple . .Values.data.disablePodNamePrefixRestrictions)) ( include "bssc-indexsearch.fullname" .) .Values.data.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "bssc-indexsearch.endpoints" -}}
{{- $replicas := .Values.manager.replicas | int }}
{{- $ismanager := printf "%s%s-%s" (include "bssc-indexsearch.podNamePrefix" (tuple . .Values.manager.disablePodNamePrefixRestrictions)) (include "bssc-indexsearch.fullname" .) .Values.manager.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-"}}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $ismanager }}-{{ $i }},
  {{- end }}
{{- end }}

{{- define "bssc-indexsearch.delete.pvcJob.name" -}}
{{- if .Values.customResourceNames.postDeletePvcJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.postDeletePvcJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-delpvc" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.cleanUpJob.name" -}}
{{- if .Values.customResourceNames.postDeleteCleanupJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.postDeleteCleanupJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-cleanup" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.preHealJob.name" -}}
{{- if .Values.customResourceNames.preHealJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.preHealJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-preheal" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.postScaleInJob.name" -}}
{{- if .Values.customResourceNames.postScaleInJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.postScaleInJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-postscalein" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.preUpgradeJob.name" -}}
{{- if .Values.customResourceNames.preUpgradeSecJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.preUpgradeSecJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-preupg" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.upgradeJob.name" -}}
{{- if .Values.customResourceNames.upgradeJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.upgradeJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-upg" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{/*
This function is referred from csf-common-lib/templates/_containerName.tpl. The difference here is prefixMaxLength and suffixMaxLength are fixed as per requirements and not computed from the csf-common-lib.v1._nameLimits.tpl function.
suffixMaxLength = $containerNameMaxLength - $containerNamePrefixMaxLength - 1
suffixMaxLength = 63 - 34 - 1 = 28
*/}}
{{- define "bssc-indexsearch.v1.containerName" -}}
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

{{- define "bssc-indexsearch.upgradeContainer.name" -}}
{{- $suffix := ( default "upgrade" .Values.customResourceNames.upgradeJob.upgradeContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.preRollbackJob.name" -}}
{{- if .Values.customResourceNames.preRollbackJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.preRollbackJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-prerb" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.preRollbackContainer.name" -}}
{{- $suffix := ( default "prerollback" .Values.customResourceNames.preRollbackJob.preRollbackContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.helmTestPod.name" -}}
{{- $suffixMaxLength := 19 }}
{{- $resourceLimit := 63 }}
{{- if .Values.customResourceNames.helmTestPod.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.helmTestPod.name | trunc $resourceLimit | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "istest" | trunc $suffixMaxLength -}}
{{- $nameMaxLength := sub (sub $resourceLimit (len $suffix)) 1 | int }}
{{- printf "%s-%s" ( $name |trunc $nameMaxLength ) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.helmTestPostApiPod.name" -}}
{{- $suffixMaxLength := 19 }}
{{- $resourceLimit := 63 }}
{{- if .Values.customResourceNames.helmTestPostApiPod.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.helmTestPostApiPod.name | trunc $resourceLimit | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "postapitest" | trunc $suffixMaxLength -}}
{{- $nameMaxLength := sub (sub $resourceLimit (len $suffix)) 1 | int }}
{{- printf "%s-%s" ( $name |trunc $nameMaxLength ) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.delete.pvcContainer.name" -}}
{{- $suffix := ( default "post-delete-pvc" .Values.customResourceNames.postDeletePvcJob.postDeletePvcContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.cleanUpContainer.name" -}}
{{- $suffix := ( default "post-delete-cleanup" .Values.customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.preUpgradeSecContainer.name" -}}
{{- $suffix := ( default "upgrade-is-job" .Values.customResourceNames.preUpgradeSecJob.preUpgradeSecContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.preHealContainer.name" -}}
{{- $suffix := ( default "preheal" .Values.customResourceNames.preHealJob.preHealContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.postScaleInContainer.name" -}}
{{- $suffix := ( default "postscalein" .Values.customResourceNames.postScaleInJob.postScaleInContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.helmTestContainer.name" -}}
{{- $suffix := ( default "istest" .Values.customResourceNames.helmTestPod.helmTestContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.helmTestPostApiContainer.name" -}}
{{- $suffix := ( default "postapitest" .Values.customResourceNames.helmTestPostApiPod.helmTestPostApiContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}


{{- define "bssc-indexsearch.secAdminJob.name" -}}
{{- if .Values.customResourceNames.secAdminJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.secAdminJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-secadmin-is" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.secAdminContainer.name" -}}
{{- $suffix := ( default "secadminis" .Values.customResourceNames.secAdminJob.secAdminContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.client.container" -}}
{{- $suffix := default (printf "%s%s" "is-" (.Values.client.name)) .Values.customResourceNames.clientPod.clientContainerName }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.data.container" -}}
{{- $suffix := default (printf "%s%s" "is-" (.Values.data.name)) .Values.customResourceNames.dataPod.dataContainerName }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.manager.container" -}}
{{- $suffix := default (printf "%s%s" "is-" (.Values.manager.name)) .Values.customResourceNames.managerPod.managerContainerName }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.initContainer.name" -}}
{{- $suffix := ( default "is-init" .Values.customResourceNames.initContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.unifiedLoggingContainer.name" -}}
{{- $suffix := ( default "unifiedlogging-sidecar" .Values.customResourceNames.unifiedLoggingContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.ciphers" -}}
{{- join "," .Values.security.ciphers }}
{{- end -}}

{{- define "bssc-indexsearch.csf-toolkit-helm.annotations" -}}
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

{{- define "bssc-indexsearch.csf-toolkit-helm.labels" -}}
{{- $envAll := index . 0 -}}
{{- $global_labels := $envAll.Values.global.labels }}
{{- $final_labels := $global_labels }}
{{- if gt (len .) 1 -}}
{{- $customized_labels := index . 1 -}}
{{- $final_labels = merge $customized_labels $global_labels }}
{{- end }}
{{- range $key, $value := $final_labels }}
{{ $key | quote }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
1. Optional labels: app.kubernetes.io/component , app.kubernetes.io/version, app.kubernetes.io/part-of and helm.sh/chart are optional as per HBP.
2. app.kubernetes.io/version and helm.sh/chart depends on Chart.AppVersion and Chart.version and so their values would differ with each chart. These two labels are added for all resources except for volumeMounts as they are immutable on upgrades.
3. Helper methods defined:
- commonLabelsWithoutChartVersion: defines all common labels except version and helm.sh/chart. This helper is used to define labels for volumeMount resources.
- commonLabels: uses method commonLabelsWithoutChartVersion + adds two labels (version and helm.sh/chart).
  This helper is used to define labels for all k8s resources except volumeMounts.
- selectorLabels: As per HBP, Kubernetes workload objects should use these 3 labels app.kubernetes.io/name,app.kubernetes.io/instance,app.kubernetes.io/component as label selectors. This helper is used to defines the values for these three labels.
It is referenced in the templates at selectors of services, deployments, PDBs etc. Also, it is re-used in the method commonLabelsWithoutChartVersion to define values of these 3 labels.
4. app.kubernetes.io/component: name of the workload.
   As per HBP, for k8s resources associated with a workload, component name should be set with the name of the workload. For common objects or objects not related to any workload, this label is optional.
   In indexsearch, there are 3 workloads - master, client and data.
   For k8s objects that are used by all these 3 workloads(ex. secret, cert-manager secret etc), this label is not set.
   For other resources, this label is set as per associated workload.
*/}}


{{- define "bssc-indexsearch.commonLabelsWithoutChartVersion" -}}
{{/*
$root -> First argument to the method to pass the root context. Mandatory.
$workloadName -> Second argument to the method to pass the name of the workload. Optional. 
*/}}
{{- $root := index . 0 }}
{{- if gt (len .) 1 -}}
{{- $workloadName := index . 1 -}}
{{- include "bssc-indexsearch.selectorLabels" (tuple $root $workloadName) }}
{{- else }}
{{- include "bssc-indexsearch.selectorLabels" (tuple $root "") }}
{{- end }}
{{- if $root.Values.partOf }}
app.kubernetes.io/part-of: {{ $root.Values.partOf }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Values.managedBy | default $root.Release.Service | quote}}
{{- end }}

{{- define "bssc-indexsearch.commonLabels" -}}
{{- $root := index . 0 -}}
{{- if gt (len .) 1 -}}
{{- $workloadName := index . 1 -}}
{{ template "bssc-indexsearch.commonLabelsWithoutChartVersion" (tuple $root $workloadName) }}
{{- else }}
{{ template "bssc-indexsearch.commonLabelsWithoutChartVersion" (tuple $root "") }}
{{- end }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
helm.sh/chart: "{{ default $root.Chart.Name $root.Values.nameOverride }}-{{ $root.Chart.Version }}"
{{- end }}

{{- define "bssc-indexsearch.selectorLabels" -}}
{{- $root := index . 0 }}
release: {{ $root.Release.Name }}
{{- $workloadName := index . 1 }}
app.kubernetes.io/name: {{ default $root.Chart.Name $root.Values.nameOverride }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- if not (empty $workloadName ) }}
app.kubernetes.io/component: {{ $workloadName }}
{{- end }}
{{- end }}

{{- define "bssc-indexsearch.preUpgradePvMigrateContainer.name" -}}
{{- $suffix := ( default "pre-upg-pv-mig" .Values.customResourceNames.preUpgradePvMigrateJob.preUpgradePvMigrateContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}


{{- define "bssc-indexsearch.preUpgradePvMigrateJob.name" -}}
{{- if .Values.customResourceNames.preUpgradePvMigrateJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.preUpgradePvMigrateJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-pvmig" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for extensions/v1beta1 for Deployment.
*/}}
{{- define "bssc-indexsearch.apiVersionExtensionsV1Beta1orAppsV1" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for PDB.
*/}}
{{- define "bssc-indexsearch.apiVersionPolicyV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" -}}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for role/rolebinding.
*/}}
{{- define "bssc-indexsearch.apiVersionRbacAuthorizatioK8sIoV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.serviceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-is-min-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 10)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.delServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-del-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 7)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.scaleServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-scale-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 9)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.preServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-preupg-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 10)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.inupgServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-is-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 6)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.rollbackServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-preroll-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 11)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.preUpgradePvMigrateServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-preupgpv-sa" ( include "bssc-indexsearch.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 12)|int)) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Create PodDisruptionBudget parameters based on input values.
*/}}
{{- define "bssc-indexsearch.pdb" -}}
{{- if .ispdb_custom.maxUnavailable }}
maxUnavailable: {{ .ispdb_custom.maxUnavailable }}
{{- end }}
{{- if .ispdb_custom.minAvailable }}
minAvailable: {{ .ispdb_custom.minAvailable }}
{{- end }}
{{- if or (and .ispdb_custom.maxUnavailable .ispdb_custom.minAvailable) (and (not .ispdb_custom.maxUnavailable) (not .ispdb_custom.minAvailable)) }}
{{- required "One of maxUnavailable or minAvailable values need to be set." "" }}
{{- end }}
{{- end }}

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-indexsearch.v1.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{- define "bssc-indexsearch.v1.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "bssc-indexsearch.v1.isEmptyValue" .) "false" }}
        {{- if eq (include "bssc-indexsearch.v1.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}

{{/*
Return the appropriate apiVersion for certManager.
*/}}
{{- define "bssc-indexsearch.apiVersionCertManager" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else }}
{{- print .Values.security.certManager.apiVersion}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for brPolicy
*/}}
{{- define "bssc-indexsearch.apiVersionBrPolicy" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end -}}
{{- end -}}

{{/*
Indexsearch svc dual stack config
*/}}
{{- define "bssc-indexsearch.dualStack.config" -}}
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


{{- define "bssc-indexsearch.pod.securityContext" -}}
{{- if .Values.securityContext.enabled }}
runAsNonRoot: true
{{- $securityContext := .Values.securityContext -}}
{{- $securityContext = omit $securityContext "enabled" -}}
{{- if eq ( toString ( .Values.securityContext.fsGroup )) "auto" }}
{{- $securityContext = omit $securityContext "fsGroup" -}}
{{- end }}
{{- if eq ( toString ( .Values.securityContext.runAsUser )) "auto" }}
{{- $securityContext = omit $securityContext "runAsUser" -}}
{{- end }}
{{- if and (.Capabilities.APIVersions.Has "config.openshift.io/v1") (semverCompare "< 1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- $securityContext = omit $securityContext "seccompProfile" -}}
{{- end }}
{{- if $securityContext }}
{{ toYaml $securityContext }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "bssc-indexsearch.container.securityContext" -}}
{{- if .Values.securityContext.enabled }}
{{- if and (.Values.persistence) (.Values.persistence.enabled) }}
readOnlyRootFilesystem: true
{{- else }}
readOnlyRootFilesystem: false
{{- end }}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
{{- $securityContext := .Values.containerSecurityContext -}}
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
{{- define "bssc-indexsearch.client.hpaValues" -}}
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
{{- define "bssc-indexsearch.isHpaEnabled" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $hpaEnabledGlobalScope := and (hasKey $root.Values.global "hpa") (hasKey $root.Values.global.hpa "enabled") $root.Values.global.hpa.enabled }}
{{- $hpaEnabledGlobalScopeDefaultFalse := eq (include "bssc-indexsearch.boolDefaultFalse" $hpaEnabledGlobalScope) "true" }}
{{- $hpaEnabledWorkloadScope := and (hasKey $workload "hpa") (hasKey $workload.hpa "enabled") $workload.hpa.enabled }}
{{- $hpaEnabledWorkloadScopeDefaultFalse := eq (include "bssc-indexsearch.boolDefaultFalse" $hpaEnabledWorkloadScope) "true" }}
{{- $hpaEnabledWorkloadScopeIsEmpty := eq (include "bssc-indexsearch.v1.isEmptyValue" $workload.hpa.enabled) "true" }}
{{- or $hpaEnabledWorkloadScopeDefaultFalse (and $hpaEnabledGlobalScopeDefaultFalse $hpaEnabledWorkloadScopeIsEmpty) }}
{{- end -}}

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-indexsearch.boolDefaultFalse" -}}
{{- eq (. | toString | lower) "true" -}}
{{- end -}}

{{- define "bssc-indexsearch.syslogValues" -}}
{{/*
As per HBP, precedence is given to syslog defined at workload level over global level.
If syslog is enabled at workload level, all syslog properties are read from the workload level.
Only if syslog is enabled at global level and left empty at workload level, then all syslog properties are read from the global level.
*/}}
{{- if and (hasKey .Values "unifiedLogging") (hasKey .Values.unifiedLogging "syslog")  (hasKey .Values.unifiedLogging.syslog "enabled") (eq (include "bssc-indexsearch.boolDefaultFalse" .Values.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- else if and (hasKey .Values.global "unifiedLogging") (hasKey .Values.global.unifiedLogging "syslog") (hasKey .Values.global.unifiedLogging.syslog "enabled") (eq (include "bssc-indexsearch.boolDefaultFalse" .Values.global.unifiedLogging.syslog.enabled) "true") (eq (include "bssc-indexsearch.v1.isEmptyValue" .Values.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.global.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- end -}}
{{- end -}}

{{/*
Below template function is referred from HBP csf-common-lib/_topologySpreadConstraints-v2.tpl. It is modified in the labelselector section as the implementation of selectorLabels in bssc is different from csf-common-lib.
*/}}
{{- define "bssc-indexsearch.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}

- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels: {{- include "bssc-indexsearch.selectorLabels" (tuple $root $workload.name) | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "bssc-indexsearch.syslogTlsValues" -}}
{{- include "bssc-indexsearch.syslogValues" . }}
{{- if $.syslogEnabled }}
{{- if and (tpl (default "" $.syslog.tls.secretRef.name) .) (tpl (default "" $.syslog.tls.secretRef.keyNames.caCrt) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.tls.secretRef.name) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.tls.secretRef.keyNames.caCrt) .) }}
{{- if $.syslog.tls.secretRef.keyNames.tlsCrt }}
{{- $_ := set . "syslogTlsCrt" (tpl ($.syslog.tls.secretRef.keyNames.tlsCrt) .) }}
{{- end }}
{{- if $.syslog.tls.secretRef.keyNames.tlsKey }}
{{- $_ := set . "syslogTlsKey" (tpl ($.syslog.tls.secretRef.keyNames.tlsKey) .) }}
{{- end }}
{{- else if and (tpl (default "" $.syslog.caCrt.secretName ) .) (tpl (default "" $.syslog.caCrt.key ) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.caCrt.secretName) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.caCrt.key) .) }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "bssc-indexsearch.isCertManagerEnable" -}}
{{- if eq (tpl (.Values.security.certManager.enabled | toString ) .) "true" }}
{{- $_ := set . "workloadCertMgr" true }}
{{- else if eq (tpl (.Values.security.certManager.enabled | toString ) .) "false" }}
{{- $_ := set . "workloadCertMgr" false }}
{{- end }}
{{- if (eq (include "bssc-indexsearch.v1.coalesceBoolean" (tuple ($.workloadCertMgr) (.Values.certManager.enabled) (.Values.global.certManager.enabled) false)) "true") }}
{{- $_ := set . "isCertManagerEnabled" "true" }}
{{- else -}}
{{- $_ := set . "isCertManagerEnabled" "false" }}
{{- end }}
{{- end }}

{{- define "bssc-indexsearch.stakaterReloaderAnnotation" -}}
{{- include "bssc-indexsearch.syslogValues" . }}
{{- include "bssc-indexsearch.syslogTlsValues" . }}
{{- include "bssc-indexsearch.isCertManagerEnable" . }}
{{- $secretList := list }}
{{- if and (.Values.security.enable) (eq (tpl (.Values.security.sensitiveInfoInSecret.enabled | toString ) .) "true") }}
  {{- $secretList = append $secretList (.Values.security.sensitiveInfoInSecret.credentialNamePassword) }}
  {{- if eq $.isCertManagerEnabled "true" }}
    {{- $nodeSecretName := printf "%s-%s" (include "bssc-indexsearch.fullname" .) "nodecert" }}
    {{- $clientSecretName := printf "%s-%s" (include "bssc-indexsearch.fullname" .) "clientcert" }}
    {{- $secretList = append $secretList $nodeSecretName -}}
    {{- $secretList = append $secretList $clientSecretName -}}
  {{- else -}}
    {{- $secretList = append $secretList (.Values.security.sensitiveInfoInSecret.credentialNameCert) }}
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

{{- define "bssc-indexsearch.registry" -}}
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

{{- define "bssc-indexsearch.securityPrereqCheck" -}}
{{/*
Function to check if security is enabled without enabling sensitiveInfoInSecret flag.
*/}}
{{- if .Values.security.enable }}
  {{- if  eq (tpl (.Values.security.sensitiveInfoInSecret.enabled | toString ) .) "false" }}
    {{- print "SensitiveInfoInSecret flag is disabled" }}
    {{- fail "SensitiveInfoInSecret flag has to be enabled if security is enabled" }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Below template function is used to determine whether cpu limits are enabled for all the containers.
As per HBP, precedence is given to enableDefaultCpuLimits defined at workload level over global level.
Only if enableDefaultCpuLimits is enabled at global level and left empty at workload level, then cpu limits are defined by the global level.
*/}}
{{- define "bssc-indexsearch.defineCpuLimits" -}}
{{- if (eq (include "bssc-indexsearch.v1.coalesceBoolean" (tuple (.Values.enableDefaultCpuLimits) (.Values.global.enableDefaultCpuLimits) false)) "true") }}
{{- $_ := set . "enableCpuLimit" "true" }}
{{- else -}}
{{- $_ := set . "enableCpuLimit" "false" }}
{{- end }}
{{- end -}}

{{/*
Below template function is used to define the values that will be set for the cpu limits for all containers.
*/}}
{{- define "bssc-indexsearch.resources" -}}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $defaultCpuLimit := index . 2 -}}
{{ include "bssc-indexsearch.defineCpuLimits" $root }}
{{- if and (eq $root.enableCpuLimit "true") (not (hasKey $resources.limits "cpu")) }}
{{ $_ := set $resources.limits "cpu" $defaultCpuLimit }}
{{- end }}
{{ toYaml $resources }}
{{- end }}

{{- define "bssc-indexsearch.syslogSendLogsViaLog4j" -}}
{{- include "bssc-indexsearch.syslogValues" . }}
{{- if $.syslogEnabled }}
{{- if eq (lower (.Values.unifiedLogging.syslog.sendLogsViaLog4j | toString)) "true" }}
{{- $_ := set . "sendLogsViaLog4j" "true" }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "bssc-indexsearch.nodeRoles" -}}
{{- $root := index . 0 }}
{{- $nodeRole := index . 1 }}
{{- if $root.Values.crossClusterReplication.follower.enabled }}
{{- printf "%s, remote_cluster_client" $nodeRole }}
{{- else }}
{{- printf "%s" $nodeRole }}
{{- end }}
{{- end }}


{{- define "bssc-indexsearch.ccrReplicateIndices" -}}
{{- $indexRulePair := index . 0 -}}
{{- range $key, $value := $indexRulePair -}}
{{- printf " %s:%s" $key $value -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.postSetupApiJobContainer.name" -}}
{{- $suffix := ( default "post-setup-api" .Values.customResourceNames.postSetupApiJob.postSetupApiJobContainerName) }}
{{- include "bssc-indexsearch.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexsearch.postSetupApiJob.name" -}}
{{- if .Values.customResourceNames.postSetupApiJob.name -}}
{{- printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) .Values.customResourceNames.postSetupApiJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexsearch.podNamePrefix" (tuple .)) (include "bssc-indexsearch.fullname" .) -}}
{{- $suffix := "-post-api-job" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.ccr.followerDNs" -}}
{{- $followerDNs := .Values.crossClusterReplication.leader.followerDNs }}
  {{- range $followerDNs -}}
{{ . }};
  {{- end }}
{{- end }}

{{- define "bssc-indexsearch.ccr.connectionName" -}}
{{- if .Values.crossClusterReplication.follower.connectionName -}}
{{- printf "%s" .Values.crossClusterReplication.follower.connectionName -}}
{{- else -}}
{{- $leaderUrl := split ":" .Values.crossClusterReplication.follower.leaderURL -}}
{{- printf "%s-%s-%s-%s" (.Release.Name) (.Release.Namespace) ($leaderUrl._0) ($leaderUrl._1)  -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexsearch.ccrEnabled" -}}
{{- if or (.Values.crossClusterReplication.leader.enabled) (.Values.crossClusterReplication.follower.enabled) }}
{{- $_ := set . "ccrEnabled" true }}
{{- else }}
{{- $_ := set . "ccrEnabled" false }}
{{- end }}
{{- end }}

{{- define "bssc-indexsearch.imageRepositoryPath" -}}
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

{{- define "bssc-indexsearch.supportedImageFlavor" -}}
{{/*
This function returns a list of supported imageFlavors for the respective containers. The order of the supported container image flavors must be in descending order, i.e, the first element is taken the default when imageFlavor is empty at all levels.
*/}}
{{- $_ := set . "commonSupportedImageFlavor" (list "rocky8-jre11" "rocky8-jre17") -}}
{{- end -}}

{{- define "bssc-indexsearch.imageTag" -}}
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
{{- if eq (include "bssc-indexsearch.v1.isEmptyValue" $flavor) "true" }}
{{- $flavor = include "bssc-indexsearch.imageHelper" . -}}
{{- end }}
{{- printf "%s-%s-%s" $openSourceVersion $flavor $releaseTag -}}
{{- end }}

{{- define "bssc-indexsearch.imageHelper" -}}
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
{{- $finalImageFlavor :=  include "bssc-indexsearch.imageFlavorOrFail" (tuple $requestedFlavor $supportedFlavorList $requestedFlavorPolicy) }}
{{- $finalImageFlavor }}
{{- end -}}

{{- define "bssc-indexsearch.imageFlavorOrFail" -}}
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

{{- define "bssc-indexsearch.certificateValues" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $certificate := $workload.certificate }}
  {{- if gt (len .) 2 }}
    {{- $certificate = index . 2 }}
  {{- end }}
{{- $secretSuffix := index . 3 }}
{{- $serviceName := $root.Values.service.name }}
{{- $useV1alpha3 := and ($root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate") (not ($root.Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate")) }}
issuerRef:
  name: {{ $certificate.issuerRef.name | default $root.Values.security.certManager.issuerRef.name | quote }}
  kind: {{ $certificate.issuerRef.kind | default $root.Values.security.certManager.issuerRef.kind | quote }}
{{- $issuergroup := $root.Values.security.certManager.issuerRef.group | default "cert-manager.io" }}
  group: {{ $certificate.issuerRef.group | default $issuergroup | quote }}
{{ $duration := $root.Values.security.certManager.duration | default "8760h" }}
duration: {{ $certificate.duration | default $duration | quote }}
{{ $renewBefore := $root.Values.security.certManager.renewBefore | default "360h" }}
renewBefore: {{ $certificate.renewBefore | default $renewBefore | quote }}
  {{- if $certificate.subject }}
subject: {{ $certificate.subject | toYaml | indent 2 }}
  {{- end }}
  {{- if $certificate.commonName }}
commonName: {{ $certificate.commonName | quote }}
  {{- else  if (eq $secretSuffix "nodecert") }}
commonName: {{ $serviceName }}
  {{- else }}
commonName: "admin"
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
  {{- else  if (eq $secretSuffix "nodecert") }}
usages:
  - server auth
  - client auth
  {{- else }}
usages:
  - client auth
  {{- end }}
  {{- if $certificate.dnsNames }}
dnsNames:
{{ tpl ($certificate.dnsNames | toYaml) $root | indent 2 }}
  {{- else  if (eq $secretSuffix "nodecert") }}
dnsNames:
  - {{ $serviceName }}.{{ $root.Release.Namespace }}
  - {{ $serviceName }}.{{ $root.Release.Namespace }}.svc
  - {{ $serviceName }}.{{ $root.Release.Namespace }}.svc.{{ $root.Values.clusterDomain | default "cluster.local" }}
    {{- range $root.Values.security.certManager.dnsNames }}
  - "{{ . }}"
    {{- end }}
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
{{- $secretName := $certificate.secretName }}
secretName: {{ $secretName }}
  {{- else }}
{{- $secretName :=  printf "%s-%s" (include "bssc-indexsearch.fullname" $root) ($secretSuffix) }}
secretName: {{ $secretName }}
  {{- end }}
  {{- if $root.Capabilities.APIVersions.Has "cert-manager.io/v1" }}
secretTemplate:
  labels:
{{- include "bssc-indexsearch.csf-toolkit-helm.labels" (tuple $root) | nindent 4 }}
{{- include "bssc-indexsearch.commonLabels" (tuple $root) | indent 4 }}
  annotations:
{{- include "bssc-indexsearch.csf-toolkit-helm.annotations" (tuple $root) | nindent 4 }}
  {{- end }}
keystores:
  jks:
    create: true
    # Password used to encrypt the keystore
    passwordSecretRef:
        name: {{ $root.Values.security.certManager.storePasswordCredentialName }}
        key: {{ $root.Values.security.certManager.storePasswordKey }}
{{- end }}
