{{/* vim: set filetype=mustache: */}}
{{/*
*  Expand the name of the chart.
*/}}
{{- define "cmdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
*  Create a default fully qualified app name.
*  We truncate at 63 chars because some Kubernetes name fields are limited
*  to this (by the DNS naming spec).
*/}}
{{- define "cmdb.fullname" -}}
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


{{- define "cmdb.chart-full-version" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
*  mariadb/maxscale HPA templates:
*
*  cmdb.has_maxscale         - should maxscale resources should be allocated.
*  cmdb.maxscale_hpa_enabled - Is maxscale HPA enabled?
*  cmdb.maxscale_size        - MAXSCALE_SIZE environment variable value
*
*  cmdb.mariadb_hpa_enabled  - Is mariadb HPA enabled?
*  cmdb.mariadb_size         - CLUSTER_sIZE environment variable value
*
*  Use maxscale for cluster type master-slave and either count > 0 HPA enabled. 
*  MAXSCALE_SIZE will be minReplicas if maxscale HPA is enabled.
*/}}
{{- define "cmdb.has_maxscale" -}}
{{- and (eq .Values.cluster_type "master-slave") (or (gt (int .Values.maxscale.count) 0) (eq (include "cmdb.maxscale_hpa_enabled" .) "true")) }}
{{- end }}
{{- define "cmdb.maxscale_hpa_enabled" -}}
{{- (and (hasKey .Values.maxscale.hpa "enabled") (kindIs "bool" .Values.maxscale.hpa.enabled)) | ternary .Values.maxscale.hpa.enabled (.Values.global.hpa.enabled | default false) -}}
{{- end }}
{{- define "cmdb.maxscale_size" -}}
{{- if eq (include "cmdb.maxscale_hpa_enabled" .) "true" }}
{{- .Values.maxscale.hpa.minReplicas }}
{{- else }}
{{- eq (include "cmdb.has_maxscale" .) "true" | ternary .Values.maxscale.count 0 }}
{{- end }}
{{- end }}

{{- define "cmdb.cmgr_enabled" -}}
{{- (eq (include "cmdb.coalesceBoolean" (tuple .Values.certManager.enabled .Values.global.certManager.enabled true)) "true") -}}
{{- end }}

