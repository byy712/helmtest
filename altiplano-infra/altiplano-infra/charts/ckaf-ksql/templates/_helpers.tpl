{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{- define "ckaf-ksql.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-ks-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Namespace of the chart
*/}}
{{- define "ckaf-ksql.namespace" -}}
{{- printf "%s" .Release.Namespace }}
{{- end -}}

{{/*
Form the Kafka URL provided by user.
*/}}
{{- define "ckaf-ksql.kafkaBootstrapServers" -}}
{{- if .Values.kafka.bootstrapServers -}}
{{- .Values.kafka.bootstrapServers -}}
{{- end -}}
{{- end -}}

{{/*
Default Server Pool Id to Release Name but allow it to be overridden
*/}}
{{- define "ckaf-ksql.serviceId" -}}
{{- if .Values.overrideServiceId -}}
{{- .Values.overrideServiceId -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.schema-registry.serviceName" -}}
{{- if (index .Values "schema-registry" "url") -}}
{{- printf "%s" (index .Values "schema-registry" "url") -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.srprotocol" -}}
{{- if eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.schema)) "true" -}}
  {{- printf "https" }}
{{- else -}}
  {{- printf "http" }}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.securityProtocol" -}}
{{- if and (.Values.KafkaKsql.security.kafka.sasl.enabled) (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.kafka)) "true") -}}
 {{- printf "SASL_SSL" }}
{{- else if .Values.KafkaKsql.security.kafka.sasl.enabled -}}
 {{- printf "SASL_PLAINTEXT" }}
{{- else if eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.kafka)) "true" -}}
 {{- printf "SSL" }}
{{- else -}}
 {{- printf "PLAINTEXT" }}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.listeners" -}}
{{- $servicePort := .Values.servicePort  | toString }}
{{- if eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.rest)) "true" -}}
{{- printf "https://0.0.0.0:%s" $servicePort }}
{{- else -}}
{{- printf "http://0.0.0.0:%s" $servicePort }}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.enc.paths" -}}
{{- $paths := "" -}}
{{- if or (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.kafka)) "true") (and (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.rest)) "true") (not .Values.ksql.headless)) -}}
{{- $paths = printf "%s %s," $paths (include "ckaf-ksql.tls.basePath" (tuple (default .Values.KafkaKsql.ssl dict).kafkarestssl .Values.KafkaKsql.security.kafkaRest)) -}}
{{- end -}}
{{- if eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.schema)) "true" -}}
{{- $paths = printf "%s %s," $paths (include "ckaf-ksql.tls.basePath" (tuple (default .Values.KafkaKsql.ssl dict).schema .Values.KafkaKsql.security.schema)) -}}
{{- end -}}
{{- if and (eq .Values.KafkaKsql.security.kafka.sasl.enabled true) (eq .Values.KafkaKsql.security.kafka.sasl.mechanism "PLAIN") -}}
{{- $paths = printf "%s %s," $paths "/etc/ksql/plain" -}}
{{- end -}}
{{- if eq .Values.KafkaKsql.security.schema.basicAuth.saslInheritAuthentication true -}}
{{- $paths = printf "%s %s," $paths "/etc/ksql/basic" -}}
{{- end -}}
{{- printf "%s" $paths -}}
{{- end -}}

