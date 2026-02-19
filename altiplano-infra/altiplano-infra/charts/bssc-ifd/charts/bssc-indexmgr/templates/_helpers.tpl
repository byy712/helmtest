{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bssc-indexmgr.name" -}}
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
{{- define "bssc-indexmgr.fullname" -}}
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
{{- define "bssc-indexmgr.podNamePrefix" -}}
{{- $podNamePrefix := ( default "" .Values.global.podNamePrefix) }}
{{- if and (eq (include "bssc-indexmgr.v1.coalesceBoolean" (tuple (.Values.disablePodNamePrefixRestrictions) (.Values.global.disablePodNamePrefixRestrictions) false)) "false") (ne $podNamePrefix "" ) -}}
{{- $prefixMaxLength := 30 }}
{{- $podNamePrefix := $podNamePrefix | trunc ($prefixMaxLength | int ) -}}
{{- printf "%s-" $podNamePrefix }}
{{- else -}}
{{- printf "%s" $podNamePrefix }}
{{- end -}}
{{- end -}}


{{/*
Indexmgr job name is truncted to 52 characters as CronJob.Metadata.Name can only be max 52 characters.
*/}}
{{- define "bssc-indexmgr.job.name" -}}
{{- $cronJobMaxLength := 52 -}}
{{- printf "%s%s" (include "bssc-indexmgr.podNamePrefix" .) ( include "bssc-indexmgr.fullname" .) | trunc ($cronJobMaxLength | int ) | trimSuffix "-" -}}
{{- end -}}

{{/*
This function is referred from csf-common-lib/templates/_containerName.tpl. The difference here is prefixMaxLength and suffixMaxLength are fixed as per requirements and not computed from the csf-common-lib.v1._nameLimits.tpl function.
suffixMaxLength = $containerNameMaxLength - $containerNamePrefixMaxLength - 1
suffixMaxLength = 63 - 34 - 1 = 28
*/}}
{{- define "bssc-indexmgr.v1.containerName" -}}
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

{{- define "bssc-indexmgr.container.name" -}}
{{- $suffix := ( default "indexmgr" .Values.customResourceNames.indexmgrCronJobPod.indexmgrContainerName) }}
{{- include "bssc-indexmgr.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexmgr.initContainer.name" -}}
{{- $suffix := ( default "indexmgr-init" .Values.customResourceNames.indexmgrCronJobPod.indexmgrInitContainer) }}
{{- include "bssc-indexmgr.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexmgr.deleteJob.container.name" -}}
{{- $suffix := ( default "im-delete" .Values.customResourceNames.deleteJob.deleteJobContainerName) }}
{{- include "bssc-indexmgr.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexmgr.deleteJob.name" -}}
{{- if .Values.customResourceNames.deleteJob.name -}}
{{- printf "%s%s" (include "bssc-indexmgr.podNamePrefix" .) .Values.customResourceNames.deleteJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexmgr.podNamePrefix" .) (include "bssc-indexmgr.fullname" .) -}}
{{- $suffix := "-del" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.helmTestPod.name" -}}
{{- $suffixMaxLength := 19 }}
{{- $resourceLimit := 63 }}
{{- if .Values.customResourceNames.helmTestPod.name -}}
{{- printf "%s%s" (include "bssc-indexmgr.podNamePrefix" .) .Values.customResourceNames.helmTestPod.name | trunc $resourceLimit | trimSuffix "-" -}}
{{- else -}}
{{- $name := printf "%s%s" (include "bssc-indexmgr.podNamePrefix" .) (include "bssc-indexmgr.fullname" .) -}}
{{- $suffix := "imtest" | trunc $suffixMaxLength -}}
{{- $nameMaxLength := sub (sub $resourceLimit (len $suffix)) 1 | int }}
{{- printf "%s-%s" ( $name |trunc $nameMaxLength ) $suffix -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.helmTestContainer.name" -}}
{{- $suffix := ( default "imtest" .Values.customResourceNames.helmTestPod.helmTestContainerName) }}
{{- include "bssc-indexmgr.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{/* Reference
*/}}
{{- define "bssc-indexmgr.csf-toolkit-helm.annotations" -}}
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

{{- define "bssc-indexmgr.unifiedLoggingContainer.name" -}}
{{- $suffix := ( default "unifiedlogging-sidecar" .Values.customResourceNames.indexmgrCronJobPod.unifiedLoggingContainerName) }}
{{- include "bssc-indexmgr.v1.containerName" (tuple . $suffix ) -}}
{{- end -}}

{{- define "bssc-indexmgr.csf-toolkit-helm.labels" -}}
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

{{/*
1. Optional labels: As per HBP: app.kubernetes.io/component, app.kubernetes.io/version, app.kubernetes.io/part-of and helm.sh/chart are optional.
 i. app.kubernetes.io/version and helm.sh/chart -> depends on Chart.AppVersion and Chart.version and so they are skipped for volumeMounts as they are immutable on upgrades.
 ii. app.kubernetes.io/component: name of the workload. As per HBP, for k8s resources associated with a workload, component name should be set with the name of the workload. For common objects or objects not related to any workload, this label is optional.
   For indexmgr, all resources are related to indexmgr workload only and so the label is set as "indexmgr" for all.

2. Helper methods defined:
  i. commonLabels: defines all common labels as per HBP and used for all resources.
 ii. selectorLabels: As per HBP, Kubernetes workload objects should use these 3 labels as label selectors -> app.kubernetes.io/name, app.kubernetes.io/instance, app.kubernetes.io/component.
 This helper is used to defines the values for these three labels. It is referenced in the templates at selectors of services, deployments, PDBs etc.
 Also, it is re-used in the method commonLabels to define these labels.

*/}}
{{- define "bssc-indexmgr.commonLabels" -}}
{{/*
$root -> First argument to the method to pass the root context. Mandatory.
$workloadName -> Second argument to the method to pass the name of the workload. Optional.
*/}}
{{- $root := index . 0 }}
{{- if gt (len .) 1 -}}
{{- $workloadName := index . 1 -}}
{{- include "bssc-indexmgr.selectorLabels" (tuple $root $workloadName) }}
{{- else }}
{{- include "bssc-indexmgr.selectorLabels" (tuple $root "") }}
{{- end }}
{{- if $root.Values.partOf }}
app.kubernetes.io/part-of: {{ $root.Values.partOf }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Values.managedBy | default $root.Release.Service | quote}}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
helm.sh/chart: "{{ default $root.Chart.Name $root.Values.nameOverride }}-{{ $root.Chart.Version }}"
{{- end }}

{{- define "bssc-indexmgr.selectorLabels" -}}
{{- $root := index . 0 }}
{{- $workloadName := index . 1 }}
app.kubernetes.io/name: {{ default $root.Chart.Name $root.Values.nameOverride }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- if not (empty $workloadName ) }}
app.kubernetes.io/component: {{ $workloadName }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for role/rolebinding.
*/}}
{{- define "bssc-indexmgr.apiVersionRbacAuthorizatioK8sIoV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for cronjob.
*/}}
{{- define "bssc-indexmgr.apiVersionBatchV1Beta1orBatchV1" -}}
{{- if .Capabilities.APIVersions.Has "batch/v1/CronJob" -}}
{{- print "batch/v1" -}}
{{- else -}}
{{- print "batch/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "bssc-indexmgr.serviceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-indexmgr-sa" ( include "bssc-indexmgr.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 12)|int) ) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.delServiceAccount.name" -}}
{{- if .Values.rbac -}}
{{- if .Values.rbac.enabled -}}
{{- printf "%s-del-sa" ( include "bssc-indexmgr.fullname" . |trunc ((sub .Values.customResourceNames.resourceNameLimit 7)|int) ) -}}
{{- else if .Values.serviceAccountName -}}
{{- .Values.serviceAccountName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.unifiedLogging.configMap.name" -}}
{{- $name := printf "%s" (include "bssc-indexmgr.fullname" .) -}}
{{- $suffix := "-logging-conf" -}}
{{- printf "%s%s" ( $name |trunc ((sub .Values.customResourceNames.resourceNameLimit (len $suffix))|int )) $suffix -}}
{{- end -}}

{{- define "bssc-indexmgr.imageRepositoryPath" -}}
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

{{- define "bssc-indexmgr.supportedImageFlavor" -}}
{{/*
This function returns a list of supported imageFlavors for the respective containers. The order of the supported container image flavors must be in descending order, i.e, the first element is taken the default when imageFlavor is empty at all levels.
*/}}
{{- $_ := set . "commonSupportedImageFlavor" (list "rocky8-jre11" "rocky8-jre17") -}}
{{- end -}}

{{- define "bssc-indexmgr.imageTag" -}}
{{/*
This function takes the imageTag of the containers as input and checks if the flavor is mentioned within the tag or not.
If the flavor is predefined in the tag by the user, it is taken as it is. Else the imageHelper function is called to check for the flavor to be used according to the respective imageFlavorPolicy mentioned.
*/}}
{{- $imagetag := index . 0 }}
{{- $splits := regexSplit "-" $imagetag 2 }}
{{- $tag := regexSplit "-" (index $splits 1) -1 }}
{{- $opensourceVersion := index $splits 0 }}
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
{{- if eq (include "bssc-indexmgr.v1.isEmptyValue" $flavor) "true" }}
{{- $flavor = include "bssc-indexmgr.v1.imageHelper" . -}}
{{- end }}
{{- printf "%s-%s-%s" $opensourceVersion $flavor $releaseTag -}}
{{- end }}

{{- define "bssc-indexmgr.v1.imageHelper" -}}
{{/*
Below template function is referred from HBP csf-common-lib/_imageHelper-v2.tpl
All the arguments passed to "bssc-indexmgr.imageTag" are passed to this function.
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
{{- $finalImageFlavor :=  include "bssc-indexmgr.v1.imageFlavorOrFail" (tuple $requestedFlavor $supportedFlavorList $requestedFlavorPolicy) }}
{{- $finalImageFlavor }}
{{- end -}}

{{- define "bssc-indexmgr.v1.imageFlavorOrFail" -}}
{{/*
Below template function is referred from HBP csf-common-lib/_imageFlavorOrFail.tpl and taken as it is.
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

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-indexmgr.v1.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{- define "bssc-indexmgr.v1.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "bssc-indexmgr.v1.isEmptyValue" .) "false" }}
        {{- if eq (include "bssc-indexmgr.v1.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}

{{/*
Return the appropriate apiVersion for certManager.
*/}}
{{- define "bssc-indexmgr.apiVersionCertManager" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else }}
{{- print .Values.security.certManager.apiVersion}}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.container.securityContext" -}}
{{- if .Values.indexmgr.securityContext.enabled }}
readOnlyRootFilesystem: true
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
{{- $securityContext := .Values.indexmgr.containerSecurityContext -}}
{{- if and (.Capabilities.APIVersions.Has "config.openshift.io/v1") (semverCompare "< 1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- $securityContext = omit $securityContext "seccompProfile" -}}
{{- end }}
{{- if $securityContext }}
{{ toYaml $securityContext }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "bssc-indexmgr.pod.securityContext" -}}
{{- if .Values.indexmgr.securityContext.enabled }}
runAsNonRoot: true
{{- $securityContext := .Values.indexmgr.securityContext -}}
{{- $securityContext = omit $securityContext "enabled" -}}
{{- if eq ( toString ( .Values.indexmgr.securityContext.fsGroup )) "auto" }}
{{- $securityContext = omit $securityContext "fsGroup" -}}
{{- end }}
{{- if eq ( toString ( .Values.indexmgr.securityContext.runAsUser )) "auto" }}
{{- $securityContext = omit $securityContext "runAsUser" -}}
{{- end }}
{{- if and (.Capabilities.APIVersions.Has "config.openshift.io/v1") (semverCompare "< 1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- $securityContext = omit $securityContext "seccompProfile" -}}
{{- end }}
{{- if $securityContext  }}
{{ toYaml $securityContext }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Below template function is referred from HBP csf-common-lib/_utilities.tpl
*/}}
{{- define "bssc-indexmgr.boolDefaultFalse" -}}
{{- eq (. | toString | lower) "true" -}}
{{- end -}}

{{- define "bssc-indexmgr.syslogValues" -}}
{{/*
As per HBP, precedence is given to syslog defined at workload level over global level.
If syslog is enabled at workload level, all syslog properties are read from the workload level.
Only if syslog is enabled at global level and left empty at workload level, then all syslog properties are read from the global level.
*/}}
{{- if and (hasKey .Values.indexmgr "unifiedLogging") (hasKey .Values.indexmgr.unifiedLogging "syslog")  (hasKey .Values.indexmgr.unifiedLogging.syslog "enabled") (eq (include "bssc-indexmgr.boolDefaultFalse" .Values.indexmgr.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.indexmgr.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- else if and (hasKey .Values.global "unifiedLogging") (hasKey .Values.global.unifiedLogging "syslog") (hasKey .Values.global.unifiedLogging.syslog "enabled") (eq (include "bssc-indexmgr.boolDefaultFalse" .Values.global.unifiedLogging.syslog.enabled) "true") (eq (include "bssc-indexmgr.v1.isEmptyValue" .Values.indexmgr.unifiedLogging.syslog.enabled ) "true") }}
{{- $_ := set . "syslog" .Values.global.unifiedLogging.syslog }}
{{- $_ := set . "syslogEnabled" "true" }}
{{- end -}}
{{- end -}}

{{- define "bssc-indexmgr.syslogTlsValues" -}}
{{- include "bssc-indexmgr.syslogValues" . }}
{{- if $.syslogEnabled }}
{{- if and (tpl (default "" $.syslog.tls.secretRef.name ) .) (tpl (default "" $.syslog.tls.secretRef.keyNames.caCrt ) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.tls.secretRef.name) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.tls.secretRef.keyNames.caCrt) .) }}
{{- else if and (tpl (default "" $.syslog.caCrt.secretName ) .) (tpl (default "" $.syslog.caCrt.key ) .) }}
{{- $_ := set . "syslogSecretName" (tpl ($.syslog.caCrt.secretName) .) }}
{{- $_ := set . "syslogSecretKey" (tpl ($.syslog.caCrt.key) .) }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "bssc-indexmgr.registry" -}}
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

{{- define "bssc-indexmgr.securityPrereqCheck" -}}
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
{{- define "bssc-indexmgr.defineCpuLimits" -}}
{{- if (eq (include "bssc-indexmgr.v1.coalesceBoolean" (tuple (.Values.enableDefaultCpuLimits) (.Values.global.enableDefaultCpuLimits) false)) "true") }}
{{- $_ := set . "enableCpuLimit" "true" }}
{{- else -}}
{{- $_ := set . "enableCpuLimit" "false" }}
{{- end }}
{{- end -}}

{{/*
Below template function is used to define the values that will be set for the cpu limits for all containers.
*/}}
{{- define "bssc-indexmgr.resources" -}}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $defaultCpuLimit := index . 2 -}}
{{ include "bssc-indexmgr.defineCpuLimits" $root }}
{{- if and (eq $root.enableCpuLimit "true") (not (hasKey $resources.limits "cpu")) }}
{{ $_ := set $resources.limits "cpu" $defaultCpuLimit }}
{{- end }}
{{ toYaml $resources }}
{{- end -}}

{{- define "bssc-indexmgr.isCertManagerEnable" -}}
{{- if eq (tpl (.Values.security.certManager.enabled | toString ) .) "true" }}
{{- $_ := set . "workloadCertMgr" true }}
{{- else if eq (tpl (.Values.security.certManager.enabled | toString ) .) "false" }}
{{- $_ := set . "workloadCertMgr" false }}
{{- end }}
{{- if (eq (include "bssc-indexmgr.v1.coalesceBoolean" (tuple ($.workloadCertMgr) (.Values.certManager.enabled) (.Values.global.certManager.enabled) false)) "true") }}
{{- $_ := set . "isCertManagerEnabled" "true" }}
{{- else -}}
{{- $_ := set . "isCertManagerEnabled" "false" }}
{{- end }}
{{- end }}

{{- define "bssc-indexmgr.certificateValues" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $certificate := $workload.certificate }}
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
{{- else }}
commonName: "test"
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
secretName: {{ template "bssc-indexmgr.fullname" $root }}-certmgr
{{- end }}
{{- if $root.Capabilities.APIVersions.Has "cert-manager.io/v1" }}
secretTemplate:
  labels:
{{- include "bssc-indexmgr.commonLabels" (tuple $root "indexmgr" ) | indent 4 }}
{{- include "bssc-indexmgr.csf-toolkit-helm.labels" (tuple $root) | nindent 4 }}
  annotations:
{{- include "bssc-indexmgr.csf-toolkit-helm.annotations" (tuple $root) | nindent 4}}
{{- end }}
{{- end }}
