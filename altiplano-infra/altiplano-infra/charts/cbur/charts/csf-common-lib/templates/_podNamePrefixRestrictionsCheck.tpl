{{/*
Verifies that global.podNamePrefix meets restrictions.
If does not, helm operation will fail.

## Parameters

One parameter is expected.
* . - root


## Examples

* Create separate file e.g. `templates/input-data-validation.yaml` or use it inside "init" function.
** code snippet
+
----
{{- include "csf-common-lib.v1.podNamePrefixRestrictionsCheck" . }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Pod_6 of HBP v3.4.0
****
Pod name prefix must be configurable in the values.yaml file and it must not exceed 30 characters.
Naming convention:
global:
  podNamePrefix: <prefix>
****

.HBP_Kubernetes_Pod_7 of HBP v3.7.0
****
`Pod` name prefix restrictions introduced in HBP_Kubernetes_Pod_6 must be optional.

Naming convention:
global:
  disablePodNamePrefixRestrictions:
disablePodNamePrefixRestrictions:
****

*/}}
{{- define "csf-common-lib.v1.podNamePrefixRestrictionsCheck" -}}
{{- $nameLimits := (include "csf-common-lib.v1._nameLimits" .) | fromYaml }}
{{- $podNamePrefix := ((.Values.global | default dict).podNamePrefix | default "") }}
{{- if and $podNamePrefix (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.disablePodNamePrefixRestrictions (default (.Values.global | default dict).disablePodNamePrefixRestrictions) false)) "false") }}
    {{- $podNamePrefixMaxLength := (get $nameLimits "podNamePrefixMaxLength") | int }}
    {{- if or (gt (len ($podNamePrefix | trimSuffix "-")) $podNamePrefixMaxLength) (not (hasSuffix "-" $podNamePrefix)) }}
        {{- fail (print "'global.podNamePrefix' do not meet restrictions, it should be less than " $podNamePrefixMaxLength " and end with a '-'. Try to disable new 'podNamePrefix' restrictions by setting 'disablePodNamePrefixRestrictions' to true.") }}
    {{- end }}
{{- end }}
{{- end }}