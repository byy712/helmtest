{{- define "ckaf-kafka.istio.initIstio" -}}
{{- $_ := set . "istio" .Values.global.istio }}
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
 
    # Added to support istio 1.6.8 which needs DR for kafka headless service #
    {{- if or (eq .istio.enabled true) (and (eq .istio.enabled false) (eq .istio.createDrForClient true)) }}
        {{- $_ := set . "create_dr" true }}
    {{- else }}
        {{- $_ := set . "create_dr" false }}
    {{- end -}}

    {{- if (eq .istio.enabled true) }}
        {{- $_ := set . "dr_mode" "ISTIO_MUTUAL" }}
    {{- else if (and (eq .istio.enabled false) (eq .istio.createDrForClient true)) }}
        {{- $_ := set . "dr_mode" "DISABLE" }}
    {{- end -}}
{{- end -}}

{{- define "ckaf-kafka.istio.psp" -}}
{{- include "ckaf-kafka.istio.initIstio" . }}
{{- if and (eq $.istio.cni.enabled false) (eq $.istio.enabled true) ( eq (include "ckaf-kafka.PspCreation" .) "true") }}
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-istio-psp
  labels:
{{ include "ckaf-kafka.commonLabels" . | indent 4 }}
{{- include "csf-common-lib.v1.customLabels" (tuple .Values.global.labels) | indent 4 }}
    app: {{ .Chart.Name }}
    release: {{ .Release.Name | quote }}
    heritage: {{ .Release.Service | quote }}
  annotations:
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
