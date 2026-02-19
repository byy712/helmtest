{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{- define "ckaf-mirror-maker.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-mm-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "ckaf-mm-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Service Account for Mirror-Maker */}}
{{- define "ckaf-mirror-maker.serviceAccountName" }}
      {{- if .Values.global.rbac.enabled }}
      {{- if .Values.serviceAccountName }}
        {{ .Values.serviceAccountName }}
      {{- else -}}
        {{ template "ckaf-mirror-maker.name" . }}-sa-mmadmin
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "ckaf-mirror-maker.encPaths" -}}
  {{- $paths := "" -}}
  {{- range $clusters := .Values.mirrorMakerConfig.clusters }}
    {{- $alias := .alias }}
      {{- if eq (include "ckaf-mirror-maker.cluster.tls.enabled" (tuple $clusters)) "true" }}
        {{- $paths = printf "%s %s%s," $paths  "/etc/mirror-maker/secrets/ssl/" $alias -}}
      {{- end }}
    {{- with .saslPlain }}
      {{- if eq .enabled true }}
        {{- $paths = printf "%s %s%s," $paths  "/etc/mirror-maker/secrets/plain/" $alias -}}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- printf "%s" $paths -}}
{{- end -}}

{{/* Generate/Add Common labels as per HBP */}}
{{- define "ckaf-mirror-maker.commonLabels" }}
{{- if .Values.global.common_labels -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: {{.Values.name}}
app.kubernetes.io/managed-by: {{ .Values.managedBy }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.timeZoneEnv" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{- .Values.timeZone.timeZoneEnv | quote -}}
{{- else }}
{{- .Values.global.timeZoneEnv | default "UTC" | quote -}}
{{- end }}
{{- end }}

{{/* kind API Version for deployment */}}
{{- define "ckaf-mirror-maker.deploymentApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta2" }}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.pdbValues" -}}
{{- if and ( and ( not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" )) }}
  {{- required "Both the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- else if and (not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" ) }}
minAvailable: {{ .Values.pdb.minAvailable }}
{{- else if and (not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" ) }}
maxUnavailable: {{ .Values.pdb.maxUnavailable  }}
{{- else }}
  {{- required "None of the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- end }}
{{- end -}}

{{/*  Taint/Toleration Feature */}}
{{- define "ckaf-mirror-maker.tolerations" -}}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . }}
{{- end }}
{{ end }}
{{/* creating psp only when kube version is less than 1.25 */}}
{{- define "ckaf-mirror-maker.PspCreation" }}
{{- if lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.25.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* render seccomp profile type */}}
{{- define "ckaf-mirror-maker.renderSeccompProfile" }}
{{- if and (lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.24.0") (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable syslog based on values.yaml */}}
{{- define "ckaf-mirror-maker.syslogEnabled" }}
{{- $syslog := dict }}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.unifiedLogging.syslog.enabled .Values.global.unifiedLogging.syslog.enabled false)) "true" }}
{{- $_ := set . "syslogEnabled" "true" }}
  {{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.global.unifiedLogging.syslog.enabled false)) "false" }}
    {{- $_ := set . "syslog"  .Values.unifiedLogging.syslog }}
  {{- else }}
    {{- $_ := set . "syslog"  (merge  .Values.unifiedLogging.syslog .Values.global.unifiedLogging.syslog) }}
  {{- end }}
{{- else }}
{{- $_ := set . "syslogEnabled" "false" }}
{{- end }}
{{- end }}

{{/* check if ssl is enabled or not */}}
{{- define "ckaf-mirror-maker.tls" -}}
{{- $_ := set . "tmp" "false" }}
{{- range $clusters := .Values.mirrorMakerConfig.clusters }}
{{- if eq $.tmp "false" -}}
{{- if eq (include "ckaf-mirror-maker.cluster.tls.enabled" (tuple $clusters)) "true" }}
{{- $_ := set $ "tmp" "true" }}
{{- print "true" }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "ckaf-mirror-maker.tls.secretName" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $workload := index . 2 }}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid secret name need to be provided" $secretRef }}
{{- else }}
{{- coalesce $secretRef (include "csf-common-lib.v3.certificateSecretName" (tuple $root $workload)) -}}
{{- end }}
{{- end }}


{{- define "ckaf-mirror-maker.tls.keystore" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 -}}
{{- $certificateRef := index . 2 -}}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid KeystoreLocationKey secret key to be provided" $secretRef }}
{{- else -}}
{{- coalesce $secretRef "keystore.jks" }}
{{- end }}
{{- end }}


{{- define "ckaf-mirror-maker.tls.trustore" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 -}}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid TrustStoreLocationKey secret key to be provided" $secretRef }}
{{- else -}}
{{- coalesce $secretRef "truststore.jks" }}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.tls.store.secretName" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid ssl secret name to be provided" $secretRef }}
{{- else -}}
{{- coalesce $secretRef $certificateRef.keystores.jks.passwordSecretRef.name }}
{{- end -}}
{{- end -}}

{{- define "ckaf-mirror-maker.tls.keystore.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid KeyStorePassKey secret key to be provided." $secretRef }}
{{- else -}}
{{- coalesce $secretRef $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end -}}


{{- define "ckaf-mirror-maker.tls.key.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid KeyPassKey secret key to be provided." $secretRef }}
{{- else -}}
{{- coalesce $secretRef $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end -}}

{{- define "ckaf-mirror-maker.tls.truststore.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- if (eq (include "ckaf-mirror-maker.certManager.enabled" $root) "false") -}}
{{- required "Valid TrustStorePassKey secret key to be provided." $secretRef }}
{{- else -}}
{{- coalesce $secretRef $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end -}}

{{- define "ckaf-mirror-maker.kubectlImageRepo" }}
{{- coalesce .Values.kubectlImage .Values.kubectlImageRepo | default "" }}
{{- end }}

{{/* render kubernetes resources */}}
{{- define "ckaf-mirror-maker.getResources" }}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $defaultCpuLimit := index . 2 }}
requests:
  memory: {{ $resources.requests.memory }}
  cpu: {{ $resources.requests.cpu }}
  ephemeral-storage: {{ index $resources.requests "ephemeral-storage" }}
limits:
  memory: {{ $resources.limits.memory }}
  {{- if ne ( toString ( $resources.limits.cpu )) ""}}
  cpu: {{ $resources.limits.cpu }}
  {{- else if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits false)) "true" }}
  cpu: {{ $defaultCpuLimit }}
  {{- end }}
  ephemeral-storage: {{ index $resources.limits "ephemeral-storage" }}
{{- end -}}

{{/* cert-manager must be switchable on a global and root scope
.certManager.enabled takes precedence over global.certManager.enabled */}}
{{- define "ckaf-mirror-maker.certManager.enabled" -}}
{{- $certManagerEnabled := .Values.mirrorMakerConfig.certManager -}}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple $certManagerEnabled.enabled .Values.certManager.enabled .Values.global.certManager.enabled false) }}
{{- end -}}

