{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "citm-ingress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{/*
Create a default fully qualified controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "citm-ingress.fullname" -}}
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
{{- define "citm-ingress.containerNameSuffix" -}}
{{- $chartName := index . 0 -}}
{{- $suffix := index . 1 -}}
{{- printf "%s-%s" $chartName $suffix | trunc 28 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the path for the publish-service.

By convention this will simply use the <namesapce>/<controller-name> to match the name of the
service generated.

Users can provide an override for an explicit service they want bound via `.Values.controller.publishService.pathOverride`

*/}}
{{- define "citm-ingress.publishServicePath" -}}
{{- $defServiceName := printf "%s/%s" .Release.Namespace (include "citm-ingress.fullname" .) -}}
{{- $servicePath := default $defServiceName .Values.controller.publishService.pathOverride }}
{{- print $servicePath | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "citm-ingress.getAppsV1orextV1Beta1" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "citm-ingress.getPodSecurityPolicyAPI" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1" -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*

Using the csf-common-lib.v1
Refer CSF-CHARTS.git; file csf-common-lib/README.md

*/}}
{{ define "citm-ingress.commonLabels" }}
{{- if .Values.controller.commonLabels }}
{{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.component ) }}
{{- end -}}
{{- if or .Values.controller.labels .Values.global.labels }}
{{- include "csf-common-lib.v1.customLabels" (tuple .Values.controller.labels .Values.global.labels) }}
{{- end -}}
{{ end }}

{{- define "citm-ingress.annotations" -}}
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
{{- define "citm-ingress.pdb.apiVersionPolicyV1Beta1orV1" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" -}}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
* Define topology spread constraints for ingress controller
*/}}
{{- define "citm-ingress.spread-constraints" -}}
{{- $g := first . -}}
{{- $Values := index $g "Values" -}}
{{- range $index, $item := $Values.controller.topologySpreadConstraints }}
- maxSkew: {{ $item.maxSkew }}
  topologyKey: {{ $item.topologyKey }}
  whenUnsatisfiable: {{ default "DoNotSchedule" $item.whenUnsatisfiable }}
{{- if $item.labelSelector }}
  labelSelector:
    {{- $item.labelSelector | toYaml | nindent 4 }}
{{- else if eq ( toString $item.autoGenerateLabelSelector) "true" }}
  labelSelector:
    matchLabels:
      app: {{ template "citm-ingress.name" $g }}
{{- end -}}
{{- end -}}
{{- end }}


{{- define "citm-ingress.timeZoneName" -}}
{{- if or (.Values.controller.timezone.timeZoneEnv) (.Values.controller.timezone.timeZoneNameEnv) -}}
{{ .Values.controller.timezone.timeZoneEnv | default .Values.controller.timezone.timeZoneNameEnv | quote }}
{{- else if or (.Values.global.timeZoneEnv) (.Values.global.timeZoneName) -}}
{{ .Values.global.timeZoneEnv | default .Values.global.timeZoneName | quote }}
{{- else -}}
{{- printf "%s" "UTC" -}}
{{- end -}}
{{- end -}}

{{/*
*Setting the custom PSP name
*/}}
{{- define "citm-ingress.pspName" -}}
{{- if .Values.global.podSecurityPolicy.userProvided -}}
{{- printf "%s" .Values.global.podSecurityPolicy.pspName -}}
{{- end -}}
{{- end -}}

{{/*
*set disableIvp4 and disableIvp6 variable
*/}}
{{- define "citm-ingress.disableIpv4" -}}
{{- default .Values.controller.disableIpv4 .Values.controller.disableIvp4 -}}
{{- end -}}

{{- define "citm-ingress.disableIpv6" -}}
{{- default .Values.controller.disableIpv6 .Values.controller.disableIvp6 -}}
{{- end -}}

{{- define "citm-ingress.statusPortScheme" -}}
{{- if (eq .Values.controller.disableTlsForStatusPort true) }}
{{- printf "%s" "HTTP" }}
{{- else -}}
{{- printf "%s" "HTTPS" }}
{{- end -}}
{{- end -}}

