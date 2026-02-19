{{/* vim: set filetype=mustache: */}}
{{/* Shared template for all BrHook Jobs */}}

{{- define "cmdb-cbur.brhook" -}}
{{- if and .Values.cbur.enabled (.Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1") }}

{{- $job_type := .Template.Name | base | trimPrefix "mariadb-cbur-" | trimSuffix "-brhook.yaml" -}}
{{- $prepost := ternary "pre" "post" (hasPrefix "pre" $job_type) }}
{{- $hook := $job_type | trimPrefix $prepost -}}
{{- $hValues := index .Values.cbur (printf "%s%sHook" $prepost (title $hook)) -}}
{{- $job_delay := int (default .Values.hooks.jobDelay $hValues.jobDelay) }}
{{- $job_name := printf "%s-%s" (include "cmdb.pod-prefix" .) (default (printf "%s-brhook" $job_type) $hValues.name) | trunc 63 | trimSuffix "-" -}}
{{- $container_name := printf "%s%s" (include "cmdb.container-prefix" .) (default (printf "%s-admin" $job_type) $hValues.containerName) -}}

apiVersion: "cbur.csf.nokia.com/v1"
kind: BrHook
metadata:
  name: {{ $job_name }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "cmdb-mariadb.labels" (tuple . "cbur" "brhook") | nindent 4 }}
  annotations:
    {{- include "cmdb-mariadb.annotations" (tuple . "cbur" "brhook") | nindent 4 }}
spec:
  properties:
    targetType: "{{ .Values.cbur.brhookType }}"
    targetName: {{ template "cmdb.pod-prefix" . }}-mariadb
    hookPoint: {{ $job_type }}
    weight: {{ .Values.cbur.brhookWeight }}
    enable: {{ .Values.cbur.brhookEnable }}
    timeout: {{ .Values.cbur.brhookTimeout }}
    deletePolicy: {{ .Values.hooks.deletePolicy | nospace | quote }}
  template:
    spec:
      template:
        metadata:
          labels:
            {{- include "cmdb-admin.labels" (tuple . "cbur" "pod") | nindent 12 }}
            type: admin
          annotations:
            {{- include "cmdb-mariadb.annotations" (tuple . "cbur" "pod") | nindent 12 }}
            {{- include "cmdb.istio-annotation" . | nindent 12 }}
        spec:
          {{- include "cmdb.get_image_pull_secrets" (tuple . "admin") | nindent 10 }}
          {{- include "cmdb.get_security_context" (tuple . "pod" "admin" 1773) | nindent 10 }}
          {{- include "cmdb.job-minimal-sa" . | nindent 10 }}
          restartPolicy: Never
          terminationGracePeriodSeconds: 30

          containers:
          - name: {{ $container_name }}
            {{- include "cmdb-admin.image" . | nindent 12 }}
            {{- include "cmdb.get_security_context" (tuple . "container" "admin" 1773) | nindent 12 }}

            args: [ {{ $hook }} ]
            env:
            - name: HOOK_TYPE
              value: {{ $prepost }}
            {{- if gt (int $hValues.timeout) 0 }}
            - name: HOOK_TIMEOUT
              value: "{{ $hValues.timeout }}"
            {{- end }}
            {{- if and .Values.admin.debug (gt $job_delay 0) }}
            - name: HOOK_DELAY
              value: "{{ $job_delay }}"
            {{- end }}
            - name: CLUSTER_TYPE
              value: "{{ .Values.cluster_type }}"
            - name: CLUSTER_NAME
              value: "{{ .Values.cluster_name | default .Release.Name | trunc 32 }}"
            {{- if and (eq $hook "backup") (eq .Values.cluster_type "master-slave") }}
            - name: SELECT_POD
              value: "{{ .Values.cbur.selectPod }}"
            - name: VOLUME_BACKUP_TYPE
              value: "{{ .Values.cbur.volumeBackupType }}"
            {{- end }}
            {{- include "cmdb-k8s.env" . | nindent 12 }}
            {{- include "cmdb-admin.service" . | nindent 12 }}
            {{- include "cmdb-tz.env" . | nindent 12 }}
            {{- include "cmdb-logging.env" . | nindent 12 }}
            resources:
              {{ include "cmdb.get_resources" ( tuple .  .Values.hooks.resources ) | nindent 14 }}
            volumeMounts:
            {{- include "cmdb-fs.vm" (tuple . "admin") | nindent 12 }}
            {{- if eq (.Values.cluster_type) "simplex" }}
            {{- include "cmdb-logging.vm" (tuple . .Values.mariadb) | nindent 12 }}
            {{- else }}
            {{- include "cmdb-logging.vm" (tuple . .Values.admin) | nindent 12 }}
            {{- end }}
          volumes:
          {{- include "cmdb-fs.vol" (tuple . "admin") | nindent 10 }}
          {{- if eq (.Values.cluster_type) "simplex" }}
          {{- include "cmdb-logging.vol" (tuple . .Values.mariadb "false") | nindent 10 }}
          {{- else }}
          {{- include "cmdb-logging.vol" (tuple . .Values.admin "false") | nindent 10 }}
          {{- end }}
        {{- if .Values.admin.tolerations }}
          tolerations:
            {{ toYaml .Values.admin.tolerations | nindent 12 }}
        {{- end }}
        {{- if .Values.admin.nodeSelector }}
          nodeSelector:
            {{ toYaml .Values.admin.nodeSelector | nindent 12 }}
        {{- end }}
{{- end }}
{{- end }}
