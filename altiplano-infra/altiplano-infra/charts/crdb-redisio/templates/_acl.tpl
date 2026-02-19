{{- define "crdb-redisio.values-update-acl" -}}
{{/*

This template manipulates the acl portion of the .Values
Additionally, some checks are performed regarding the acl Values.

It will populate some additional fields into .Values.acl as well as perform the initial
generation of passwords, if needed.

*/}}

{{- range $username, $def := .Values.acl -}}
  {{/* If password set to 'none', reset to b64-encoded nopass */}}
  {{- if eq (default "unset" $def.password) "none" -}}
    {{- $_ := set $def "password" (b64enc "nopass") -}}
  {{- end -}}

  {{/* Check that password is base64-encoded */}}
  {{- if contains "illegal" (default "" $def.password | b64dec) -}}
    {{- fail (printf "Password for user %s [acl.%s.password] not base64-encoded" $username $username) -}}
  {{- end -}}

{{- end }}

{{/* disallow disablement of certain system users */}}
{{- $checks := list -}}
{{/* tools, probe users - never */}}
{{- $checks = append $checks (dict "roles" (list "tools" "probe") "check" true) -}}
{{/* sentinel user - sentinel enabled */}}
{{- $checks = append $checks (dict "roles" (list "sentinel") "check" .sentinel_enabled) -}}
{{/* replication user - server.count > 1 */}}
{{- $checks = append $checks (dict "roles" (list "replication") "check" (gt (int .Values.server.count) 1)) -}}
{{/* metrics user - server.metrics disabled */}}
{{- $checks = append $checks (dict "roles" (list "metrics") "check" ( .Values.server.metrics.enabled )) -}}

{{/* perform checks */}}
{{- range $checks -}}
  {{- if .check -}}
    {{- range .roles -}}
      {{- $username := index $.Values.systemUsers . -}}
      {{- if ne (index (index $.Values.acl $username) "enabled") true -}}
        {{- fail (printf "Cannot disable %s user (%s)" . $username) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Check default user - if enabled and no password, must have protected-mode no in server.confInclude */}}
{{- if (default (dict) .Values.acl.default).enabled -}}
  {{/* Note - will be b64-encoded "nopass" at this point */}}
  {{- $def_acl := .Values.acl.default -}}
  {{- if and (eq (default "" $def_acl.password) (b64enc "nopass")) (not (contains " #" $def_acl.rules)) (not (contains " >" $def_acl.rules)) -}}
    {{- if not (contains "protected-mode no" .Values.server.confInclude) -}}
      {{- fail "server.confInclude must contain 'protected-mode no' if default user enabled without password" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- end -}}

{{/* Gets the actual ACL list (config params) to inject into the Server pods
   * Obtains data from each user credential Secret, if exists, otherwise Values
   * Arg: <scope>
   * Outputs: <acl> (string)
  */}}
{{- define "crdb-redisio.acl" }}
  {{- $top := . -}}
  {{- range $username, $def := $top.Values.acl }}
    {{- if hasKey $def "enabled" | ternary $def.enabled true }}
      {{- $creds := include "crdb-redisio.usercreds.creds" (tuple $top $username) | fromYaml -}}
      {{- $raw_pass := eq "nopass" $creds.password | ternary $creds.password (b64dec $creds.password) -}}
      {{- $pass_entry := eq "nopass" $raw_pass | ternary "nopass" (printf "#%s" (sha256sum $raw_pass)) -}}
      {{- $rules_entry := printf " %s " (b64dec $creds.rules) -}}
      {{/* Don't inject nopass in rules if there's already a password/hash */}}
      {{- if eq "nopass" $pass_entry -}}
        {{- $pass_entry = or (contains " #" $rules_entry) (contains " >" $rules_entry) | ternary "" "nopass" -}}
      {{- end -}}
      {{- $on_entry := (and (not (contains " on " $rules_entry)) (not (contains " off " $rules_entry))) | ternary "on" "" -}}
      {{- printf "user %s %s %s %s\n" $username $on_entry $rules_entry $pass_entry }}
    {{- else if eq $username "default" }}
      {{- /* Special case required to force-disable default user */ -}}
      {{- printf "user %s off\n" $username }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Gets a user-auth line for inclusion in a Secret.
   * Arg: (tuple <scope> <role>)
   * Outputs: "<role>-auth: <b64 <username>:<password>>" (string)
   */}}
{{- define "crdb-redisio.sysuserauth.get" -}}
  {{- $top := first . -}}{{- $role := last . -}}
  {{- $username := index $top.Values.systemUsers $role -}}
  {{- $_ := required (printf "System User with role [%s] not found" $role) $username -}}
  {{- $creds := include "crdb-redisio.usercreds.creds" (tuple $top $username) | fromYaml -}}
  {{- printf "%s-auth: %s\n" $role (printf "%s:%s" (b64dec $creds.username) (b64dec $creds.password) | b64enc) }}
{{- end -}}

