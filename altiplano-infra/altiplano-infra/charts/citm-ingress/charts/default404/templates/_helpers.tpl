{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "default404.name" -}}
{{- if .Values.nameOverride }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "default404.fullname" -}}
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
Create a container name,maximum length should be 28 characters. <containerNamePrefix>-<containerName> (63 - 34 - 1) characters
*/}}
{{- define "default404.containerNameSuffix" -}}
{{- $chartName := index . 0 -}}
{{- $suffix := index . 1 -}}
{{- printf "%s-%s" $chartName $suffix | trunc 28 | trimSuffix "-" -}}
{{- end -}}

{{- define "default404.getDeploymentAPI" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "default404.getPodSecurityPolicyAPI" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1" -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
* Allow private registry images to be used
*/}}
{{- define "default404.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.imagePullSecrets | nindent 2 }}
{{- else }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*

Using the csf-common-lib.v1
Refer CSF-CHARTS.git; file csf-common-lib/README.md

*/}}
{{ define "default404.commonLabels" }}
{{- if .Values.commonLabels }}
{{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.component ) }}
{{- end -}}
{{- if or .Values.labels .Values.global.labels }}
{{- include "csf-common-lib.v1.customLabels" (tuple .Values.labels .Values.global.labels) }}
{{- end -}}
{{ end }}

{{- define "default404.annotations" -}}
{{- $envAll := index . 0 -}}
{{- $global_annotations := $envAll.Values.global.annotations }}
{{- $customized_annotations := index . 1 }}
{{- $final_annotations := merge $customized_annotations $global_annotations}}
{{- range $key, $value := $final_annotations }}
{{$key}}: "{{$value}}"
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for pod disruption budget
*/}}
{{- define "default404.pdb.apiVersionPolicyV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" -}}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
* Define topology spread constraints for default404
*/}}
{{- define "default404.spread-constraints" -}}
{{- $g := first . -}}
{{- $Values := index $g "Values" -}}
{{- range $index, $item := $Values.topologySpreadConstraints -}}
- maxSkew: {{ $item.maxSkew }}
  topologyKey: {{ $item.topologyKey }}
  whenUnsatisfiable: {{ default "DoNotSchedule" $item.whenUnsatisfiable }}
{{- if $item.labelSelector }}
  labelSelector:
    {{- $item.labelSelector | toYaml | nindent 4 }}
{{- else if eq ( toString $item.autoGenerateLabelSelector) "true" }}
  labelSelector:
    matchLabels:
      app: {{ template "default404.name" $g }}
{{- end -}}
{{- end -}}
{{- end }}


{{/*
*Setting the custom PSP name
*/}}
{{- define "default404.pspName" -}}
{{- if .Values.global.podSecurityPolicy.userProvided -}}
{{- printf "%s" .Values.global.podSecurityPolicy.pspName -}}
{{- end -}}
{{- end -}}

{{/*
*Setting the securityContext runAsUser
*/}}
{{- define "default404.securityContextrunAsUser" -}}
{{- if or (eq (toString .Values.global.securityContext.runAsUser) "auto") (eq (toString .Values.securityContext.runAsUser) "auto") -}}
{{- printf "%s" "auto" -}}
{{- else if .Values.global.securityContext.runAsUser -}}
{{- printf "%d" (.Values.global.securityContext.runAsUser | int) -}}
{{- else -}}
{{- printf "%d" (.Values.securityContext.runAsUser | int) -}}
{{- end -}}
{{- end -}}

{{/*
*Setting the securityContext runAsGroup
*/}}
{{- define "default404.securityContextrunAsGroup" -}}
{{- if or (eq (toString .Values.global.securityContext.runAsGroup) "auto") (eq (toString .Values.securityContext.runAsGroup) "auto") -}}
{{- printf "%s" "auto" -}}
{{- else if .Values.global.securityContext.runAsGroup -}}
{{- printf "%d" (.Values.global.securityContext.runAsGroup | int) -}}
{{- else -}}
{{- printf "%d" (.Values.securityContext.runAsGroup | int) -}}
{{- end -}}
{{- end -}}

{{/*
*Setting the securityContext fsGroup
*/}}
{{- define "default404.securityContextfsGroup" -}}
{{- if or (eq (toString .Values.global.securityContext.fsGroup) "auto") (eq (toString .Values.securityContext.fsGroup) "auto") -}}
{{- printf "%s" "auto" -}}
{{- else if .Values.global.securityContext.fsGroup -}}
{{- printf "%d" (.Values.global.securityContext.fsGroup | int) -}}
{{- else -}}
{{- printf "%d" (.Values.securityContext.fsGroup | int) -}}
{{- end -}}
{{- end -}}


