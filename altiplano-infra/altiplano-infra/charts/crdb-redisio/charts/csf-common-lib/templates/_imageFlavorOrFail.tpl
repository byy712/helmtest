{{/*
Function returns the selected imageFlavor from a given container imageFlavor list based on the requested imageFlavor.
It supports "BestMatch" and "Strict" imageFlavorPolicy.
If requested imageFlavor does not match any supported container image tags then function fails.

## Parameters

Three parameters are expected.
* requested imageFlavor
* container imageFlavor list
* (optional) imageFlavorPolicy

All parameters need to be grouped in the one tuple.

## Examples

* snippet from a _helper.tpl template which use csf-common-lib.v1.imageFlavorOrFail to get selected image flavor
+
----
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $imageFlavor := coalesce $workload.imageFlavor $root.imageFlavor $root.global.imageFlavor }}
{{- $imageFlavorPolicy := coalesce $workload.imageFlavorPolicy $root.imageFlavorPolicy $root.global.imageFlavorPolicy }}
{{- $selectedImageFlavor := include "csf-common-lib.v1.imageFlavorOrFail" (tuple $imageFlavor (list "rocky8" "centos8") $imageFlavorPolicy) }}
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
{{- define "csf-common-lib.v1.imageFlavorOrFail" -}}
{{- $requestedFlavor := lower (index . 0)  }}
{{- $containerFlavorsList := index . 1  }}
{{- $supportedFlavorPoliciesList := (list "BestMatch" "Strict") }}
{{- $flavorPolicy := "BestMatch" }}
{{- if gt (len .) 2 }}
    {{- $flavorPolicy = index . 2 | default $flavorPolicy }}
    {{- if not (has $flavorPolicy $supportedFlavorPoliciesList) }}
        {{- fail (print "None of the container image flavor policies " $supportedFlavorPoliciesList " match requested imageFlavorPolicy \"" $flavorPolicy "\".") }}
    {{- end }}
{{- end }}
{{- if not $requestedFlavor }}
    {{- first $containerFlavorsList }}
{{- else }}
    {{- if eq $flavorPolicy "Strict" }}
        {{- if has $requestedFlavor $containerFlavorsList }}
            {{- $requestedFlavor }}
        {{- else }}
            {{- fail (print "None of the container image flavors " $containerFlavorsList " match requested imageFlavor \"" $requestedFlavor "\". Consider using \"BestMatch\" imageFlavorPolicy.") }}
        {{- end }}
    {{- end }}
    {{- if eq $flavorPolicy "BestMatch" }}
        {{- /* filter by OS */}}
        {{- $requestedOsFlavor := first (regexSplit "-" $requestedFlavor -1) }}
        {{- $osMatchingContainerFlavorsList := list }}
        {{- range $containerFlavor := $containerFlavorsList }}
            {{- $containerOsFlavor := first (regexSplit "-" $containerFlavor -1) }}
            {{- if or (eq $containerOsFlavor $requestedOsFlavor) (eq $containerOsFlavor "distroless") }}
                {{- $osMatchingContainerFlavorsList = append $osMatchingContainerFlavorsList $containerFlavor }}
            {{- end }}
        {{- end }}
        {{- if not $osMatchingContainerFlavorsList }}
            {{- fail (print "None of the container image flavors match \"" $requestedOsFlavor "\" OS flavor of requested imageFlavor \"" $requestedFlavor "\". All supported container images: \"" $containerFlavorsList "\".") }}
        {{- end }}

        {{- /* filter by Runtimes */}}
        {{- /* At the moment flavors have no overlapping names, so for simplicity we can just search in strings.
               To easy understand the code comments base on the example, where:
                 - $requestedFlavor is 'centos8-jdk17-python3'
                 - $containerFlavor is 'centos8-python3.8' */}}
        {{- $requestedEnvFlavorsList := rest (regexSplit "-" $requestedFlavor -1) }}
        {{- $notMatchingContainerFlavorsList := list }}
        {{- range $containerFlavor := $osMatchingContainerFlavorsList }}
            {{- /* 'centos8-python3.8' -> '-python3.8-' */}}
            {{- $containerEnvFlavorsWithDashes := print "-" (trimPrefix $requestedOsFlavor $containerFlavor | trimPrefix "-") "-" }}
            {{- range $requestedEnvFlavor := $requestedEnvFlavorsList }}
                {{- /* iteration 1: 'jdk17' -> 'jdk' */}}
                {{- /* iteration 2: 'python3' -> 'python' */}}
                {{- $requestedEnvTypeFlavor := regexReplaceAll "[0-9.]*$" $requestedEnvFlavor "" }}
                {{- /* iteration 1: contains '-jdk' '-python3.8-' */}}
                {{- /* iteration 2: contains '-python' '-python3.8-' */}}
                {{- $containerFlavorContainsRequestedEnvType := contains (print "-" $requestedEnvTypeFlavor) $containerEnvFlavorsWithDashes }}
                {{- /* iteration 1: contains '-jdk17-' '-python3.8-' */}}
                {{- /* iteration 2: contains '-python3-' '-python3.8-' */}}
                {{- $containerFlavorContainsRequestedEnv := contains (print "-" $requestedEnvFlavor "-") $containerEnvFlavorsWithDashes }}
                {{- /* iteration 1: regexMatch '-jdk17.[0-9.]+-' '-python3.8-' */}}
                {{- /* iteration 2: regexMatch '-python3.[0-9.]+-' '-python3.8-' */}}
                {{- $containerFlavorContainsRequestedEnvBaseVersion := regexMatch (print "-" $requestedEnvFlavor "[.][0-9.]+-") $containerEnvFlavorsWithDashes }}
                {{- if and $containerFlavorContainsRequestedEnvType (not (or $containerFlavorContainsRequestedEnv $containerFlavorContainsRequestedEnvBaseVersion)) }}
                    {{- $notMatchingContainerFlavorsList = append $notMatchingContainerFlavorsList $containerFlavor }}
                {{- end }}
            {{- end }}
        {{- end }}
        {{- /* exclude all $notMatchingContainerFlavorsList items from $osMatchingContainerFlavor */}}
        {{- $finalMatchingContainerFlavorsList := list }}
        {{- range $_, $osMatchingContainerFlavor := $osMatchingContainerFlavorsList }}
            {{- if not (has $osMatchingContainerFlavor $notMatchingContainerFlavorsList) }}
                {{- $finalMatchingContainerFlavorsList = append $finalMatchingContainerFlavorsList $osMatchingContainerFlavor }}
            {{- end }}
        {{- end }}
        {{- if $finalMatchingContainerFlavorsList }}
            {{- first $finalMatchingContainerFlavorsList }}
        {{- else }}
            {{- fail (print "None of the container image flavors match requested imageFlavor \"" $requestedFlavor "\". All supported container images: \"" $containerFlavorsList "\".") }}
        {{- end }}
    {{- end }}
{{- end }}
{{- end }}