{{/* Generate/Add Common labels as per HBP */}}
{{- define "ckaf-ksql.commonlabels" }}
{{- if .Values.global.common_labels -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: {{.Values.name}}
app.kubernetes.io/managed-by: {{ .Values.managedBy }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
{{- end }}

{{/* Create PodDisruptionBudget parameters based on input values. */}}
{{- define "ckaf-ksql.pdb-values" -}}
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

{{/* kind ingress API versions */}}
{{- define "ckaf-ksql.ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" }}
{{- print "networking.k8s.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1/Ingress" }}
{{- print "networking.k8s.io/v1beta1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.timeZoneEnv" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{- .Values.timeZone.timeZoneEnv | quote -}}
{{- else }}
{{- .Values.global.timeZoneEnv | default "UTC" | quote -}}
{{- end }}
{{- end }}

{{/* kind API Version for deployment */}}
{{- define "ckaf-ksql.deployment.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta2" }}
{{- end }}
{{- end }}

{{/*  Taint/Toleration Feature */}}
{{- define "ckaf-ksql.tolerations" -}}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . }}
{{- end }}
{{ end }}

{{- define "ckaf-ksql.dualStack.config" -}}
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

{{/* creating psp only when kube version is less than 1.25 */}}
{{- define "ckaf-ksql.PspCreation" }}
{{- if lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.25.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable Generic ephemeral Volume */}}
{{- define "ckaf-ksql.ephemeralVolume" -}}
{{- if .Values.ephemeralVolume.enabled }}
{{- .Values.ephemeralVolume.enabled }}
{{- else }}
{{- .Values.global.ephemeralVolume.enabled | default false }}
{{- end }}
{{- end }}

{{/* render seccomp profile type */}}
{{- define "ckaf-ksql.renderSeccompProfile" }}
{{- if and (lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.24.0") (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable syslog based on values.yaml */}}
{{- define "ckaf-ksql.syslogEnabled" }}
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
{{- define "ckaf-ksql.ssl" -}}
{{- $workload := .Values.KafkaKsql.security }}
{{- if or (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.kafka)) "true") (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.schema)) "true") (eq (include "ckaf-ksql.tls.enabled" (tuple .Values.KafkaKsql.security.rest)) "true") -}}
{{ print "true" }}
{{- else }}
{{ print "false" }}
{{- end -}}
{{- end -}}

{{- define "ckaf-ksql.ssl.secretName" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $workload := index . 2 }}
{{- $secretName := coalesce $secretRef.sslSecretName (default (default $secretRef.tls dict).secretRef dict).name }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid secret name need to be provided" $secretName }}
{{- else }}
{{- coalesce $secretName (include "csf-common-lib.v3.certificateSecretName" (tuple $root $workload)) -}}
{{- end }}
{{- end }}


{{- define "ckaf-ksql.ssl.keystore" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 -}}
{{- $certificateRef := index . 2 -}}
{{- $keyStoreLocationKey := coalesce $secretRef.sslKeyStoreLocationKey (default (default (default $secretRef.tls dict).secretRef dict).keyNames dict).keystore_key }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid KeystoreLocationKey secret key to be provided" $keyStoreLocationKey }}
{{- else -}}
{{- coalesce $keyStoreLocationKey "keystore.jks" }}
{{- end }}
{{- end }}


{{- define "ckaf-ksql.ssl.trustore" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 -}}
{{- $trustStoreLocationKey := coalesce $secretRef.sslTrustStoreLocationKey (default (default (default $secretRef.tls dict).secretRef dict).keyNames dict).truststore_key }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid TrustStoreLocationKey secret key to be provided" $trustStoreLocationKey }}
{{- else -}}
{{- coalesce $trustStoreLocationKey "truststore.jks" }}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.ssl.store.secretName" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- $secretName := coalesce $secretRef.sslSecretName (default (default $secretRef.tls dict).secretRef dict).name }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid ssl secret name to be provided" $secretName }}
{{- else -}} 
{{- coalesce $secretName $certificateRef.keystores.jks.passwordSecretRef.name }}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.ssl.keystore.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- $keyStorePassKey := coalesce $secretRef.sslKeyStorePassKey (default (default (default $secretRef.tls dict).secretRef dict).keyNames dict).keystore_passwd_key }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid KeyStorePassKey secret key to be provided." $keyStorePassKey }}
{{- else -}}
{{- coalesce $keyStorePassKey $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end }}


{{- define "ckaf-ksql.ssl.key.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- $keyPassKey := coalesce $secretRef.sslKeyPassKey (default (default (default $secretRef.tls dict).secretRef dict).keyNames dict).keystore_key_passwd_key }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid KeyPassKey secret key to be provided." $keyPassKey }}
{{- else -}}
{{- coalesce $keyPassKey $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end }}

{{- define "ckaf-ksql.ssl.truststore.password" -}}
{{- $root := index . 0 -}}
{{- $secretRef := index . 1 }}
{{- $certificateRef := index . 2 }}
{{- $trustStorePassKey := coalesce $secretRef.sslTrustStorePassKey (default (default (default $secretRef.tls dict).secretRef dict).keyNames dict).truststore_passwd_key }}
{{- if (eq (include "ckaf-ksql.certManager.enabled" $root) "false") -}}
{{- required "Valid TrustStorePassKey secret key to be provided." $trustStorePassKey }}
{{- else -}}
{{- coalesce $trustStorePassKey $certificateRef.keystores.jks.passwordSecretRef.key }}
{{- end -}}
{{- end }}

{{- define "ckaf-ksql.kubectlImageRepo" }}
{{- coalesce .Values.kubectlImageRepo .Values.kubectlImage | default "" }}
{{- end }}

{{/* render kubernetes resources */}}
{{- define "ckaf-ksql.getResources" }}
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

{{/* function to determine if istio/gateways are configured with TLS*/}}
{{- define "ckaf-ksql.istioTlsEnabled" }}
{{- $root := index . 0 }}
{{- $istio := index . 1 }}
{{- $istioTlsEnabled := true }}
{{- if and (eq $istio.enabled true) (eq $istio.mtls.enabled false) (eq $istio.permissive false) }}
  {{- range $index, $gateway := $istio.gateways }}
    {{- if and (eq $gateway.enabled true) (ne ($gateway.protocol | lower) "https") }}
      {{- $istioTlsEnabled = false }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- $istioTlsEnabled = false }}
{{- end }}
{{- $istioTlsEnabled }}
{{- end }}

