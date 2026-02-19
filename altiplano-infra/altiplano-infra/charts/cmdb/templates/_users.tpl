{{/* vim: set filetype=mustache: */}}

{{/*
    CMDB Built-in Users upgradable credentials
*/}}
{{- define "cmdb-user-creds.env" -}}
{{- if hasPrefix "master" .Values.cluster_type }}
- name: USER_CREDS_REPLICATION
  value: {{ default (printf "%s-user-replication" (include "cmdb.fullname" .)) .Values.users.replication.credentialName | quote }}
{{- end }}
{{- if .Values.mariadb.metrics.enabled }}
- name: USER_CREDS_MARIADB_METRICS
  value: {{ default (printf "%s-user-mariadb-metrics" (include "cmdb.fullname" .)) .Values.users.mariadbMetrics.credentialName | quote }}
{{- end }}
{{- if .Values.maxscale.metrics.enabled }}
- name: USER_CREDS_MAXSCALE_METRICS
  value: {{ default (printf "%s-user-maxscale-metrics" (include "cmdb.fullname" .)) .Values.users.maxscaleMetrics.credentialName | quote }}
{{- end }}
{{- if eq (include "cmdb.has_maxscale" .) "true" }}
- name: USER_CREDS_MAXSCALE
  value: {{ default (printf "%s-user-maxscale" (include "cmdb.fullname" .)) .Values.users.maxscale.credentialName | quote }}
{{- end }}
{{- end }}

{{/*
    CMDB All Users credentials (built-in and additional users)
    Construct user environment to pass secret names with user credentials
    to pre_install job for database_users.json creation.
*/}}
{{- define "cmdb-all-user-creds.env" -}}
{{/* Built-in Users */}}
- name: USER_CREDS_ROOT
  value: {{ default (printf "%s-user-root" (include "cmdb.fullname" .)) .Values.users.root.credentialName | quote }}
{{- if .Values.users.root.allowExternal }}
- name: ALLOW_ROOT_ALL
  value: "true"
{{- end }}
- name: USE_TLS
  value: {{ eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true" | quote }}
{{/* Upgradable users */}}
{{ include "cmdb-user-creds.env" . }}
{{/* Additional Database User(s) */}}
{{- if .Values.mariadb.users }}
{{- $g := . }}
{{- $cred_list := (list) }}
{{- range $index, $item := .Values.mariadb.users }}
{{- $cred_list = append $cred_list (default (printf "%s-dbuser-%d" (include "cmdb.fullname" $g) $index) $item.credentialName) }}
{{- end }}
- name: USER_CREDS_ADD_USERS
  value: {{ $cred_list | join "," | quote }}
{{- end }}
{{- end }}

{{/*
    CMDB Built-in Users environment to pass to pods.
    All configurable built-in user names come from user secret credentials.
*/}}
{{- define "cmdb-users.common-env" -}}
{{- if hasPrefix "master" .Values.cluster_type }}
- name: REPLICATION_USER
  valueFrom:
    secretKeyRef:
      key: username
      name: {{ default (printf "%s-user-replication" (include "cmdb.fullname" .)) .Values.users.replication.credentialName }}
{{- end }}
{{- if eq (include "cmdb.has_maxscale" .) "true" }}
- name: MAXSCALE_USER
  valueFrom:
    secretKeyRef:
      key: username
      name: {{ default (printf "%s-user-maxscale" (include "cmdb.fullname" .)) .Values.users.maxscale.credentialName }}
{{- end }}
{{- end }}

{{- define "cmdb-users.mariadb-metrics-env" -}}
{{- if .Values.mariadb.metrics.enabled }}
- name: MYSQL_METRICS_USER
  valueFrom:
    secretKeyRef:
      key: username
      name: {{ default (printf "%s-user-mariadb-metrics" (include "cmdb.fullname" .)) .Values.users.mariadbMetrics.credentialName }}
{{- end }}
{{- end }}

{{- define "cmdb-users.maxscale-metrics-env" -}}
{{- if .Values.maxscale.metrics.enabled }}
- name: MAXSCALE_METRICS_USER
  valueFrom:
    secretKeyRef:
      key: username
      name: {{ default (printf "%s-user-maxscale-metrics" (include "cmdb.fullname" .)) .Values.users.maxscaleMetrics.credentialName }}
{{- end }}
{{- end }}

{{/*
    CMDB User Credentials (Secrets).
    Admin container will watch these secrets for changes, which will trigger
    an automated password change event if the password changes in any of these
    credentials.
*/}}
{{- define "cmdb.user-creds.json" -}}
{{ include "cmdb.user-creds.yaml" . | fromYaml | toJson }}
{{- end }}

{{- define "cmdb.user-creds.yaml" -}}
Credentials:
  Built-in Users:
  - User: root
    Secret: {{ default (printf "%s-user-root" (include "cmdb.fullname" .)) .Values.users.root.credentialName | quote }}
  {{- if hasPrefix "master" .Values.cluster_type }}
  - User: replication
    Secret: {{ default (printf "%s-user-replication" (include "cmdb.fullname" .)) .Values.users.replication.credentialName }}
  {{- end }}
  {{- if eq (include "cmdb.has_maxscale" .) "true" }}
  - User: maxscale
    Secret: {{ default (printf "%s-user-maxscale" (include "cmdb.fullname" .)) .Values.users.maxscale.credentialName }}
  {{- end }}
  {{- if .Values.mariadb.metrics.enabled }}
  - User: mariadbMetrics
    Secret: {{ default (printf "%s-user-mariadb-metrics" (include "cmdb.fullname" .)) .Values.users.mariadbMetrics.credentialName }}
  {{- end }}
  {{- if .Values.maxscale.metrics.enabled }}
  - User: maxscaleMetrics
    Secret: {{ default (printf "%s-user-maxscale-metrics" (include "cmdb.fullname" .)) .Values.users.maxscaleMetrics.credentialName }}
  {{- end }}
{{- if .Values.mariadb.users }}
  Add Users:
  {{- $g := . }}
  {{- range $index, $item := .Values.mariadb.users }}
  - Secret: {{ default (printf "%s-dbuser-%d" (include "cmdb.fullname" $g) $index) $item.credentialName }}
  {{- end }}
{{- end }}
{{- end }}
