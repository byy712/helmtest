{{/*
Common template for cermanager for the cpro components
This will gerenrate the certificates and create a secret with the certificates
inputs required
1 Values.yaml for common config details
2 component which is equivalent to .Values.component
3 certificateName nameof cert to be created
4 secretName name of secret to be created
5 service name to be added by default
*/}}
{{- define "cpro.certmanager.template" -}}
apiVersion: {{ template "cpro.apiVersion.certManagerApiversion" . }}
kind: Certificate
metadata:
  name: {{ include .certificateName . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "cpro.app.labels.v3" ( dict "root" . "context" .component ) | nindent 4 }}
    {{- include "cpro.labelsOrAnnotations" (tuple .Values.global.labels) | indent 4}}
  annotations:
    {{- include "cpro.labelsOrAnnotations" (tuple .Values.global.annotations) | indent 4}}
spec:
  secretName: {{ include .secretName . }}
  duration: {{ .Values.certManagerConfig.duration }}
  renewBefore: {{ .Values.certManagerConfig.renewBefore }}
{{- include "cpro.prometheus.certManagerConfig.keySize" . | nindent 2}}
{{- if .Values.certManagerConfig.servername }}
  commonName: {{ .Values.certManagerConfig.servername }}
{{- end }}
  dnsNames:
#{{- if (hasKey .component "ingress") }}
#{{- if and .component.ingress.enabled .component.ingress.tls }}
#{{- range $tlshosts := .component.ingress.tls }}
#{{- if not (hasKey $tlshosts "secretName") }}
#{{- range $host := $tlshosts.hosts }}
#  - {{ $host }}
#{{- end }}
#{{- end }}
#{{- end }}
#{{- end }}
#{{- end }}
{{- if or (.Values.certManagerConfig.dnsNames)  ((((.component).tls_auth_config).tls).dnsNames) }}
{{- if .Values.certManagerConfig.dnsNames }}
{{ toYaml .Values.certManagerConfig.dnsNames | indent 2 }}
{{- end }}
{{- if (((.component).tls_auth_config).tls).dnsNames }}
{{ toYaml .component.tls_auth_config.tls.dnsNames | indent 2 }}
{{- end }}
{{- end }}
  - {{ .serviceName }}.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
{{- if hasKey . "serviceNameExt" }}
  - {{ .serviceNameExt }}.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
{{- end }}
{{- if or .Values.certManagerConfig.ipAddresses ((((.component).tls_auth_config).tls).ipAddresses) }}
  ipAddresses:
{{- if .Values.certManagerConfig.ipAddresses }}
{{ toYaml .Values.certManagerConfig.ipAddresses | indent 2 }}
{{- end }}
{{- if (((.component).tls_auth_config).tls).ipAddresses }}
{{ toYaml .component.tls_auth_config.tls.ipAddresses | indent 2 }}
{{- end }}
{{- end }}
  usages:
    - server auth
    - client auth
  issuerRef:
    name: {{ .Values.certManagerConfig.issuerRef.name }}
    kind: {{ .Values.certManagerConfig.issuerRef.kind }}
    group: {{ .Values.certManagerConfig.issuerRef.group }}
{{- end }}

