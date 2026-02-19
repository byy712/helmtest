{{/*
Custom annotations function merges any number of dicts.

## Parameters

Any number of dicts with string key and a string value.
All parameters need to be grouped in the one tuple.
Order is important keys are not overwritten.
Example:
    dict1:
        key1: a
    dict2:
        key1: b

If you pass tuple(.Values.dict1 .Values.dict2) then finally key1 will be "a"
If you pass tuple(.Values.dict2 .Values.dict1) then finally key1 will be "b"

## Examples

* Pass global scoped annotations and workload (named echoserver) annotations
** values.yaml
+
----
global:
  annotations:

echoserver:
  annotations:
----
** snippet from a deployment template (order of passing parameters is important)
+
----
metadata:
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.echoserver.annotations .Values.global.annotations) | indent 4 }}
spec:
  template:
    metadata:
      annotations:
        {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.echoserver.annotations .Values.global.annotations) | indent 8 }}
----
* Pass only global scope annotations (in case of not workload objects like e.g. ConfigMap)
** values.yaml
+
----
global:
  annotations:
----
** snippet from a configmap template
+
----
metadata:
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.global.annotations) | indent 4 }}
----
* Pass global scoped annotations and workload (named core) annotations and old custom annotations
** values.yaml
+
----
global:
  annotations:

custom:
  core:
    annotations:

core:
  annotations:
----
** snippet from a statefulset template (order of passing parameters is important)
+
----
metadata:
  annotations:
    {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.core.annotations .Values.custom.core.annotations .Values.global.annotations) | indent 4 }}
spec:
  template:
    metadata:
      annotations:
        {{- include "csf-common-lib.v1.customAnnotations" (tuple .Values.core.annotations .Values.custom.core.annotations .Values.global.annotations) | indent 8 }}
----

## HBP

This is a helper function for:

.HBP_Helm_Annotations_1 of HBP v3.0.0
****
Kubernetes objects should support global custom annotations defined in the `global.annotations` parameter.
****

.HBP_Helm_Annotations_2 of HBP v3.0.0
****
Kubernetes objects should support custom annotations per each workload defined in the `<workload>.annotations` parameter.
****

.HBP_Helm_Annotations_3 of HBP v3.0.0
****
Kubernetes objects should support custom annotations per each workload defined in the `custom.<workload name>.annotations` parameter.
****

*/}}
{{- define "csf-common-lib.v1.customAnnotations" -}}
{{- include "csf-common-lib.v1.mergeDicts" . }}
{{- end -}}
