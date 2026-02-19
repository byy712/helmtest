{{/* vim: set filetype=mustache: */}}
{{/*
*
* Expand the name of the chart.
*
*/}}
{{- define "crdb-redisio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
*
* Create a default fully qualified app name.
* We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
* If release name contains chart name it will be used as a full name.
*
*/}}
{{- define "crdb-redisio.fullname" -}}
{{- if .Values.fullnameOverride -}}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- if contains $name .Release.Name -}}
    {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
*
* Set the group name (Sentinel master group name)
*
*/}}
{{- define "crdb-redisio.groupname" -}}
{{- .Values.groupName | default (include "crdb-redisio.fullname" .) -}}
{{- end -}}

{{/*
*
* Define the Database Access URIs
*
*/}}
{{- define "crdb-redisio.db.svc" -}}
{{- include "crdb-redisio.groupname" . -}}.{{- .Release.Namespace -}}.svc.{{- .Values.clusterDomain -}}
{{- end -}}
{{- define "crdb-redisio.db-readonly.svc" -}}
{{- include "crdb-redisio.groupname" . -}}-readonly.{{- .Release.Namespace -}}.svc.{{- .Values.clusterDomain -}}
{{- end -}}

{{- define "crdb-redisio.db.port" -}}
{{- /* Primary DB access port */ -}}
6379
{{- end -}}

{{- define "crdb-redisio.db.alt-port" -}}
{{- /* Alternate (non-TLS) DB access port - if TLS and non-TLS simultanesouly enabled */ -}}
{{- if and .server_tls (first (without (splitList "," (toString .Values.services.redis.nonTlsPort)) "0")) -}}
6380
{{- end -}}
{{- end -}}

{{- define "crdb-redisio.db.scheme" -}}
{{- ternary "rediss" "redis" .server_tls -}}
{{- end -}}

{{- define "crdb-redisio.db.svcport" -}}
{{- include "crdb-redisio.db.svc" . -}}:{{- include "crdb-redisio.db.port" . -}}
{{- end -}}
{{- define "crdb-redisio.db-readonly.svcport" -}}
{{- include "crdb-redisio.db-readonly.svc" . -}}:{{- include "crdb-redisio.db.port" . -}}
{{- end -}}

{{- define "crdb-redisio.db.uri" -}}
{{- include "crdb-redisio.db.scheme" . -}}://{{- include "crdb-redisio.db.svcport" . -}}
{{- end -}}
{{- define "crdb-redisio.db-readonly.uri" -}}
{{ include "crdb-redisio.db.scheme" . -}}://{{- include "crdb-redisio.db-readonly.svcport" . }}
{{- end -}}

{{/*
*
* CLI command and arguments
*
*/}}
{{- define "crdb-redisio.cli.env" -}}
{{- $cli := cat "/usr/bin/redis-cli " (.redis_cluster | ternary "-c " "") -}}
{{- if .server_tls }}
- name: REDIS_CLI_TLS
  value: "yes"
- name: REDIS_CLI_CACERTDIR
  value: {{ include "crdb-redisio.tls.dir.ca" . }}
- name: REDIS_CLI_CACERT
  value: $(REDIS_CLI_CACERTDIR)/server-ca.crt
{{- $cli = cat $cli "--tls --cacert $(REDIS_CLI_CACERT) " }}
{{- if .client_tls }}
- name: REDIS_CLI_CERT
  value: {{ include "crdb-redisio.tls.cert.client" . }}
- name: REDIS_CLI_KEY
  value: {{ include "crdb-redisio.tls.key.client" . }}
{{- $cli = cat $cli "--cert $(REDIS_CLI_CERT) --key $(REDIS_CLI_KEY) " }}
{{- end }}
{{- end }}
- name: REDIS_CLI
  value: {{ $cli }}
{{- end -}}

{{/*
* Common env - shared among admin and server
*/}}
{{- define "crdb-redisio.common.env" -}}
- name: K8S_NAMESPACE
  value: "{{ .Release.Namespace }}"
