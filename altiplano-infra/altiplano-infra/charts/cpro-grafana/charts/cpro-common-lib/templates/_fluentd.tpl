
## Example

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.fluentd" ( dict "root" . "context" .Values.fluentd "workload" .Values.core "registry" .Values.global.registry ) | nindent 8 }}

* root refers to .Values(root) level and workload referes to .Values.core(workload) level and context refers to .Values.fluentd level
* registry refers to registry where fluentd image is present.
----

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cpro-common-lib.fluentd" -}}
{{- $root := .root }}
{{- $context := .context }}
{{- $workload := .workload }}
{{- $registry := .registry }}
- name: {{ template "cpro-common-lib.v1.containername" (dict "name" "fluentd" "context" $root) }} 
{{- include "cpro-common-lib-v1.rockyimage" ( dict "root" $root "context" $context "registry" $registry ) | nindent 2 }}
  command: ['bash', '-c', "/opt/scripts/fluentd-sidecar-entrypoint.sh"] 
  securityContext:
          {{- include "cpro-common-lib.v1.containerSecurityContext" (dict "root" $root "context" $context.containerSecurityContext ) | nindent 5 }}
{{- include "cpro-common-lib.v1.terminationMessage" $root | nindent 2 }}
  resources:
{{- include "cpro-common-lib.v1.resources" ( dict "root" $root "workloadresources" $context.resources "defaultcpulimit" "500m") | nindent 4 }}
  env:
    {{- include "cpro-common-lib.v1.timeZoneName" . | nindent 4 }}
    - name: RELEASE_NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
    - name: PODNAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
    - name: TMPDIR
      value: /tmp/fluentd-tmp-sidecar
{{- with $context.env }}
    {{ toYaml . | nindent 4 }}
{{- end }}
    - name: EXTENSION_FIELDS
      value: {{ or $workload.unifiedLogging.extension $root.Values.global.unifiedLogging.extension | toJson | quote }} 
{{- end}}




{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cpro-common-lib.fluentd-v2" -}}
{{- $root := .root }}
{{- $context := .context }}
{{- $workload := .workload }}
{{- $container := $root.Values.fluentd }}
{{- $imageName:= $root.Values.fluentd.image}}
{{- $supportedflavour := list "rocky8-jre17"}}
{{- $imagetag := split "-" ( toString $root.Values.fluentd.image.tag ) }}
{{- $registry := .registry }}
- name: {{ template "cpro-common-lib.v1.containername" (dict "name" "fluentd" "context" $root) }} 
  image: "{{ template "cpro-common-lib.v1.imageRegistry" ( dict "root" $root "imageInfo" $root.Values.fluentd.image.repo "internalRegisty" $root.Values.intFluentdReg ) }}:{{ $imagetag._0 }}-{{ template "cpro-common-lib.imageFlavorMapper-v2" (tuple $root.Values $workload $container $imageName $supportedflavour ) }}-{{ $imagetag._1 }}"
  imagePullPolicy: "{{ $root.Values.fluentd.image.ImagePullPolicy }}"
  command: ['bash', '-c', "/opt/scripts/fluentd-sidecar-entrypoint.sh"] 
  securityContext:
          {{- include "cpro-common-lib.v1.containerSecurityContext" (dict "root" $root "context" $context.containerSecurityContext ) | nindent 5 }}
{{- include "cpro-common-lib.v1.terminationMessage" $root | nindent 2 }}
  resources:
{{- include "cpro-common-lib.v1.resources" ( dict "root" $root "workloadresources" $context.resources "defaultcpulimit" "500m") | nindent 4 }}
  env:
    {{- include "cpro-common-lib.v1.timeZoneName" . | nindent 4 }}
    - name: RELEASE_NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
    - name: PODNAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
    - name: TMPDIR
      value: /tmp/fluentd-tmp-sidecar
{{- with $context.env }}
    {{ toYaml . | nindent 4 }}
{{- end }}
    - name: EXTENSION_FIELDS
      value: {{ or $workload.unifiedLogging.extension $root.Values.global.unifiedLogging.extension | toJson | quote }} 
{{- end}}
