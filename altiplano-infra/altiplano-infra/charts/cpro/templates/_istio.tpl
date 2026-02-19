

{{- define "cpro.istio.cproInitIstio" -}}
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

{{- define "cpro.istio.cproAlertmanagerPsp" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and ($.istio.enabled) (not $.istio.cni.enabled) ($.Values.rbac.enabled) ($.Values.rbac.psp.create) ($.Values.alertmanager.enabled)  (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: {{ template "cpro.apiVersion.podSecurityPolicy" $ }}
kind: PodSecurityPolicy
metadata:
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.alertmanager ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.global.labels) | indent 4}}
  name: {{ template "cpro.prometheus.alertmanager.psp" $ }}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.rbac.psp.annotations $.Values.global.annotations) | indent 4}}
spec:
  allowPrivilegeEscalation: true
  seLinux:
    rule: RunAsAny
  runAsUser:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
  - '*'
{{- end }}
{{- end -}}

{{- define "cpro.istio.checkAndGenerateCproAlertmanagerHttpGateway" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and (eq $.istio.sharedHttpGateway.name "") ($.istio.enabled) ($.Values.alertmanager.enabled) }}
{{- if ($.istio.gateways.cproAlertmanager.enabled) }}
apiVersion: {{ template "cpro.apiVersion.gatewayApiversion" $ }}
kind: Gateway
metadata:
  name: {{ template "cpro.alertmanager.istioGatewayName"  $ }}
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.alertmanager ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproAlertmanager.labels $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproAlertmanager.annotations $.Values.global.annotations) | indent 4}}
{{ $prtcl := $.istio.gateways.cproAlertmanager.protocol | upper }}
spec:
  selector:
  {{- if $.istio.gateways.cproAlertmanager.ingressPodSelector }}
  {{ toYaml ( $.istio.gateways.cproAlertmanager.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{- if ( eq $prtcl "HTTPS" ) }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproAlertmanager.host) 0 }}
{{- range $.istio.gateways.cproAlertmanager.host }}
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
      httpsRedirect: {{ $.istio.gateways.cproAlertmanager.tls.redirect }} # sends 301 redirect for http requests
  - hosts:
    {{- if gt (len $.istio.gateways.cproAlertmanager.host) 0 }}
{{- range $.istio.gateways.cproAlertmanager.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: https
      number: {{ $.istio.gateways.cproAlertmanager.port }}
      protocol: HTTPS
    tls:
      {{- if eq $.istio.gateways.cproAlertmanager.tls.mode "PASSTHROUGH" }}
      mode: PASSTHROUGH
      {{- else if eq $.istio.gateways.cproAlertmanager.tls.mode "SIMPLE" }}
      credentialName : {{ $.istio.gateways.cproAlertmanager.tls.credentialName}}
      mode: SIMPLE
      {{- else if eq $.istio.gateways.cproAlertmanager.tls.mode "MUTUAL" }}
      credentialName : {{ $.istio.gateways.cproAlertmanager.tls.credentialName}}
      mode: MUTUAL
      {{- else if eq $.istio.gateways.cproAlertmanager.tls.mode "ISTIO_MUTUAL" }}
      {{- if eq $.istio.gateways.cproAlertmanager.tls.credentialName "" }}
      mode: ISTIO_MUTUAL
      {{- else}}
      mode: ISTIO_MUTUAL
      credentialName : {{ $.istio.gateways.cproAlertmanager.tls.credentialName }}
      {{- end }}
      {{- end }}
  {{- else }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproAlertmanager.host) 0 }}
{{- range $.istio.gateways.cproAlertmanager.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: {{ $.istio.gateways.cproAlertmanager.port }}
      protocol: HTTP
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro.istio.checkAndGenerateCproServerHttpGateway" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and (eq $.istio.sharedHttpGateway.name "") ($.istio.enabled) }}
{{- if ($.istio.gateways.cproServer.enabled) }}
apiVersion: {{ template "cpro.apiVersion.gatewayApiversion" $ }}
kind: Gateway
metadata:
  name: {{ template "cpro.server.istioGatewayName"  $ }}
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.server ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproServer.labels $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproServer.annotations $.Values.global.annotations) | indent 4}}
{{ $prtcl := $.istio.gateways.cproServer.protocol | upper }}
spec:
  selector:
  {{- if $.istio.gateways.cproServer.ingressPodSelector }}
  {{ toYaml ( $.istio.gateways.cproServer.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{- if ( eq $prtcl "HTTPS" ) }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproServer.host) 0 }}
{{- range $.istio.gateways.cproServer.host }}
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
      httpsRedirect: {{ $.istio.gateways.cproServer.tls.redirect }} # sends 301 redirect for http requests
  - hosts:
    {{- if gt (len $.istio.gateways.cproServer.host) 0 }}
{{- range $.istio.gateways.cproServer.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: https
      number: {{ $.istio.gateways.cproServer.port }}
      protocol: HTTPS
    tls:
      {{- if eq $.istio.gateways.cproServer.tls.mode "PASSTHROUGH" }}
      mode: PASSTHROUGH
      {{- else if eq $.istio.gateways.cproServer.tls.mode "SIMPLE" }}
      credentialName : {{ $.istio.gateways.cproServer.tls.credentialName}}
      mode: SIMPLE
      {{- else if eq $.istio.gateways.cproServer.tls.mode "MUTUAL" }}
      credentialName : {{ $.istio.gateways.cproServer.tls.credentialName}}
      mode: MUTUAL
      {{- else if eq $.istio.gateways.cproServer.tls.mode "ISTIO_MUTUAL" }}
      {{- if eq $.istio.gateways.cproServer.tls.credentialName "" }}
      mode: ISTIO_MUTUAL
      {{- else}}
      mode: ISTIO_MUTUAL
      credentialName : {{ $.istio.gateways.cproServer.tls.credentialName }}
      {{- end }}
      {{- end }}
  {{- else }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproServer.host) 0 }}
{{- range $.istio.gateways.cproServer.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: {{ $.istio.gateways.cproServer.port }}
      protocol: HTTP
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro.istio.cproPushgatewayPsp" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and ($.istio.enabled) (not $.istio.cni.enabled) ($.Values.rbac.enabled) ($.Values.rbac.psp.create) ($.Values.pushgateway.enabled)  (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: {{ template "cpro.apiVersion.podSecurityPolicy" $ }}
kind: PodSecurityPolicy
metadata:
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.pushgateway ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.global.labels) | indent 4}}
  name: {{ template "cpro.prometheus.pushgateway.psp" $ }}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.rbac.psp.annotations $.Values.global.annotations) | indent 4}}
