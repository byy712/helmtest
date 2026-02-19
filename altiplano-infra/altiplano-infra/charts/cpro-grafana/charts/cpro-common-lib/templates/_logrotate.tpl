
## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.logrotate" ( dict "root" . "context" .Values.logrotate "registry" .Values.global.registry ) | nindent 8 }}

* root refers to .Values(root) level and context refers to .Values.logrotate level
* registry refers to registry where logrotate image is present.
----


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cpro-common-lib.logrotate" -}}
{{- $root := .root }}
{{- $context := .context }}
{{- $registry := .registry }}
- name: {{ template "cpro-common-lib.v1.containername" (dict "name" "logrotate" "context" $root) }} 
  image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $context.image.repo "internalRegisty" $root.Values.intLogrotateReg ) }}:{{ $context.image.tag }}"
  imagePullPolicy: {{ $context.ImagePullPolicy }}
  command: ["/usr/bin/bash" , "/logRotate/rotate.sh"] 
  securityContext:
          {{- include "cpro-common-lib.v1.containerSecurityContext" (dict "root" $root "context" $context.containerSecurityContext ) | nindent 5 }}
{{- include "cpro-common-lib.v1.terminationMessage" $root | nindent 2 }}
  resources:
{{- include "cpro-common-lib.v1.resources" ( dict "root" $root "workloadresources" $context.resources "defaultcpulimit" "500m") | nindent 4 }}
  env:
    {{- include "cpro-common-lib.v1.timeZoneName" . | nindent 4 }}
{{- end}}
