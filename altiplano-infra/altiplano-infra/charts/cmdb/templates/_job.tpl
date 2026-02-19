{{/* vim: set filetype=mustache: */}}
{{/* Shared template for all LCM Jobs:
The following are the RBAC permissions given to each job hook:
  - cmdb.job-preinstall-sa : pre-install
  - cmdb.job-postdelete-sa : post-delete
  - cmdb.sa                : pre/post-upgrade, pre/post-rollback
                             (simplex) post-install, pre-delete, test
  - cmdb.job-minimal-sa    : (cluster) post-install, pre-delete, test
*/}}

{{- define "cmdb.job" -}}
{{- $job_type := .Template.Name | base | trimSuffix "-jobs.yaml" -}}
{{- $prepost := splitList "-" $job_type | first -}}
{{- $hook := splitList "-" $job_type | last -}}
{{- $jValues := index .Values.hooks (printf "%s%sJob" $prepost (title $hook)) -}}
{{- if eq $job_type "test" }}
  {{/* test Job */}}
  {{- $prepost = "" -}}
  {{- $hook = "test" -}}
  {{- $jValues = .Values.hooks.testJob -}}
{{- end }}
{{- $job_delay := int (default .Values.hooks.jobDelay $jValues.jobDelay) }}
{{- $res_ref_ok := and (ne $job_type "pre-install") (ne $job_type "post-delete") -}}
{{- $pre_upgrade := or (eq $job_type "pre-upgrade") (eq $job_type "pre-rollback") -}}
{{- $post_upgrade := or (eq $job_type "post-upgrade") (eq $job_type "post-rollback") -}}
{{- $job_name := printf "%s-%s" (include "cmdb.pod-prefix" .) (default $job_type $jValues.name) | trunc 63 | trimSuffix "-" -}}
{{- $container_name := printf "%s%s" (include "cmdb.container-prefix" .) (default (printf "%s-admin" $job_type) $jValues.containerName) -}}

{{- if $jValues.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ $job_name }}
  labels:
    altiplano-role: {{ .Values.accessRoleLabel }}
    {{- include "cmdb-admin.labels" (tuple . "job") | nindent 4 }}
  annotations:
    {{- include "cmdb-admin.annotations" (tuple . "job") | nindent 4 }}
    "helm.sh/hook": {{ $job_type }}
    "helm.sh/hook-weight": {{ $jValues.weight | default 0 | quote }}
    "helm.sh/hook-delete-policy": {{ $jValues.deletePolicy | default .Values.hooks.deletePolicy | quote }}