{{- define "cmdb.mariadb_use_cmgr" -}}
{{- if and (eq (include "cmdb.cmgr_enabled" .) "true") (.Values.mariadb.certificate.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{- define "cmdb.maxscale_use_cmgr" -}}
{{- if and (eq (include "cmdb.cmgr_enabled" .) "true") (.Values.maxscale.certificate.enabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{/* Utility template to check tls enabled
*/}}
{{- define "cmdb.tls_enabled" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $spec.tls.enabled $Values.tls.enabled $Values.global.tls.enabled true)) "true" | ternary "true" "false" -}}
{{- end }}

{{- define "cmdb.mariadb_hpa_enabled" -}}
{{- (and (hasKey .Values.mariadb.hpa "enabled") (kindIs "bool" .Values.mariadb.hpa.enabled)) | ternary .Values.mariadb.hpa.enabled (.Values.global.hpa.enabled | default false) -}}
{{- end }}
{{- define "cmdb.mariadb_size" -}}
{{- if eq (include "cmdb.mariadb_hpa_enabled" .) "true" }}
{{- .Values.mariadb.hpa.minReplicas }}
{{- else }}
{{- eq .Values.cluster_type "simplex" | ternary 1 .Values.mariadb.count }}
{{- end }}
{{- end }}

{{/* disallow mariadb HPA in simplex and master-master topologies */}}
{{- if and (or (eq .Values.cluster_type "simplex") (eq .Values.cluster_type "master-master")) (include "cmdb.mariadb_hpa_enabled" "true") -}}
  {{- fail (printf "Cannot enable MariaDB HPA for cluster_type %s" .Values.cluster_type) -}}
{{- end -}}

{{/* Utility template for whether a value is empty
Returns string "true" for:
- empty value
- empty string
- non-existent key
- null|Null|NULL value

Returns string "false" for non empty value, including:
- empty list
- empty dict
- booleans true and false
- integers e.g. 0
*/}}
{{- define "cmdb.isEmptyValue" -}}
{{- or (eq (typeOf .) "<nil>") (eq (. | toString) "") -}}
{{- end -}}

{{- define "cmdb.coalesceBoolean" -}}
{{- $result := "" }}
{{- range . }}
    {{- if eq (include "cmdb.isEmptyValue" .) "false" }}
        {{- if eq (include "cmdb.isEmptyValue" $result) "true" }}
            {{- $result = ternary "true" "false" . }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $result }}
{{- end -}}

{{/* Utility template for imagePullSecrets
*/}}
{{- define "cmdb.get_image_pull_secrets" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- with (default $Values.global.imagePullSecrets $spec.imagePullSecrets) }}
imagePullSecrets: {{- toYaml . | nindent 0 }}
{{- end -}}
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
<workload>:
  labels:
  annotations:

Arg: (tuple <scope> annotations|labels <workload> (list <types>...))
*/}}
{{- define "cmdb.get_custom" -}}
{{- $Values := index (first .) "Values" -}}
{{- $key_type := index . 1 -}}
{{- $workload := index . 2 -}}
{{- $types := index . 3 | default (list) -}}
{{- range $k,$v := merge (index $Values $key_type ) (index $Values.global $key_type ) }}
{{ $k }}: {{ $v | quote }}
{{- end -}}
{{- $custom_val := $Values.custom | default (dict) -}}
{{- range $type := $types -}}{{- range $k,$v := index (index $custom_val $type | default (dict)) $key_type }}
{{ $k }}: {{ $v | quote }} 
{{- end -}}{{- end -}}
{{- range $k,$v := (index (index $Values $workload | default (dict)) $key_type | default (dict)) }}
{{ $k }}: {{ $v | quote }}
{{- end -}}
{{- end }}

{{/* Utility template for getting custom selector labels

custom:
  mariadbSts:
    selectors:
  maxscaleSts:
    selectors:

Arg: (tuple <scope> <sts>)
*/}}
{{- define "cmdb.get_custom_selectors" -}}
{{- $Values := index (first .) "Values" -}}
{{- $type := index . 1 -}}
{{- $custom_val := $Values.custom | default (dict) -}}
{{- range $k,$v := index ( index $custom_val $type | default (dict)) "selectors" }}
{{ $k }}: {{ $v | quote }}
{{- end -}}
{{- end }}

{{- define "cmdb.get_mtls_labels" -}}
{{- $Values := index . "Values" -}}
{{- if and $Values.istio.enabled $Values.istio.mtls.enabled  }}
  {{- printf "%s" ( $Values.istio.permissive | ternary ("istio.io/permissive-mtls: \"true\"") ("mtls-strict: \"true\"")) -}}
{{- else }}
  {{- printf "" -}}
{{- end -}}
{{- end }}

{{- define "cmdb.istio_mtls_mode" -}}
{{- $Values := index . "Values" -}}
{{- if and $Values.istio.enabled  $Values.istio.mtls.enabled ( not $Values.istio.permissive ) }}
  {{- printf "STRICT" -}}
{{- else if and $Values.istio.enabled  $Values.istio.mtls.enabled $Values.istio.permissive }}
  {{- printf "PERMISSIVE" -}}
{{- else if and $Values.istio.enabled ( not $Values.istio.mtls.enabled ) }}
  {{- printf "UNSET" -}}
{{- end -}}
{{- end }}

