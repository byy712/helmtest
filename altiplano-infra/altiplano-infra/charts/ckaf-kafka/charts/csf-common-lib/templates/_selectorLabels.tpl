{{/*
Selector labels function generates common selector labels as defined in a HBP.

## Parameters

Two parameters are expected.
* . - root
* name/role of a workload

All parameters need to be grouped in the one tuple.

Note that this function supports passing "name/role of a workload" parameter as empty string.
But this logic should be used inside a "csf-common-lib.v1.commonLabels" only.

## Examples

* Workload (named echoserver) selector labels
** values.yaml
+
----
echoserver:
  name: echoserver
----
** snippet from a deployment template
+
----
spec:
  selector:
    matchLabels:
      {{- include "csf-common-lib.v1.selectorLabels" (tuple . .Values.echoserver.name) | indent 6 }}
----

## HBP

This is a helper function for:

.HBP_Helm_Labels_3 of HBP v3.0.0
****
Kubernetes workload objects should use the following labels as a label selectors:

app.kubernetes.io/name
app.kubernetes.io/instance
app.kubernetes.io/component
****
*/}}
{{- define "csf-common-lib.v1.selectorLabels" -}}
{{- $root := index . 0 }}
{{- $workloadName := index . 1 }}
app.kubernetes.io/name: {{ include "csf-common-lib.v1.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- if not (empty $workloadName) }}
app.kubernetes.io/component: {{ $workloadName | default $root.Chart.Name }}
{{- end }}
{{- end }}
