{{/* vim: set filetype=mustache: */}}
{{/*
Image Flavor to append to all image tags based on flavor defined in values.
NOTE: custom flavor is supported to allow tag to be used as-is.
*/}}
{{- define "cmdb-image.tag" -}}
{{- $SupportedFlavors := dict "rocky8" "-rocky8" "rocky9" "-rocky9" "custom" "#X" -}}
{{- $Values := first . -}}
{{- $spec := index . 1 -}}
{{- $imageFlavor := coalesce $spec.flavor $Values.imageFlavor $Values.global.imageFlavor -}}
{{- $imageFlavorPolicy := coalesce $spec.flavorPolicy $Values.imageFlavorPolicy $Values.global.imageFlavorPolicy -}}
{{- $flavor := include "csf-common-lib.v1.imageFlavorOrFail" (tuple $imageFlavor (keys $SupportedFlavors | sortAlpha) $imageFlavorPolicy) -}}
{{- $tagSuffix := required (printf "Image flavor is required to be one of the supported image flavors: %s" (keys $SupportedFlavors | sortAlpha)) (get $SupportedFlavors $flavor) -}}
{{- printf "%s%s" $spec.tag (eq $tagSuffix "#X" | ternary "" $tagSuffix) }}
{{- end -}}

{{- define "cmdb-image.path" -}}
{{- $Values := index (first .) "Values" -}}
{{- $registry := ( hasPrefix "internal" (index . 1) ) | ternary ( $Values.internalRegistry | default $Values.global.registry | default $Values._internalRegistry ) ( $Values.global.registry | default $Values.global._registry ) -}}
{{- $spec := index . 2 -}}
{{- $flat := $Values.global.flatRegistry -}}
{{- with $spec.image -}}
image: "{{ coalesce .registry $registry }}/{{ $flat | ternary (base .name) .name }}:{{ include "cmdb-image.tag" (tuple $Values .) -}}"
imagePullPolicy: {{ .pullPolicy | quote }}
{{- end -}}
{{- end -}}

{{/*
Image path definitions using global registry or overridden image for testing.
*/}}
{{/*
  MariaDB Images
*/}}
{{- define "cmdb-mariadb.image" -}}
{{- include "cmdb-image.path" (tuple . "internalRegistry" .Values.mariadb) -}}
{{- end -}}

{{- define "cmdb-mariadb.image.sum" }}
{{- include "cmdb-mariadb.image" . | sha1sum }}
{{- end -}}

{{- define "mariadb-metrics.image" -}}
{{- include "cmdb-image.path" (tuple . "registry" .Values.mariadb.metrics) -}}
{{- end -}}

{{- define "mariadb-auth.image" -}}
{{- include "cmdb-image.path" (tuple . "registry" .Values.mariadb.auth) -}}
{{- end -}}

{{/*
  MaxScale Images
*/}}
{{- define "cmdb-maxscale.image" -}}
{{- include "cmdb-image.path" (tuple . "internalRegistry" .Values.maxscale) -}}
{{- end -}}

{{- define "maxscale-metrics.image" -}}
{{- include "cmdb-image.path" (tuple . "registry" .Values.maxscale.metrics) -}}
{{- end -}}

{{- define "maxscale-auth.image" -}}
{{- include "cmdb-image.path" (tuple . "registry" .Values.maxscale.auth) -}}
{{- end -}}

{{/*
  Admin Images
*/}}
{{- define "cmdb-admin.image" -}}
{{- include "cmdb-image.path" (tuple . "internalRegistry" .Values.admin) -}}
{{- end -}}

{{/*
  CBUR Image
*/}}
{{- define "cbur-mariadb.image" -}}
{{- $registry := .Values.global.registry | default .Values.global._registry -}}
{{- $flat := .Values.global.flatRegistry -}}
{{- with .Values.cbur.image -}}
image: "{{ coalesce .registry $registry }}/{{ $flat | ternary (base .name) .name }}:{{ .tag }}"
imagePullPolicy: {{ .pullPolicy }}
{{- end -}}
{{- end -}}
