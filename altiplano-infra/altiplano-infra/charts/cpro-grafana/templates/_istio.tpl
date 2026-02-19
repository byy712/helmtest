{{- define "cpro-grafana.istio.grafanaInitIstio" -}}
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

{{- define "cpro-grafana.istio.grafanaPsp" -}}
{{- include "cpro-grafana.istio.grafanaInitIstio" . }}
{{- if and ($.istio.enabled) (not $.istio.cni.enabled) (.Values.rbac.enabled) (.Values.rbac.psp.create) (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
{{- if not .Values.deployOnComPaaS }}
apiVersion: {{ template "cpro-grafana.grafanaApiVersion.podSecurityPolicy" . }}
kind: PodSecurityPolicy
metadata:
  name: {{ template "cpro-grafana.fullname" . }}
  labels:
  {{- include "cpro-grafana.app.labels-v3" $ | nindent 4 }}
{{- include "cpro-grafana.labelsOrAnnotations" (tuple $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro-grafana.labelsOrAnnotations" (tuple $.Values.rbac.psp.annotations $.Values.global.annotations) | indent 4}}
spec:
  privileged: false
  allowPrivilegeEscalation: true
  allowedCapabilities:
    - 'NET_ADMIN'
    - 'NET_RAW'
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  readOnlyRootFilesystem: false
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro-grafana.istio.grafanaCheckAndGenerateHttpGateway" -}}
{{- include "cpro-grafana.istio.grafanaInitIstio" . }}
{{- if and (eq $.istio.sharedHttpGateway.name "") ($.istio.enabled) }}
{{- if eq $.istio.gateways.cproGrafana.enabled true }}
apiVersion: {{ template "cpro-grafana.grafanaApiVersion.gateway" . }}
kind: Gateway
metadata:
  name: {{ template "cpro-grafana.istioGatewayName" $ }}
  labels:
{{- include "cpro-grafana.app.labels-v3" $ | nindent 4 }}
{{- include "cpro-grafana.labelsOrAnnotations" (tuple $.Values.istio.gateways.cproGrafana.labels $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro-grafana.labelsOrAnnotations" (tuple $.Values.istio.gateways.cproGrafana.annotations $.Values.global.annotations) | indent 4}}
{{ $prtcl := $.istio.gateways.cproGrafana.protocol | upper  }}
spec:
  selector:
  {{- if $.istio.gateways.cproGrafana.ingressPodSelector }}
{{ toYaml ( $.istio.gateways.cproGrafana.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{- if ( eq $prtcl "HTTPS" ) }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproGrafana.host) 0 }}
    {{- range $.istio.gateways.cproGrafana.host }}
    - {{ . | quote }}
    {{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: 80
      protocol: HTTP
    tls:
      httpsRedirect: {{ $.istio.gateways.cproGrafana.tls.redirect }} # sends 301 redirect for http requests
  - hosts:
    {{- if gt (len $.istio.gateways.cproGrafana.host) 0 }}
    {{- range $.istio.gateways.cproGrafana.host }}
    - {{ . | quote }}
    {{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: https
      number: {{ $.istio.gateways.cproGrafana.port }}
      protocol: HTTPS
    tls:
      {{- if eq $.istio.gateways.cproGrafana.tls.mode "PASSTHROUGH" }}
      mode: PASSTHROUGH
      {{- else if eq $.istio.gateways.cproGrafana.tls.mode "SIMPLE" }}
      credentialName : {{ $.istio.gateways.cproGrafana.tls.credentialName}}
      mode: SIMPLE
      {{- else if eq $.istio.gateways.cproGrafana.tls.mode "MUTUAL" }}
      credentialName : {{ $.istio.gateways.cproGrafana.tls.credentialName}}
      mode: MUTUAL
      {{- else if eq $.istio.gateways.cproGrafana.tls.mode "ISTIO_MUTUAL" }}
      {{- if eq $.istio.gateways.cproGrafana.tls.credentialName "" }}
      mode: ISTIO_MUTUAL
      {{- else}}
      mode: ISTIO_MUTUAL
      credentialName : {{ $.istio.gateways.cproGrafana.tls.credentialName}}
      {{- end }}
      {{- end }}
  {{- else }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproGrafana.host) 0 }}
    {{- range $.istio.gateways.cproGrafana.host }}
    - {{ . | quote }}
    {{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: {{ $.istio.gateways.cproGrafana.port }}
      protocol: HTTP
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