{{/*
IngressClass parameters.
*/}}
{{- define "ingressClass.parameters" -}}
  {{- if .Values.controller.ingressClassResource.parameters -}}
          parameters:
{{ toYaml .Values.controller.ingressClassResource.parameters | indent 4}}
  {{ end }}
{{- end -}}

{{/*
* Setting default name for ingress test pod
*/}}
{{- define "citm-ingress.testName" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $podPrefix := default "" .Values.global.podNamePrefix -}}
{{- $randomchar := randAlphaNum 6 | lower -}}
{{- $podPrefixAndReleaseName := printf "%s%s" $podPrefix .Release.Name -}}
{{- printf "%s-%s-%s" $podPrefixAndReleaseName "citm-ingress.test-connection" $randomchar | trunc -63 -}}
{{- end -}}
{{- end -}}

{{/*
*Setting the securityContext runAsUser
*/}}
{{- define "citm-ingress.securityContextrunAsUser" -}}
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
{{- define "citm-ingress.securityContextrunAsGroup" -}}
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
{{- define "citm-ingress.securityContextfsGroup" -}}
{{- if or (eq (toString .Values.global.securityContext.fsGroup) "auto") (eq (toString .Values.securityContext.fsGroup) "auto") -}}
{{- printf "%s" "auto" -}}
{{- else if .Values.global.securityContext.fsGroup -}}
{{- printf "%d" (.Values.global.securityContext.fsGroup | int) -}}
{{- else -}}
{{- printf "%d" (.Values.securityContext.fsGroup | int) -}}
{{- end -}}
{{- end -}}

