{{- define "ckaf-ksql.istio.checkAndGenerateHttpGateway" -}}
{{- include "ckaf-ksql.istio.initIstio" . }}
{{- if $.istio.enabled }}
{{- $root := . }}
{{- range $.istio.gateways }}
{{- if eq .enabled true }}
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: {{ .name }}
  labels:
{{ include "ckaf-ksql.commonlabels" $root | indent 4 }}
{{- include "csf-common-lib.v1.customLabels" (tuple .labels $root.Values.global.labels) | indent 4 }}
  annotations:
{{- include "csf-common-lib.v1.customAnnotations" (tuple .annotations $root.Values.global.annotations) | indent 4 }}
spec:
  selector:
  {{- if .ingressPodSelector }}
{{ toYaml ( .ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{ $prtcl := .protocol | upper  }}
  - port:
      name: {{ .protocol | lower }}-{{ .port }}
      number: {{ .port }}
      protocol: {{ $prtcl }}
    hosts:
    {{- if .hosts }}
{{ toYaml ( .hosts ) | indent 4 }}
    {{- else }}
    - "*"
    {{- end }}
{{- if ( eq $prtcl "HTTPS" ) }}
{{- if or ( not .tls ) }}
{{- include  "ckaf-ksql.istio.notls.stop" . }}
{{- end }}
    tls:
      {{- if .tls.custom }}
{{ toYaml ( .tls.custom ) | indent 6 }}
      {{- else }}
      mode: {{ .tls.mode }}
      {{- if  .tls.credentialName }}
      credentialName: {{ .tls.credentialName }}
      {{- end }}

    {{- end }}
    {{- end }}
    {{- if .tls.redirect }}
    {{- if eq .tls.redirect true }}
    tls:
      httpsRedirect: true
    {{- end }}
    {{- end }}
---
    {{- end }}
    {{- end }}
    {{- end }}
  {{- end -}}

{{- define "ckaf-ksql.istio.notls.stop" -}}
{{- fail "TLS section cannot be empty for protocol HTTPS." -}}
{{- end -}}

{{- define "ckaf-ksql.istio.initIstio" -}}
{{- $_ := set . "istio" .Values.global.istio }}
{{- if $.istio.sharedHttpGateway }}
{{- if $.istio.sharedHttpGateway.namespace }}
{{- $gtName := printf "%s/%s" $.istio.sharedHttpGateway.namespace $.istio.sharedHttpGateway.name }}
{{- $_ := set . "shared_istio_gateway" $gtName}}
{{- else }}
{{- $_ := set . "shared_istio_gateway" $.istio.sharedHttpGateway.name}}
{{- end }}
{{- end }}

{{- if or (and (eq .istio.enabled true) (eq .istio.permissive true)) (and (eq .istio.enabled true) (eq .istio.mtls.enabled false) (eq .istio.permissive false)) }}
{{- $_ := set . "create_peerauth" true }}
{{- else }}
{{- $_ := set . "create_peerauth" false }}
{{- end -}}

{{- if and (eq .istio.enabled true) (eq .istio.permissive true) }}
{{- $_ := set . "mtls_mode" "PERMISSIVE" }}
{{- else if and (eq .istio.enabled true) (eq .istio.mtls.enabled false) (eq .istio.permissive false) }}
{{- $_ := set . "mtls_mode" "STRICT" }}
{{- end -}}
{{- end -}}


{{- define "ckaf-ksql.istio.psp" -}}
{{- include "ckaf-ksql.istio.initIstio" . }}
{{- if and (eq $.istio.cni.enabled false) (eq $.istio.enabled true) ( eq (include "ckaf-ksql.PspCreation" .) "true")   }}
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-istio-psp
  labels:
{{ include "ckaf-ksql.commonlabels" . | indent 4 }}
{{- include "csf-common-lib.v1.customLabels" (tuple .Values.global.labels) | indent 4 }}
    app: {{ .Chart.Name }}
    release: {{ .Release.Name | quote }}
    heritage: {{ .Release.Service | quote }}
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
{{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.global.annotations) | indent 4 }}
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
  - '*'
{{- end -}}
{{- end -}}

