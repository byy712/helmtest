{{- define "bssc-fluentd.istio.properties" -}}
{{- $_ := set . "istioVersion" (.Values.istio.version | default .Values.global.istio.version) }}
{{- $_ := set . "istioCni" .Values.istio.cni.enabled | default .Values.global.istio.cni.enabled }}
{{- end }}

{{- define "bssc-fluentd.istio.initIstio" -}}
{{- $_ := set . "istio" .Values.istio }}
{{- end -}}

{{/*
Return the appropriate apiVersion for serviceEntry, virtual svc and DestinationRule
*/}}
{{- define "bssc-fluentd.apiVersionNetworkIstioV1Alpha3orV1Beta1" -}}
{{- include "bssc-fluentd.istio.properties" . }}
{{- if eq $.istioVersion "1.4" -}}
{{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
{{- print "networking.istio.io/v1beta1" -}}
{{- end -}}
{{- end -}}

