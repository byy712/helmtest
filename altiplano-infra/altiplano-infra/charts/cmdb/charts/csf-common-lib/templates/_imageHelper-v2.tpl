{{/*
Function returns requested container image parameter based on requested imageFlavor and imageFlavorPolicy.
It supports "BestMatch" and "Strict" imageFlavorPolicy.
If requested imageFlavor does not match any supported container image tags then function fails.

## Changelog

### [v2]
#### Fixed
* v1 used function outside the csf-common-lib, which makes it unusable.

## Parameters

Five parameters are expected.
* parameter name available in the supportedFlavorMappingList e.g. repository, tag
* supportedFlavorMappingList is a list (must be a list to not lose the order) of objects containing flavor key and any other keys like: tag, repository, etc.
Example:
- flavor: "rocky8"
  tag: "1.28.5-rocky8-nano-20231222"
  repository: "tools/kubectl"
- flavor: "centos7"
  tag: "v1.25.11-nano-20230630"
  repository: "tools/centos/kubectl"
* . - values block, usually `.Values` (with global.imageFlavor and imageFlavor and global.imageFlavorPolicy and imageFlavorPolicy)
* workload - workload dict block (with imageFlavor and imageFlavorPolicy or image.flavor and image.flavorPolicy)
* (optional) container - container dict block (with imageFlavor and imageFlavorPolicy or image.flavor and image.flavorPolicy)

All parameters need to be grouped in the one tuple.

## Examples

* snippet from a imageTag named template
+
----
{{- include "csf-common-lib.v1.imageHelper" (prepend . "tag") }}
----
** values.yaml
+
----
core:
  _imageFlavorMapping:
    - flavor: "rocky8"
      tag: "1.28.5-rocky8-nano-20231222"
      repository: "tools/kubectl"
    - flavor: "centos7"
      tag: "v1.25.11-nano-20230630"
      repository: "tools/centos/kubectl"
  imageFlavor:
  imageFlavorPolicy:
  imageTag:
  imageRepository:
----

## HBP

This is a helper function for:

.HBP_Kubernetes_Pod_2 of HBP v3.7.0
****
Naming convention of the values.yaml for container image flavor.

    global:
        imageFlavor:
    imageFlavor:
    <workload name>:
      image:
        flavor:
[...]
****

.HBP_Kubernetes_Pod_8 of HBP v3.7.0
****
Image flavor should be matched to container image flavor based on imageFlavorPolicy, which can be set to Strict or BestMatch. Naming convention of the values.yaml for container image flavor policy selection method.

    global:
        imageFlavorPolicy:
    imageFlavorPolicy:
    <workload name>:
      image:
        flavorPolicy:
****
*/}}
{{- define "csf-common-lib.v2.imageHelper" -}}
{{- $parameterName := index . 0 }}
{{- $supportedFlavorMappingList := index . 1 }}
{{- $values := index . 2 }}
{{- $workload := index . 3 }}
{{- $container := dict }}
{{- if gt (len .) 4 }}
    {{- $container = index . 4 | default dict }}
{{- end }}
{{- $requestedFlavor := coalesce $container.imageFlavor ($workload.image | default dict).flavor $workload.imageFlavor $values.imageFlavor $values.global.imageFlavor }}
{{- $requestedFlavorPolicy := coalesce $container.imageFlavorPolicy ($workload.image | default dict).flavorPolicy $workload.imageFlavorPolicy $values.imageFlavorPolicy $values.global.imageFlavorPolicy }}
{{- $supportedFlavorList := list }}
{{- $supportedFlavorMappingDict := dict }}
{{- range $_, $supportedFlavorMapping := $supportedFlavorMappingList }}
    {{- $supportedFlavorList = append $supportedFlavorList $supportedFlavorMapping.flavor }}
    {{- $_ := set $supportedFlavorMappingDict $supportedFlavorMapping.flavor $supportedFlavorMapping }}
{{- end -}}
{{- $selectedImageFlavorDict := index $supportedFlavorMappingDict (include "csf-common-lib.v1.imageFlavorOrFail" (tuple $requestedFlavor $supportedFlavorList $requestedFlavorPolicy)) }}
{{- index $selectedImageFlavorDict $parameterName }}
{{- end -}}