{{/* render container image*/}}
{{- define "ckaf-mirror-maker.image" }}
{{- $values := index . 0 }}
{{- $registryInt := index . 1 }}
{{- $imageName := index . 2 }}
{{- $imageRepo := index . 3 }}
{{- $imageTag := index . 4 }}
{{- $workload := index . 5 }}
{{- if and (eq $values.global.flatRegistry true) $imageName }}
{{- $imageRepo = $imageName }}
{{- end }}
{{- coalesce $registryInt $values.global.registry }}/{{ $imageRepo | default (include "csf-common-lib.v2.imageRepository" (tuple $workload._imageFlavorMapping $values $workload)) }}:{{ $imageTag | default (include "csf-common-lib.v2.imageTag" (tuple $workload._imageFlavorMapping $values $workload)) }}
{{- end }}

{{- define "ckaf-mirror-maker.cluster.tls.enabled" }}
{{- $cluster := index . 0 }}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple (default $cluster.ssl dict).enabled (default $cluster.tls dict).enabled) }}
{{- end }}

{{- define "ckaf-mirror-maker.resourceName" -}}
{{- $root := index . 0 }}
{{- $suffix := index . 2 }}
{{- if or (eq $root.Values.installWithNewResourceNameConvention true) ($root.Values.global.podNamePrefix) -}}
{{ include "csf-common-lib.v3.resourceName" . -}}
{{- else if $root.Values.fullnameOverride -}}
{{- $root.Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if $root.Values.nameOverride -}}
{{- printf "ckaf-mm-%s-%s" $root.Values.nameOverride $suffix | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "ckaf-mm-%s-%s" $root.Release.Name $suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.tls.enabled" }}
{{- .Values.JmxExporter.tls.enabled  }}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.certManagerSecret" -}}
{{- .Values.JmxExporter.certificate.secretName | default (print (include "csf-common-lib.v2.resourceName" (tuple . "Certificate" "jmx-cert") )) }}
{{- end }}


{{/* cert-manager must be switchable on a global and root scope
.certManager.enabled takes precedence over global.certManager.enabled */}}
{{- define "ckaf-mirror-maker.jmx.certManager.enabled" -}}
{{- $emptyUserSecret := "" }}
{{- if ne (include "ckaf-mirror-maker.jmx.tls.secret_name" .) "" }}
{{- $emptyUserSecret = false }}
{{- end }}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple $emptyUserSecret .Values.certManager.enabled .Values.global.certManager.enabled false) }}
{{- end -}}


