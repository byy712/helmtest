{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cbur.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50| trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cbur.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-cbur" .Release.Name | replace "+" "-" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
define the default issuer name
*/}}
{{- define "cbur.defaultIssuerName" -}}
{{- printf "%s-ca-issuer" (include "cbur.fullname" .) -}}
{{- end -}}

{{/*
Convert use_celery to direct_redis to keep backward compatibility with older releases
*/}}
{{- define "cbur.initCelery" -}}
{{- if .Values.use_celery -}}
{{- if .Values.use_celery.enabled -}}
{{- $_ := set .Values.direct_redis "enabled" true }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Convert tls settings to keep backward compatibility with older releases
*/}}
{{- define "cbur.tls" -}}
{{- if .Values.https -}}
{{- if .Values.https.enabled -}}
{{- $_ := set .Values.tls "enabled" true }}
{{- if .Values.https.certsPath -}}
{{- $_ := set .Values.tls "certsPath" .Values.https.certsPath }}
{{- end -}}
{{- if .Values.https.port -}}
{{- $_ := set .Values.tls "port" .Values.https.port }}
{{- end -}}
{{- if and .Values.https.tls.enabled .Values.https.tls.credentialName -}}
{{- $_ := set .Values.tls "secretName" .Values.https.tls.credentialName }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and .Values.tls.secretName (not .Values.tls.serverSecretRef.credentialName) }}
{{- $_ := set .Values.tls.serverSecretRef "credentialName" .Values.tls.secretName }}
{{- end -}}
{{- if and .Values.tls.secretName (not .Values.tls.clientSecretRef.credentialName) -}}
{{- $_ := set .Values.tls.clientSecretRef "credentialName" .Values.tls.secretName }}
{{- end -}}
{{- end -}}
{{/*
Merging global.unifiedLogging section with <workload>.unifiedSection to ensure not set values on worload level be taken from the global section.
*/}}
{{- define "cbur.unifiedLoggingMerge" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $workload_tmp := merge (deepCopy (index $root.Values $workload).unifiedLogging) (deepCopy $root.Values.global.unifiedLogging) }}
{{- $_ := set $workload_tmp.syslog "enabled" (eq (toString (index $root.Values $workload).unifiedLogging.syslog.enabled) "<nil>" | ternary $root.Values.global.unifiedLogging.syslog.enabled (index $root.Values $workload).unifiedLogging.syslog.enabled) }}
{{- $_ := set $workload_tmp.syslog.rfc "enabled" (eq (toString (index $root.Values $workload).unifiedLogging.syslog.rfc.enabled) "<nil>" | ternary $root.Values.global.unifiedLogging.syslog.rfc.enabled (index $root.Values $workload).unifiedLogging.syslog.rfc.enabled) }}
{{- $_ := set (index $root.Values $workload) "unifiedLogging" $workload_tmp}}
{{- end }}
{{/*
Convert logging.unified_logging to unifiedLogging.cburConsoleLog and more to keep backward compatibility with older releases
*/}}
{{- define "cbur.unifiedLogging" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if and (index $root.Values $workload).unifiedLogging.syslog (index $root.Values $workload).unifiedLogging.syslog.enabled}}
{{- $dot :=  index $root.Values $workload }}
{{- if $root.Values.logging.unified_logging -}}
{{- $_ := set $dot.unifiedLogging "cburConsoleLog" true }}
{{- end -}}
{{- if $root.Values.unifiedLogging.tls -}}
{{- if $root.Values.unifiedLogging.syslog.tls.credentialName -}}
{{- $_ := set $dot.unifiedLogging.syslog.tls.secretRef "name" $root.unifiedLogging.syslog.tls.credentialName }}
{{- end -}}
{{- if $root.Values.unifiedLogging.syslog.tls.caName }}
{{- $_ := set $dot.unifiedLogging.syslog.tls.secretRef.keyNames "caCrt" $root.unifiedLogging.syslog.tls.caName }}
{{- end -}}
{{- if $root.Values.unifiedLogging.syslog.tls.tlsCrtName -}}
{{- $_ := set $dot.unifiedLogging.syslog.tls.secretRef.keyNames "tlsCrt" $root.unifiedLogging.syslog.tls.tlsCrtName }}
{{- end -}}
{{- if $root.Values.unifiedLogging.syslog.tls.tlsKeyName -}}
{{- $_ := set $dot.unifiedLogging.syslog.tls.secretRef.keyNames "tlsKey" $root.unifiedLogging.syslog.tls.tlsKeyName }}
{{- end -}}
{{- end -}}
{{/*Use legacy format, when both values "syslog.unifiedLoggingFormat.enabled" and "cburConsoleLog" are defined and set to false*/}}
{{- if $root.Values.unifiedLogging.syslog.unifiedLoggingFormat }}
{{- if and (hasKey $root.Values.unifiedLogging "cburConsoleLog") (hasKey $root.Values.unifiedLogging.syslog.unifiedLoggingFormat "enabled") -}}
{{- if and (not $root.Values.unifiedLogging.cburConsoleLog) (not $root.Values.unifiedLogging.syslog.unifiedLoggingFormat.enabled) -}}
{{- $_ := set $root.Values.unifiedLogging "useLegacyFormat" true }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of cbur.unifiedLoggingExt
*/}}
{{- define "cbur.unifiedLoggingExt" -}}
{{- $dot := index . 0 }}
{{- $workloadExt := index . 1 }}
{{- if or $workloadExt $dot.Values.global.unifiedLogging.extension }}
- name: CLOG_EXTENSION
  value: {{ merge $workloadExt $dot.Values.global.unifiedLogging.extension | toJson | quote }}
{{- end -}}
{{- end -}}