{{/*
*Check for OCP and k8s version to set seccompProfile
*/}}
{{- define "default404.addSeccompProfile" }}
{{- $isOpenShift := .Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
{{- if and $isOpenShift (semverCompare "<1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end }}
{{- end }}


{{/* Default404 PodDisruptionBudget Minavailable/MaxUnavailable */}}
{{- define "default404.pdb-values" -}}
{{- if and (and (hasKey .Values.default404.pdb "minAvailable") (hasKey .Values.default404.pdb "maxUnavailable")) ( and ( not (kindIs "invalid" .Values.default404.pdb.maxUnavailable)) ( ne ( toString ( .Values.default404.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.default404.pdb.minAvailable)) ( ne ( toString ( .Values.default404.pdb.minAvailable )) "" )) }}
{{- required "Both the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- else if and (hasKey .Values.default404.pdb "minAvailable") (and (not (kindIs "invalid" .Values.default404.pdb.minAvailable)) ( ne ( toString ( .Values.default404.pdb.minAvailable )) ""))}}
minAvailable: {{ .Values.default404.pdb.minAvailable }}
{{- else if and (hasKey .Values.default404.pdb "maxUnavailable") (and (not (kindIs "invalid" .Values.default404.pdb.maxUnavailable)) ( ne ( toString ( .Values.default404.pdb.maxUnavailable )) ""))}}
maxUnavailable: {{ .Values.default404.pdb.maxUnavailable }}
{{- else }}
{{- required "None of the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- end -}}
{{- end -}}

{{/* create psp ? */}}
{{- define "default404.createPSP" }}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy" }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end -}}
{{- end -}}

{{- define "default404.dualStack" -}}
{{- $isDeprGlobalDualStackDefined := ternary  .Values.global.dualStack.enabled false (hasKey .Values.global "dualStack") }}
{{- $isDeprLocalDualStackDefined := ternary .Values.service.dualStack.enabled false (hasKey .Values.service "dualStack") }}

{{- $globalIpFamilies := ternary .Values.global.dualStack.ipFamilies .Values.global.ipFamilies $isDeprGlobalDualStackDefined }}
{{- $globalIpFamilyPolicy := ternary .Values.global.dualStack.ipFamilyPolicy .Values.global.ipFamilyPolicy $isDeprGlobalDualStackDefined }}

{{- $localIpFamilies := ternary .Values.service.dualStack.ipFamilies .Values.service.ipFamilies $isDeprLocalDualStackDefined }}
{{- $localIpFamilyPolicy := ternary .Values.service.dualStack.ipFamilyPolicy .Values.service.ipFamilyPolicy $isDeprLocalDualStackDefined }}

{{- if or $localIpFamilies  $localIpFamilyPolicy }}
{{- if $localIpFamilyPolicy }}
ipFamilyPolicy: {{ $localIpFamilyPolicy }}
{{- end }}
{{- if $localIpFamilies }}
ipFamilies: {{ toYaml $localIpFamilies | nindent 4 }}
{{- end }}
{{- else if or $globalIpFamilies $globalIpFamilyPolicy }}
{{- if $globalIpFamilyPolicy }}
ipFamilyPolicy: {{ $globalIpFamilyPolicy }}
{{- end }}
{{- if $globalIpFamilies }}
ipFamilies: {{ toYaml $globalIpFamilies | nindent 4 }}
{{- end }}
{{- end }}
{{- end -}}

{{/* handle imageRepo backward compatibility */}}
{{- define "default404.splitImageRepo" -}}
{{- $root := index . 0}}
{{- $imageRepo := index . 1 }}
{{- $imageInfo := index . 2 }}
{{- if not (contains "/" $imageRepo) }}
{{- printf "/%s" $imageInfo.imageName }}
{{- else if (eq $root.Values.global.flatRegistry true ) }}
{{- $imageName := regexSplit "/"  $imageRepo -1 | last }}
{{- printf "/%s" $imageName }}
{{- end }}
{{- end -}}

{{/* container image */}}
{{- define "default404.imageMapper" -}}
{{- $root := index . 0}}
{{- $imageInfo := index . 1 }}
{{- $internalRegistry := index . 2 }}
{{- $imageRegistry := coalesce $root.Values.global.registry $internalRegistry }}
{{- $imageRepo := $imageInfo.imageRepo }}
{{- $imageTag := $imageInfo.imageTag }}
{{- if eq $imageInfo.imageName "kubectl" }}
{{- $imageRepo = coalesce $imageInfo.image $imageInfo.imageRepo }}
{{- $imageTag = coalesce $imageInfo.tag $imageInfo.imageTag }}
{{- end }}
{{- $imageName := (include "default404.splitImageRepo" ( tuple $root $imageRepo $imageInfo ) ) }}
{{- if eq $root.Values.global.flatRegistry false -}}
{{- printf "%s/%s%s:%s" $imageRegistry $imageRepo $imageName $imageTag -}}
{{- else -}}
{{- printf "%s%s:%s" $imageRegistry $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{/*
resources block for the default404 pod
*/}}
{{- define "default404.resources" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
requests:
  memory: {{ $workload.resources.requests.memory }}
  cpu: {{ $workload.resources.requests.cpu }}
limits:
  memory: {{ $workload.resources.limits.memory }}
{{- if ( eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits false)) "true" ) }}
  cpu: {{ $workload.resources.limits.cpu }}
{{- end }}
{{- end -}}
