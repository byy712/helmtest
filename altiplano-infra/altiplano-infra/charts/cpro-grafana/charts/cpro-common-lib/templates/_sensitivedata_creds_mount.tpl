{{/*
Template function to add volumes to manifests based on the credentials. If the keyNames mappings are empty, then the default keys under keyNames will be used
Example and usage: 
Values.yaml
externalCredentials:
  ckey:
    credentialName: "mycred"
    keyNames:
      key1: ""
      key2: ""
volumes:
 {{- include "cpro-common-lib.v1-includeExternalCredentials" (dict "creds" .Values.externalCredentials ) | indent 8 -}} 
*/}}

{{- define "cpro-common-lib.v1-includeExternalCredentials" -}}
{{- $externalCredentials:= .creds -}}
{{- with $externalCredentials -}}
{{- range $key, $value := $externalCredentials }}
- name: {{ $key }}
  secret:
    secretName: {{ $value.credentialName }}
    items:
{{- with $value.keyNames }}
{{- range $innerKey, $innerValue := . }}
{{- if ne $innerValue "" }}
      - key: {{ $innerValue }}
        path: {{ $innerValue -}}
{{- else }}
      - key: {{ $innerKey }}
        path: {{ $innerKey -}}
{{ end -}}
{{ end -}}
{{ end -}}
{{ end -}}
{{- end -}}
{{- end -}}

{{/*
Template function to add volumesMounts to manifests based on the credentials map passed.
Example and usage: 
Values.yaml
externalCredentials:
  ckey:
    credentialName: "mycred"
    keyNames:
      key1: ""
      key2: ""
volumesMounts:
 {{- include "cpro-common-lib.v1-includeExternalCredentialMounts" (dict "creds" .Values.externalCredentials "root" . ) | indent 12 }}
*/}}
{{- define "cpro-common-lib.v1-includeExternalCredentialMounts" -}}
{{- $externalCredentials:= .creds }}
{{- $root:= .root }}
{{- with $externalCredentials }}
{{- range $key, $value := $externalCredentials -}}
{{- $prefix:= $root.Values.secretPathPrefix | default "/secrets" }}
{{- $path:= printf "%s/%s" $prefix $key}}
- mountPath: {{ $path }}
  name: {{ $key }}
  readOnly: true
{{- end -}}
{{ end -}}
{{ end -}}



{{/*
Template function to add volume to manifests based on the credential map passed.
Example and usage: 
Values.yaml
nodeexporter:
    auth:
      credentialName: "mycred"
      keyNames:
        username: ""
        password: ""

deployment.yaml
volumes:
 {{- include "cpro-common-lib.v1-includeCredential" (dict "creds" .Values.nodeexporter.auth "volumeName" "nxp-auth") | indent 8 -}} 
*/}}
{{- define "cpro-common-lib.v1-includeCredential" -}}
{{- $creds:= .creds }}
{{- $volumeName:= .volumeName }}
- name: {{ $volumeName }}
  secret:
    secretName: {{ $creds.credentialName }}
    items:
{{- with $creds.keyNames }}
{{- range $innerKey, $innerValue := . }}
{{- if ne $innerValue "" }}
      - key: {{ $innerValue }}
        path: {{ $innerValue -}}
{{- else }}
      - key: {{ $innerKey }}
        path: {{ $innerKey -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Template function to add volumesMounts to manifests based on the credentials map passed.
Example and usage: 
Values.yaml
nodeexporter:
    auth:
      credentialName: "mycred"
      keyNames:
        username: ""
        password: ""
volumesMounts:
 {{- include "cpro-common-lib.v1-includeCredentialMount" (dict "cred" .Values.nodeexporter.auth "root" . "volumeName" "nxp-auth") | indent 12 -}} 
*/}}
{{- define "cpro-common-lib.v1-includeCredentialMount" -}}
{{- $root:= .root }}
{{- $cred := .cred }}
{{- $volumeName := .volumeName }}
{{- $prefix:= $root.Values.secretPathPrefix | default "/secrets" }}
{{- $path:= printf "%s/%s" $prefix $volumeName}}
- mountPath: {{ $path }}
  name: {{ $volumeName }}
  readOnly: true
{{- end -}}