{{/* Utility templates for pod/container name with prefix

Must keep under 63 for Statefulsets (-admin/mariadb/maxscale) which can
add up to 9 characters

See HBP 2.26.1 - Pod/Container Prefix used in controllers (Statefulset, etc).
Controller names can be max 63 characters in length, however, due to the
following K8s issue: https://github.com/kubernetes/kubernetes/issues/64023,
where K8s appends a 10 or 11-character suffix to the controller name for a Pod
label (which is also limited to 63-char max), controller names must then be
kept to a maximum of 52 characters.
The CMDB-added suffixes (-[admin|mariadb|maxscale]) can add up to 9 characters.
Thus, pod-prefix truncated to 43 (63-11-9)
HBP 3.6: w/restriction: <podNamePrefix>-(31)<.Release.Name>-<.Chart.Name>(12)-<resourceSuffix>(190)
*/}}
{{- define "cmdb.pod-prefix" -}}
{{- $podNamePrefix := (.Values.global.podNamePrefix | default "") }}
{{- if and $podNamePrefix (ne (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions .Values.global.disablePodNamePrefixRestrictions false)) "true") -}}
  {{- $podNamePrefix = $podNamePrefix | trunc 31 | trimSuffix "-" }}
  {{- $podNamePrefix = (print $podNamePrefix "-") }}
{{- end }}
{{- printf "%s%s" $podNamePrefix (include "cmdb.fullname" .) | trunc 43 -}}
{{- end -}}

{{- define "cmdb.container-prefix" -}}
{{- printf "%s-" (default "" .Values.global.containerNamePrefix | trunc 34 | trimSuffix "-") | trimPrefix "-" -}}
{{- end -}}