spec:
  allowPrivilegeEscalation: true
  seLinux:
    rule: RunAsAny
  runAsUser:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
  - '*'
{{- end }}
{{- end -}}

{{- define "cpro.istio.checkAndGenerateCproPushgatewayHttpGateway" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and (eq $.istio.sharedHttpGateway.name "") ($.istio.enabled) ($.Values.pushgateway.enabled) }}
{{- if ($.istio.gateways.cproPushgateway.enabled) }}
apiVersion: {{ template "cpro.apiVersion.gatewayApiversion" $ }}
kind: Gateway
metadata:
  name: {{ template "cpro.pushgateway.istioGatewayName"  $ }}
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.pushgateway ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproPushgateway.labels $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproPushgateway.annotations $.Values.global.annotations) | indent 4}}
{{ $prtcl := $.istio.gateways.cproPushgateway.protocol | upper }}
spec:
  selector:
  {{- if $.istio.gateways.cproPushgateway.ingressPodSelector }}
  {{ toYaml ( $.istio.gateways.cproPushgateway.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{- if ( eq $prtcl "HTTPS" ) }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproPushgateway.host) 0 }}
{{- range $.istio.gateways.cproPushgateway.host }}
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
      httpsRedirect: {{ $.istio.gateways.cproPushgateway.tls.redirect }} # sends 301 redirect for http requests
  - hosts:
    {{- if gt (len $.istio.gateways.cproPushgateway.host) 0 }}
{{- range $.istio.gateways.cproPushgateway.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: https
      number: {{ $.istio.gateways.cproPushgateway.port }}
      protocol: HTTPS
    tls:
      {{- if eq $.istio.gateways.cproPushgateway.tls.mode "PASSTHROUGH" }}
      mode: PASSTHROUGH
      {{- else if eq $.istio.gateways.cproPushgateway.tls.mode "SIMPLE" }}
      credentialName : {{ $.istio.gateways.cproPushgateway.tls.credentialName}}
      mode: SIMPLE
      {{- else if eq $.istio.gateways.cproPushgateway.tls.mode "MUTUAL" }}
      credentialName : {{ $.istio.gateways.cproPushgateway.tls.credentialName}}
      mode: MUTUAL
      {{- else if eq $.istio.gateways.cproPushgateway.tls.mode "ISTIO_MUTUAL" }}
      {{- if eq $.istio.gateways.cproPushgateway.tls.credentialName "" }}
      mode: ISTIO_MUTUAL
      {{- else}}
      mode: ISTIO_MUTUAL
      credentialName : {{ $.istio.gateways.cproPushgateway.tls.credentialName }}
      {{- end }}
      {{- end }}
  {{- else }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproPushgateway.host) 0 }}
{{- range $.istio.gateways.cproPushgateway.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: {{ $.istio.gateways.cproPushgateway.port }}
      protocol: HTTP
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro.istio.cproRestserverPsp" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and ($.istio.enabled) (not $.istio.cni.enabled) ($.Values.rbac.enabled) ($.Values.rbac.psp.create) ($.Values.restserver.enabled)  (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: {{ template "cpro.apiVersion.podSecurityPolicy" $ }}
kind: PodSecurityPolicy
metadata:
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.restserver ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.global.labels) | indent 4}}
  name: {{ template "cpro.prometheus.restserver.psp" $ }}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple  $.Values.rbac.psp.annotations $.Values.global.annotations) | indent 4}}