{{/* Gets a list of user-auth line(s) for all System-Users for inclusion in a Secret.
   * Arg: <scope>
   * Outputs: "<role>-auth: <b64 <username>:<password>>" (multi-line string)
   */}}
{{- define "crdb-redisio.sysuserauth.all" }}
  {{- $top := . -}}
  {{- range $role, $_ := $top.Values.systemUsers -}}
    {{ include "crdb-redisio.sysuserauth.get" (tuple $top $role) }}
  {{- end }}
{{- end }}

{{/* A checksum of system user names/passwords to detect password-change */}}
{{- define "crdb-redisio.sysuserauth.sum" }}
  {{- include "crdb-redisio.sysuserauth.all" . | sha256sum -}}
{{- end }}
{{/* A checksum of sentinel user names/passwords to detect password-change */}}
{{- define "crdb-redisio.sentineluserauth.sum" }}
  {{- include "crdb-redisio.sysuserauth.get" (tuple . "sentinel") | sha256sum -}}
{{- end }}

{{- define "crdb-redisio.acl.user.probe.env" }}
- name: "CRDB_PROBE_USER"
  value: "{{ .Values.systemUsers.probe }}"
{{- end }}
{{- define "crdb-redisio.acl.user.replication.env" }}
- name: "CRDB_REPLICATION_USER"
  value: "{{ .Values.systemUsers.replication }}"
{{- end }}
{{- define "crdb-redisio.acl.user.sentinel.env" }}
- name: "CRDB_SENTINEL_USER"
  value: "{{ .Values.systemUsers.sentinel }}"
- name: "SENTINEL_ACL_ENABLED"
  value: "{{ .Values.sentinel.acl.enabled }}"
{{- end }}
{{- define "crdb-redisio.acl.user.tools.env" }}
- name: "CRDB_TOOLS_USER"
  value: "{{ .Values.systemUsers.tools }}"
{{- end }}
{{- define "crdb-redisio.acl.user.metrics.env" }}
- name: "CRDB_METRICS_USER"
  value: "{{ .Values.systemUsers.metrics }}"
{{- end }}

{{- define "crdb-redisio.acl.user.all_system.env" }}
{{- range $role, $user := .Values.systemUsers }}
- name: "CRDB_{{ upper $role }}_USER"
  value: "{{ $user }}"
{{- end }}
{{- end }}

{{/* create a sentinel acl entry */}}
{{- define "crdb-redisio.sentinel.acl.sentinel-user" }}
  {{- $username := .Values.systemUsers.sentinel }}
  {{- $creds := include "crdb-redisio.usercreds.creds" (tuple . $username ) | fromYaml -}}
  {{- printf "user %s on %s #%s" $username .Values.sentinel.acl.rules.sentinel (sha256sum (b64dec $creds.password)) }}
{{- end }}

{{- define "crdb-redisio.sentinel.acl.metrics" }}
  {{- $username := .Values.systemUsers.metrics }}
  {{- $creds := include "crdb-redisio.usercreds.creds" (tuple . $username ) | fromYaml -}}
  {{- printf "user %s on %s #%s" $username .Values.sentinel.acl.rules.metrics (sha256sum (b64dec $creds.password)) }}
{{- end }}