{{/* cert-manager must be switchable on a global and root scope
.certManager.enabled takes precedence over global.certManager.enabled */}}
{{- define "ckaf-ksql.certManager.enabled" -}}
{{- $certManagerEnabled := .Values.KafkaKsql.certManager -}}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $certManagerEnabled.enabled .Values.certManager.enabled .Values.global.certManager.enabled false)) "true" }}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/* render container image*/}}
{{- define "ckaf-ksql.image" }}
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

{{- define "ckaf-ksql.resourceName" -}}
{{- $root := index . 0 }}
{{- $suffix := index . 2 }}
{{- if or (eq $root.Values.installWithNewResourceNameConvention true) ($root.Values.global.podNamePrefix) -}}
{{ include "csf-common-lib.v3.resourceName" . -}}
{{- else if $root.Values.fullnameOverride -}}
{{- $root.Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if $root.Values.nameOverride -}}
{{- printf "ckaf-ks-%s-%s" $root.Values.nameOverride $suffix | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" $root.Release.Name $root.Chart.Name $suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/* kind certificate API versions */}}
{{- define "ckaf-ksql.certificateApiVersion" -}}
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

{{- define "ckaf-ksql.tls.enabled" -}}
{{- $workload := index . 0 }}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple (default $workload.ssl dict).enabled $workload.tls.enabled) }} 
{{- end -}}

{{- define "ckaf-ksql.tls.basePath" -}}
{{- $workload := coalesce (index . 0) (index . 1) }}
{{- coalesce $workload.sslBasePath (default $workload.tls dict).basePath }}
{{- end -}}

{{- define "ckaf-ksql.jmx.tls.enabled" }}
{{- .Values.JmxExporter.tls.enabled  }}
{{- end }}

{{- define "ckaf-ksql.jmx.certManagerSecret" -}}
{{- .Values.JmxExporter.certificate.secretName | default (print (include "csf-common-lib.v2.resourceName" (tuple . "Certificate" "jmx-cert") )) }}
{{- end }}


