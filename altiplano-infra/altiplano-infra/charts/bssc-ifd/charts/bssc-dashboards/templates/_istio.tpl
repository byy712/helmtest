{{- define "bssc-dashboards.istio.properties" -}}
{{- $_ := set . "istioVersion" (.Values.istio.version | default .Values.global.istio.version) }}
{{- $_ := set . "istioCni" .Values.istio.cni.enabled | default .Values.global.istio.cni.enabled }}
{{- end }}

{{/*
Return the appropriate apiVersion for serviceEntry, virtual svc and DestinationRule
*/}}
{{- define "bssc-dashboards.apiVersionNetworkIstioV1Alpha3orV1Beta1" -}}
{{- include "bssc-dashboards.istio.properties" . }}
{{- if eq $.istioVersion "1.4" -}}
{{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
{{- print "networking.istio.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "bssc-dashboards.istio.initIstio" -}}
{{- $_ := set . "istio" .Values.istio }}
{{- if $.istio.sharedHttpGateway }}
{{- if $.istio.sharedHttpGateway.namespace }}
{{- $gtName := printf "%s/%s" $.istio.sharedHttpGateway.namespace $.istio.sharedHttpGateway.name }}
{{- $_ := set . "shared_istio_gateway" $gtName}}
{{- else }}
{{- $_ := set . "shared_istio_gateway" $.istio.sharedHttpGateway.name}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "bssc-dashboards.istio.checkAndGenerateHttpGateway" -}}
  {{- include "bssc-dashboards.istio.initIstio" . }}
  {{- if  $.istio.enabled }}
    {{ $release := .Release }}
    {{ $root := . }}
    {{- range $key,$val := $.istio.gateways }}
    {{- if eq $val.enabled true }}
apiVersion: {{ template "bssc-dashboards.apiVersionNetworkIstioV1Alpha3orV1Beta1" $root }}
kind: Gateway
metadata:
  name: "{{ $key }}"
  namespace: {{ $release.Namespace }}
  labels:
{{- include "bssc-dashboards.csf-toolkit-helm.labels" (tuple $root) | nindent 4 }}
{{- include "bssc-dashboards.commonLabels" (tuple $root  "dashboards" ) | indent 4 }}
  {{- if $val.labels }}
{{ toYaml ( $val.labels ) | indent 4 }}
  {{- end }}
  annotations:
{{- include "bssc-dashboards.csf-toolkit-helm.annotations" (tuple $root) | nindent 4 }}
  {{- if $val.annotations }}
{{ toYaml ( $val.annotations ) | indent 4 }}
  {{- end }}
spec:
  selector:
  {{- if $val.ingressPodSelector }}
{{ toYaml ( $val.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{ $prtcl := $val.protocol | upper  }}
  - port:
      name: {{ $val.protocol | lower }}-{{ $val.port }}
      number: {{ $val.port }}
      protocol: {{ $prtcl }}
    hosts:
    {{- if $val.hosts }}
{{ toYaml ( $val.hosts ) | indent 4 }}
    {{- else }}
    - "*"
    {{- end }}
    {{- if or ( eq $prtcl "HTTPS" ) (eq $prtcl "TLS" )}}
    tls:
      {{- if $val.tls.custom }}
{{ toYaml ( $val.tls.custom ) | indent 6 }}
      {{- else }}
      mode: {{ $val.tls.mode }}
        {{- if  $val.tls.credentialName }}
      credentialName: {{ $val.tls.credentialName }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if $val.tls.redirect }}
      {{- if eq $val.tls.redirect true }}
    tls:
      httpsRedirect: true
      {{- end }}
    {{- end }}
---
    {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "bssc-dashboards.istio.psp" -}}
{{- include "bssc-dashboards.istio.initIstio" . }}
{{- include "bssc-dashboards.istio.properties" . }}
{{- if and ($.istio.enabled ) (not $.istioCni) (.Values.rbac.enabled) (.Values.rbac.psp.create) (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: policy/v1beta1 
kind: PodSecurityPolicy
metadata:
  labels:
{{- include "bssc-dashboards.commonLabels" (tuple .  "dashboards" ) | indent 4 }}
{{- include "bssc-dashboards.csf-toolkit-helm.labels" (tuple .) | nindent 4 }}
  annotations:
{{- include "bssc-dashboards.csf-toolkit-helm.annotations" (tuple . .Values.rbac.psp.annotations) | nindent 4 }}
  name: {{ template "bssc-dashboards.fullname" . }}-istio-psp
spec:
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
    - 'downwardAPI'
    - 'configMap'
    - 'emptyDir'
    - 'secret'
    - 'hostPath'
    - 'projected'
{{- end -}}
{{- end -}}


{{- define "bssc-dashboards.istio.scc" -}}
{{- include "bssc-dashboards.istio.initIstio" . }}
{{- include "bssc-dashboards.istio.properties" . }}
{{- if and ($.istio.enabled) (not $.istioCni) (.Values.rbac.enabled) (.Values.rbac.scc.create) (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: {{ template "bssc-dashboards.fullname" . }}-istio-scc
  labels:
{{- include "bssc-dashboards.commonLabels" (tuple .  "dashboards" ) | indent 4 }}
{{- include "bssc-dashboards.csf-toolkit-helm.labels" (tuple .) | nindent 4 }}
  annotations:
{{- include "bssc-dashboards.csf-toolkit-helm.annotations" (tuple . .Values.rbac.scc.annotations) | nindent 4 }}
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
readOnlyRootFilesystem: true
defaultAddCapabilities: []
requiredDropCapabilities:
- 'KILL'
- 'MKNOD'
- 'SETUID'
- 'SETGID'
allowedCapabilities:
- 'NET_ADMIN'
- 'NET_RAW'
runAsUser:
  type: MustRunAsNonRoot
fsGroup:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
{{- if semverCompare ">= 1.24.0-0" .Capabilities.KubeVersion.GitVersion }}
seccompProfiles:
- runtime/default
{{- end }}
groups: []
users: []
volumes:
- 'secret'
- 'emptyDir'
- 'configMap'
- 'projected'
- 'downwardAPI'
- 'persistentVolumeClaim'
{{- end -}}
{{- end -}}


{{/*
Below template function returns a list of Istio gateways names whose tls is disabled.
*/}}
{{- define "bssc-dashboards.istio.createlistOfGateway.nonTls" -}}
{{ $_ := set . "istio" .Values.istio }}
{{- if $.istio.enabled }}
{{ $nonTlsIstioGatewayList := list }}
{{- range $key,$val := $.istio.gateways }}
{{- if eq $val.enabled true }}
{{ $protocol := $val.protocol | upper }}
{{- if not (or ( eq $protocol "HTTPS" ) (eq $protocol "TLS" )) }}
{{ $nonTlsIstioGatewayList = append $nonTlsIstioGatewayList $key }}
{{- end }}
{{- end }}
{{- end }}
{{ $nonTlsIstioGatewayList = $nonTlsIstioGatewayList | join "," }}
{{- if ne $nonTlsIstioGatewayList "" }}
- name: NON_TLS_ISTIO_GATEWAYS
  value: "{{ $nonTlsIstioGatewayList }}"
{{- end }}
{{- end }}
{{- end -}}