{{/* Utility template for getting custom securityContext Values

See HBP 2.16 - Gets securityContext from .Values via the following structure:

podSecurityContext:
containerSecurityContext:
<val_path>:
  podSecurityContext:
  containerSecurityContext:

Will search into <val_path> first, then top-level, then use defaut for security context, except for the disabled, top level disable everything, yet lower-level disabled:false to override that

Arg: (tuple <scope> pod|container <val_path> <id>)

Output, e.g:
spec.securityContext:
  runAsUser: 1773
  runAsGroup: 1773
  fsGroup: 1773
  runAsNonRoot: true               # HPB_ContainerUser_1
  seccompProfile:                  # HBP_Security_Seccomp_1 (k8s>=1.25.0)
    type: "RuntimeDefault"
spec.container[*].securityContext:
  runAsUser: 1773
  runAsGroup: 1773
  readOnlyFilesystem: true         # HBP_Security_Volume_2
  allowPrivilegeEscalation: false  # HBP_Security_Privilege_2
  capabilites:
    drop: ["ALL"]                  # HBP_Security_Capabilities_1
    add: ["NET_ADMIN", "NET_RAW"]  # k8s>=1.25 istio (no PSP)
*/}}
{{- define "cmdb.get_security_context" -}}
{{- $ctx := first . -}}
{{- $sc_type := printf "%sSecurityContext" (index . 1) -}}
{{- $val_path := index . 2 | splitList "." -}}
{{- $id := index . 3 }}
{{- $Values := index $ctx "Values" -}}
{{- $Capabilities := index $ctx "Capabilities" -}}
{{- $istio_nopsp := and $Values.istio.enabled (not $Values.istio.cni.enabled) (not ($Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy")) -}}
{{- $k8s123 := semverCompare "<=1.23" (include "cmdb.k8sver" $ctx) -}}
{{- $openshift := $Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" -}}

{{/* Setup default securityContext */}}
{{- $default_sc := dict "runAsUser" $id  "runAsGroup" $id -}}
{{- if eq $sc_type "podSecurityContext" -}}
  {{- $_ := set $default_sc "fsGroup" $id -}}
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
{{- $sc := coalesce (index $user_val $sc_type) (index $Values $sc_type) $default_sc -}}
{{- $sc_disable := coalesce (pick (index $user_val $sc_type) "disabled") (pick (index $Values $sc_type) "disabled") -}}
{{- if not $sc_disable.disabled -}}
securityContext: {{- omit $sc "disabled" | toYaml | nindent 2 }}
{{- else -}}
securityContext: {}
{{- end -}}
{{- end }}

{{/*
* Define topology spread constraints

See HBP_Kubernetes_PodTopology_1 / HBP_Kubernetes_PodTopology_2:

<workload name>:
  toplogySpreadConstraints:
    - <topologySpreadConstraint parameters>
      autoGenerateLabelSelector: <boolean>
*/}}
{{- define "cmdb.spread-constraints" -}}
{{- $ctx := first . -}}
{{- $subcomp := index . 1 -}}
{{- $Values := index $ctx "Values" $subcomp -}}
{{- range $index, $item := $Values.topologySpreadConstraints -}}
  -
  {{- omit $item "autoGenerateLabelSelector" | toYaml | nindent 2 }}
{{- if and $item.autoGenerateLabelSelector (not $item.labelSelector) }}
  labelSelector:
    matchLabels:
      app: {{ template "cmdb.fullname" $ctx }}
      release: {{ $ctx.Release.Name | quote }}
      csf-subcomponent: {{ $subcomp }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
* Determine the serviceAccountNames
*/}}
{{/* Admin SA */}}
{{- define "cmdb.sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ include "cmdb.fullname" . }}
automountServiceAccountToken: true
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* MaxScale SA */}}
{{- define "cmdb.maxscale-sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ include "cmdb.fullname" . -}}-maxscale
automountServiceAccountToken: true
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* MariaDB SA (istio-only requires ServiceAccount) */}}
{{- define "cmdb.istio-sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
{{- if and .Values.istio.enabled (not .Values.istio.cni.enabled) }}
serviceAccountName: {{ include "cmdb.fullname" . -}}-istio
{{- else }}
{{/* assign minimal privileges to mariadb statefulset */}}
serviceAccountName: {{ include "cmdb.fullname" . }}-mariadb
{{- end }}
{{- if not .Values.istio.enabled }}
automountServiceAccountToken: false
{{- end }}
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* Pre-install Job SA */}}
{{- define "cmdb.job-preinstall-sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ include "cmdb.fullname" . -}}-install
automountServiceAccountToken: true
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* Minimal Job SA */}}
{{- define "cmdb.job-minimal-sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ include "cmdb.fullname" . -}}-minlcm
automountServiceAccountToken: true
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/* Post-delete Job SA */}}
{{- define "cmdb.job-postdelete-sa" -}}
{{- $user_sa := coalesce .Values.serviceAccountName .Values.global.serviceAccountName -}}
{{- if .Values.rbac.enabled }}
serviceAccountName: {{ include "cmdb.fullname" . -}}-delete
automountServiceAccountToken: true
{{- else if $user_sa }}
serviceAccountName: {{ $user_sa }}
{{- end }}
{{- end }}

{{/*
*  Admin service name for all pods to be able to talk to Admin DB.
*/}}
{{- define "cmdb-admin.service" -}}
{{- if ne (.Values.cluster_type) "simplex" }}
- name: ADMIN_SERVICE_NAME
  value: "{{- default (printf "%s-admin" (include "cmdb.fullname" .)) .Values.services.admin.name }}"
{{- end -}}
{{- end -}}

{{/*
*  Maxscale Listener Service ports
*/}}
{{- /* Primary listener port (based on TLS enabled) */ -}}
{{- define "cmdb-maxscale.listener-port" -}}
{{- $g := first . -}}
{{- $spec := index $g.Values.services.mysql (index . 1) -}}
{{- $use_tls := eq (include "cmdb.tls_enabled" (tuple $g "mariadb")) "true" -}}
{{- if $spec.enabled }}
  {{- ternary (int (first (without (splitList "," (toString $spec.tlsPort)) "0"))) (int (first (without (splitList "," (toString $spec.nonTlsPort)) "0"))) $use_tls | default (index . 2) -}}
{{- end -}}
{{- end -}}

{{- /* Alternate listener port (non-TLS if TLS enabled) */ -}}
{{- define "cmdb-maxscale.listener-alt-port" -}}
{{- $g := first . -}}
{{- $spec := index $g.Values.services.mysql (index . 1) -}}
{{- $use_tls := eq (include "cmdb.tls_enabled" (tuple $g "mariadb")) "true" -}}
{{- if and $spec.enabled $use_tls }}
  {{- int (first (without (splitList "," (toString $spec.nonTlsPort)) "0")) -}}
{{- end -}}
{{- end -}}

{{- /* Listener service ports for mysql service */ -}}
{{- define "cmdb-maxscale.listener-svc-ports" -}}
{{- $g := first . -}}
{{- $listener := index . 1 -}}
{{- $def_port := index . 2 -}}
{{- $type := $g.Values.services.mysql.type -}}
{{- $use_tls := eq (include "cmdb.tls_enabled" (tuple $g "mariadb")) "true" -}}
{{- $spec := index $g.Values.services.mysql $listener -}}
{{- if $spec.enabled }}
  {{- $primary_port := include "cmdb-maxscale.listener-port" . -}}
  {{- $alternate_port := include "cmdb-maxscale.listener-alt-port" . -}}
  {{- $tls_ports := without (splitList "," (toString $spec.tlsPort)) "0" -}}
  {{- $notls_ports := without (splitList "," (toString $spec.nonTlsPort)) "0" -}}
  {{- range $index, $port := (ternary $tls_ports $notls_ports $use_tls | default (list (toString $def_port))) }}
- name: {{ printf "tcp-mysql-%s" $port }}
  port: {{ $port }}
  targetPort: {{ $primary_port }}
  {{- if and (eq $type "NodePort") (ne $spec.nodePort "") -}}
    {{- if gt (len (splitList "," (toString $spec.nodePort))) $index }}
  nodePort: {{ index (splitList "," (toString $spec.nodePort)) $index }}
    {{- end -}}
  {{- end -}}
  {{- end -}}
  {{- range $port := ternary $notls_ports (list) $use_tls }}
- name: {{ printf "tcp-mysql-%s" $port }}
  port: {{ $port }}
  targetPort: {{ $alternate_port }}
  {{- end }}
{{- end }}
{{- end }}

{{- /* Listener container ports for mysql service */ -}}
{{- define "cmdb-maxscale.mysql-listener-ports" -}}
{{- $g := first . -}}
{{- $listener := index . 1 -}}
{{- $def_port := index . 2 -}}
{{- $use_tls := eq (include "cmdb.tls_enabled" (tuple $g "mariadb")) "true" -}}
{{- $spec := index $g.Values.services.mysql $listener -}}
{{- if $spec.enabled }}
  {{- $primary_port := include "cmdb-maxscale.listener-port" . -}}
  {{- $alternate_port := include "cmdb-maxscale.listener-alt-port" . -}}
- containerPort: {{ $primary_port }}
  name: {{ printf "tcp-mysql-%s" $primary_port }}
  {{- if gt (int $alternate_port) 0 }}
- containerPort: {{ $alternate_port }}
  name: {{ printf "tcp-mysql-%s" $alternate_port }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
*  Standard CMDB kubernetes (k8s) environment
*/}}
{{- define "cmdb-k8s.env" -}}
- name: K8S_NAMESPACE
  value: "{{ .Release.Namespace }}"
- name: K8S_LABELS
  value: app={{ template "cmdb.fullname" . }},release={{ .Release.Name }}
- name: K8S_PREFIX
  value: {{ template "cmdb.fullname" . }}
- name: K8S_POD_PREFIX
  value: {{ template "cmdb.pod-prefix" . }}
- name: K8S_CONTAINER_PREFIX
  value: {{ template "cmdb.container-prefix" . }}
- name: K8S_DOMAIN
  value: {{ .Values.clusterDomain }}
- name: ISTIO_ENABLED
  value: "{{ .Values.istio.enabled }}"
- name: ISTIO_STOP_PORT
  value: "{{ default 15000 .Values.global.istio.sidecar.stopPort }}"
- name: ISTIO_HEALTH_PORT
  value: "{{ default (semverCompare "<1.6" .Values.istio.version | ternary 15020 15021) .Values.global.istio.sidecar.healthCheckPort }}"
{{- end -}}

{{/* Utility templates for timezone environment
     HBP: Values.timeZoneEnv has precedence over the global level.
*/}}
{{- define "cmdb-tz.env" -}}
{{- if .Values.timeZoneEnv }}
- name: TZ
  value: {{ .Values.timeZoneEnv | quote }}
{{- else if .Values.global.timeZoneEnv }}
- name: TZ
  value: {{ .Values.global.timeZoneEnv | quote }}
{{- else }}
- name: TZ
  value: "UTC"
{{- end }}
{{- end }}

{{/* Define the Mariadb and Maxscale Database Access svc */}}
{{- define "cmdb-maxscale.db.svc" -}}
{{- $service_value := .Values.services.maxscale -}}
{{- $service_name := $service_value.name | default (printf "%s-maxscale" (include "cmdb.fullname" .)) -}}
{{- $service_name }}.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
{{- end -}}


{{/* Utility templates for filesystem volumeMounts/volume

  To provide writable emptyDir space instead of using
  root filesystem in support of readOnlyRootFilesystem

  Arg: (tuple subsys varlibdir)

*/}}
{{- define "cmdb-fs.vm" -}}
{{- $ctx := first . -}}
{{- $subsys := index . 1 -}}
{{- $libdir := ternary "mysql" $subsys (eq $subsys "mariadb") -}}
- name: fs-tmp
  mountPath: /tmp
- name: fs-etcmariadb
  mountPath: /etc/mariadb
{{- if ne $subsys "admin" }}
- name: fs-etcmycnfd
  mountPath: /etc/my.cnf.d
- name: {{ printf "fs-varlib%s" $libdir }}
  mountPath: {{ printf "/var/lib/%s" $libdir }}
{{- end }}
{{- if eq $subsys "maxscale" }}
- name: fs-etcmaxscalecnfd
  mountPath: /etc/maxscale.cnf.d
{{- end }}
- name: fs-varlibcmdb
  mountPath: /var/lib/cmdb
- name: {{ printf "fs-varlog%s" $subsys }}
  mountPath: {{ printf "/var/log/%s" $subsys }}
- name: fs-etcsupervisord
  mountPath: /etc/supervisord.d
- name: fs-varrunsupervisor
  mountPath: /var/run/supervisor
- name: fs-varlogsupervisor
  mountPath: /var/log/supervisor
{{- end }}

{{- define "cmdb-fs.vol" -}}
{{- $ctx := first . -}}
{{- $subsys := index . 1 -}}
{{- $libdir := ternary "mysql" $subsys (eq $subsys "mariadb") -}}
- name: fs-tmp
  emptyDir: {}
- name: fs-etcmariadb
  emptyDir: {}
{{- if ne $subsys "admin" }}
- name: fs-etcmycnfd
  emptyDir: {}
- name: {{ printf "fs-varlib%s" $libdir }}
  emptyDir: {}
{{- end }}
{{- if eq $subsys "maxscale" }}
- name: fs-etcmaxscalecnfd
  emptyDir: {}
{{- end }}
- name: fs-varlibcmdb
  emptyDir: {}
- name: {{ printf "fs-varlog%s" $subsys }}
  emptyDir: {}
- name: fs-etcsupervisord
  emptyDir: {}
- name: fs-varrunsupervisor
  emptyDir: {}
- name: fs-varlogsupervisor
  emptyDir: {}
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
{{- define "cmdb.dual-stack" -}}
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

{{/* Utility template for HBP_Kubernetes_Pod_res_5
 Return the resources w or w/o limits.cpu
 If limits.cpu is set, use it regardless enableDefaultCpuLimits.
 Otherwise, limits._cpu should be used if enableDefaultCpuLimits is true
 resources:
   requests:
     ...
   limits:
     cpu:
     ...
 Arg: (tuple <scope> <val_path> )
*/}}
{{- define "cmdb.get_resources" -}}
{{- $Values := index (first .) "Values" -}}
{{- $enableCpuLimits := (eq (include "cmdb.coalesceBoolean" (tuple $Values.enableDefaultCpuLimits $Values.global.enableDefaultCpuLimits )) "true")  -}}
{{- $spec := index . 1 -}}
{{- $_ := merge $spec.limits (dict "cpu" ($enableCpuLimits | ternary $spec.limits._cpu "")) -}}
{{- $_ := unset $spec.limits  "_cpu" -}}
{{- if empty $spec.limits.cpu  -}}
{{- $_ := unset $spec.limits  "cpu" -}}
{{- end -}}
{{- toYaml $spec -}}
{{- end -}}
