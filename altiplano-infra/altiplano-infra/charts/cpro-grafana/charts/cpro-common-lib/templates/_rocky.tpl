
## Example

+
----
{{- include "cpro-common-lib-v1.rockyimage" ( dict "root" . "context" .Values.fluentd "registry" .Values.global.registry ) | nindent 10 }}

* root refers to .Values(root) level and context refers to .Values.fluentd level
* registry refers to registry where fluentd image is present.
----



{{- define "cpro-common-lib-v1.rockyimage" -}}
{{- $root := .root }}
{{- $context := .context }}
{{- $registry := .registry }}
image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $context.image.repo "internalRegisty" $root.Values.intFluentdReg ) }}:{{ tpl $context.image.tag $root }}"
imagePullPolicy: {{ $context.image.ImagePullPolicy }}
{{- end -}}
