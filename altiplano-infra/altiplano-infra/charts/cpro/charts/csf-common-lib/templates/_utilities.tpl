{{/*
Strip out additional labels like pre-release and build metadata from Kubernetes version
and return version in format: MAJOR.MINOR.PATCH

Note that additional labels to semver are added by some Kubernetes, examples:
* EKS -> v1.23.13-eks-fb459a0
* OCP -> v1.23.5+70fb84c

`semverCompare` handles incorrectly Kubernetes version on EKS.

## Parameters

One parameter is expected.
* . - root - Kubernetes version using `.Capabilities.KubeVersion.Version` is read from this parameter

## Examples

----
{{- $isKubernetesVersionUsedByOpenShiftPre4_11 := semverCompare "<=1.23" (include "csf-common-lib.v1.kubeVersion" $root) }}
----
*/}}
{{- define "csf-common-lib.v1.kubeVersion" -}}
{{- include "csf-common-lib.v1._kubeVersion" .Capabilities.KubeVersion.Version -}}
{{- end -}}

{{- define "csf-common-lib.v1._kubeVersion" -}}
{{- default . (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .) -}}
{{- end -}}
