{{/*
Outputs the image: and imagePullPolicy: for a particular workload/container image

Arg: (tuple <scope> <regname> <spec>)
<scope>: ./$
<regname>: name portion of internal Registry, e.g., Redisio -> .Values.internalRedisioRegistry
<spec>: index into Values for relevant image: dict, e.g., .Values.server
*/}}
{{- define "crdb-redisio.image" -}}
{{- $top := first . -}}
{{- $regname := index . 1 -}}
{{- $spec := index . 2 | deepCopy -}} {{/* copy due to merge with server.image */}}
{{- $_intReg := printf "internal%sRegistry" $regname -}}
{{- $_intRegDef := printf "_internal%sRegistry" $regname -}}
{{- $Values := $top.Values -}}

{{/* use server.image for per-subcomponent image defaults */}}
{{- $_ := merge $spec.image $Values.server.image -}}

{{- $flatRegistry := $Values.global.flatRegistry -}}
{{- $registry := coalesce $spec.image.registry (index $Values $_intReg) $Values.global.registry (index $Values $_intRegDef) -}}
{{- $name := $flatRegistry | ternary (splitList "/" $spec.image.name | last) $spec.image.name -}}
{{- $tag := $spec.image.tag -}}
{{- $flav_suffix := include "csf-common-lib.v2.imageTag" (tuple $Values._supportedFlavors $Values $spec) -}}
image: "{{ $registry }}/{{ $name }}:{{ $tag }}{{ $flav_suffix }}"
imagePullPolicy: {{ $spec.image.pullPolicy | quote }}
{{- end -}}

{{/* Convenience functions */}}

{{/* Server */}}
{{- define "crdb-redisio.server.image" -}}
{{- include "crdb-redisio.image" (tuple . "Redisio" .Values.server) -}}
{{- end -}}

{{- define "crdb-redisio.server.image.sum" -}}
{{- include "crdb-redisio.server.image" . | sha1sum -}}
{{- end -}}

{{/* Rolemon */}}
{{- define "crdb-redisio.rolemon.image" -}}
{{- include "crdb-redisio.image" (tuple . "Rolemon" .Values.rolemon) -}}
{{- end -}}

{{/* Sentinel */}}
{{- define "crdb-redisio.sentinel.image" -}}
{{- include "crdb-redisio.image" (tuple . "Redisio" .Values.sentinel) -}}
{{- end -}}

{{/* Admin */}}
{{- define "crdb-redisio.admin.image" -}}
{{- include "crdb-redisio.image" (tuple . "Admin" .Values.admin) -}}
{{- end -}}

{{/* CBURA Sidecar */}}
{{- define "crdb-redisio.cbur.image" -}}
{{- include "crdb-redisio.image" (tuple . "CburAgent" .Values.cbur) -}}
{{- end -}}

{{/* Metrics/Exporters */}}
{{- define "crdb-redisio.server.metrics.image" }}
{{- include "crdb-redisio.image" (tuple . "Exporter" .Values.server.metrics) -}}
{{- end -}}
{{- define "crdb-redisio.sentinel.metrics.image" }}
{{- include "crdb-redisio.image" (tuple . "Exporter" .Values.sentinel.metrics) -}}
{{- end -}}