- name: K8S_DOMAIN
  value: "{{ .Values.clusterDomain }}"
- name: K8S_SVC_DOMAIN
  value: "svc.{{ .Values.clusterDomain }}"
- name: K8S_LABELS
  value: app={{ template "crdb-redisio.fullname" . }},release={{ .Release.Name }}
- name: K8S_PREFIX
  value: {{ include "csf-common-lib.v3.resourceName" (tuple . "configmap") }}
- name: K8S_POD_PREFIX
  value: {{ include "csf-common-lib.v3.resourceName" (tuple . "pod") }}
- name: K8S_CONTAINER_PREFIX
  value: {{ include "csf-common-lib.v1.containerName" (tuple . "") }}
{{- if .redis_cluster }}
- name: REDIS_CLUSTER
  value: "yes"
{{- end }}
{{- if not .Values.server.persistence.enabled }}
- name: PVCLESS
  value: "yes"
{{- end }}
{{- if .Values.istio.enabled }}
- name: ISTIO_ENABLED
  value: "true"
- name: ISTIO_HEALTH_PORT
  value: {{ .Values.global.istio.sidecar.healthCheckPort | default (semverCompare "<1.6" (toString .Values.istio.version) | ternary 15020 15021) | quote }}
- name: ISTIO_STOP_PORT
  value: {{ .Values.global.istio.sidecar.stopPort | default 15000 | quote }}
{{- end }}
{{- end -}}

{{/*
* Admin access env snippet
*/}}
{{- define "crdb-redisio.admin-access.env" -}}
- name: ADMIN_SERVICE_NAME
  value: {{ .Values.services.admin.name | default (include "csf-common-lib.v3.resourceName" (tuple . "service" .Values.admin.nameSuffix)) | quote }}
{{- end -}}

{{/*
* Admin service env snippet for admin job pods K8s params
*/}}
{{- define "crdb-redisio.admin.env" -}}
{{- include "crdb-redisio.common.env" . }}
- name: GROUP_NAME
  value: {{ template "crdb-redisio.groupname" . }}
- name: PRESERVE_PVC
  value: {{ .Values.server.persistence.preservePvc | quote }}
# Set HOME to give kubectl a writable path for caching
- name: HOME
  value: /tmp
{{ include "crdb-redisio.acl.user.all_system.env" . }}
{{- if .Values.common }}{{/* Upgrade from v5.x.x */}}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "csf-common-lib.v3.resourceName" (tuple . "secret" "redis-secrets") }}
      key: redis-password
      optional: true
{{- end -}}
{{- if and .Values.admin.debug (gt (int (default '0' .Values.admin.jobDelay)) 0) }}
- name: HOOK_DELAY
  value: "{{ int .Values.admin.jobDelay }}"
{{- end -}}
{{- end -}}

{{/*
* Server env snippet for K8s params to update configmaps in pvcless
*/}}
{{- define "crdb-redisio.server.env" -}}
{{- include "crdb-redisio.common.env" . }}
{{- if .redis_cluster }}
- name: RESTARTDELAY
  value: {{ quote .Values.cluster.masterRestartDelay }}
{{- end }}
{{- end -}}

{{/*
* Define topology spread constraints
*/}}
{{- define "crdb-redisio.spread-constraints" -}}
{{- $g := first . -}}
{{- $subcomp := index . 1 -}}
{{- $Values := index $g "Values" $subcomp -}}
{{- if $Values.topologySpreadConstraints -}}
topologySpreadConstraints:
{{- range $index, $item := $Values.topologySpreadConstraints }}
{{- list (omit $item "autoGenerateLabelSelector") | toYaml | nindent 0 }}
{{- if and (not $item.labelSelector) $item.autoGenerateLabelSelector }}
  labelSelector:
    matchLabels:
      app: {{ template "crdb-redisio.fullname" $g }}
      release: {{ $g.Release.Name | quote }}
      csf-subcomponent: redisio{{ if eq $subcomp "admin" }}-admin{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
* priorityClassName
Arg: (tuple <scope> server|admin|sentinel)
*/}}
{{- define "crdb-redisio.priority-class-name" -}}
{{- $g := first . -}}
{{- $subcomp := index . 1 -}}
{{- $pcn := index $g.Values $subcomp "priorityClassName" | default $g.Values.global.priorityClassName -}}
{{- with $pcn -}}
priorityClassName: {{ . }}
{{- end -}}
{{- end }}

