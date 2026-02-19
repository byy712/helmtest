{{/*
This template is designed to manage and specify the resource limits and requests for Kubernetes resources blocks.
It provides a structured way to define CPU, memory, and ephemeral storage requirements.

## Parameters

Three parameters are expected.
* . - root
* resourcesBlock - container's resources block (dict)
* defaultCpuLimits - Defines a default cpu limits for enableDefaultCpuLimits. For example, "100m", "200m", etc.

## Example

* resourcesBlock (named core.resources)
** code snippet
+
----
{{- $resourcesBlock := .Values.core.resources }}
containers:
  {{- include "csf-common-lib.v1.resourcesContainer" (tuple . $resourcesBlock "50m") | indent 10 }}
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Pod_res_5 of HBP v3.9.0
*/}}
{{- define "csf-common-lib.v1.resourcesContainer" -}}
{{- $root := (index . 0 ) }}
{{- $resourcesBlock := (index . 1 ) }}
{{- $defaultCpuLimits := (index . 2 ) }}

resources:
  limits:
    {{- if $resourcesBlock.limits.cpu }}
    cpu: {{ $resourcesBlock.limits.cpu }}
    {{- else if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits false)) "true" }}
    cpu: {{ $defaultCpuLimits }}
    {{- end }}
    memory: {{ $resourcesBlock.limits.memory }}
    ephemeral-storage: {{ index $resourcesBlock.limits "ephemeral-storage" }}
  requests:
    cpu: {{ $resourcesBlock.requests.cpu }}
    memory: {{ $resourcesBlock.requests.memory }}
    ephemeral-storage: {{ index $resourcesBlock.requests "ephemeral-storage" }}
{{- end }}