spec:
  allowPrivilegeEscalation: true
  seLinux:
    rule: RunAsAny
  runAsUser:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
  - '*'
{{- end }}
{{- end -}}

{{- define "cpro.istio.checkAndGenerateCproRestserverHttpGateway" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and (eq $.istio.sharedHttpGateway.name "") ($.istio.enabled) ($.Values.restserver.enabled) }}
{{- if ($.istio.gateways.cproRestserver.enabled) }}
apiVersion: {{ template "cpro.apiVersion.gatewayApiversion" $ }}
kind: Gateway
metadata:
  name: {{ template "cpro.restserver.istioGatewayName"  $ }}
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.restserver ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproRestserver.labels $.Values.global.labels) | indent 4}}
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.istio.gateways.cproRestserver.annotations $.Values.global.annotations) | indent 4}}
{{ $prtcl := $.istio.gateways.cproRestserver.protocol | upper }}
spec:
  selector:
  {{- if $.istio.gateways.cproRestserver.ingressPodSelector }}
  {{ toYaml ( $.istio.gateways.cproRestserver.ingressPodSelector ) | indent 4 }}
  {{- else }}
    istio: ingressgateway
  {{- end }}
  servers:
  {{- if ( eq $prtcl "HTTPS" ) }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproRestserver.host) 0 }}
{{- range $.istio.gateways.cproRestserver.host }}
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
      httpsRedirect: {{ $.istio.gateways.cproRestserver.tls.redirect }} # sends 301 redirect for http requests
  - hosts:
    {{- if gt (len $.istio.gateways.cproRestserver.host) 0 }}
{{- range $.istio.gateways.cproRestserver.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: https
      number: {{ $.istio.gateways.cproRestserver.port }}
      protocol: HTTPS
    tls:
      {{- if eq $.istio.gateways.cproRestserver.tls.mode "PASSTHROUGH" }}
      mode: PASSTHROUGH
      {{- else if eq $.istio.gateways.cproRestserver.tls.mode "SIMPLE" }}
      credentialName : {{ $.istio.gateways.cproRestserver.tls.credentialName}}
      mode: SIMPLE
      {{- else if eq $.istio.gateways.cproRestserver.tls.mode "MUTUAL" }}
      credentialName : {{ $.istio.gateways.cproRestserver.tls.credentialName}}
      mode: MUTUAL
      {{- else if eq $.istio.gateways.cproRestserver.tls.mode "ISTIO_MUTUAL" }}
      {{- if eq $.istio.gateways.cproRestserver.tls.credentialName "" }}
      mode: ISTIO_MUTUAL
      {{- else}}
      mode: ISTIO_MUTUAL
      credentialName : {{ $.istio.gateways.cproRestserver.tls.credentialName }}
      {{- end }}
      {{- end }}
  {{- else }}
  - hosts:
    {{- if gt (len $.istio.gateways.cproRestserver.host) 0 }}
{{- range $.istio.gateways.cproRestserver.host }}
    - {{ . | quote }}
{{- end }}
    {{- else }}
    - "*"
    {{- end }}
    port:
      name: http
      number: {{ $.istio.gateways.cproRestserver.port }}
      protocol: HTTP
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cpro.istio.cproWebhook4fluentdPsp" -}}
{{- include "cpro.istio.cproInitIstio" . }}
{{- if and ($.istio.enabled) (not $.istio.cni.enabled) ($.Values.rbac.enabled) ($.Values.rbac.psp.create) ($.Values.webhook4fluentd.enabled)  (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: {{ template "cpro.apiVersion.podSecurityPolicy" $ }}
kind: PodSecurityPolicy
metadata:
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .Values.webhook4fluentd ) | nindent 4 }}
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.global.labels) | indent 4}}
  name: {{ template "cpro.prometheus.webhook4fluentd.fullname" $ }}-psp
  annotations:
{{- include "cpro.labelsOrAnnotations" (tuple $.Values.rbac.psp.annotations $.Values.global.annotations) | indent 4}}
spec:
  allowPrivilegeEscalation: true
  seLinux:
    rule: RunAsAny
  runAsUser:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    ranges:
    - max: 65534
      min: 1
    rule: MustRunAs
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
  - '*'
{{- end }}
{{- end -}}
