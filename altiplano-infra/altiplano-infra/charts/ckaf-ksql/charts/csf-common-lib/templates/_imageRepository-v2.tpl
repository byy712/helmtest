{{/*
Function returns container image repository based on requested imageFlavor and imageFlavorPolicy.
It supports "BestMatch" and "Strict" imageFlavorPolicy.
If requested imageFlavor does not match any supported container image tags then function fails.
When `.global.flatRegistry` is set to true, then only a container image name is returned (last part of registry).

## Changelog

### [v2]
#### Fixed
* v1 used "csf-common-lib.v1.imageHelper" function, which used function outside the csf-common-lib, which makes it unusable.

## Parameters

Four parameters are expected.
* supportedFlavorMappingList is a list (must be a list to not lose the order) of objects containing flavor and repository keys.
Example:
- flavor: "rocky8"
  repository: "tools/kubectl"
- flavor: "centos7"
  repository: "tools/centos/kubectl"
* . - values block, usually `.Values` (with global.imageFlavor and imageFlavor and global.imageFlavorPolicy and imageFlavorPolicy and .global.flatRegistry)
* workload - workload dict block (with imageFlavor and imageFlavorPolicy or image.flavor and image.flavorPolicy)
* (optional) container - container dict block (with imageFlavor and imageFlavorPolicy or image.flavor and image.flavorPolicy)

All parameters need to be grouped in the one tuple.

## Examples

* snippet from a statefulset template
+
----
image: {{ or .Values.global.registry .Values.global._registry }}/{{ .Values.core.imageRepo | default (include "csf-common-lib.v1.imageRepository" (tuple .Values.core._imageFlavorMapping .Values .Values.core)) }}:{{ .Values.core.imageTag | default (include "csf-common-lib.v1.imageTag" (tuple .Values.core._imageFlavorMapping .Values .Values.core)) }}
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

.HBP_Helm_reloc_3 of HBP v3.5.0
****
Helm chart must support container registries with a flat structure.
Naming convention:

    global:
      flatRegistry: false
****
*/}}
{{- define "csf-common-lib.v2.imageRepository" -}}
{{- $values := index . 1 }}
{{- $selectedRepository := include "csf-common-lib.v2.imageHelper" (prepend . "repository") }}
{{- if ($values.global | default dict).flatRegistry }}
    {{- last (regexSplit "/" $selectedRepository -1) }}
{{- else }}
    {{- $selectedRepository }}
{{- end }}
{{- end -}}
