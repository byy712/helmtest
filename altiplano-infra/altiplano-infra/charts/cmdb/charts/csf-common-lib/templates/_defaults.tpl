{{- define "csf-common-lib.v1._nameLimits_default" -}}
containerNamePrefixMaxLength: 34
resourceNameMaxLength: 253
#Possible max 190, but limited to 40 per HBP
suffixMaxLength: 40
resourceNameWithoutSuffixMaxLength: 63
podNamePrefixMaxLength: 30
podNamePrefixKinds: ["statefulset", "cronjob", "job", "deployment", "daemonset", "pod", "brpolicy"]
customLimits:
- kinds: ["statefulset", "cronjob"]
  resourceNameMaxLength: 52
  suffixMaxLength: 8
- kinds: ["deployment", "daemonset", "job"]
  resourceNameMaxLength: 58
  suffixMaxLength: 14
- kinds: ["service", "pod", "brpolicy"]
  resourceNameMaxLength: 63
  suffixMaxLength: 19
{{- end }}

{{- define "csf-common-lib.v1._nameLimits" -}}
{{- $nameLimits := (include "csf-common-lib.v1._nameLimits_default" .) | fromYaml }}
{{- if and (hasKey .Values "csf-common-lib") (get .Values "csf-common-lib").nameLimits }}
    {{- $customNameLimits := (get .Values "csf-common-lib").nameLimits }}
    {{- $nameLimits = merge $customNameLimits $nameLimits }}
{{- end }}
{{- $nameLimits | toYaml }}
{{- end }}
