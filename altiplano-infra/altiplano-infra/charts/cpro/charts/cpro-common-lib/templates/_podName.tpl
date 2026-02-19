##Examples

* Workload (named core)
** code snippet
+
----
{{- template "cpro-common-lib.podnameprefix" ( tuple . "kind" .Values.workloadName "suffix") }}
----


{{- define "cpro-common-lib.podnameprefix" -}}
{{- $root := index . 0 }}
{{- $kind := index . 1 }}
{{- $workload := index . 2 }}
{{- $suffix := "" }}
{{- if gt (len .) 3 }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" (index . 3)) "false" }}
        {{- $suffix = index . 3 | trimPrefix "-" | default "" }}
    {{- end }}
{{- end }}
{{- $customResourceName := "" }}
{{- if gt (len .) 4 }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" (index . 4)) "false" }}
        {{- $customResourceName = index . 4 | trimAll "-" | default "" }}
    {{- end }}
{{- end }}
{{- $nameLimits := (include "csf-common-lib.v1._nameLimits" $root) | fromYaml }}
{{- $suffixMaxLength := get $nameLimits "suffixMaxLength" | int }}
{{- $resourceNameMaxLength := get $nameLimits "resourceNameMaxLength" | int }}
{{- $podNamePrefixMaxLength := (get $nameLimits "podNamePrefixMaxLength") | int }}
{{- $resourceNameWithoutSuffixMaxLength := (get $nameLimits "resourceNameWithoutSuffixMaxLength") | int }}
{{- $podNamePrefix := "" }}
{{- if has (lower $kind) (get $nameLimits "podNamePrefixKinds") }}
    {{- $podNamePrefix = (($root.Values.global | default dict).podNamePrefix | default "") }}
    {{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.disablePodNamePrefixRestrictions (default ($root.Values.global | default dict).disablePodNamePrefixRestrictions) false)) "false" }}
        {{- $podNamePrefix = $podNamePrefix | trunc $podNamePrefixMaxLength  | trimSuffix "-" }}
        {{- if $podNamePrefix }}
            {{- $podNamePrefix = (print $podNamePrefix "-") }}
        {{- end }}
    {{- end }}
{{- end }}
{{- range (get $nameLimits "customLimits") }}
    {{- if has (lower $kind) .kinds }}
        {{- $suffixMaxLength = int .suffixMaxLength }}
        {{- $resourceNameMaxLength = int .resourceNameMaxLength }}
    {{- end }}
{{- end }}
{{- if gt (len $suffix) $suffixMaxLength }}
    {{- fail (print "Suffix (" $suffix ") is too long. Limit for " $kind " is " $suffixMaxLength) }}
{{- end }}
{{- if $suffix }}
    {{- $suffix = (print "-" $suffix) }}
{{- end }}
{{- $currentFullnameMaxLength := (sub $resourceNameMaxLength (len $suffix)) | int }}
{{- if gt $currentFullnameMaxLength $resourceNameWithoutSuffixMaxLength }}
    {{- $currentFullnameMaxLength = $resourceNameWithoutSuffixMaxLength }}
{{- end }}
{{- $currentFullnameMaxLength = (sub $currentFullnameMaxLength (len $podNamePrefix)) | int }}
{{- $fullname := "" }}
{{- if $customResourceName }}
    {{- $fullname = $customResourceName | trunc $currentFullnameMaxLength | trimSuffix "-" }}
{{- else }}
    {{- $fullname = include "cpro-common-lib.v1.fullname" (tuple $root $workload $currentFullnameMaxLength) }}
{{- end }}
{{- print $podNamePrefix $fullname $suffix }}
{{- end }}

