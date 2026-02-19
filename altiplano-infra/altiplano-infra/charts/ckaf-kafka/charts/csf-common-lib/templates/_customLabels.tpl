{{/*
Custom labels function merges any number of dicts.

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

* Pass global scoped labels and workload (named echoserver) labels
** values.yaml
+
----
global:
  labels:

echoserver:
  labels:
----
** snippet from a deployment template (order of passing parameters is important)
+
----
metadata:
  labels:
    {{- include "csf-common-lib.v1.customLabels" (tuple .Values.echoserver.labels .Values.global.labels) | indent 4 }}
spec:
  template:
    metadata:
      labels:
        {{- include "csf-common-lib.v1.customLabels" (tuple .Values.echoserver.labels .Values.global.labels) | indent 8 }}
----
* Pass only global scope labels (in case of not workload objects like e.g. ConfigMap)
** values.yaml
+
----
global:
  labels:
----
** snippet from a configmap template
+
----
metadata:
  labels:
    {{- include "csf-common-lib.v1.customLabels" (tuple .Values.global.labels) | indent 4 }}
----


## HBP

This is a helper function for:

.HBP_Helm_Labels_5 of HBP v3.0.0
****
Kubernetes objects should support global custom labels defined in the `global.labels` parameter.
****

.HBP_Helm_Labels_6 of HBP v3.0.0
****
Kubernetes objects should support custom labels per each workload defined in the `<workload>.labels` parameter.
****
*/}}
{{- define "csf-common-lib.v1.customLabels" -}}
{{- include "csf-common-lib.v1.mergeDicts" . }}
{{- end -}}