{{/*
Create the name of cbur.role
*/}}
{{- define "cbur.role" -}}
{{- if and (hasKey .Values "accessAllResources") (not .Values.accessAllResources) }}
{{- $_ := set .Values.rbac "accessAllResources" false }}
{{- end }}
{{- if and (hasKey .Values "adminRole") (not .Values.adminRole) }}
{{- $_ := set .Values.rbac "adminRole" false }}
{{- end }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cbur.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define valid SSH modes and strictHostKeyChecking.
*/}}
{{- define "cbur.valid.ssh.mode" }}
{{- printf "sftp" }}
{{- end }}
{{- define "cbur.valid.ssh.strictHostKeyChecking" }}
{{- printf "no,yes,autoadd" }}
{{- end }}

{{- define "cbur.DeploymentAPI" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Define CBUR service name used for istio traffic management.
*/}}
{{- define "cbur.host" -}}
{{- if .Values.clusterDomain -}}
{{ template "cbur.fullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
{{- else -}}
{{ template "cbur.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Define CBUR redis service name.
*/}}
{{- define "cbur.redisServiceHost" -}}
{{- if .Values.clusterDomain -}}
{{ template "cbur.fullname" . }}-redis.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
{{- else -}}
{{ template "cbur.fullname" . }}-redis
{{- end -}}
{{- end -}}

{{- define "cbur.istio.initIstio" -}}
{{- if .Values.istio }}
{{- $_ := set . "istio" .Values.istio }}
{{- else }}
{{- $_ := set . "istio" .Values.global.istio }}
{{- end }}
{{- if $.istio.sharedHttpGateway }}
{{- if $.istio.sharedHttpGateway.namespace }}
{{- $gtName := printf "%s/%s" $.istio.sharedHttpGateway.namespace $.istio.sharedHttpGateway.name }}
{{- $_ := set . "shared_istio_gateway" $gtName}}
{{- else }}
{{- $_ := set . "shared_istio_gateway" $.istio.sharedHttpGateway.name}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.istio.checkAndGenerateHttpGateway" -}}
{{- include "cbur.istio.initIstio" . }}
{{- if  $.istio.enabled }}
{{- if $.istio.gateway.enabled }}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{ template "cbur.fullname" . }}
  labels:
  {{- include "cbur.proxy.commonLabels" (tuple .) | indent 4 }}
  {{- include "cbur.customLabels" (tuple .Values.global.labels) | indent 4 }}
  {{- if $.istio.gateway.labels }}
  labels:
{{ toYaml ( $.istio.gateway.labels ) | indent 4 }}
  {{- end }}
  annotations:
  {{- include "cbur.customAnnotations" (tuple .Values.global.annotations) | indent 4 }}
  {{- if $.istio.gateway.annotations }}
  annotations:
{{ toYaml ( $.istio.gateway.annotations ) | indent 4 }}
  {{- end }}
spec:
  selector:
  {{- if $.istio.gateway.ingressPodSelector }}
{{ toYaml ( $.istio.gateway.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{ $prtcl := $.istio.gateway.protocol | upper  }}
  - port:
      name: {{ $.istio.gateway.protocol | lower }}-{{ $.istio.gateway.port }}
      number: {{ $.istio.gateway.port }}
      protocol: {{ $prtcl }}
    hosts:
    {{- if $.istio.virtualservice.hosts }}
{{ toYaml ( $.istio.virtualservice.hosts ) | indent 4 }}
    {{- else }}
    - "*"
    {{- end }}
{{- if or ( eq $prtcl "HTTPS" ) (eq $prtcl "TLS" )}}
    {{- if $.istio.gateway.tls }}
    tls:
      {{- if $.istio.gateway.tls.custom }}
{{ toYaml ( $.istio.gateway.tls.custom ) | indent 6 }}
      {{- else }}
      mode: {{ $.istio.gateway.tls.mode }}
      {{- if  $.istio.gateway.tls.credentialName }}
      credentialName: {{ $.istio.gateway.tls.credentialName }}
      {{- end }}
      {{- end }}
    {{- end }}
    {{- if $.istio.gateway.tls }}
    {{- if $.istio.gateway.tls.redirect }}
    tls:
      httpsRedirect: true
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.helmHome.userProvided" -}}
{{- if .Values.helmHome }}
{{- $noHome := true }}
{{- if .Values.helmHome.glusterfs }}
{{- if .Values.helmHome.glusterfs.enabled }}
{{- $noHome = false }}
glusterfs:
  endpoints: {{ .Values.helmHome.glusterfs.endpoints }}
  path: {{ .Values.helmHome.glusterfs.path }}
{{- end }}
{{- end }}
{{- if and $noHome .Values.helmHome.hostPath }}
hostPath:
  path: {{ .Values.helmHome.hostPath }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.helmHome.path" -}}
{{- if (include "cbur.helmHome.userProvided" . ) }}
{{- include "cbur.helmHome.userProvided" .}}
{{- else }}
hostPath:
{{- if semverCompare ">=1.18.0-0" .Capabilities.KubeVersion.GitVersion }}
  path: "/opt/bcmt/storage/helm_home"
{{- else }}
  path: "/root/.helm"
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.storageClassName" -}}
{{- if .Values.storageClass }}
{{- if (eq "-" .Values.storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: "{{ .Values.storageClass }}"
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create the name of cbur.PSP
*/}}
{{- define "cbur.PSP" -}}
{{- include "cbur.tls" . }}
{{- if and .Values.rbac.psp.create (not .Values.rbac.accessAllResources) (or (and .Values.avamar.enabled .Values.hostNetwork.avamar) (and .Values.k8swatcher.enabled .Values.k8swatcher.clusterBrEnabled) .Values.volumeType.glusterfs (and .Values.istio.enabled (not .Values.istio.cni.enabled)) (and (eq (include "cbur.proxy.coalesceBoolean" (tuple .Values.tls.enabled .Values.global.tls.enabled false)) "true") .Values.tls.certsPath)) }}
{{- "true" }}
{{- else -}}
{{- "false" }}
{{- end }}
{{- end -}}

{{- define "cbur.alertsPSS" -}}
{{- $reasons := list }}
{{- if and .Values.avamar.enabled .Values.hostNetwork.avamar }}
{{- $reasons = append $reasons "\"hostNetwork and hostPorts are needed for current avamar configuration\"" }}
{{- end }}
{{- if and .Values.k8swatcher.enabled .Values.k8swatcher.clusterBrEnabled }}
{{- $reasons = append $reasons "\"hostPath is needed to be used and container must run as root for current k8swatcher configuration\"" }}
{{- end }}
{{- if .Values.volumeType.glusterfs }}
{{- $reasons = append $reasons "\"container must run as root when volumeType.glusterfs is set to true\"" }}
{{- end}}
{{- if and .Values.istio.enabled (not .Values.istio.cni.enabled) }}
{{- $reasons = append $reasons "\"Capabilities NET_ADMIN and NET_RAW are needed and allowPrivilegeEscalation must be set to true for non-root user for current istio configuration\"" }}
{{- end }}
{{- if and (or .Values.global.tls.enabled .Values.tls.enabled) .Values.tls.certsPath (not .Values.tls.serverSecretRef.credentialName) (not .Values.tls.clientSecretRef.credentialName) }}
{{- $reasons = append $reasons "\"hostPath is needed for current tls configuration\"" }}
{{- end }}
{{- if $reasons }}
- name: PSS_ALERT_MESSAGES
  value: '{"messages": [{{- join "," $reasons }}]}'
{{- end }}
{{- end }}

{{- define "cbur.mergeDicts" -}}
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

{{- define "cbur.customAnnotations" -}}
{{- include "cbur.mergeDicts" . }}
{{- end -}}

{{- define "cbur.customLabels" -}}
{{- include "cbur.mergeDicts" . }}
{{- end -}}

{{- define "cbur.containerSecurityContext" -}}
{{- if .Values.securityContext.enabled }}
securityContext:
  {{- if or ( semverCompare ">=1.25.0-0" .Capabilities.KubeVersion.GitVersion ) .Values.pss.enabled }}
  allowPrivilegeEscalation: false
  {{- if or (and (not (.Capabilities.APIVersions.Has "security.openshift.io/v1")) (eq ( toString ( .Values.securityContext.runAsUser )) "auto")) (eq ( toString ( .Values.securityContext.runAsUser )) "0") }}
  capabilities:
    drop:
      - ALL
    add:
      - CHOWN
      - SETUID
      - SETGID
      {{- if and .Values.k8swatcher.enabled .Values.k8swatcher.clusterBrEnabled }}
      - DAC_OVERRIDE
      - FOWNER
      {{- end }}
  {{- else }}
  capabilities:
    drop:
      - ALL
  {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.containerRunAsUser" -}}
{{- if .Values.securityContext.enabled }}
{{- if ne ( toString ( .Values.securityContext.runAsUser )) "auto" }}
runAsUser: {{ .Values.securityContext.runAsUser }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.containerRunAsGroup" -}}
{{- if .Values.securityContext.enabled }}
{{- if ne ( toString ( .Values.securityContext.runAsGroup)) "auto" }}
runAsGroup: {{ .Values.securityContext.runAsGroup }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.readOnlyRootFilesystem" -}}
{{/* Using not because readOnlyRootFilesystem default value should be true even if not provisioned */}}
{{- if .Values.securityContext.enabled }}
{{- if not .Values.securityContext.readOnlyRootFilesystem }}
readOnlyRootFilesystem: {{ .Values.securityContext.readOnlyRootFilesystem }}
{{- else }}
readOnlyRootFilesystem: true
{{- end }}
{{- end }}
{{- end -}}

{{- define "cbur.hookpod.readOnlyRootFilesystem" -}}
{{- if .Values.securityContext.enabled }}
readOnlyRootFilesystem: true
{{- end }}
{{- end -}}

{{- define "cbur.podSecurityContext" -}}
{{- if .Values.securityContext.enabled }}
securityContext:
  {{- if or (and (not (.Capabilities.APIVersions.Has "security.openshift.io/v1")) (eq ( toString ( .Values.securityContext.runAsUser )) "auto")) (eq ( toString ( .Values.securityContext.runAsUser )) "0") }}
  runAsNonRoot: false
  {{- else }}
  runAsNonRoot: true
  {{- end }}
  {{- if not ( and (.Capabilities.APIVersions.Has "config.openshift.io/v1") ( semverCompare "<1.24.0-0" .Capabilities.KubeVersion.GitVersion )) }}
  seccompProfile:
    type: {{ .Values.securityContext.seccompProfile.type }}
    {{- if eq .Values.securityContext.seccompProfile.type "Localhost" }}
    localhostProfile: {{ .Values.securityContext.seccompProfile.localhostProfile }}
    {{- end }}
  {{- end }}
{{- if ne ( toString ( .Values.securityContext.fsGroup )) "auto" }}
  fsGroup: {{ .Values.securityContext.fsGroup }}
{{- end }}
{{- if .Values.securityContext.seLinuxOptions }}
  seLinuxOptions:
{{ toYaml .Values.securityContext.seLinuxOptions | indent 4 }}
{{- end }}
{{- end }}
{{- end -}}

{{/* emptydir volume for mount to /tmp */}}
{{- define "cbur.tmpemptydirvolume" -}}
- name: tmpemptydirvolume
  emptyDir:
    medium: ""
{{- end -}}

{{- define "cbur.tmpemptydirvolumemount" -}}
- name: tmpemptydirvolume
  mountPath: /tmp
- name: tmpemptydirvolume
{{- if or (and (not (.Capabilities.APIVersions.Has "security.openshift.io/v1")) (eq ( toString ( .Values.securityContext.runAsUser )) "auto")) (eq ( toString ( .Values.securityContext.runAsUser )) "0") }}
  mountPath: /root/.kube
{{- else }}
  mountPath: /.kube
{{- end }}
  subPath: tmpkube
{{- end -}}

{{- define "cbur.redis.tmpemptydirvolumemount" -}}
- name: tmpemptydirvolume
  mountPath: /tmp
{{- end -}}

{{- define "cbur.k8swatcher.logvolumemount" -}}
{{- if and (not .Values.direct_redis.enabled) .Values.k8swatcher.enabled }}
- name: tmpemptydirvolume
  mountPath: /var/log/cbur
  subPath: cbur-log
{{- end }}
{{- end -}}

{{- define "cbur.emptydirvolumemount" -}}
- name: tmpemptydirvolume
  mountPath: /tmp
- name: tmpemptydirvolume
  mountPath: /var/cache/nginx
  subPath: tmpcache
{{- if .Values.direct_redis.enabled }}
- name: tmpemptydirvolume
  mountPath: /var/log/cbur
  subPath: cbur-log
{{- end }}
- name: tmpemptydirvolume
  mountPath: /var/log/nginx
  subPath: nginx-log
- name: tmpemptydirvolume
{{- if or (and (not (.Capabilities.APIVersions.Has "security.openshift.io/v1")) (eq ( toString ( .Values.securityContext.runAsUser )) "auto")) (eq ( toString ( .Values.securityContext.runAsUser )) "0") }}
  mountPath: /root/.kube
{{- else }}
  mountPath: /.kube
{{- end }}
  subPath: tmpkube
{{- end -}}

{{/* get the minor version of kubernetes server, change the logic if major version also changes in future */}}
{{- define "cbur.kubeVersion" -}}
{{- regexReplaceAll "[^0-9]*$" .Capabilities.KubeVersion.Minor "" | quote -}}
{{- end -}}

{{/* apiversion for VirtualService */}}
{{- define "cbur.virtualServiceVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/VirtualService" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{- define "cbur.defaultContainer" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $dot :=  index $root.Values $workload }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled }}
kubectl.kubernetes.io/default-container: {{ include "cbur.proxy.containerName" (tuple $root "cbur-syslog") }}
{{- else }}
kubectl.kubernetes.io/default-container: {{ include "cbur.proxy.containerName" (tuple $root "cbur") }}
{{- end }}
{{- end -}}

{{- define "cbur.defaultContainer4avamar" -}}
{{/*- $dot :=  .Values.avamar }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled }}
kubectl.kubernetes.io/default-container: {{ include "cbur.proxy.containerName" (tuple . "cbur-syslog") }}
{{- else */}}
kubectl.kubernetes.io/default-container: {{ include "cbur.proxy.containerName" (tuple . "cbur-avamar") }}
{{/*- end */}}
{{- end -}}

{{- define "cbur.syslogCmChecksum" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if or (and (index $root.Values $workload).unifiedLogging.syslog (index $root.Values $workload).unifiedLogging.syslog.enabled) (and $root.Values.global.unifiedLogging.syslog $root.Values.global.unifiedLogging.syslog.enabled) }}
checksum/config-syslog: {{ include (print $root.Template.BasePath "/syslog-configmap.yaml") $root | sha256sum }}
{{- end }}
{{- end }}

{{- define "cbur.certCmChecksum" -}}
{{- include "cbur.tls" . }}
{{- if and (eq (include "cbur.proxy.coalesceBoolean" (tuple .Values.tls.enabled .Values.global.tls.enabled false)) "true") (and (not .Values.tls.certsPath) (not .Values.tls.clientSecretRef.credentialName)) (eq (include "cbur.proxy.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled false)) "true") }}
checksum/config-clientcert: {{ include (print $.Template.BasePath "/certificate-client.yaml") . | sha256sum }}
{{- end }}
{{- end }}

{{- define "cbur.syslogSidecarVolume" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $dot :=  index $root.Values $workload }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled }}
- name: logmanager-managerdata
  emptyDir:
    medium: ""
    sizeLimit: {{ index $root.Values.unifiedLogging.syslog.resources.limits "ephemeral-storage" | quote }}
- name: rsyslog-output-conf
  configMap:
    name: {{ template "cbur.fullname" $root }}-syslog-confmap-{{ $workload }}
    items:
    - key: output.conf
      path: output.conf
{{- if and $dot.unifiedLogging.syslog.keyStore.secretName $dot.unifiedLogging.syslog.keyStore.key }}
- name: logmanager-keystore
  secret:
    secretName: {{ $dot.unifiedLogging.syslog.keyStore.secretName }}
    items:
    - key: {{ $dot.unifiedLogging.syslog.keyStore.key }}
      path: keystore.p12
- name: logmanager-tmp-keystore
  emptyDir:
    medium: ""
{{- end }}
{{- if and $dot.unifiedLogging.syslog.trustStore.secretName $dot.unifiedLogging.syslog.trustStore.key }}
- name: logmanager-truststore
  secret:
    secretName: {{ $dot.unifiedLogging.syslog.trustStore.secretName }}
    items:
    - key: {{ $dot.unifiedLogging.syslog.trustStore.key }}
      path: truststore.p12
- name: logmanager-tmp-truststore
  emptyDir:
    medium: ""
{{- end }}
{{- if $dot.unifiedLogging.syslog.tls.secretRef.name }}
- name: logmanager-tls
  secret:
    secretName: {{ $dot.unifiedLogging.syslog.tls.secretRef.name }}
    items:
{{- if $dot.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt }}
    - key: {{ $dot.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt }}
      path: ca.crt
{{- end }}
{{- if $dot.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt }}
    - key: {{ $dot.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt }}
      path: tls.crt
{{- end }}
{{- if $dot.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey }}
    - key: {{ $dot.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey }}
      path: tls.key
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cbur.syslogSidecarVolume4avamar" -}}
{{- $dot := .Values.avamar }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled .Values.avamar.enabled }}
- name: rsyslog-input-conf
  configMap:
    name: {{ template "cbur.fullname" . }}-syslog-confmap-avamar
    items:
    - key: input.conf
      path: input.conf
{{- end }}
{{- end }}

{{/*
Common environmental variables used in unified logging containers
*/}}
{{- define "cbur.unifiedLoggingEnv" -}}
{{- $root := index . 0 }}
{{- $log := index . 1 }}
{{- $facility := $log.unifiedLogging.syslog.facility | default "user" }}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: TZ
  value: {{ $root.Values.global.timeZoneEnv | default "UTC" | quote }}
- name: TMPDIR
  value: /tmp/logger-manager
- name: CBUR_NAMESPACE
  value: "{{ $root.Release.Namespace }}"
{{- if and $log.unifiedLogging.syslog.keyStorePassword.secretName $log.unifiedLogging.syslog.keyStorePassword.key }}
- name: KEYSTORE_PASS_SECRET
  value: {{ $log.unifiedLogging.syslog.keyStorePassword.secretName }}
- name: KEYSTORE_PASS_KEY
  value: {{ $log.unifiedLogging.syslog.keyStorePassword.key }}
{{- end }}
{{- if and $log.unifiedLogging.syslog.trustStorePassword.secretName $log.unifiedLogging.syslog.trustStorePassword.key }}
- name: TRUSTSTORE_PASS_SECRET
  value: {{ $log.unifiedLogging.syslog.trustStorePassword.secretName }}
- name: TRUSTSTORE_PASS_KEY
  value: {{ $log.unifiedLogging.syslog.trustStorePassword.key }}
{{- end }}
{{- if $log.unifiedLogging.syslog.rfc.enabled }}
- name: APPNAME
  value: {{ $log.unifiedLogging.syslog.rfc.appName | quote }}
- name: PROCID
  value: {{ $log.unifiedLogging.syslog.rfc.procId | quote }}
- name: MSGID
  value: {{ $log.unifiedLogging.syslog.rfc.msgId | quote }}
- name: VERSION
  value: {{ $log.unifiedLogging.syslog.rfc.version | quote }}
{{- end }}
- name: FACILITY
  value: {{ $facility | quote }}
- name: FACILITY_ID
  value: {{ include "cbur.syslog.facilityConversion" $facility | quote }}
{{- if not $root.Values.unifiedLogging.useLegacyFormat }}
- name: TIMEZONE
  value: {{ $root.Values.global.timeZoneEnv | default "UTC" | quote }}
- name: SYSTEM
  value: {{ $root.Values.clusterName }}
- name: SYSTEMID
  value: "{{ $root.Values.clusterId }}"
{{- include "cbur.unifiedLoggingExt" (tuple $root $log.unifiedLogging.extension) }}
{{- end -}}
{{- end -}}

{{/* syslog side car template */}}
{{- define "cbur.syslogSidecar" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $dot := index $root.Values $workload }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled -}}
- name: {{ include "cbur.proxy.containerName" (tuple $root "cbur-syslog") }}
  image: "{{ include "cbur.image.mapper" (tuple $root $root.Values.image.logmanager $root.Values.internalCBURLogManagerRegistry) }}"
  imagePullPolicy: {{ $root.Values.image.logmanager.pullPolicy | default "IfNotPresent" | quote }}
{{ include "cbur.containerSecurityContext" $root | indent 2 }}
{{ include "cbur.hookpod.readOnlyRootFilesystem" $root | indent 4 }}
{{- if ne ( toString ( $root.Values.securityContext.runAsUser )) "0" }}
{{ include "cbur.containerRunAsUser" $root | indent 4 }}
{{- end }}
{{- if ne ( toString ( $root.Values.securityContext.runAsGroup)) "0" }}
{{ include "cbur.containerRunAsGroup" $root | indent 4 }}
{{- end }}
  env:
{{ include "cbur.unifiedLoggingEnv" (tuple $root $dot) | indent 2 }}
  volumeMounts:
  - mountPath: /tmp/container-log
    name: tmpemptydirvolume
    subPath: container-log
  - mountPath: /tmp/logger-manager
    name: logmanager-managerdata
  - name: rsyslog-output-conf
    mountPath: /logmanager/conf/rsyslog.d/output.conf
    subPath: output.conf
{{- if $dot.unifiedLogging.syslog.tls.secretRef.name }}
  - mountPath: /cert
    name: logmanager-tls
    readOnly: true
{{- end }}
{{- if and $dot.unifiedLogging.syslog.keyStore.secretName $dot.unifiedLogging.syslog.keyStore.key }}
  - mountPath: /keystore
    name: logmanager-keystore
  - mountPath: /tmp/keystore
    name: logmanager-tmp-keystore
{{- end }}
{{- if and $dot.unifiedLogging.syslog.trustStore.secretName $dot.unifiedLogging.syslog.trustStore.key }}
  - mountPath: /truststore
    name: logmanager-truststore
  - mountPath: /tmp/truststore
    name: logmanager-tmp-truststore
{{- end }}
  resources:
{{ include "cbur.resources" (tuple $root $root.Values.unifiedLogging.syslog.resources "100m") | indent 4 }}
  livenessProbe:
{{ toYaml $root.Values.unifiedLogging.syslog.livenessProbe | indent  4 }}
  readinessProbe:
{{ toYaml $root.Values.unifiedLogging.syslog.readinessProbe | indent  4 }}
  {{- end }}
{{- end -}}

{{/* syslog side car template for avamar pod */}}
{{- define "cbur.syslogSidecar4avamar" -}}
{{- $root := index . 0 }}
{{- $dot := $root.Values.avamar }}
{{- if and $dot.unifiedLogging.syslog $dot.unifiedLogging.syslog.enabled -}}
- name: {{ include "cbur.proxy.containerName" (tuple $root "cbur-syslog") }}
  image: "{{ include "cbur.image.mapper" (tuple $root $root.Values.image.logmanager $root.Values.internalCBURLogManagerRegistry) }}"
  imagePullPolicy: {{ $root.Values.image.logmanager.pullPolicy | default "IfNotPresent" | quote }}
{{ include "cbur.containerSecurityContext" $root | indent 2 }}
{{ include "cbur.hookpod.readOnlyRootFilesystem" $root | indent 4 }}
{{ include "cbur.containerRunAsUser" $root | indent 4 }}
{{ include "cbur.containerRunAsGroup" $root | indent 4 }}
{{- if and ($root.Values.securityContext.enabled) (not ($root.Capabilities.APIVersions.Has "security.openshift.io/v1")) }}
{{- if eq ( toString ( $root.Values.securityContext.runAsUser )) "auto"}}
    runAsUser: 0
{{- end }}
{{- if eq ( toString ( $root.Values.securityContext.runAsGroup )) "auto" }}
    runAsGroup: 0
{{- end }}
{{- end }}
  env:
{{ include "cbur.unifiedLoggingEnv" (tuple $root $dot) | indent 2 }}
  volumeMounts:
  - mountPath: /tmp/container-log4avamar
    name: "cbur-repo"
    subPath: avamarconf
  - mountPath: /tmp/logger-manager
    name: logmanager-managerdata
  - name: rsyslog-input-conf
    mountPath: /logmanager/conf/rsyslog.d/input.conf
    subPath: input.conf
  - name: rsyslog-output-conf
    mountPath: /logmanager/conf/rsyslog.d/output.conf
    subPath: output.conf
{{- if $dot.unifiedLogging.syslog.tls.secretRef.name }}
  - mountPath: /cert
    name: logmanager-tls
    readOnly: true
{{- end }}
{{- if and $dot.unifiedLogging.syslog.keyStore.secretName $dot.unifiedLogging.syslog.keyStore.key }}
  - mountPath: /keystore
    name: logmanager-keystore
  - mountPath: /tmp/keystore
    name: logmanager-tmp-keystore
{{- end }}
{{- if and $dot.unifiedLogging.syslog.trustStore.secretName $dot.unifiedLogging.syslog.trustStore.key }}
  - mountPath: /truststore
    name: logmanager-truststore
  - mountPath: /tmp/truststore
    name: logmanager-tmp-truststore
{{- end }}
  resources:
{{ include "cbur.resources" (tuple $root $root.Values.unifiedLogging.syslog.resources "100m") | indent 4 }}
  livenessProbe:
{{ toYaml $root.Values.unifiedLogging.syslog.livenessProbe | indent  4 }}
  readinessProbe:
{{ toYaml $root.Values.unifiedLogging.syslog.readinessProbe | indent  4 }}
  {{- end }}
{{- end -}}

{{/* configMap volume for checking istio ready */}}
{{- define "cbur.istiocheckvolume" -}}
- name: istiocheck
  configMap:
    name: "{{ .Release.Name }}-check"
{{- end -}}

{{/* volume mount for checking istio ready */}}
{{- define "cbur.istiocheckvolumemount" -}}
- name: istiocheck
  mountPath: /tmp/istio_ready.py
  subPath: istio_ready.py
- name: istiocheck
  mountPath: /tmp/istio_exit.py
  subPath: istio_exit.py
{{- end -}}

{{- define "cbur.ingresspath" -}}
{{- $ingressPath := index . 0 }}
{{- $hasRouteV1 := index . 1 }}
{{- $ingressType := index . 2 }}
{{- $path := $ingressPath }}
{{- if and (ne $ingressPath "") (not (hasPrefix "/" $ingressPath)) }}
{{- $path = printf "/%s" $ingressPath }}
{{- end }}
{{- if or $hasRouteV1 (ne $ingressType "nginx")}}
path: {{ $path }}
{{- else }}
path: {{ $path }}/(.*)
{{- end }}
{{ end }}

{{/*
Create the name of cbur.gkeingress to convert useGKEIngress to ingressType
*/}}
{{- define "cbur.gkeingress" -}}
{{- if .Values.ingress -}}
{{- if .Values.ingress.useGKEIngress -}}
{{- $_ := set .Values.ingress "ingressType" "gce" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "cbur.croncliImagePullSecret" -}}
{{- if .Values.image.croncli.imagePullSecrets }}
- name: CRONCLI_IMAGE_PULL_SECRET
  value: |+
  {{- with .Values.image.croncli.imagePullSecrets }}
{{ toYaml . | indent 4 }}
  {{- end }}
{{- else if .Values.global.imagePullSecrets }}
- name: CRONCLI_IMAGE_PULL_SECRET
  value: |+
  {{- with .Values.global.imagePullSecrets }}
{{ toYaml . | indent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "cbur.cburaImagePullSecret" -}}
{{- if .Values.image.agent.imagePullSecrets }}
- name: CBURA_IMAGE_PULL_SECRET
  value: |+
  {{- with .Values.image.agent.imagePullSecrets }}
{{ toYaml . | indent 4 }}
  {{- end }}
{{- else if .Values.global.imagePullSecrets }}
- name: CBURA_IMAGE_PULL_SECRET
  value: |+
  {{- with .Values.global.imagePullSecrets }}
{{ toYaml . | indent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "cbur.copyFlags" -}}
{{- if .Values.copyFromCburaMethod }}
- name: CP_METHOD
  value: "{{ .Values.copyFromCburaMethod }}"
{{- end }}
{{- if .Values.cpRetries }}
- name: CP_RETRIES
  value: "{{ .Values.cpRetries }}"
{{- end }}
{{- end -}}

{{- define "cbur.modsecurity" -}}
{{- if not .Values.modsecurity }}
- name: MODSECURITY
  value: "true"
{{- else }}
- name: MODSECURITY
  value: "{{ .Values.modsecurity.enabled }}"
{{- end }}
{{- end -}}

{{- define "cbur.resources" -}}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $cpu := index . 2 -}}
limits:
{{- if $resources.limits.cpu }}
  cpu: {{ printf "%v" $resources.limits.cpu }}
{{- else if or $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits }}
  cpu: {{ printf "%s" $cpu }}
{{- end }}
  memory: {{ printf "%s" $resources.limits.memory }}
  ephemeral-storage: {{ index $resources.limits "ephemeral-storage" }}
requests:
  cpu: {{ printf "%v" $resources.requests.cpu }}
  memory: {{ printf "%s" $resources.requests.memory }}
  ephemeral-storage: {{ index $resources.requests "ephemeral-storage" }}
{{- end -}}

{{/* Return full image name with added tag */}}
{{- define "cbur.image.mapper" -}}
{{- $root := index . 0 }}
{{- $imageInfo := index . 1 }}
{{- $internalRegistry := index . 2 }}
{{- $tag := $imageInfo.tag | default (include "cbur.proxy.imageTag" (tuple $imageInfo._imageFlavorMapping $root.Values $imageInfo)) }}
{{- $registry := $root.Values.global.registry | default $internalRegistry }}
{{- if eq $root.Values.global.flatRegistry false -}}
{{- printf "%s/%s/%s:%s" $registry $imageInfo.path $imageInfo.name $tag -}}
{{- else -}}
{{- printf "%s/%s:%s" $registry $imageInfo.name $tag -}}
{{- end -}}
{{- end -}}

{{- define "cbur.issuer" -}}
{{- $root := index . 0 }}
{{- $certificate := index . 1 }}
{{- $defaultIssuerName := include "cbur.defaultIssuerName" $root -}}
{{- if (eq (include "cbur.checkIfIssuerRefIsValid" (tuple $root $certificate.issuerRef)) "true") }}
{{- include "cbur.generateIssuerRef" (tuple $root $certificate.issuerRef $defaultIssuerName) }}
{{- else if (eq (include "cbur.checkIfIssuerRefIsValid" (tuple $root $root.Values.certManager.issuerRef)) "true") }}
{{- include "cbur.generateIssuerRef" (tuple $root $root.Values.certManager.issuerRef $defaultIssuerName) }}
{{- else if (eq (include "cbur.checkIfIssuerRefIsValid" (tuple $root $root.Values.global.certManager.issuerRef)) "true") }}
{{- include "cbur.generateIssuerRef" (tuple $root $root.Values.global.certManager.issuerRef $defaultIssuerName) }}
{{- else }}
{{- $issuer := dict "name" "" "kind" "Issuer" "group" "cert-manager.io" }}
{{- include "cbur.generateIssuerRef" (tuple $root $issuer $defaultIssuerName) }}
{{- end }}
{{- end }}

{{- define "cbur.checkIfIssuerRefIsValid" -}}
{{- $root := index . 0 }}
{{- $issuerRef := index . 1 }}
{{- $result := "false" }}
{{- if (eq (include "cbur.proxy.isEmptyValue" $issuerRef.name) "false") }}
{{- $result = "true" }}
{{- end }}
{{- $result }}
{{- end }}

{{- define "cbur.generateIssuerRef" -}}
{{- $root := index . 0 }}
{{- $issuerRef := index . 1 }}
{{- $defaultIssuerName := index . 2 }}
{{- $defaultIssuerKind := $root.Values.global.certManager.issuerRef.kind }}
{{- $defaultIssuerGroup := $root.Values.global.certManager.issuerRef.group }}
issuerRef:
  name: {{ ($issuerRef | default (dict)).name | default $defaultIssuerName | quote }}
  kind: {{ ($issuerRef | default (dict)).kind | default $defaultIssuerKind | quote }}
  group: {{ ($issuerRef | default (dict)).group | default $defaultIssuerGroup | quote }}
{{- end }}

{{- define "cbur.logging.level" }}
- name: FILE_LOGGING_LEVEL
  value: {{ or .Values.logging.file_logging_level .Values.logging.level.file | quote }}
- name: CONSOLE_LOGGING_LEVEL
  value: {{ or .Values.logging.console_logging_level .Values.logging.level.console | quote }}
- name: KUBERNETES_LOGGING_LEVEL
  value: {{ .Values.logging.level.kubernetes | quote }}
- name: S3TRANSFER_LOGGING_LEVEL
  value: {{ .Values.logging.level.s3transfer | quote }}
- name: BOTOCORE_LOGGING_LEVEL
  value: {{ .Values.logging.level.botocore | quote }}
- name: PARAMIKO_LOGGING_LEVEL
  value: {{ .Values.logging.level.paramiko | quote }}
- name: CONNEXION_LOGGING_LEVEL
  value: {{ .Values.logging.level.connexion | quote }}
- name: OPENAPI_LOGGING_LEVEL
  value: {{ .Values.logging.level.openapi_spec_validator | quote }}
{{- end -}}

{{- define "cbur.multus.routes" -}}
{{- if and .Values.multus.enabled .Values.multus.config.routes }}
{{- if .Values.multus.config.gateway }}
{{- $route_gw := .Values.multus.config.gateway }}
{{- range $dst := .Values.multus.config.routes }}{{(printf "{ \"dst\": \"%s\", \"gw\": \"%s\" }," $dst $route_gw) }}{{- end }}
{{- else }}
{{- range $dst := .Values.multus.config.routes }}{{(printf "{ \"dst\": \"%s\" }," $dst) }}{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cbur.multus.annotation" -}}
{{- if .Values.multus.networkAttachmentName }}
k8s.v1.cni.cncf.io/networks: {{ .Values.multus.networkAttachmentName }}
{{- else }}
k8s.v1.cni.cncf.io/networks: {{ template "cbur.fullname" . }}-conf
{{- end }}
{{- end }}
