


## Example

* Workload (named core)
** code snippet
+
----
tag: 2.1.0-{{ include "cpro-common-lib.imageFlavorMapper" ( tuple .Values .Values.image.python) }}-12345

* root refers to .Values(root) level and workload referes to .Values.image.python( where imageflavour variable is declared under)
----


{{- define "cpro-common-lib.imageFlavorMapper" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $imageFlavor := coalesce $workload.imageFlavor $root.imageFlavor }}
{{- $OSFlavor := "" -}}
{{- if $imageFlavor -}}
  {{- if contains "rocky8" (lower $imageFlavor) -}}
       {{- $OSFlavor = "rocky8" -}}
  {{- else if contains "centos7" (lower $imageFlavor) -}}
       {{- $OSFlavor = "centos7" -}}
  {{- end -}}
  {{- if $OSFlavor -}}
    {{- if contains "python36" (lower $imageFlavor) -}}
         {{- printf "%s-%s" $OSFlavor "python36" -}}
    {{- else if contains "python38" (lower $imageFlavor) -}}
         {{- printf "%s-%s" $OSFlavor "python38" -}}
    {{- else if contains "python39" (lower $imageFlavor) -}}
         {{- printf "%s-%s" $OSFlavor "python39" -}}
    {{- else if contains "jre11" (lower $imageFlavor) -}}
         {{- printf "%s-%s" $OSFlavor "jre11" -}}
    {{- else if and (eq $OSFlavor "rocky8") (contains "jre17" (lower $imageFlavor)) -}}
           {{- printf "%s-%s" $OSFlavor "jre17" -}}
    {{- else -}}
         {{- printf "%s" $OSFlavor -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}



{{- define "cpro-common-lib.imageFlavorMapper-v2" -}}
{{- $root := index . 0 }}
{{- $workload := index . 1 }}
{{- $container := index . 2 }}
{{- $imageName := index . 3 }}
{{- $supportedFlavorList := index . 4 }}
{{- $imageFlavor := coalesce $container.imageFlavor $workload.imageFlavor $root.imageFlavor $root.global.imageFlavor }}
{{- $imageFlavorPolicy := coalesce $container.imageFlavorPolicy $workload.imageFlavorPolicy $root.imageFlavorPolicy $root.global.imageFlavorPolicy }}
{{- if $imageFlavor }}
{{- include "csf-common-lib.v1.imageFlavorOrFail" (tuple $imageFlavor $supportedFlavorList $imageFlavorPolicy) }}
{{- else }}
{{- print $imageName.__defaultFlavor }}
{{- end -}}
{{- end -}}

