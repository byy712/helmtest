{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "crmq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "crmq.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "crmq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create managemenbt service name used by certmanager
*/}}
{{- define "crmq.managementService" -}}
{{- if .Values.managementnameOverride -}}
{{- .Values.managementnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "mgt" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create prometheus service name used by certmanager
*/}}
{{- define "crmq.prometheusService" -}}
{{- if .Values.prometheusnameOverride -}}
{{- .Values.prometheusnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pro" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create rbac ApiVersion
*/}}
{{- define "crmq.rbacApiVersion" -}}
{{- if (.Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1") -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.PSPVersion" -}}
{{- if (.Capabilities.APIVersions.Has "policy/v1beta1") -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/* kind certificate API versions */}}
{{- define "crmq.certificateVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1beta1" }}
{{- print "cert-manager.io/v1beta1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha2" }}
{{- print "cert-manager.io/v1alpha2" }}
{{- end }}
{{- end }}

{{/* keyencryption details for internodetls cert-manager */}}
{{- define "crmq.internodetls.privateKey.configs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.rabbitmq.internodetls.certmanager.algorithm }}
  encoding: {{ .Values.rabbitmq.internodetls.certmanager.encoding }}
  size: {{ .Values.rabbitmq.internodetls.certmanager.keySize }}
{{- else }}
keyAlgorithm: {{ .Values.rabbitmq.internodetls.certmanager.algorithm |lower }}
keyEncoding: {{ .Values.rabbitmq.internodetls.certmanager.encoding |lower }}
keySize: {{ .Values.rabbitmq.internodetls.certmanager.keySize }}
{{- end }}
{{- end }}

{{/* keyencryption details for tls cert-manager */}}
{{- define "crmq.tls.privateKey.configs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.rabbitmq.tls.certmanager.algorithm }}
  encoding: {{ .Values.rabbitmq.tls.certmanager.encoding }}
  size: {{ .Values.rabbitmq.tls.certmanager.keySize }}
{{- else }}
keyAlgorithm: {{ .Values.rabbitmq.tls.certmanager.algorithm |lower }}
keyEncoding: {{ .Values.rabbitmq.tls.certmanager.encoding |lower }}
keySize: {{ .Values.rabbitmq.tls.certmanager.keySize }}
{{- end }}
{{- end }}

{{/* keyencryption details for management tls cert-manager */}}
{{- define "crmq.management.tls.privateKey.configs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.rabbitmq.management.tls.certmanager.algorithm }}
  encoding: {{ .Values.rabbitmq.management.tls.certmanager.encoding }}
  size: {{ .Values.rabbitmq.management.tls.certmanager.keySize }}
{{- else }}
keyAlgorithm: {{ .Values.rabbitmq.management.tls.certmanager.algorithm |lower }}
keyEncoding: {{ .Values.rabbitmq.management.tls.certmanager.encoding |lower }}
keySize: {{ .Values.rabbitmq.management.tls.certmanager.keySize }}
{{- end }}
{{- end }}

{{/* keyencryption details for prometheus tls cert-manager */}}
{{- define "crmq.prometheus.tls.privateKey.configs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.rabbitmq.prometheus.tls.certmanager.algorithm }}
  encoding: {{ .Values.rabbitmq.prometheus.tls.certmanager.encoding }}
  size: {{ .Values.rabbitmq.prometheus.tls.certmanager.keySize }}
{{- else }}
keyAlgorithm: {{ .Values.rabbitmq.prometheus.tls.certmanager.algorithm |lower }}
keyEncoding: {{ .Values.rabbitmq.prometheus.tls.certmanager.encoding |lower }}
keySize: {{ .Values.rabbitmq.prometheus.tls.certmanager.keySize }}
{{- end }}
{{- end }}

{{/* keyencryption details for ingress cert-manager */}}
{{- define "crmq.ingress.privateKey.configs" -}}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.ingress.certmanager.algorithm  }}
  encoding: {{ .Values.ingress.certmanager.encoding  }}
  size: {{ .Values.ingress.certmanager.keySize }}
{{- else }}
keyAlgorithm: {{ .Values.ingress.certmanager.algorithm |lower }}
keyEncoding: {{ .Values.ingress.certmanager.encoding |lower }}
keySize: {{ .Values.ingress.certmanager.keySize }}
{{- end }}
{{- end }}

{{/*
Create suffix on pod/container
*/}}

{{- define "crmq.postDeleteJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postDeleteJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postDeleteJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postDeleteJobName -}}
{{- .Values.postDeleteJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pod-delete-jobs" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postDeleteContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.postDeleteContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.postDeleteContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postDeleteContainerName -}}
{{- .Values.postDeleteContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-delete-job"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postInstallJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postInstallJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postInstallJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postInstallJobName -}}
{{- .Values.postInstallJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "dynamic-config-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postInstallContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.postInstallContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.postInstallContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postInstallContainerName -}}
{{- .Values.postInstallContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "dynamic-config-pod"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postUpgradeJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postUpgradeJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postUpgradeJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postUpgradeJobName -}}
{{- .Values.postUpgradeJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-upgrade-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "preUpgradeJobName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pre-upgrade-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{- define "crmq.postUpgradeContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.postUpgradeContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.postUpgradeContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postUpgradeContainerName -}}
{{- .Values.postUpgradeContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-upgrade-pod"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "preUpgradeContainerName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pre-upgrade-pod"| trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{- define "crmq.postScaleinJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postScaleinJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postScaleinJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postScaleinJobName -}}
{{- .Values.postScaleinJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "postscalein" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postScaleinContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.postScaleinContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.postScaleinContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postScaleinContainerName -}}
{{- .Values.postScaleinContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "postscalein"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.podDisruptionBudgetJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.podDisruptionBudgetJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.podDisruptionBudgetJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.podDisruptionBudgetJobName -}}
{{- .Values.podDisruptionBudgetJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pdb" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.preHealJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.preHealJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.preHealJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.preHealJobName -}}
{{- .Values.preHealJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pre-heal-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.preHealContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.preHealContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.preHealContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.preHealContainerName -}}
{{- .Values.preHealContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pre-heal" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postHealJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postHealJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postHealJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postHealJobName -}}
{{- .Values.postHealJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-heal-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.postHealContainerName" -}}
{{- if and .Values.global.containerNamePrefix .Values.postHealContainerName -}}
{{- printf "%s%s" .Values.global.containerNamePrefix .Values.postHealContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postHealContainerName -}}
{{- .Values.postHealContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-heal" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{ define "crmq.commonLabels" }}
{{- if .Values.commonLabels }}
app.kubernetes.io/name: "{{ .Chart.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{.Values.managedBy}}"
app.kubernetes.io/component: {{.Values.name}}
app.kubernetes.io/version: "{{.Chart.AppVersion}}"
{{- if .Values.partOf }}
app.kubernetes.io/part-of: {{ .Values.partOf | quote }}
{{- end }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
{{- end -}}


{{- define "crmq.management.tls.enabled" -}}
{{- if  and ( .Values.rabbitmq.management.tls.enabled )  (or ( .Values.rabbitmq.management.tls.certmanager.used ) ( .Values.rabbitmq.management.tls.secret.used ) ( and .Values.rabbitmq.management.tls.uploadPath.cacert .Values.rabbitmq.management.tls.uploadPath.cert .Values.rabbitmq.management.tls.uploadPath.key)) -}}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.management.tls.uploadPath.enabled" -}}
{{- if  and ( .Values.rabbitmq.management.tls.enabled ) ( and .Values.rabbitmq.management.tls.uploadPath.cacert .Values.rabbitmq.management.tls.uploadPath.cert .Values.rabbitmq.management.tls.uploadPath.key ) -}}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.istio.initIstio" -}}
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

{{- define "crmq.server.tls.enabled" -}}
{{- if and (.Values.rabbitmq.tls.enabled) (or (.Values.rabbitmq.tls.certmanager.used) (and .Values.rabbitmq.tls.uploadPath.cacert .Values.rabbitmq.tls.uploadPath.cert .Values.rabbitmq.tls.uploadPath.key) (.Values.rabbitmq.tls.secret.used)) }}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.prometheus.tls.enabled" -}}
{{- if and (.Values.rabbitmq.prometheus.enabled) (.Values.rabbitmq.prometheus.tls.enabled) (or (.Values.rabbitmq.prometheus.tls.certmanager.used) (and .Values.rabbitmq.prometheus.tls.uploadPath.cacert .Values.rabbitmq.prometheus.tls.uploadPath.cert .Values.rabbitmq.prometheus.tls.uploadPath.key) (.Values.rabbitmq.prometheus.tls.secret.used)) }}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{- define "crmq.server.tls.uploadPath.enabled" -}}
{{- if  and ( .Values.rabbitmq.tls.enabled ) (and .Values.rabbitmq.tls.uploadPath.cacert .Values.rabbitmq.tls.uploadPath.cert .Values.rabbitmq.tls.uploadPath.key) -}}
{{- printf "%s" "true" -}}
{{- else -}}
{{- printf "%s" "false" -}}
{{- end -}}
{{- end -}}

{{/*
* Define topology spread constraints for crmq
*/}}
{{- define "crmq.spread-constraints" -}}
{{- $g := first . -}}
{{- $Values := index $g "Values" -}}
{{- range $index, $item := $Values.topologySpreadConstraints -}}
- maxSkew: {{ $item.maxSkew }}
  topologyKey: {{ $item.topologyKey }}
  whenUnsatisfiable: {{ default "DoNotSchedule" $item.whenUnsatisfiable }} 
{{- if $item.labelSelector }}
  labelSelector:
    {{- $item.labelSelector | toYaml | nindent 4 }}
{{- else }}
  labelSelector:
    matchLabels:
      app: {{ template "crmq.name" $g }}
      release: {{ $g.Release.Name | quote }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Create PodDisruptionBudget parameters based on input values.
*/}}
{{- define "crmq.pdb-values" -}}
{{- if and ( .Values.rabbitmq.mqtt.enabled ) ( eq ( int .Values.replicas ) 2 ) }}
  {{- required "CRMQ with MQTT enabled should have 1 or >2 replicas" "" }}
{{- end }}
{{- if and ( and ( not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" )) }}
{{- required "Both the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- else if and (not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" ) }}
minAvailable: {{ .Values.pdb.minAvailable }}
{{- else if and (not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" ) }}
maxUnavailable: {{ .Values.pdb.maxUnavailable }}
{{- else }}
{{- required "None of the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- end }}
{{- end -}}

{{- define "crmq.timeZoneEnv" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{- .Values.timeZone.timeZoneEnv | quote -}}
{{- else }}
{{- .Values.global.timeZoneEnv | default "UTC" | quote -}}
{{- end }}
{{- end }}

{{/* Cert-Manager DNS entries for internode TLS */}}
{{- define "crmq.internode.tls.dns" }}
{{- $fullname := ( include "crmq.fullname" .) }}
{{- $namespace := .Release.Namespace -}}
{{- $clusterDomain := .Values.clusterDomain -}}
{{- range $key, $value := until  ( .Values.replicas | int ) }}
{{ printf "- %s-%d" $fullname  $key | indent 4 }}
{{- end }}
    - "*.{{ $fullname }}.{{ $namespace }}.svc.{{ $clusterDomain }}"
{{- end }}

{{/* InternodeTLS secret name */}}
{{- define "crmq.internode.tls.secret_name" }}
{{- if .Values.rabbitmq.internodetls.certmanager.used }}
{{- printf "%s-crmq-internode-cert-secret" ( include "crmq.fullname" . ) }}
{{- else }}
{{- printf "%s" .Values.rabbitmq.internodetls.secret.name }}
{{- end }}
{{- end }}

{{/* InternodeTLS secret CA key name */}}
{{- define "crmq.internode.tls.secretCAKey" }}
{{- if .Values.rabbitmq.internodetls.certmanager.used }}
{{- print "ca.crt" }}
{{- else }}
{{- printf "%s" .Values.rabbitmq.internodetls.secret.ca_cert_key }}
{{- end }}
{{- end }}

{{/* InternodeTLS secret cert key name  */}}
{{- define "crmq.internode.tls.secretCertKey" }}
{{- if .Values.rabbitmq.internodetls.certmanager.used }}
{{- print "tls.crt" }}
{{- else }}
{{- printf "%s" .Values.rabbitmq.internodetls.secret.tls_cert_key }}
{{- end }}
{{- end }}

{{/* InternodeTLS secret private-key key name */}}
{{- define "crmq.internode.tls.secretKeyKey" }}
{{- if .Values.rabbitmq.internodetls.certmanager.used }}
{{- print "tls.key" }}
{{- else }}
{{- printf "%s" .Values.rabbitmq.internodetls.secret.tls_key_key }}
{{- end }}
{{- end }}

{{/* check if tls configuration has version 1.3 */}}
{{- define "crmq.internode.tls.has.tls3" }}
{{- if contains "tlsv1.3" .Values.rabbitmq.internodetls.versions }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end }}

{{/* Select API Version for CBUR */}}
{{- define "crmq.cbur.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{/* dualstack configuration */}}
{{- define "crmq.dualStack.config" -}}
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

{{/* is single stack ipv6 enabled */}}
{{- define "crmq.singleStack.ipv6" }}
{{- if and .Values.ipFamilyPolicy .Values.ipFamilies }}
{{- if and (eq .Values.ipFamilyPolicy "SingleStack") (eq (first .Values.ipFamilies) "IPv6") }}
{{- print "true" }}
{{- end }}
{{- else if and ( .Values.global.ipFamilyPolicy ) ( .Values.global.ipFamilies ) }}
{{- if and (eq .Values.global.ipFamilyPolicy "SingleStack") (eq (first .Values.global.ipFamilies) "IPv6") }}
{{- print "true" }}
{{- end }}
{{- end }}
{{- end }}

{{/* creating psp only when kube version is less than 1.25 */}}
{{- define "crmq.createPsp" }}
{{- if lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.25.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* render seccomp profile type */}}
{{- define "crmq.renderSeccompProfile" }}
{{- if and (lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.24.0") (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end -}}
{{- end -}}
