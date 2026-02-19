{{- define "ckaf-mirror-maker.istioInitIstio" -}}
{{- $_ := set . "istio" .Values.global.istio }}
{{- end -}}

{{- define "ckaf-mirror-maker.istioPsp" -}}
{{- include "ckaf-mirror-maker.istioInitIstio" . }}
{{- if and (eq $.istio.cni.enabled false) (eq $.istio.enabled true)  (eq (include "ckaf-mirror-maker.PspCreation" .) "true") }}
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: {{ template "ckaf-mirror-maker.name" . }}-psp
  labels:
{{ include "ckaf-mirror-maker.commonLabels" . | indent 4 }}
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
