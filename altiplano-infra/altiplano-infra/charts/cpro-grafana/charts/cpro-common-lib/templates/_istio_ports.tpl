
{{/*
Return the istio health check port
*/}}
{{- define "cpro-common-lib.istioHealthCheckPort" -}}
{{- if not .Values.istio.sidecar.healthCheckPort -}}
{{- if semverCompare ">=1.6" .Values.istio.version }}
{{- printf "%d" (15021) -}}
{{- else -}}
{{- printf "%d" (15020) -}}
{{- end -}}
{{- else -}}
{{- printf "%d" (.Values.istio.sidecar.healthCheckPort | int) -}}
{{- end -}}
{{- end -}}

{{/*
Return the istio stop port
*/}}
{{- define "cpro-common-lib.istioStopPort" -}}
{{- if .Values.istio.sidecar.stopPort -}}
{{- printf "%d" (.Values.istio.sidecar.stopPort | int) -}}
{{- else -}}
{{- printf "%d" (15000) -}}
{{- end -}}
{{- end -}}