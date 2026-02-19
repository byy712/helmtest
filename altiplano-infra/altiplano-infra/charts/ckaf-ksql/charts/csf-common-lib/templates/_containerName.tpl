{{/*
Generate name with appropriate length and form as defined in a HBP.
Function supports:
- `.global.containerNamePrefix`

## Parameters

Two parameters are expected.

* . - root
* suffix - suffix will be added to the container name,
  note that if suffix length exceed max limit then error will be reported

All parameters need to be grouped in the one tuple.

## Name parts and limits

Container name parts and max lengths:
----
******************************************************************************
*      containerNamePrefix     * - *                 suffix                  *
******************************************************************************
^                              ^   ^                                         ^
|------------------------------|   |-----------------------------------------|
| containerNamePrefixMaxLength |   |         max suffix length               |
|                              |   | (63 - containerNamePrefixMaxLength - 1) |
|------------------------------|   |-----------------------------------------|
^                                                                            ^
|                                                                            |
|----------------------------------------------------------------------------|
|                        max container name is 63                            |
|----------------------------------------------------------------------------|
----

Default limits are defined in `_defaults.tpl` file in `csf-common-lib.v1._nameLimits`
Note that 'just in case' limit constants can be redefined by setting `.nameLimits` in `values.yaml`
For parameters structure see at `csf-common-lib.v1._nameLimits`

## Examples

* snippet from a statefulset template
+
----
spec:
  template:
    spec:
      containers:
        - name: {{ include "csf-common-lib.v1.containerName" (tuple . "core") }}
----
* Redefine `nameLimits`
** values.yaml
+
----
csf-common-lib:
  nameLimits:
    containerNamePrefixMaxLength: 40
----
** snippet from a statefulset template
+
----
spec:
  template:
    spec:
      containers:
        - name: {{ include "csf-common-lib.v1.containerName" (tuple . "core") }}
----


## HBP

This is a helper function for:

.HBP_Kubernetes_Pod_container_2 of HBP v3.4.0
****
The name of the container must have a configurable prefix and be in the following format <containerNamePrefix>-<containerName>. Where <containerNamePrefix> must not exceed 34 characters and be configurable in the values.yaml file.

Naming convention:

global:
  containerNamePrefix: <prefix>
****
*/}}
{{- define "csf-common-lib.v1.containerName" -}}
{{- $root := index . 0 }}
{{- $suffix := index . 1 }}
{{- $nameLimits := (include "csf-common-lib.v1._nameLimits" $root) | fromYaml }}
{{- $containerNamePrefixMaxLength := get $nameLimits "containerNamePrefixMaxLength" | int }}
{{- $containerNameMaxLength := 63 }}
{{- $suffixMaxLength := (sub (sub $containerNameMaxLength $containerNamePrefixMaxLength) 1) }}
{{- $prefix := (($root.Values.global | default dict).containerNamePrefix | default "") | trunc $containerNamePrefixMaxLength | trimSuffix "-" }}
{{- if gt (len $suffix) $suffixMaxLength }}
    {{- fail (print "Container name (" $suffix ") is too long. Limit is " $suffixMaxLength) }}
{{- end }}
{{- if $prefix }}
    {{- (print $prefix "-" $suffix) }}
{{- else }}
    {{- $suffix }}
{{- end }}
{{- end }}
