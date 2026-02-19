{{/* Coalesces credentials Secret name for a user, using:
   * credentialName, secretName (compatibility), "<fullname>-creds-<username>"
   * Arg: (tuple <scope> <username>)
   * Outputs: <secret_name>
*/}}
{{- define "crdb-redisio.usercreds.secretname" -}}
  {{- $top := first . -}}{{- $user := last . -}}
  {{- $user_val := index $top.Values.acl $user -}}
  {{- coalesce $user_val.credentialName $user_val.secretName (include "csf-common-lib.v3.resourceName" (tuple $top "secret" (printf "creds-%s" $user))) -}}
{{- end -}}

{{/* Lookup credentials Secret for a user
   * Arg: (tuple <scope> <username>)
   * Outputs: lookup results (JSON)
*/}}
{{- define "crdb-redisio.usercreds.secretlookup" -}}
  {{- $top := first . -}}{{- $user := last . -}}
  {{- $secret_name := include "crdb-redisio.usercreds.secretname" . -}}
  {{- lookup "v1" "Secret" $top.Release.Namespace $secret_name | toJson -}}
{{- end -}}

{{/* Determines if credentials Secret is external (e.g., unmanaged by this chart)
   * Uses the app.kubernetes.io/name label compared to name
   * Arg: (tuple <scope> <secretname>)
   * Outputs: true if found and not-managed, nil otherwise
 */}}
{{- define "crdb-redisio.usercreds.secretexternal" -}}
  {{- $top := first . -}}{{- $user := last . -}}
  {{- $existing := include "crdb-redisio.usercreds.secretlookup" . | fromJson -}}
  {{- if $existing -}}
    {{/* Set empty dict of labels, in case none specified */}}
    {{- $_ := merge $existing (dict "metadata" (dict "labels" (dict))) -}}
    {{- $l_key := "app.kubernetes.io/name" -}}
    {{- $l_value := include "crdb-redisio.name" $top -}}
    {{- if ne (index $existing.metadata.labels $l_key | default "") $l_value -}}true{{- end -}}
  {{- end -}}
{{- end -}}

{{/* Gets user credentials from an existing Secret or Values.acl
   * Arg: (tuple <scope> <username>)
   * Outputs (yaml) (all b64):
   * username: <username>
   * password: <password>
   * rules: <rules>
   * NOTE: password is b64-encoded 'nopass' if user without password
 */}}
{{- define "crdb-redisio.usercreds.creds" -}}
  {{- $top := first . -}}{{- $user := last . -}}

  {{/* Temporary cache for generated passwords for later access */}}
  {{/* As top-level, should not result in being saved in Values of stored release */}}
  {{- $_ := merge $top (dict "_pwCache" (dict)) -}}

  {{- $user_val := index $top.Values.acl $user -}}
  {{- $existing := include "crdb-redisio.usercreds.secretlookup" . | fromJson -}}

  {{/* Special lookup to find old default pass, if default user was stored as system user, Ref: CSFS-38808 */}}
  {{- if (and (eq $user "default") (not $user_val.password) (has $user (values $top.Values.systemUsers))) -}}
    {{- $_old_secret_name := include "csf-common-lib.v3.resourceName" (tuple $top "secret" "redis-secrets") -}}
    {{- $_old_secret := lookup "v1" "Secret" $top.Release.Namespace $_old_secret_name -}}
    {{- range $k, $v := (default (dict) $_old_secret.data) -}}
      {{- if hasSuffix "-auth" $k -}}
        {{- $_auth_item := $v | b64dec | splitn ":" 2 -}}
        {{- if (and (eq $_auth_item._0 "default") $_auth_item._1) -}}
          {{- $_ := set $user_val "password" (b64enc $_auth_item._1) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $existing_data := default (dict) $existing.data -}}
  {{/* If managed Secret, then Values serve as source for rules/password; otherwise Secret*/}}
  {{- $is_managed := empty (include "crdb-redisio.usercreds.secretexternal" (tuple $top $user)) -}}
  {{- $rules_b64 := $is_managed | ternary (b64enc $user_val.rules) $existing_data.rules -}}
  {{- $pass_b64 := $is_managed | ternary (coalesce $user_val.password $existing_data.password (index $top._pwCache $user) (b64enc (randAlphaNum 64))) $existing_data.password -}}
  {{/* Save password in cache in case it was generated */}}
  {{- $_ := set $top._pwCache $user $pass_b64 -}}
  username: {{ b64enc $user }}
  password: {{ $pass_b64 }}
  rules: {{ required (printf "Rules not found for user (%s) in values." $user) $rules_b64 }}
{{- end -}}