{{/*
* Determine the serviceAccountName
Arg: (tuple <scope> ""|pre|post)
*/}}
{{- define "crdb-redisio.sa" -}}
{{- $g := first . -}}
{{- $suffix := "" -}}
{{- if gt (len .) 1 -}}
  {{- $suffix = index . 1 -}}
{{- end -}}
{{- $user_sa := coalesce $g.Values.serviceAccountName $g.Values.global.serviceAccountName -}}
{{- if $g.Values.rbac.enabled }}
serviceAccountName: {{ include "csf-common-lib.v3.resourceName" (tuple $g "serviceaccount" $suffix) }}
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* Istio Annotations */}}
{{- define "crdb-redisio.istio-annotation" -}}
{{- if .Values.istio.enabled }}
sidecar.istio.io/inject: "true"
{{- if .Values.istio.mtls.enabled }}
sidecar.istio.io/rewriteAppHTTPProbers: "true"
{{- end }}
{{- end }}
{{- end }}

{{/* Utility template for getting custom labels/annotations

See HBP 2.13 - Gets annotations or labels from .Values via the following
structure:
global:
  labels:
  annotations:
labels:
annotations:
custom:
  <type>:
    labels:
    annotations:

Arg: (tuple <scope> annotations|labels (list <types>...))
*/}}
{{- define "crdb-redisio.get_custom" -}}
{{- $Values := index (first .) "Values" -}}
{{- $key_type := index . 1 -}}
{{- $types := index . 2 | default (list) -}}
{{- range $k,$v := merge (index $Values $key_type) (index $Values.global $key_type) }}
{{ $k }}: {{ $v | quote }}
{{- end -}}
{{- $custom_val := $Values.custom | default (dict) -}}
{{- range $type := $types -}}{{- range $k,$v := index (index $custom_val $type | default (dict)) $key_type }}
{{ $k }}: {{ $v | quote }}
{{- end -}}{{- end -}}
{{- end }}

{{/* Utility template for getting custom securityContext Values

See HBP 2.16 - Gets securityContext from .Values via the following
structure:
podSecurityContext:
containerSecurityContext:
<val_path>:
  podSecurityContext:
  containerSecurityContext:

Will search into <val_path> first, then top-level, then use default
For disabled, top-level takes precedence if disabled: true, however,
lower-level can re-enable with disabled: false

Arg: (tuple <scope> pod|container <val_path>)

Output, e.g:
(pod, spec.):
securityContext:
  runAsUser: 6379
  runAsGroup: 6379
  fsGroup: 6379
  runAsNonRoot: true                # HBP_ContainerUser_1
  seccompProfile:                   # HBP_Security_Seccomp_1 (k8s>=1.25.0)
    type: RuntimeDefault

(container, spec.container[*].):
securityContext:
  runAsUser: 6379
  runAsGroup: 6379
  readOnlyRootFilesystem: true      # HBP_Security_Volume_2
  allowPrivilegeEscalation: false   # HBP_Security_Privilege_2
  capabilities:
    drop: [ALL]                     # HBP_Security_Capabilities_1
    add:  [NET_ADMIN, NET_RAW]      # k8s>1.25.0 istio (no PSP)

*/}}
{{- define "crdb-redisio.get_security_context" -}}
{{/* Args */}}
{{- $ctx := index . 0 -}}
{{- $sc_type := printf "%sSecurityContext" (index . 1) -}}
{{- $val_path := index . 2 | splitList "." -}}

