{{/*
Generate name with appropriate length and form as defined in a HBP.

Function will use following values if defined:
- `.fullnameOverride`
- `.nameOverride`
- `.global.podNamePrefix`
- `.global.disablePodNamePrefixRestrictions`

Check `Name parts and limits` section for more details.

## Changelog

### [v2]
#### Changed
* handle empty suffix and `.global.disablePodNamePrefixRestrictions`

## Parameters

Three parameters are expected.

* . - root
* kind of object
* suffix - this parameter is optional - suffix will be added to the object,
  note that if suffix length exceed max limit then error will be reported

All parameters need to be grouped in the one tuple.

## Name parts and limits

Resource name parts and max lengths:
----
                             |----------------------------------|
                             | This part is calculated by       |
                             | "csf-common-lib.v2.fullname"     |
                             |----------------------------------|
                             |                                  |
|************************|***|**********************************|***|*******************|
|     podNamePrefix      | - |    Release.Name-Chart.name       | - |       suffix      |
|     podNamePrefix      | - | Release.Name-Values.nameOverride | - |       suffix      |
|     podNamePrefix      | - |     Values.fullnameOverride      | - |       suffix      |
|************************|***|**********************************|***|*******************|
^                        ^                                          ^                   ^
|------------------------|                                          |-------------------|
| podNamePrefixMaxLength |                                          |  suffixMaxLength  |
|------------------------|                                          |-------------------|
^                                                                   ^                   ^
|-------------------------------------------------------------------|                   |
|             resourceNameWithoutSuffixMaxLength                    |                   |
|-------------------------------------------------------------------|                   |
^                                                                                       |
|---------------------------------------------------------------------------------------|
|                                 resourceNameMaxLength                                 |
|---------------------------------------------------------------------------------------|
----

Default limits are defined in `_defaults.tpl` file in `csf-common-lib.v1._nameLimits`
Note that 'just in case' limit constants can be redefined by setting `.nameLimits` in `values.yaml`
For parameters structure see at `csf-common-lib.v1._nameLimits`

## Examples

* Workload (named core) with suffix
** values.yaml
+
----
core:
  nameSuffix: "core"
----
** snippet from a statefulset template
+
----
metadata:
  name: {{ include "csf-common-lib.v2.resourceName" (tuple . "StatefulSet" .Values.core.nameSuffix) }}
----
* Kubernetes object without suffix
** snippet from a configmap template
+
----
metadata:
  name: {{ include "csf-common-lib.v2.resourceName" (tuple . "ConfigMap") }}
----
* Redefine `nameLimits` to behave like a common "<chart>.fullname" template
** disable `podNamePrefix` and do not count `suffix` - which can create too long names
** values.yaml
+
----
csf-common-lib:
  nameLimits:
    resourceNameMaxLength: 253
    suffixMaxLength: 190
    resourceNameWithoutSuffixMaxLength: 63
    podNamePrefixMaxLength: 30
    podNamePrefixKinds: []
    customLimits: []
----
** snippet from a configmap template
+
----
metadata:
  name: {{ include "csf-common-lib.v2.resourceName" (tuple . "ConfigMap") }}
----


## HBP

This is a helper function for:

.HBP_Kubernetes_name_1 of HBP v3.4.0
****
The name of the Kubernetes resource (object) should be in the following format: <.Release.Name>-<.Chart.Name>-<resourceSuffix>.
****

.HBP_Kubernetes_name_3 of HBP v3.4.0
****
Helm chart name used in common labels and in the Kubernetes resource name need to be parameterised in values.yaml as .nameOverride
****

.HBP_Kubernetes_name_4 of HBP v3.4.0
****
The <.Release.Name>-<.Chart.Name> Kubernetes resource name part needs to be parameterised in values.yaml as .fullnameOverride.
****

.HBP_Kubernetes_sts_1 of HBP v3.4.0
****
StatefulSet name should:

* be limited to 52 characters
* follow HBP_Kubernetes_name_1, with <resourceSuffix> part be limited to 8 characters.
****

.HBP_Kubernetes_CronJob_1 of HBP v3.4.0
****
CronJob name should:

* be limited to 52 characters
* follow HBP_Kubernetes_name_1 format, with <resourceSuffix> part be limited to 8 characters.
****

.HBP_Kubernetes_name_5 of HBP v3.4.0
****
Deployment, Job, DaemonSet name should:

* be limited to 58 characters
* follow HBP_Kubernetes_name_1 format, with <resourceSuffix> part limited to 14 characters.
****

.HBP_Kubernetes_Service_5 of HBP v3.4.0
****
Service name should:

* be limited to 63 characters
* follow HBP_Kubernetes_name_1 format, with <resourceSuffix> part limited to 19 characters.
* follow RFC 1035 Label Names restrictions.
****

.HBP_Kubernetes_Pod_5 of HBP v3.4.0
****
Pod name should:

* be limited to 63 characters
* follow HBP_Kubernetes_name_1 format, with <resourceSuffix> part limited to 19 characters.
****

.HBP_Kubernetes_Pod_6 of HBP v3.4.0
****
Pod name prefix must be configurable in the values.yaml file and it must not exceed 30 characters.
Naming convention:
global:
  podNamePrefix: <prefix>
****

.HBP_Kubernetes_Pod_7
****
`Pod` name prefix restrictions introduced in HBP_Kubernetes_Pod_6 must be optional.

Naming convention:
global:
  disablePodNamePrefixRestrictions:
****
*/}}
{{- define "csf-common-lib.v2.resourceName" -}}
{{- $root := index . 0 }}
{{- $kind := index . 1 }}
{{- $suffix := "" }}
{{- if gt (len .) 2 }}
    {{- if eq (include "csf-common-lib.v1.isEmptyValue" (index . 2)) "false" }}
        {{- $suffix = index . 2 | trimPrefix "-" | default "" }}
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
    {{- if not (($root.Values.global | default dict).disablePodNamePrefixRestrictions | default false) }}
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
{{- $fullname := (include "csf-common-lib.v1.fullname" (tuple $root $currentFullnameMaxLength)) }}
{{- print $podNamePrefix $fullname $suffix }}
{{- end }}

{{/*
Simplified version of `csf-common-lib.v2.resourceName`
For more info see description of `csf-common-lib.v2.resourceName`

## Changelog

### [v2]
#### Changed
* handle empty suffix and `.global.disablePodNamePrefixRestrictions`

## Parameters

Two parameters are expected.

* . - root
* workload - dict block containing `_kind` and `nameSuffix`.

## Examples

* Workload named `core`
** values.yaml
+
----
core:
  _kind: "StatefulSet"
  nameSuffix: "core"
----
** snippet from a statefulset template
+
----
metadata:
  name: include "csf-common-lib.v2.workloadName" (tuple . .Values.core)
----
*/}}
{{- define "csf-common-lib.v2.workloadName" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $kind := $workload._kind }}
{{- $suffix := $workload.nameSuffix | default "" }}
{{- include "csf-common-lib.v2.resourceName" (tuple $root $kind $suffix) }}
{{- end }}
