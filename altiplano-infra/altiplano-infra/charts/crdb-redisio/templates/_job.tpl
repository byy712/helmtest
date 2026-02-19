{{/* vim: set filetype=mustache: */}}

{{- /* Shared template for all Admin/LCM Jobs */ -}}

{{- define "crdb-redisio.job" -}}
{{- $job_type := .Template.Name | base | trimSuffix "-jobs.yaml" -}}
{{- $helm_hook := $job_type -}}

{{/* Check for install during upgrade (subchart) */}}
{{- if .Release.IsUpgrade -}}
  {{- $svr_sts := lookup "apps/v1" "StatefulSet" .Release.Namespace (include "csf-common-lib.v3.resourceName" (tuple . "statefulset" .Values.server.nameSuffix)) -}}
  {{- if and (empty $svr_sts) (ne (splitList "/" .Template.Name | first) "crdb-redisio") -}}
    {{/* no sts during upgrade render, subchart being enabled */}}
    {{- if eq $job_type "pre-upgrade" -}}
      {{- $job_type = "pre-install" -}}
    {{- end -}}
    {{- if eq $job_type "post-upgrade" -}}
      {{- $job_type = "post-install" -}}
    {{- end -}}
    {{/* NOTE: The opposite case of being disabled during upgrade/rollback cannot be handled due to the
             fact that helm doesn't render a disabled subchart at all - including the hooks, so there
             is nothing that we can implement to detect nor handle such a disablement situation. */}}
  {{- end -}}
{{- end -}}

{{- $prepost := splitList "-" $job_type | first -}}
{{- $hook := splitList "-" $job_type | last -}}
{{- $jValues := index .Values.hooks (printf "%s%sJob" $prepost (title $hook)) -}}
{{- if eq $job_type "test" }}
{{/* test Job */}}
  {{- $prepost = "" -}}
  {{- $hook = "test" -}}
  {{- $jValues = .Values.hooks.testJob -}}
{{- end }}

{{- $job_delay := int ($jValues.jobDelay | default .Values.hooks.jobDelay | default 0) }}
{{- $res_ref_ok := and (ne $job_type "pre-install") (ne $job_type "post-delete") -}}
{{- $pre_upgrade := or (eq $job_type "pre-rollback") (eq $job_type "pre-upgrade") -}}
{{- $job_name := include "csf-common-lib.v3.resourceName" (tuple . "job" (default $job_type $jValues.name)) -}}
{{- $container_name := include "csf-common-lib.v1.containerName" (tuple . (default (printf "%s-admin" $job_type) $jValues.containerName)) }}

{{- if $jValues.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ $job_name }}
  labels:
    {{- include "crdb-redisio.admin.labels" (tuple . "admin" "job") | nindent 4 }}
  annotations:
    {{- include "crdb-redisio.annotations" (tuple . "admin" "job") | nindent 4 }}
    "helm.sh/hook": {{ $helm_hook }}
    "helm.sh/hook-weight": {{ $jValues.weight | default 0 | quote }}
    "helm.sh/hook-delete-policy": {{ $jValues.deletePolicy | default .Values.hooks.deletePolicy | quote }}