{{- define "ckaf-mirror-maker.jmx.tls.secret_name" }}
{{- .Values.JmxExporter.tls.secretRef.name | default "" }}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.storeSecret" -}}
{{- if eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true" }}
{{- include "ckaf-mirror-maker.jmx.certManagerSecret" . }}
{{- else if (include "ckaf-mirror-maker.jmx.tls.secret_name" .) }}
{{- include "ckaf-mirror-maker.jmx.tls.secret_name" . }}
{{- else -}}
{{- fail "valid ssl secret name (.Values.JmxExporter.tls.secretRef.name) to be provided or certmanager to be enabled" -}}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.keystoreSecretKey" -}}
{{- if eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true" }}
{{- printf "keystore.jks" -}}
{{- else -}}
{{- required "valid keystore secret key reference name to be provided .Values.JmxExporter.tls.secretRef.keyNames.keystore_key" .Values.JmxExporter.tls.secretRef.keyNames.keystore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.truststoreSecretKey" -}}
{{- if eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true" }}
{{- printf "truststore.jks" -}}
{{- else -}}
{{- required "valid truststore secret key reference name to be provided .Values.JmxExporter.tls.secretRef.keyNames.truststore_key" .Values.JmxExporter.tls.secretRef.keyNames.truststore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.jmx.storePasswordSecret" -}}
{{- if and (eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true")  }}
{{- required "valid cert-manager store encryption secret name to be provided" .Values.JmxExporter.certificate.store_password_secret_name -}}
{{- else if (include "ckaf-mirror-maker.jmx.tls.secret_name" .) }}
{{- include "ckaf-mirror-maker.jmx.tls.secret_name" . }}
{{- else -}}
{{- fail "valid ssl secret name (.Values.jmx.tls.secretRef.name) to be provided or cert-manager store encryption secret name to be provided" -}}
{{- end }}
{{- end }}


{{- define "ckaf-mirror-maker.jmx.keystorePasswordSecretKey" -}}
{{- if(eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true") }}
{{- required "valid cert-manager store encryption secret key name to be provided" .Values.JmxExporter.certificate.store_password_key -}}
{{- else -}}
{{- required "valid keystore password secret key name to be provided .Values.JmxExporter.tls.secretRef.keyNames.keystore_passwd_key" .Values.JmxExporter.tls.secretRef.keyNames.keystore_passwd_key -}}
{{- end }}
{{- end }}


{{- define "ckaf-mirror-maker.jmx.truststorePasswordSecretKey" -}}
{{- if and (eq (include "ckaf-mirror-maker.jmx.certManager.enabled" .) "true") }}
{{-  required "valid cert-manager store encryption secret key name to be provided" .Values.JmxExporter.certificate.store_password_key  -}}
{{- else -}}
{{- required "valid truststore password secret key  name to be provided .Values.JmxExporter.tls.secretRef.keyNames.truststore_passwd_key" .Values.JmxExporter.tls.secretRef.keyNames.truststore_passwd_key -}}
{{- end }}
{{- end }}


{{/* keyencryption details for cert-manager */}}
{{- define "ckaf-mirror-maker.jmx.privateKeyConfigs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.JmxExporter.certificate.privateKey.algorithm }}
  encoding: {{ .Values.JmxExporter.certificate.privateKey.encoding }}
  size: {{ .Values.JmxExporter.certificate.privateKey.size }}
  rotationPolicy: {{ .Values.JmxExporter.certificate.privateKey.rotationPolicy }}
{{- else }}
keyAlgorithm: {{ .Values.JmxExporter.certificate.privateKey.algorithm |lower}}
keyEncoding: {{ .Values.JmxExporter.certificate.privateKey.encoding |lower}}
keySize: {{ .Values.JmxExporter.certificate.privateKey.size }}
rotationPolicy: {{ .Values.JmxExporter.certificate.privateKey.rotationPolicy }}
{{- end }}
{{- end }}

{{/* kind certificate API versions */}}
{{- define "ckaf-mirror-maker.certificateApiVersion" -}}
{{- $root := index . 0 }}
{{- if $root.Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if $root.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" }}
{{- print "cert-manager.io/v1beta1" }}
{{- else if $root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else if $root.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2" }}
{{- print "cert-manager.io/v1alpha2" }}
{{- end }}
{{- end }}

{{- define "ckaf-mirror-maker.dualStackConfig" -}}
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