{{- define "cpro-common-lib.v1.fullname" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $limit := 63 }}
{{- if gt (len .) 2 }}
    {{- $limit = index . 2 }}
{{- end }}
{{- if $workload.fullnameOverride }}
{{- $workload.fullnameOverride | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- $name := default $root.Chart.Name $root.Values.nameOverride }}
{{- if contains $name $root.Release.Name }}
{{- $root.Release.Name | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $root.Release.Name $name | trunc $limit | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Below cpro-common-lib.podnameprefix-v2 and fullname-v2 functions are for vmalert and vmcluster as implementation on fullnamveroverride and nameoverride is different from other charts and both are taking from workload level.
*/}}
{{- define "cpro-common-lib.podnameprefix-v2" -}}
{{- $root := index . 0 }}
{{- $kind := index . 1 }}
{{- $workload := index . 2 }}
{{- $suffix := "" }}
{{- if gt (len .) 3 }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" (index . 3)) "false" }}
        {{- $suffix = index . 3 | trimPrefix "-" | default "" }}
    {{- end }}
{{- end }}
{{- $customResourceName := "" }}
{{- if gt (len .) 4 }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" (index . 4)) "false" }}
        {{- $customResourceName = index . 4 | trimAll "-" | default "" }}
    {{- end }}
{{- end }}
{{- $nameoverridelevel := index . 5 }}
{{- $nameLimits := (include "csf-common-lib.v1._nameLimits" $root) | fromYaml }}
{{- $suffixMaxLength := get $nameLimits "suffixMaxLength" | int }}
{{- $resourceNameMaxLength := get $nameLimits "resourceNameMaxLength" | int }}
{{- $podNamePrefixMaxLength := (get $nameLimits "podNamePrefixMaxLength") | int }}
{{- $resourceNameWithoutSuffixMaxLength := (get $nameLimits "resourceNameWithoutSuffixMaxLength") | int }}
{{- $podNamePrefix := "" }}
{{- if has (lower $kind) (get $nameLimits "podNamePrefixKinds") }}
    {{- $podNamePrefix = (($root.Values.global | default dict).podNamePrefix | default "") }}
    {{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.disablePodNamePrefixRestrictions (default ($root.Values.global | default dict).disablePodNamePrefixRestrictions) false)) "false" }}
        {{- $podNamePrefix = $podNamePrefix | trunc $podNamePrefixMaxLength  | trimSuffix "-" }}
        {{- if $podNamePrefix }}
            {{- $podNamePrefix = (print $podNamePrefix "-") }}
        {{- end }}
    {{- end }}
{{- end }}
{{- range (get $nameLimits "customLimits") }}
    {{- if has (lower $kind) .kinds }}
        {{- $suffixMaxLength = int .suffixMaxLength }}
        {{- $resourceNameMaxLength = int .resourceNameMaxLength }}
    {{- end }}
{{- end }}
{{- if gt (len $suffix) $suffixMaxLength }}
    {{- fail (print "Suffix (" $suffix ") is too long. Limit for " $kind " is " $suffixMaxLength) }}
{{- end }}
{{- if $suffix }}
    {{- $suffix = (print "-" $suffix) }}
{{- end }}
{{- $currentFullnameMaxLength := (sub $resourceNameMaxLength (len $suffix)) | int }}
{{- if gt $currentFullnameMaxLength $resourceNameWithoutSuffixMaxLength }}
    {{- $currentFullnameMaxLength = $resourceNameWithoutSuffixMaxLength }}
{{- end }}
{{- $currentFullnameMaxLength = (sub $currentFullnameMaxLength (len $podNamePrefix)) | int }}
{{- $fullname := "" }}
{{- if $customResourceName }}
    {{- $fullname = $customResourceName | trunc $currentFullnameMaxLength | trimSuffix "-" }}
{{- else }}
    {{- $fullname = include "cpro-common-lib.fullname-v2" (tuple $root $workload $currentFullnameMaxLength $nameoverridelevel) }}
{{- end }}
{{- print $podNamePrefix $fullname $suffix }}
{{- end }}

{{- define "cpro-common-lib.fullname-v2" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $limit := 63 }}
{{- if gt (len .) 2 }}
    {{- $limit = index . 2 }}
{{- end }}
{{- $nameoverridelevel := index . 3 }}
{{- if $workload.fullnameOverride }}
{{- $workload.fullnameOverride | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- $name := default $root.Chart.Name $nameoverridelevel.nameOverride }}
{{- if contains $name $root.Release.Name }}
{{- $root.Release.Name | trunc $limit | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $root.Release.Name $name | trunc $limit | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

