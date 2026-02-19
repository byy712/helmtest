{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hdfs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 54 chars because some Kubernetes name fields are limited to 63 (by the DNS naming spec),
as we append -datanode or -namenode to the names
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hdfs.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 54 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 54 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 54 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Standard Labels from Helm documentation https://helm.sh/docs/chart_best_practices/#labels-and-annotations
*/}}

{{- define "hdfs.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
Derive the image name from three different parameters.
*/}}
{{- define "image.fullname" -}}

    {{- if not (empty .Values.image.registry) -}}
        {{- if not (eq "-" .Values.image.registry) -}} {{ .Values.image.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}

    {{- if .Values.image.repository -}}
        {{- if not (empty .Values.image.registry) -}}
            {{- if not (eq "-" .Values.image.registry) -}}/{{- end -}}
        {{- else if .Values.global.registry -}}/
        {{- end -}}
    {{ .Values.image.repository }}
    {{- end -}}

    {{- if .Values.image.tag -}}
        {{- if .Values.image.repository -}}:
        {{- else -}}
            {{- if not (empty .Values.image.registry) -}}
                {{- if not (eq "-" .Values.image.registry) -}}:{{- end -}}
            {{- else if .Values.global.registry -}}:
            {{- end -}}
        {{- end -}}
    {{ .Values.image.tag }}
    {{- end -}}

{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 0.
*/}}
{{- define "namenode-svc-0" -}}
{{- $pod := include "namenode-pod-0" . -}}
{{- $service := include "namenode-svc" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s.%s" $pod $service $domain -}}
{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 1.
*/}}
{{- define "namenode-svc-1" -}}
{{- $pod := include "namenode-pod-1" . -}}
{{- $service := include "namenode-svc" . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s.%s" $pod $service $domain -}}
{{- end -}}

{{- define "svc-domain" -}}
{{- printf "%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}

{{- define "namenode-svc" -}}
{{ include "hdfs.fullname" . }}-namenode
{{- end -}}

{{/*
Construct the name of the namenode pod 0.
*/}}
{{- define "namenode-pod-0" -}}
{{ include "hdfs.fullname" . }}-namenode-0
{{- end -}}

{{/*
Construct the name of the namenode pod 1.
*/}}
{{- define "namenode-pod-1" -}}
{{ include "hdfs.fullname" . }}-namenode-1
{{- end -}}


{{- define "journalnode-quorum" -}}
{{- $service := include "jnode-svc" . -}}
{{- $domain := include "svc-domain" . -}}
{{- $replicas := .Values.journalNode.journalnodeQuorumSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "%s-%d.%s.%s:8485;" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "%s-%d.%s.%s:8485" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "jnode-svc" -}}
{{ include "hdfs.fullname" . }}-journalnode
{{- end -}}

{{- define "zk-quorum" -}}
{{- printf "altiplano-zookeeper-headless.%s" .Release.Namespace -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodDisruptionBudget
*/}}
{{- define "hdfs.apiVersionPolicyV1Beta1orPolicyV1" -}}
{{- if semverCompare "<1.21.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}