{{/*
*Check for OCP
*/}}
{{- define "citm-ingress.isOpenShift" }}
{{- .Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
{{- end }}

{{/*
*Check for OCP and k8s version to set seccompProfile
*/}}
{{- define "citm-ingress.addSeccompProfile" }}
{{- if and ( eq ( include "citm-ingress.isOpenShift" .) "true" ) (semverCompare "<1.24.0-0" .Capabilities.KubeVersion.GitVersion) }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end }}
{{- end }}


{{/*
*Check for allocateLoadBalancerNodePorts

DO NOT allocate nodeports ONLY if ALL the below conditions are satisfied
    - serviceType is LoadBalancer
    - (AND) allocateLoadBalancerNodePorts is set to false
    - (AND) K8s version is >= 1.24.0

*/}}
{{- define "citm-ingress.notAllocateLoadBalancerNodePorts" }}
{{- if and (semverCompare ">=1.24.0-0" .Capabilities.KubeVersion.GitVersion) (eq (.Values.controller.service.allocateLoadBalancerNodePorts | toString) "false") (eq .Values.controller.service.type "LoadBalancer")  }}
{{- printf "%t" true }}
{{- else }}
{{- printf "" }}
{{- end }}
{{- end }}


{{/*
*Check for k8s version to set image version
*/}}
{{- define "citm-ingress.imageTag" }}
{{- print (.Values.controller.imageTag) }}
{{- end }}


{{/*
Set Image Flavor for the workload
$imageFlavor:= $workload.imageFlavor $root.imageFlavor $global.imageFlavor Returns first non empty value from the args, defaults to rocky8 if both are empty
$imageFlavorPolicy := coalesce $workload.imageFlavorPolicy $root.imageFlavorPolicy $global.imageFlavorPolicy
$selectedImageFlavor Checks container image flavor based on imageFlavorPolicy i.e Strict or BestMatch
if yes print the the flavor with a - in the front
else "csf-common-lib.v1.imageFlavorOrFail" fails with the incorrect flavor message
*/}}
{{- define "citm-ingress.imageFlavor" }}
{{- $workload:= index . 0 }}
{{- $root:= index . 1 }}
{{- $global:= index . 2 }}
{{- $supportedFlavors:= (list "rocky8") }}
{{- $imageFlavor:= coalesce $workload.imageFlavor $root.imageFlavor $global.imageFlavor "rocky8"}}
{{- $imageFlavorPolicy := coalesce $workload.imageFlavorPolicy $root.imageFlavorPolicy $global.imageFlavorPolicy }}
{{- $selectedImageFlavor := include "csf-common-lib.v1.imageFlavorOrFail" (tuple $imageFlavor $supportedFlavors $imageFlavorPolicy) }}
{{- printf "-%s" $selectedImageFlavor }}
{{- end -}}

{{/*
* Allow private registry images to be used
*/}}
{{- define "citm-ingress.imagePullSecrets" -}}
{{- if .Values.controller.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.controller.imagePullSecrets | nindent 2 }}
{{- else }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets: {{- toYaml .Values.global.imagePullSecrets | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Ingress PodDisruptionBudget Minavailable/MaxUnavailable */}}
{{- define "citm-ingress.pdb-values" -}}
{{- if and (and (hasKey .Values.controller.pdb "minAvailable") (hasKey .Values.controller.pdb "maxUnavailable")) ( and ( not (kindIs "invalid" .Values.controller.pdb.maxUnavailable)) ( ne ( toString ( .Values.controller.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.controller.pdb.minAvailable)) ( ne ( toString ( .Values.controller.pdb.minAvailable )) "" )) }}
{{- required "Both the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- else if and (hasKey .Values.controller.pdb "minAvailable") (and (not (kindIs "invalid" .Values.controller.pdb.minAvailable)) ( ne ( toString ( .Values.controller.pdb.minAvailable )) ""))}}
minAvailable: {{ .Values.controller.pdb.minAvailable }}
{{- else if and (hasKey .Values.controller.pdb "maxUnavailable") (and (not (kindIs "invalid" .Values.controller.pdb.maxUnavailable)) ( ne ( toString ( .Values.controller.pdb.maxUnavailable )) ""))}}
maxUnavailable: {{ .Values.controller.pdb.maxUnavailable }}
{{- else }}
{{- required "None of the values(maxUnavailable/minAvailable) are set for pdb. Only One of the values to be set." "" }}
{{- end -}}
{{- end -}}

{{- define "citm-ingress.getAutoScalerAPI" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
{{- print "autoscaling/v2" -}}
{{- else if .Capabilities.APIVersions.Has "autoscaling/v2beta2" -}}
{{- print "autoscaling/v2beta2" -}}
{{- else -}}
{{- print "autoscaling/v1" -}}
{{- end -}}
{{- end -}}

{{- define "citm-ingress.certificateVersion" -}}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1") }}
{{- print "cert-manager.io/v1" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") }}
{{- print "cert-manager.io/v1alpha2" }}
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha1") }}
{{- print "cert-manager.io/v1alpha1" }}
{{- end }}
{{- end -}}


{{- define "citm-ingress.isHPAenabled" -}}
{{- $hpa_local_unset := or (eq (.Values.controller.hpa.enabled | toString) "<nil>") (eq (.Values.controller.hpa.enabled | toString) "") }}
{{- if .Values.controller.hpa.enabled }}
{{- print "true" }}
{{- else if and $hpa_local_unset (eq .Values.global.hpa.enabled true) }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}

{{- define "citm-ingress.isGenericVolumeEnabled" -}}
{{- $generic_local_unset := or (eq (.Values.controller.ephemeralVolume.generic.enabled | toString) "<nil>") (eq (.Values.controller.ephemeralVolume.generic.enabled | toString) "") }}
{{- if .Values.controller.ephemeralVolume.generic.enabled }}
{{- print "true" }}
{{- else if and $generic_local_unset (eq .Values.global.ephemeralVolume.generic.enabled true) }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}

{{/* create psp ? */}}
{{- define "citm-ingress.createPSP" }}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy" }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end }}

{{/* Merge extensions with logFormatUpstream

If controller.unifiedLogging.extension or global.unifiedLogging.extension NOT defined
   - keep logFormatUpstream as is.
Else
   - convert extension to json and trim { and }
   - quote the extension(required to convert the json to string with escape characters)  after trim
   - trim the quoted string with quotes at the beging and at the end
   - replace <"log\":> with <extension,"log\":>

Ex :
     extension:
         ns_uuid : "CITM_G_333"
         cnf_uuid : "CNF_G_666"
         cnfc_uuid : "NFC_G_999"

     - convert extension to json                   => {"cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"}

     - trim { and }                                => "cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"

     - quote the extension                         => "\"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\""
       Notice the extension is surrounded by ""

     - trim the quotes from beginning and end      => \"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\"
       Notice last and first "" removed

     - replace the <"log\":>                       =>  \"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\","log\":
       <\\\"log\\\":> is used as regex to retain slash(\) and quote(")

*/}}
{{/* String replacement logic in log format.
   "citm-pod-name" is a place holder which will later be replaced with pod_name in config.go of ingress image

   ==> replace "\\\"process\\\":\\\"nginx\\\"," "\\\"process\\\":\\\"nginx\\\",\\\"service\\\":\\\"citm-ingress\\\","
   Find "process":"nginx" in log format and add "service":"citm-ingress" after that

   ==> replace "$hostname" (printf "citm-pod-name.%s" .Release.Namespace)
   Replace $hostname with "citm-pod-name.namespace"

   ==> replace "\\\"host\\\":" (printf "\\\"systemid\\\":\\\"citm-pod-name\\\",\\\"host\\\":")

   Find "host": in logs and add "systemid":"citm-pod-name" before that
*/}}

{{- define "citm-ingress.logFormatUpstream" }}
{{- $def_logFormatUpstream := .Values.controller.logFormats.logFormatUpstream }}
{{- $def_logFormatUpstream = $def_logFormatUpstream | replace "\\\"process\\\":\\\"nginx\\\"," "\\\"process\\\":\\\"nginx\\\",\\\"service\\\":\\\"citm-ingress\\\"," }}
{{- $def_logFormatUpstream = $def_logFormatUpstream | replace "$hostname" (printf "citm-pod-name.%s" .Release.Namespace) }}
{{- if .Values.controller.enableSystemId }}
{{- $def_logFormatUpstream = $def_logFormatUpstream | replace "\\\"host\\\":" (printf "\\\"systemid\\\":\\\"citm-pod-name\\\",\\\"host\\\":") }}
{{- end }}
{{- if not (or .Values.global.unifiedLogging.extension .Values.controller.unifiedLogging.extension) }}
{{- printf "%s" $def_logFormatUpstream }}
{{- else }}
{{- $str_extension := (.Values.controller.unifiedLogging.extension | default .Values.global.unifiedLogging.extension) | toJson | trimPrefix "{" | trimSuffix "}" | quote | trimPrefix "\"" | trimSuffix "\"" }}
{{- $merged_logFormatUpstream := $def_logFormatUpstream | replace "\\\"log\\\":" (printf "%s,\\\"log\\\":" $str_extension)  }}
{{- printf "%s" $merged_logFormatUpstream}}
{{- end }}
{{- end }}


{{/* Merge extensions with logFormatStream

If controller.unifiedLogging.extension or global.unifiedLogging.extension NOT defined
   - keep logFormatStream as is.
Else
   - convert extension to json and trim {,}
   - quote the extension(required to convert the json to string with escape characters)  after trim
   - trim the quoted string with quotes athe beging and at the end
   - replace <"log\":> with <extension,"log\":>

Ex :
     extension:
         ns_uuid : "CITM_G_333"
         cnf_uuid : "CNF_G_666"
         cnfc_uuid : "NFC_G_999"

     - convert extension to json                   => {"cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"}

     - trim { and }                                => "cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"

     - quote the extension                         => "\"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\""
       Notice the extension is surrounded by ""

     - trim the quotes from beginning and end      => \"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\"
       Notice last and first "" removed

     - replace the <\"log\":>                       =>  \"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\",\"log\":
       <\\\"log\\\":> is used as regex to retain slash(\) and quote(")

*/}}

{{/* String replacement logic in log format.
   "citm-pod-name" is a place holder which will later be replaced with pod_name in config.go of ingress image

   ==> replace "\\\"process\\\":\\\"nginx\\\"," "\\\"process\\\":\\\"nginx\\\",\\\"service\\\":\\\"citm-ingress\\\","
   Find "process":"nginx" in log format and add "service":"citm-ingress" after that

   ==> replace "$hostname" (printf "citm-pod-name.%s" .Release.Namespace)
   Replace $hostname with "citm-pod-name.namespace"

   ==> replace "\\\"host\\\":" (printf "\\\"systemid\\\":\\\"citm-pod-name\\\",\\\"host\\\":")

   Find "host": in logs and add "systemid":"citm-pod-name" before that
*/}}
{{- define "citm-ingress.logFormatStream" }}
{{- $def_logFormatStream := .Values.controller.logFormats.logFormatStream }}
{{- $def_logFormatStream = $def_logFormatStream | replace "\\\"process\\\":\\\"nginx\\\"," "\\\"process\\\":\\\"nginx\\\",\\\"service\\\":\\\"citm-ingress\\\"," }}
{{- $def_logFormatStream = $def_logFormatStream | replace "$hostname" (printf "citm-pod-name.%s" .Release.Namespace) }}
{{- if .Values.controller.enableSystemId }}
{{- $def_logFormatStream = $def_logFormatStream | replace "\\\"host\\\":" (printf "\\\"systemid\\\":\\\"citm-pod-name\\\",\\\"host\\\":") }}
{{- end }}
{{- if not (or .Values.global.unifiedLogging.extension .Values.controller.unifiedLogging.extension) }}
{{- printf "%s" $def_logFormatStream }}
{{- else }}
{{- $str_extension := (.Values.controller.unifiedLogging.extension | default .Values.global.unifiedLogging.extension) | toJson | trimPrefix "{" | trimSuffix "}" | quote | trimPrefix "\"" | trimSuffix "\"" }}
{{- $merged_logFormatStream := $def_logFormatStream | replace "\\\"log\\\":" (printf "%s,\\\"log\\\":" $str_extension)  }}
{{- printf "%s" $merged_logFormatStream}}
{{- end }}
{{- end }}


{{/* Exporting fomatted extensions as env

- convert extension to json and trim {,}
- quote the extension(required to convert the json to string with escape characters)  after trim
- trim the quoted string with quotes athe beging and at the end

Ex :
     extension:
         ns_uuid : "CITM_G_333"
         cnf_uuid : "CNF_G_666"
         cnfc_uuid : "NFC_G_999"

     - convert extension to json                   => {"cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"}

     - trim { and }                                => "cnf_uuid":"CNF_666","cnfc_uuid":"CNFC_999","ns_uuid":"CITM_333"

     - quote the extension                         => "\"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\""
       Notice the extension is surrounded by ""

     - trim the quotes from beginning and end      => \"cnf_uuid\":\"CNF_666\",\"cnfc_uuid\":\"CNFC_999\",\"ns_uuid\":\"CITM_333\"
       Notice last and first " removed

*/}}
{{- define "citm-ingress.logExtensions" }}
{{- if or .Values.global.unifiedLogging.extension .Values.controller.unifiedLogging.extension }}
{{- $str_extension := (.Values.controller.unifiedLogging.extension | default .Values.global.unifiedLogging.extension) | toJson | trimPrefix "{" | trimSuffix "}" | quote | trimPrefix "\"" | trimSuffix "\"" }}
{{- printf "%s" $str_extension}}
{{- else }}
{{- printf "%s" "" -}}
{{- end }}
{{- end }}



{{/* Function to check the UK_TSR 8.1 Alerts

   _     _       _     _     _       _ _
  / \   / \     / \   / \   / \     /   \
 ( U ) ( K ) - ( T ) ( S ) ( R )   ( 8.1 )
  \_/   \_/     \_/   \_/   \_/     \_ _/

An alert is logged when following one or more conditions is/are met.
+---------------------------+---------------+
|      Parameter            |   Condition   |
+---------------------------+---------------+
| bindCapability**          |     true      |
| hostNetwork               |     true      |
| securityContextPrivileged |     true      |
| workerProcessAsRoot**     |     true      |
| scope.enabled             |     false     |
+---------------------------+---------------+

!!!
    ** Covered as part of Nginx C code, so those checks are not added below.
!!!

If new conditions needs to be added use below $checks
(list <PARAM TO CHECK> <VALUE TO BE CHECKED> <ALERT STRING>)


*/}}
{{- define "citm-ingress.unhardenedAlertMsg" }}
{{- $logString := "" }}

{{- $checks := list (list .Values.controller.hostNetwork true "hostNetwork is enabled") (list .Values.controller.securityContextPrivileged true "securityContextPrivileged is enabled") (list .Values.controller.scope.enabled false "Clusterwide scope is enabled") }}

{{- range $check := $checks }}
   {{- $param := index $check 0 }}
   {{- $expected := index $check 1 }}
   {{- $concatString := index $check 2 }}

   {{- if eq $param $expected }}
   {{- $logString = printf "%s%s," $logString $concatString }}
   {{- end }}
{{- end }}

{{- $logString = printf "%s" (trimSuffix "," $logString) }}

{{- if (gt (len $logString) 0)  -}}
{{- $logString = printf "%s" (default $logString .Values.controller.customUnhardenedAlertMsg) }}
{{- end }}

{{- printf "%s" $logString }}
{{- end }}


{{- define "citm-ingress.dualStack" -}}
{{- $isDeprGlobalDualStackDefined := ternary  .Values.global.dualStack.enabled false (hasKey .Values.global "dualStack") }}
{{- $isDeprLocalDualStackDefined := ternary .Values.controller.service.dualStack.enabled false (hasKey .Values.controller.service "dualStack") }}

{{- $globalIpFamilies := ternary .Values.global.dualStack.ipFamilies .Values.global.ipFamilies $isDeprGlobalDualStackDefined }}
{{- $globalIpFamilyPolicy := ternary .Values.global.dualStack.ipFamilyPolicy .Values.global.ipFamilyPolicy $isDeprGlobalDualStackDefined }}

{{- $localIpFamilies := ternary .Values.controller.service.dualStack.ipFamilies .Values.controller.service.ipFamilies $isDeprLocalDualStackDefined }}
{{- $localIpFamilyPolicy := ternary .Values.controller.service.dualStack.ipFamilyPolicy .Values.controller.service.ipFamilyPolicy $isDeprLocalDualStackDefined }}

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

{{/*
Handle imageRepo backward compatibility.
Split image repo when older values are provided ex: citm/citm-nginx-ingress to citm-nginx-ingress.
*/}}
{{- define "citm-ingress.splitImageRepo" -}}
{{- $root := index . 0}}
{{- $imageInfo := index . 1 }}
{{- if not (contains "/" $imageInfo.imageRepo) }}
{{- printf "/%s" $imageInfo.imageName }}
{{- else if (eq $root.Values.global.flatRegistry true ) }}
{{- $imageName := regexSplit "/"  $imageInfo.imageRepo -1 | last }}
{{- printf "/%s" $imageName }}
{{- end }}
{{- end -}}

{{/* container image
$root, $imageInfo, $internalRegistry, $imageFlavor pointers to root, workload, registry for image, default imageFlavor set to empty string
if not (contains "rocky" $imageInfo.imageTag) - if imageTag contains rocky, indicates older image tag which doesnt need flavor to be set
$imageFlavor = (include "citm-ingress.imageFlavor" ( tuple $imageInfo.imageFlavor $root.Values.imageFlavor ) )
call imageFlavor template and pass workload flavor followed by root flavor as arguments
gloabl registry has precendence over internalXyz registry
citm-ingress.splitImageRepo handles older implementation of imageRepo: "citm/citm-nginx-ingress"
citm-ingress.splitImageRepo handles older kubectl implementation of kubectlImageTag, kubectlImage
maps <regsitry>/<imageRepo>/<imageName>:<imageTag><imageFlavor> when gloabl.flatRegistry=false
maps <regsitry>/<imageName>:<imageTag><imageFlavor> when gloabl.flatRegistry=true
*/}}
{{- define "citm-ingress.imageMapper" -}}
{{- $root := index . 0}}
{{- $imageInfo := index . 1 }}
{{- $internalRegistry := index . 2 }}
{{- $imageFlavor := "" }}
{{- if not (contains "rocky" $imageInfo.imageTag)}}
{{- $imageFlavor = (include "citm-ingress.imageFlavor" ( list  $imageInfo $root.Values $root.Values.global ) ) }}
{{- end }}
{{- $imageRegistry := coalesce $root.Values.global.registry $internalRegistry }}
{{- $imageName := (include "citm-ingress.splitImageRepo" ( tuple $root $imageInfo ) ) }}
{{- if eq $root.Values.global.flatRegistry false -}}
{{- printf "%s/%s%s:%s%s" $imageRegistry $imageInfo.imageRepo $imageName $imageInfo.imageTag $imageFlavor -}}
{{- else -}}
{{- printf "%s%s:%s%s" $imageRegistry $imageName $imageInfo.imageTag $imageFlavor -}}
{{- end -}}
{{- end -}}

{{/*
Check if certManager is enabled or not
preference order -->  local enabled --> local used --> global enabled
check whether local enabled is set or local used it set and proceed accordingly
*/}}
{{- define "citm-ingress.isCertManagerEnabled" }}
{{- $localCertManagerEnabledUnset := or (eq (.Values.certManager.enabled | toString) "<nil>") (eq (.Values.certManager.enabled | toString) "") }}
{{- $localCertManagerUsedUnset := or (eq (.Values.certManager.used | toString) "<nil>") (eq (.Values.certManager.used | toString) "") }}
{{- $globalCertManagerEnabled := ((.Values.global).certManager).enabled }}
{{- $localCertManagerUsed := .Values.certManager.used }}
{{- $localCertManagerEnabled := .Values.certManager.enabled }}
{{- if $localCertManagerEnabledUnset }}
{{- if $localCertManagerUsedUnset }}
{{- if $globalCertManagerEnabled }}
{{- print (list "true" "enabled") }}
{{- else }}
{{- print (list "false" "enabled") }}
{{- end }}
{{- else if $localCertManagerUsed }}
{{- print (list "true" "used") }}
{{- else }}
{{- print (list "false" "used") }}
{{- end }}
{{- else if $localCertManagerEnabled }}
{{- print (list "true" "enabled") }}
{{- else }}
{{- print (list "false" "enabled") }}
{{- end }}
{{- end }}


{{/* Fetch the secret name based on the old and new variables for certificate
priority goes to tls section over defaultSSL and defaultStreamSSL secrets
*/}}
{{- define "citm-ingress.getCertificate" }}
{{- $root := index . 0 }}
{{- $certType := index . 1 }}
{{- if eq $certType "sslCertificate" }}
{{- if (((($root.Values.controller).tls).sslCertificate).secretRef).name }}
{{- print $root.Values.controller.tls.sslCertificate.secretRef.name }}
{{- else if $root.Values.controller.defaultSSLCertificate }}
{{- print $root.Values.controller.defaultSSLCertificate }}
{{- else }}
{{- print "no_certificate" }}
{{- end }}
{{- else if eq $certType "streamSSLCertificate" }}
{{- if (((($root.Values.controller).tls).streamSSLCertificate).secretRef).name }}
{{- print $root.Values.controller.tls.streamSSLCertificate.secretRef.name }}
{{- else if $root.Values.controller.defaultStreamSSLCertificate }}
{{- print $root.Values.controller.defaultStreamSSLCertificate }}
{{- else }}
{{- print "no_certificate" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
set secret cert keys
assign the certkeys from defaultSSL and defaultStreamSSL certificates first
Then rewrite the variables based on the "name" key from each block SSLCertificate and streamSSLCertificate
*/}}
{{- define "citm-ingress.setCertKeys" }}
{{- $sslCert_caCrt := .Values.controller.defaultSSLCertificateTLS.keyNames.caCrt }}
{{- $sslCert_tlsKey := required "Keyname of defaultSSLCertificate tls.key is required" .Values.controller.defaultSSLCertificateTLS.keyNames.tlsKey }}
{{- $sslCert_tlsCrt := required "Keyname of defaultSSLCertificate tls.crt is required" .Values.controller.defaultSSLCertificateTLS.keyNames.tlsCrt }}
{{- $streamSSLCert_caCrt := .Values.controller.defaultStreamSSLCertificateTLS.keyNames.caCrt }}
{{- $streamSSLCert_tlsKey := required "Keyname of defaultStreamSSLCertificate tls.key is required" .Values.controller.defaultStreamSSLCertificateTLS.keyNames.tlsKey }}
{{- $streamSSLCert_tlsCrt := required "Keyname of defaultStreamSSLCertificate tls.crt is required" .Values.controller.defaultStreamSSLCertificateTLS.keyNames.tlsCrt }}
{{- if hasKey .Values.controller "tls" }}
{{- if .Values.controller.tls.sslCertificate.secretRef.name }}
{{- $sslCert_caCrt = .Values.controller.tls.sslCertificate.secretRef.keyNames.caCrt }}
{{- $sslCert_tlsKey = required "Keyname of sslCertificate tls.key is required" .Values.controller.tls.sslCertificate.secretRef.keyNames.tlsKey }}
{{- $sslCert_tlsCrt =  required "Keyname of sslCertificate tls.crt is required" .Values.controller.tls.sslCertificate.secretRef.keyNames.tlsCrt }}
{{- end }}
{{- if .Values.controller.tls.streamSSLCertificate.secretRef.name }}
{{- $streamSSLCert_caCrt = .Values.controller.tls.streamSSLCertificate.secretRef.keyNames.caCrt }}
{{- $streamSSLCert_tlsKey = required "Keyname of streamSSLCertificate tls.key is required" .Values.controller.tls.streamSSLCertificate.secretRef.keyNames.tlsKey }}
{{- $streamSSLCert_tlsCrt = required "Keyname of streamSSLCertificate tls.crt is required" .Values.controller.tls.streamSSLCertificate.secretRef.keyNames.tlsCrt }}
{{- end }}
{{- end }}
  defaultSSLCertificate-tls-caCrt: {{ $sslCert_caCrt }}
  defaultSSLCertificate-tls-tlsKey: {{ $sslCert_tlsKey }}
  defaultSSLCertificate-tls-tlsCrt: {{ $sslCert_tlsCrt }}
  defaultStreamSSLCertificate-tls-caCrt: {{ $streamSSLCert_caCrt }}
  defaultStreamSSLCertificate-tls-tlsKey: {{ $streamSSLCert_tlsKey }}
  defaultStreamSSLCertificate-tls-tlsCrt: {{ $streamSSLCert_tlsCrt }}
{{- end }}


{{/* fetch certManager issuer
priority order as follows
workload ( certificate block), root (certManager block at root), global ( certManager block at global)
If all of the issuers are left empty then a self signed issuer will be created
*/}}
{{- define "citm-ingress.getCertManagerIssuer" }}
{{- $local := (((.Values.controller).certificate).issuerRef).name }}
{{- $root := .Values.certManager.issuerRef.name }}
{{- $global := ((.Values.global.certManager).issuerRef).name }}
{{- if $local }}
  issuerRef:
    name: {{ .Values.controller.certificate.issuerRef.name }}
    kind: {{ .Values.controller.certificate.issuerRef.kind }}
    group: {{ .Values.controller.certificate.issuerRef.group }}
{{- else if $root }}
  issuerRef:
    name: {{ .Values.certManager.issuerRef.name }}
    kind: {{ .Values.certManager.issuerRef.kind }}
    group: {{ .Values.certManager.issuerRef.group }}
{{- else if $global }}
  issuerRef:
    name: {{ .Values.global.certManager.issuerRef.name }}
    kind: {{ .Values.global.certManager.issuerRef.kind }}
    group: {{ .Values.global.certManager.issuerRef.group }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end }}