{{- $Values := $ctx.Values -}}
{{- $Capabilities := $ctx.Capabilities -}}
{{- $istio_nopsp := and $Values.istio.enabled (not $Values.istio.cni.enabled) (not ($Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy")) -}}
{{- $k8s123 := semverCompare "<=1.23" (include "crdb-redisio.k8sver" $ctx) -}}
{{- $openshift := $Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" -}}

{{/* Setup Default securityContext */}}
{{- $default_sc := dict -}}
{{- $_ := set $default_sc "runAsUser" 6379 -}}
{{- $_ := set $default_sc "runAsGroup" 6379 -}}
{{- if eq $sc_type "podSecurityContext" -}}
  {{- $_ := set $default_sc "fsGroup" 6379 -}}
  {{- $_ := set $default_sc "runAsNonRoot" true -}}
  {{- if not (and $openshift $k8s123) -}}
    {{/* include secompProfile by default unless Openshift pre-4.11 */}}
    {{- $_ := set $default_sc "seccompProfile" (dict "type" "RuntimeDefault") -}}
  {{- end -}}
{{- else if eq $sc_type "containerSecurityContext" -}}
  {{- $_ := set $default_sc "readOnlyRootFilesystem" true -}}
  {{- $_ := set $default_sc "allowPrivilegeEscalation" false -}}
  {{- $_ := set $default_sc "capabilities" (dict "drop" (list "ALL")) -}}
  {{- if $istio_nopsp -}}
    {{- $_ := merge $default_sc.capabilities (dict "add" (list "NET_ADMIN" "NET_RAW")) -}}
  {{- end -}}
{{- end -}}

{{/* Merge with user-provided values */}}
{{- $user_val := $Values -}}
{{- range $val_path -}}
{{- $user_val = index (default (dict) $user_val) . -}}
{{- end -}}
{{- $sc_disable := coalesce (pick (index $user_val $sc_type) "disabled") (pick (index $Values $sc_type) "disabled") -}}
{{- $sc := coalesce (index $user_val $sc_type) (index $Values $sc_type) $default_sc -}}
{{- if not $sc_disable.disabled -}}
securityContext: {{- omit $sc "disabled" | toYaml | nindent 2 }}
{{- else -}}
securityContext: {}
{{- end -}}
{{- end }}


{{/* Utility template for imagePullSecrets

See HBP 2.3, HBP_Kubernetes_pod_3, HBP_Kubernetes_Pod_4
*/}}
{{- define "crdb-redisio.get_image_pull_secrets" -}}
{{- $top := first . -}}
{{- $subcomp := index . 1 -}}
{{- $ips := coalesce (index $top.Values $subcomp).imagePullSecrets $top.Values.imagePullSecrets $top.Values.global.imagePullSecrets -}}
{{- with $ips }}
imagePullSecrets: {{- toYaml $ips | nindent 0 }}
{{- end -}}
{{- end }}

{{/* Utility template for timezone Env

See HBP 2.24, HBP_Kubernetes_Time_1, HBP_Kubernetes_Time_2

Note: Per HBP_Kubernetes_Time_2, former crdb-redisio.tz.vm template
      and timezone.mountHostLocalTime Value has been removed
Note: .Values.timezone moved to .Values.timeZone per HBP
*/}}
{{- define "crdb-redisio.tz.env" -}}
- name: TZ
  value: {{ .Values.timeZone.timeZoneEnv | default .Values.global.timeZoneEnv | default "UTC" | quote }}
{{- end }}

{{/* Utility templates for filesystem volumeMounts/volume

  To provide writable emptyDir space instead of using
  root filesystem in support of readOnlyRootFilesystem

*/}}
{{- define "crdb-redisio.fs.vm" -}}
- name: fs-tmp
  mountPath: /tmp
- name: fs-varlogadmin
  mountPath: /var/log/admin
- name: fs-etcsupervisord
  mountPath: /etc/supervisord.d
- name: fs-varrunsupervisor
  mountPath: /var/run/supervisor
- name: fs-varlogsupervisor
  mountPath: /var/log/supervisor
{{- end }}
{{- define "crdb-redisio.fs.vol" -}}
- name: fs-tmp
  emptyDir: {}
- name: fs-varlogadmin
  emptyDir: {}
- name: fs-etcsupervisord
  emptyDir: {}
- name: fs-varrunsupervisor
  emptyDir: {}
- name: fs-varlogsupervisor
  emptyDir: {}
{{- end }}

{{- define "crdb-redisio.fifo.env" -}}
{{- with .Values.fifoPath }}
- name: FIFO_DIR
  value: {{ . | quote }}
{{- end -}}
{{- end }}

{{/* Utility templates for Kubernetes Dual-Stack support.

See HBP_Kubernetes_Service_4 - Gets dual-stack configuration from .Values
via the following structure:

global:
  ipFamilyPolicy: {SingleStack | PreferDualStack | RequireDualStack}
  ipFamilies:
    - IPv4
    - IPv6
service:
  <name>:
    ipFamilyPolicy: {SingleStack | PreferDualStack | RequireDualStack}
    ipFamilies:
      - IPv4
      - IPv6

By default, dual-stack configuration will not be added.  If specified at
global scope, applies by default to all services.  Configuration set
at service scope takes precidence over global scope.

Arg: (tuple <scope> <service>))
*/}}
{{- define "crdb-redisio.dual-stack" -}}
{{- $Values := index (first .) "Values" -}}
{{- $service := index . 1 -}}
{{- $policy := coalesce $service.ipFamilyPolicy $Values.global.ipFamilyPolicy }}
{{- $families := coalesce $service.ipFamilies $Values.global.ipFamilies }}
{{- if $policy }}
ipFamilyPolicy: {{ $policy }}
{{- end -}}
{{- if $families }}
ipFamilies: {{ $families | toYaml | nindent 2 }}
{{- end -}}
{{- end }}

{{/* Utility for calculating storage sizes (e.g., Gi, M, Ki, etc.) for comparison purposes.
     Outputs the size in bytes.

Arg <sizestr>
*/}}
{{- define "crdb-redisio.sizecalc" -}}
{{- $sizeStr := . -}}
{{- $unit := regexSplit "[0-9]+" $sizeStr 2 | last -}}
{{- $num := trimSuffix $unit $sizeStr -}}
{{- $unitconv := dict "Ki" 1024 "K" 1000 -}}
{{- $_ := merge $unitconv (dict "Mi" (mul 1024 1024) "M" (mul 1000 1000)) -}}
{{- $_ := merge $unitconv (dict "Gi" (mul 1024 1024 1024) "G" (mul 1000 1000 1000)) -}}
{{- $_ := merge $unitconv (dict "Ti" (mul 1024 1024 1024 1024) "T" (mul 1000 1000 1000 1000)) -}}
{{- $_ := merge $unitconv (dict "Pi" (mul 1024 1024 1024 1024 1024) "P" (mul 1000 1000 1000 1000 1000)) -}}
{{- mul $num (get $unitconv $unit) -}}
{{- end -}}

{{/* revision setting to determine if this is first install for pod init */}}
{{- define "crdb-redisio.revision" -}}
{{- if .Release.IsUpgrade -}}
  {{- $svr_sts := lookup "apps/v1" "StatefulSet" .Release.Namespace (include "csf-common-lib.v3.resourceName" (tuple . "statefulset" .Values.server.nameSuffix)) -}}
  {{- if and (empty $svr_sts) (ne (splitList "/" .Template.Name | first) "crdb-redisio") -}}
    {{/* no sts during upgrade render, subchart being enabled, set the revision to 1 */}}
    {{- printf "1" -}}
  {{- else -}}
    {{- .Release.Revision -}}
  {{- end -}}
{{- else -}}
  {{- .Release.Revision -}}
{{- end -}}
{{- end -}}