{{/* cert-manager must be switchable on a global and root scope
.certManager.enabled takes precedence over global.certManager.enabled */}}
{{- define "ckaf-ksql.jmx.certManager.enabled" -}}
{{- $emptyUserSecret := "" }}
{{- if ne (include "ckaf-ksql.jmx.tls.secret_name" .) "" }}
{{- $emptyUserSecret = false }}
{{- end }}
{{- include "csf-common-lib.v1.coalesceBoolean" (tuple $emptyUserSecret .Values.certManager.enabled .Values.global.certManager.enabled false) }}
{{- end -}}


{{- define "ckaf-ksql.jmx.tls.secret_name" }}
{{- .Values.JmxExporter.tls.secretRef.name | default "" }}
{{- end }}

{{- define "ckaf-ksql.jmx.storeSecret" -}}
{{- if eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true" }}
{{- include "ckaf-ksql.jmx.certManagerSecret" . }}
{{- else if (include "ckaf-ksql.jmx.tls.secret_name" .) }}
{{- include "ckaf-ksql.jmx.tls.secret_name" . }}
{{- else -}}
{{- fail "valid ssl secret name (.Values.JmxExporter.tls.secretRef.name) to be provided or certmanager to be enabled" -}}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.jmx.keystoreSecretKey" -}}
{{- if eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true" }}
{{- printf "keystore.jks" -}}
{{- else -}}
{{- required "valid keystore secret key reference name to be provided .Values.JmxExporter.tls.secretRef.keyNames.keystore_key" .Values.JmxExporter.tls.secretRef.keyNames.keystore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.jmx.truststoreSecretKey" -}}
{{- if eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true" }}
{{- printf "truststore.jks" -}}
{{- else -}}
{{- required "valid truststore secret key reference name to be provided .Values.JmxExporter.tls.secretRef.keyNames.truststore_key" .Values.JmxExporter.tls.secretRef.keyNames.truststore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-ksql.jmx.storePasswordSecret" -}}
{{- if and (eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true")  }}
{{- required "valid cert-manager store encryption secret name to be provided" .Values.JmxExporter.certificate.store_password_secret_name -}}
{{- else if (include "ckaf-ksql.jmx.tls.secret_name" .) }}
{{- include "ckaf-ksql.jmx.tls.secret_name" . }}
{{- else -}}
{{- fail "valid ssl secret name (.Values.jmx.tls.secretRef.name) to be provided or cert-manager store encryption secret name to be provided" -}}
{{- end }}
{{- end }}


{{- define "ckaf-ksql.jmx.keystorePasswordSecretKey" -}}
{{- if(eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true") }}
{{- required "valid cert-manager store encryption secret key name to be provided" .Values.JmxExporter.certificate.store_password_key -}}
{{- else -}}
{{- required "valid keystore password secret key name to be provided .Values.JmxExporter.tls.secretRef.keyNames.keystore_passwd_key" .Values.JmxExporter.tls.secretRef.keyNames.keystore_passwd_key -}}
{{- end }}
{{- end }}


{{- define "ckaf-ksql.jmx.truststorePasswordSecretKey" -}}
{{- if and (eq (include "ckaf-ksql.jmx.certManager.enabled" .) "true") }}
{{-  required "valid cert-manager store encryption secret key name to be provided" .Values.JmxExporter.certificate.store_password_key  -}}
{{- else -}}
{{- required "valid truststore password secret key  name to be provided .Values.JmxExporter.tls.secretRef.keyNames.truststore_passwd_key" .Values.JmxExporter.tls.secretRef.keyNames.truststore_passwd_key -}}
{{- end }}
{{- end }}


{{/* keyencryption details for cert-manager */}}
{{- define "ckaf-ksql.jmx.privateKeyConfigs" -}}
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

