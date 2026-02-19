{{/*
podAntiAffinity function generates .spec.affinity.podAntiAffinity content as defined in a HBP.

## Changelog

### [v3]
#### Changed
* Add support for namespaces list and namespaceSelector
* Add `customMatchLabels` argument to pass custom `labelselectors`

### [v2]
#### Changed
* discontinued used of "and" function for better compatibility with older helm versions

## Parameters
Three parameters are expected.
* . - root
* workload - workload dict block
* basePodAntiAffinity - (optional) we cas pass the old `podAntiAffinity` and it would merge with new `podAntiAffinity`
                        generated in this funcition.

All parameters need to be grouped in the one tuple.

## Examples

* Workload (named core) selector labels
** values.yaml
+
----
core:
  # if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block
  # then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key
  # if labelSelector is provided and autoGenerateLabelSelector is set to true, then value from labelSelector is used
  podAntiAffinity:
    zone:
      type: hard
      topologyKey: "topology.kubernetes.io/zone"

    node:
      type: soft
      topologyKey: "kubernetes.io/hostname"

    customRules:
     - type: soft
       topologyKey: "kubernetes.io/whatever"
       weight: 90
       autoGenerateLabelSelector: true
----
** snippet from a StatefulSet template
+
----
spec:
  template:
    spec:
      affinity: {{- include "csf-common-lib.v3.podAntiAffinity" (tuple . .Values.core) | nindent 8}}
----

** snippet from a Deployment template
+
----
spec:
  template:
    spec:
      {{- if .Values.affinity }}
      affinity:
        {{- if omit .Values.affinity "podAntiAffinity" }}
          {{- omit .Values.affinity "podAntiAffinity" | toYaml | nindent 8}}
        {{- end }}
      {{- else}}
      affinity:
      {{- end}}
      {{- if .Values.echoserver.podAntiAffinity}}
      {{- include "csf-common-lib.v3.podAntiAffinity" (tuple . .Values.echoserver (.Values.affinity | default dict).podAntiAffinity) | indent 8}}
      {{- end }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_affinity_1 of HBP v3.8.0
****
Pod `.spec.affinity.podAntiAffinity` parameters need to be configurable in the `values.yaml`.
****

and

.HBP_Kubernetes_affinity_2
****
Naming convention of the `values.yaml` for pod `.spec.podAntiAffinity` parameters
****
```yaml
  <workload name>:
    podAntiAffinity:
      zone:
        #Possible options: soft/hard/none
        type: soft
        topologyKey: "topology.kubernetes.io/zone"
      node:
        #Possible options: soft/hard/none
        type: soft
        topologyKey: "kubernetes.io/hostname"
      customRules:
        #- type: soft/hard (by default soft)
        #  topologyKey:
        #  weight: 100 (by default 100)
        #  autoGenerateLabelSelector: true
        #  labelSelector: <pod labels> (none by default)
        #  namespaceSelector: <namespace labels> (none by default)
        #  namespaces:
```

*/}}
{{- define "csf-common-lib.v3.podAntiAffinity" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $basePodAntiAffinity := dict }}
{{- $customMatchLabels := dict }}
{{- if gt (len . ) 2 }}
{{- $basePodAntiAffinity = index . 2 }}
{{- end }}
{{- if gt (len . ) 3 }}
{{- $customMatchLabels = index . 3 }}
{{- end }}


{{- $podAntiAffinity := $workload.podAntiAffinity }}
{{- if $podAntiAffinity }}
{{- $zoneType := "none" }}
{{- $zoneTopologyKey := "topology.kubernetes.io/zone" }}
{{- if $podAntiAffinity.zone }}
    {{- $zoneType = $podAntiAffinity.zone.type | default "none" }}
    {{- $zoneTopologyKey = $podAntiAffinity.zone.topologyKey | default "topology.kubernetes.io/zone" }}
{{- end }}

{{- $nodeType := "none" }}
{{- $nodeTopologyKey := "kubernetes.io/hostname" }}
{{- if $podAntiAffinity.node }}
    {{- $nodeType = $podAntiAffinity.node.type | default "none" }}
    {{- $nodeTopologyKey = $podAntiAffinity.node.topologyKey | default "kubernetes.io/hostname" }}
{{- end }}

{{- $matchLabels := dict }}
{{- if $customMatchLabels }}
{{- $matchLabels = $customMatchLabels }}
{{- else }}
{{- $matchLabels = include "csf-common-lib.v1.selectorLabels" (tuple $root $workload.name) }}
{{- end }}

{{- $requiredList := list }}
{{- $prefferedList := list }}

{{- if $basePodAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution }}
{{- range $rule := $basePodAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution }}
{{- $requiredList = append $requiredList $rule }}
{{- end }}
{{- end }}
{{- if $basePodAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution }}
{{- range $rule := $basePodAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution }}
{{- $prefferedList = append $prefferedList $rule }}
{{- end }}
{{- end }}