spec:
  backoffLimit: {{ hasKey $jValues "backoffLimit" | ternary $jValues.backoffLimit 3 }}
  activeDeadlineSeconds: {{ $jValues.activeDeadlineSeconds | default "" }}
  template:
    metadata:
      labels:
        {{- include "crdb-redisio.admin.labels" (tuple . "admin" "pod") | nindent 8 }}
        type: admin
        altiplano-role: {{ .Values.accessRoleLabel }}
      annotations:
        {{- include "crdb-redisio.annotations" (tuple . "admin" "pod") | nindent 8 }}
        {{- if not $res_ref_ok }}
        sidecar.istio.io/inject: "false"
        {{- else }}
        {{- include "crdb-redisio.istio-annotation" . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "crdb-redisio.get_image_pull_secrets" (tuple . "admin") | nindent 6 }}
      {{- include "crdb-redisio.get_security_context" (tuple . "pod" "admin") | nindent 6 }}
      {{/* -pre suffix for all pre- Jobs, and -post for post-delete.  No suffix otherwise */}}
      {{- $sa_suffix := eq $job_type "post-delete" | ternary "post" (eq $prepost "pre" | ternary "pre" "") -}}
      {{- include "crdb-redisio.sa" (tuple . $sa_suffix) | nindent 6 }}
      automountServiceAccountToken: true
      {{- include "crdb-redisio.priority-class-name" (tuple . "admin") | nindent 6 }}
      restartPolicy: {{ $jValues.restartPolicy | default "Never" }}
      containers:
      - name: {{ $container_name }}
        {{- include "crdb-redisio.admin.image" . | nindent 8 }}
        args: [ {{ $hook }} ]
        {{- include "crdb-redisio.get_security_context" (tuple . "container" "admin") | nindent 8 }}
        resources: {{- toYaml .Values.admin.resources | nindent 10 }}
        env:
        - name: HOOK_TYPE
          value: {{ $prepost }}
        {{- include "crdb-redisio.tz.env" . | nindent 8 }}
        {{- include "crdb-redisio.admin.env" . | nindent 8 }}
        {{- include "crdb-redisio.admin-access.env" . | nindent 8 }}
        {{- if $res_ref_ok }}
        {{- include "crdb-redisio.cli.env" . | nindent 8 }}
        {{- end }}
        {{- if gt (int $jValues.timeout) 0 }}
        - name: HOOK_TIMEOUT
          value: "{{ $jValues.timeout }}"
        {{- end }}
        - name: DEBUG
          value: {{ $jValues.debug | default .Values.admin.debug | default "" | quote }}
        {{- if not $res_ref_ok }}
        # NOTE: Since configmaps do not exist, set some env
        - name: SERVER_COUNT
          value: "{{ .Values.server.count }}"
        {{- if .sentinel_enabled }}
        - name: SENTINEL_COUNT
          value: "{{ .Values.sentinel.count }}"
        {{- end }}
        ## Override ADMIN_SERVICE_NAME to null
        #- name: ADMIN_SERVICE_NAME
        #  value: ""
        {{- end }}
        {{- if $pre_upgrade }}
        # Note: all NEW_* variables will be updated on pre, before the values
        # are updated in configMap-based cluster.env.  This is to support
        # detecting changing these values on upgrade
        - name: NEW_SERVER_COUNT
          value: "{{ .Values.server.count }}"
        {{- if .sentinel_enabled }}
        - name: NEW_SENTINEL_COUNT
          value: "{{ .Values.sentinel.count }}"
        {{- end }}
        - name: NEW_CHART_VERSION
          value: "{{- include "crdb-redisio.chart-version" . }}"
        - name: NEW_SERVER_IMAGE_SUM
          value: "{{- include "crdb-redisio.server.image.sum" . }}"
        - name: NEW_SYSUSERAUTH_SUM
          value: "{{- include "crdb-redisio.sysuserauth.sum" . }}"
        - name: NEW_SERVER_TLS
          value: {{ .server_tls | ternary "on" "off" | quote }}
        {{- if .redis_cluster }}
        - name: NEW_CLUSTER_SHARD_COUNT
          value: "{{ .Values.cluster.shardCount }}"
        - name: NEW_CLUSTER_SHARD_MINSIZE
          value: "{{ .Values.cluster.shardSize | default 2 }}"
        {{- end }}
        {{- if .Values._forceClusterUpgrade }}
        - name: FORCE_CLUSTER_UPGRADE
          value: "1"
        {{- end }}
        {{- end }}
        {{- if (and (eq $job_type "pre-upgrade") .Values.cbur.enabled .Values.cbur.backup.upgrade) }}
        # Auto-backup on Upgrade via CBUR
        {{- include "crdb-redisio.cbur.env" . | nindent 8 }}
        - name: PRE_UPGRADE_BACKUP
          value: "cbur"
        {{- end }}
        volumeMounts:
        {{- include "crdb-redisio.fs.vm" . | nindent 8 }}
        {{- if $res_ref_ok }}
        - name: cluster-cm
          mountPath: /chart
        - name: event-cm
          mountPath: /event
        {{- include "crdb-redisio.logging.vm" . | nindent 8 }}
        {{- include "crdb-redisio.tls.vm.cacerts" . | nindent 8 }}
        {{- include "crdb-redisio.tls.vm.client" . | nindent 8 }}
        {{- end }}
      volumes:
      {{- include "crdb-redisio.fs.vol" . | nindent 6 }}
      {{- if $res_ref_ok }}
      - name: cluster-cm
        configMap:
          name: {{ include "csf-common-lib.v3.resourceName" (tuple . "configmap" "cluster-config") }}
      - name: event-cm
        configMap:
          name: {{ include "csf-common-lib.v3.resourceName" (tuple . "configmap" "admin-event") }}
      {{- include "crdb-redisio.logging.vol" (tuple . "job") | nindent 6 }}
      {{- include "crdb-redisio.tls.vol" (tuple . "job") | nindent 6 }}
      {{- end }}
      {{- if .Values.admin.tolerations }}
      tolerations: {{- toYaml .Values.admin.tolerations | nindent 8 }}
      {{- end }}
      {{- include "crdb-redisio.node-selector" (tuple . "admin") | nindent 6 }}
{{- end }}
{{- end }}