spec:
  backoffLimit: {{ hasKey $jValues "backoffLimit" | ternary $jValues.backoffLimit 3 }}
  activeDeadlineSeconds: {{ $jValues.activeDeadlineSeconds | default .Values.admin.activeDeadlineSeconds }}
  template:
    metadata:
      labels:
        {{- include "cmdb-admin.labels" (tuple . "pod") | nindent 8 }}
        type: admin
      annotations:
        {{- include "cmdb-admin.annotations" (tuple . "pod") | nindent 8}}
        {{- if not $res_ref_ok }}
        sidecar.istio.io/inject: "false"
        {{- else }}
        {{- include "cmdb.istio-annotation" . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "cmdb.get_security_context" (tuple . "pod" "admin" 1773) | nindent 6 }}
      {{- if not $res_ref_ok }}
      {{- include (ternary "cmdb.job-preinstall-sa" "cmdb.job-postdelete-sa" (eq $hook "install")) . | nindent 6 }}
      {{- else if or $pre_upgrade $post_upgrade (eq .Values.cluster_type "simplex") }}
      {{- include "cmdb.sa" . | nindent 6 }}
      {{- else }}
      {{- include "cmdb.job-minimal-sa" . | nindent 6 }}
      {{- end }}
      {{- include "cmdb.get_image_pull_secrets" (tuple . "admin") | nindent 6 }}
      restartPolicy: {{ $jValues.restartPolicy | default "Never" }}

      containers:
      - name: {{ $container_name }}
        {{- include "cmdb-admin.image" . | nindent 8 }}
        {{- include "cmdb.get_security_context" (tuple . "container" "admin" 1773) | nindent 8 }}
        args: [ {{ $hook }} ]
        env:
        - name: HOOK_TYPE
          value: {{ $prepost }}
        {{- if gt (int $jValues.timeout) 0 }}
        - name: HOOK_TIMEOUT
          value: "{{ $jValues.timeout }}"
        {{- end }}
        {{- if and .Values.admin.debug (gt $job_delay 0) }}
        - name: HOOK_DELAY
          value: "{{ $job_delay }}" 
        {{- end }}
        - name: DEBUG
          value: {{ $jValues.debug | default .Values.admin.debug | quote }}
        - name: CLUSTER_TYPE
          value: "{{ .Values.cluster_type }}"
        - name: CLUSTER_NAME
          value: "{{ .Values.cluster_name | default .Release.Name | trunc 32 }}"
      {{- if not $res_ref_ok }}
        # NOTE: Since configmaps don't exist (not created yet/already deleted),
        # must explicitly set mariadb and maxscale cluster sizes here
        - name: CLUSTER_SIZE
          value: {{ include "cmdb.mariadb_size" . | quote }}
        - name: MAXSCALE_SIZE
          value: {{ include "cmdb.maxscale_size" . | quote }}
      {{- end }}
      # Note: pre-install/upgrade gets all credentials, otherwise built-in users
      {{- if or (eq $job_type "pre-install") (eq $job_type "pre-upgrade") }}
        # pre-install will create database_users.json from secrets
        {{- include "cmdb-all-user-creds.env" . | nindent 8 }}
      {{- else }}
        {{- include "cmdb-user-creds.env" . | nindent 8 }}
      {{- end }}
      {{- if eq $job_type "pre-install" }}
        - name: INSTALL_REQUIRES
          value: {{ default "all" .Values.deployRequires }}
      {{- end }}
      {{- if $pre_upgrade }}
        # Note: all NEW_* variables will be updated on pre, before the values
        # are updated in configMap-based cluster.env.  This is to support
        # allowing changing these values on upgrade.
        - name: NEW_CLUSTER_SIZE
          value: {{ include "cmdb.mariadb_size" . | quote }}
        - name: NEW_MAXSCALE_SIZE
          value: {{ include "cmdb.maxscale_size" . | quote }}
        - name: NEW_CHART_VERSION
          value: "{{ include "cmdb.chart-version" . }}"
        - name: NEW_MARIADB_IMAGE_SUM
          value: "{{- include "cmdb-mariadb.image.sum" . }}"
        - name: NEW_REPLICATION_SSL
        {{- if and (eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true") (or (eq (include "cmdb.mariadb_use_cmgr" .) "true") (and (ne (default "none" .Values.mariadb.tls.secretRef.name) "none") (ne (default "none" .Values.clients.mariadb.tls.secretRef.name) "none"))) }}
          value: "on"
        {{- else }}
          value: "off"
        {{- end }}
      {{- end }}
      {{- if (and (eq $job_type "pre-upgrade") .Values.cbur.enabled .Values.cbur.backup.upgrade) }}
        # Auto-backup on Upgrade via CBUR
        {{- include "cmdb-mariadb.cbur.env" . | nindent 8 }}
        - name: PRE_UPGRADE_BACKUP
          value: "cbur"
      {{- end }}
      {{- if eq $job_type "pre-upgrade" }}
        # password secret used in pwchange/morph not rendered in event-cm yet
        {{- if .Values.admin.pwChangeSecret }}
        - name: NEW_PW_SECRET
          value: "{{ .Values.admin.pwChangeSecret }}"
        {{- end }}
        # Restore Server (RS) configuration not renderted in rs-cm yet
        {{- if eq .Values.cluster_type "master-slave" }}
        - name: RS_ENABLED
          value: {{ .Values.admin.restoreServer.enabled | quote }}
        - name: RS_JOIN_CLUSTER
          value: {{ default false .Values.admin.restoreServer.joinCluster | quote }}
        - name: RS_LABELS
          value: {{ default (dict) .Values.admin.restoreServer.labels | toJson | quote }}
        - name: RS_ANNOTATIONS
          value: {{ default (dict) .Values.admin.restoreServer.annotations | toJson | quote }}
        {{- end }}
      {{- end }}
      {{- if and (eq $hook "backup") (eq .Values.cluster_type "master-slave") }}
        - name: SELECT_POD
          value: "{{ .Values.cbur.selectPod }}"
        - name: VOLUME_BACKUP_TYPE
          value: "{{ .Values.cbur.volumeBackupType }}"
      {{- end }}
      {{- if eq $job_type "post-install" }}
        {{- if eq (default "no" .Values.admin.quickInstall) "yes" }}
        - name: QUICK_INSTALL
          value: "yes"
        {{- end }}
      {{- end }}
      {{- if $post_upgrade }}
        {{- if .Values.admin.configAnnotation }}
        - name: RUN_UPDATECFG
          value: "no"
        {{- end }}
      {{- end }}
      {{- if eq $job_type "post-delete" }}
        - name: PRESERVE_PVC
          value: {{ .Values.mariadb.persistence.preserve_pvc | quote }}
      {{- end }}
      {{- if eq $job_type "test" }}
        {{- if .Values.mariadb.metrics.enabled }}
        - name: MARIADB_METRICS_PORT
          value: {{ default 9104 .Values.services.mariadb.exporter.port | quote }}
        {{- end }}
        {{- if .Values.maxscale.metrics.enabled }}
        - name: MAXSCALE_METRICS_PORT
          value: {{ default 9195 .Values.services.maxscale.exporter.port | quote }}
        {{- end }}
      {{- end }}
        {{- include "cmdb-k8s.env" . | nindent 8 }}
        {{- if $res_ref_ok }}
        {{- include "cmdb-admin.service" . | nindent 8 }}
        {{- end }}
        {{- include "cmdb-tz.env" . | nindent 8 }}
        {{- include "cmdb-logging.env" . | nindent 8 }}
        resources:
          {{- include "cmdb.get_resources" ( tuple .  .Values.hooks.resources ) | nindent 10 }}
        volumeMounts:
        {{- include "cmdb-fs.vm" (tuple . "admin") | nindent 8 }}
      {{- if $res_ref_ok }}
        {{- if eq (.Values.cluster_type) "simplex" }}
        {{- include "cmdb-logging.vm" (tuple . .Values.mariadb ) | nindent 8 }}
        {{- else }}
        {{- include "cmdb-logging.vm" (tuple . .Values.admin ) | nindent 8 }}
        {{- end }}
        - name: cluster-cm
          mountPath: /chart
        - name: event-cm
          mountPath: /event
        {{- if eq (.Values.cluster_type) "simplex" }}
        - name: user-creds
          mountPath: /.creds
        {{- end }}
      {{- end }}

      volumes:
      {{- include "cmdb-fs.vol" (tuple . "admin") | nindent 6 }}
    {{- if $res_ref_ok }}
      {{- if eq (.Values.cluster_type) "simplex" }}
      {{- include "cmdb-logging.vol" (tuple . .Values.mariadb "true") | nindent 6 }}
      {{- else }}
      {{- include "cmdb-logging.vol" (tuple . .Values.admin "true") | nindent 6 }}
      {{- end }}
      - name: cluster-cm
        configMap:
          name: {{ template "cmdb.fullname" . }}-mariadb-cluster
      - name: event-cm
        configMap:
          name: {{ template "cmdb.fullname" . }}-admin-event
      {{- if eq (.Values.cluster_type) "simplex" }}
      - name: user-creds
        secret:
          secretName: {{ template "cmdb.fullname" . }}-admin-user-creds
          optional: true
      {{- end }}
    {{- end }}
    {{- if .Values.admin.tolerations }}
      tolerations:
        {{ toYaml .Values.admin.tolerations | nindent 8 }}
    {{- end }}
    {{- if .Values.admin.nodeSelector }}
      nodeSelector:
        {{ toYaml .Values.admin.nodeSelector | nindent 8 }}
    {{- end }}
{{- end }}
{{- end }}