{{- if eq $zoneType "hard" }}
{{- $newElement := dict "topologyKey" $zoneTopologyKey "labelSelector" (dict "matchLabels" ($matchLabels | fromYaml))  }}
{{- $requiredList = append $requiredList $newElement }}
{{- else if eq $zoneType "soft" }}
{{- $newElement := dict "weight" 50 "podAffinityTerm" (dict "topologyKey" $zoneTopologyKey "labelSelector" (dict "matchLabels" ($matchLabels | fromYaml))) }}
{{- $prefferedList = append $prefferedList $newElement }}
{{- else if eq $zoneType "none" }}
{{- else if $zoneType }}
{{ fail (printf "Invalid zoneType [%s] specified" $zoneType) }}
{{- end }}

{{- if eq $nodeType "hard" }}
{{- $newElement := dict "topologyKey" $nodeTopologyKey "labelSelector" (dict "matchLabels" ($matchLabels | fromYaml)) }}
{{- $requiredList = append $requiredList $newElement }}
{{- else if eq $nodeType "soft" }}
{{- $newElement := dict "weight" 100 "podAffinityTerm" (dict "topologyKey" $nodeTopologyKey "labelSelector" (dict "matchLabels" ($matchLabels | fromYaml))) }}
{{- $prefferedList = append $prefferedList $newElement }}
{{- else if eq $nodeType "none" }}
{{- else if  $nodeType }}
{{ fail (printf "Invalid nodeType [%s] specified" $nodeType) }}
{{- end }}

{{- range $rule := $podAntiAffinity.customRules }}
    {{- $newElement := dict }}
    {{- $type := $rule.type | default "soft" }}
    {{- $weight := $rule.weight | default 100 }}
    {{- $labels := dict }}
    {{- if $rule.labelSelector }}
        {{- if kindIs "string" $rule.labelSelector }}
            {{- if tpl $rule.labelSelector $root }}
                {{- $labels = tpl $rule.labelSelector $root | fromYaml }}
            {{- end }}
        {{- else }}
        {{- $orginalLabels := $rule.labelSelector }}
        {{- range  $key, $val := $orginalLabels }}
        {{- $labels = set $labels $key (tpl $val $root) }}
        {{- end }}
        {{- end }}
    {{- else if $rule.autoGenerateLabelSelector}}
        {{- $labels = $matchLabels | fromYaml }}
    {{- end }}
    {{- if eq $type "hard" }}
    {{- $newElement = set $newElement "topologyKey" $rule.topologyKey }}
    {{- $newElement = set $newElement "labelSelector" (dict "matchLabels" $labels) }}
    {{- /* namespaceSelector is available as alpha feature from 1.21 and stable from 1.24 */}}
    {{- if semverCompare ">=1.21" (include "csf-common-lib.v1.kubeVersion" $root) }}
        {{- if hasKey $rule "namespaceSelector" }}
            {{- $newElement = set $newElement "namespaceSelector" $rule.namespaceSelector }}
        {{- end }}
    {{- end }}
    {{- if hasKey $rule "namespaces" }}
        {{- $newElement = set $newElement "namespaces" $rule.namespaces }}
    {{- end }}
    {{- $requiredList = append $requiredList $newElement }}
    {{- else if eq $type "soft" }}
    {{- $newElement = set $newElement "weight" $weight}}
    {{- $newElement = set $newElement "podAffinityTerm" (dict "topologyKey" $rule.topologyKey "labelSelector" (dict "matchLabels" $labels))}}
    {{- /* namespaceSelector is available as alpha feature from 1.21 and stable from 1.24 */}}
    {{- if semverCompare ">=1.21" (include "csf-common-lib.v1.kubeVersion" $root) }}
        {{- if hasKey $rule "namespaceSelector" }}
            {{- $newElement = mergeOverwrite $newElement (dict "podAffinityTerm" (dict "namespaceSelector" $rule.namespaceSelector)) }}
        {{- end }}
    {{- end }}
    {{- if hasKey $rule "namespaces" }}
        {{- $newElement = mergeOverwrite $newElement (dict "podAffinityTerm" (dict "namespaces" $rule.namespaces)) }}
    {{- end }}
    {{- $prefferedList = append $prefferedList $newElement }}
    {{- else if eq $type "none" }}
    {{- else if $type }}
    {{ fail (printf "Invalid type [%s] specified" $type) }}
    {{- end }}
{{- end }}

{{- if or (gt (len $requiredList) 0) (gt (len $prefferedList) 0) }}
podAntiAffinity:
{{- end }}

{{- if gt (len $requiredList) 0 }}
  requiredDuringSchedulingIgnoredDuringExecution:
  {{- $requiredList | toYaml | nindent 4 }}
{{/* \n */}}
{{- end }}
{{- if gt (len $prefferedList) 0 }}
  preferredDuringSchedulingIgnoredDuringExecution:
  {{- $prefferedList | toYaml | nindent 4 }}
{{/* \n */}}
{{- end }}

{{- end }}
{{- end }}