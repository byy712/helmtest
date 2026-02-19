{{/*
Pod topology spread constraints function generates .spec.topologySpreadConstraints content as defined in a HBP.

## Parameters

Two parameters are expected.
* . - root
* a workload block, which contains `topologySpreadConstraints`

All parameters need to be grouped in the one tuple.

## Examples

* Workload (named echoserver) selector labels
** values.yaml
+
----
echoserver:
  # if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block
  # then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key
  topologySpreadConstraints:
#    - maxSkew: 1
#      topologyKey: topology.kubernetes.io/zone
#      whenUnsatisfiable: ScheduleAnyway
#      autoGenerateLabelSelector: True
----
** snippet from a deployment template
+
----
spec:
  template:
    spec:
      {{- if .Values.echoserver.topologySpreadConstraints }}
      topologySpreadConstraints: {{- include "csf-common-lib.v1.topologySpreadConstraints" (tuple . .Values.echoserver) | nindent 8 }}
      {{- end }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_PodTopology_1 of HBP v3.3.0
****
Pod `.spec.topologySpreadConstraints` parameters need to be configurable in the `values.yaml`.
****

and

.HBP_Kubernetes_PodTopology_2 of HBP v3.3.0
****
Naming convention of the `values.yaml` for pod `.spec.topologySpreadConstraints` parameters
```yaml
<workload name>:
  topologySpreadConstraints:
    - <topologySpreadConstraint parameters>
      autoGenerateLabelSelector: <boolean>
```

<topologySpreadConstraint parameters> are defined in Kubernetes documentation, see TopologySpreadConstraint (https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#topologyspreadconstraint-v1-core)
****
*/}}

{{- define "cpro-common-lib.v1.topologySpreadConstraints" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- if $workload.topologySpreadConstraints }}
{{- range $index, $item := $workload.topologySpreadConstraints }}
{{- $autoGenerateLabelSelector := $item.autoGenerateLabelSelector }}
{{- $item := omit $item "autoGenerateLabelSelector" }}
- {{ $item | toYaml | nindent 2 }}
{{- if and (not $item.labelSelector) $autoGenerateLabelSelector }}
  labelSelector:
    matchLabels: {{- include "csf-common-lib.v1.selectorLabels" (tuple $root $workload.name) | indent 6 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}
