{{/*
Common labels function generates common labels as defined in a HBP.

## Parameters

Two parameters are expected.
* . - root
* name/role of a workload - this parameter is optional

All parameters need to be grouped in the one tuple.

## Examples

* Workload (named echoserver) common labels
** values.yaml
+
----
echoserver:
  name: echoserver
----
** snippet from a deployment template
+
----
metadata:
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.echoserver.name) | indent 4 }}
spec:
  template:
    metadata:
      labels:
        {{- include "csf-common-lib.v1.commonLabels" (tuple . .Values.echoserver.name) | indent 8 }}
----
* Common helm chart object, not related to any workload (e.g. configmap)
** this will skip generation of optional `app.kubernetes.io/component` label
** snippet from a configmap template
+
----
metadata:
  labels:
    {{- include "csf-common-lib.v1.commonLabels" (tuple .) | indent 4 }}
----


## HBP

This is a helper function for:

.HBP_Helm_Labels_1 of HBP v3.0.0
****
Kubernetes objects need to contain the following common labels:

app.kubernetes.io/name
app.kubernetes.io/instance
app.kubernetes.io/component (Optional)
app.kubernetes.io/version (Optional)
app.kubernetes.io/part-of (Optional)
app.kubernetes.io/managed-by
helm.sh/chart
****
*/}}
{{- define "csf-common-lib.v1.commonLabels" -}}
{{- $root := index . 0 }}
helm.sh/chart: {{ include "csf-common-lib.v1.chart" $root }}
{{- if gt (len .) 1 }}
{{- $workloadName := index . 1 }}
{{- include "csf-common-lib.v1.selectorLabels" (tuple $root $workloadName) }}
{{- else }}
{{- include "csf-common-lib.v1.selectorLabels" (tuple $root "") }}
{{- end }}
{{- if $root.Chart.AppVersion }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Values.managedBy | default $root.Release.Service | quote}}
{{- if $root.Values.partOf }}
app.kubernetes.io/part-of: {{ $root.Values.partOf | quote }}
{{- end }}
{{- end }}
