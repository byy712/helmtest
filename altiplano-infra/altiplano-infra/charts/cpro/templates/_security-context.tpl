{{/* cpro securityContext */}}
{{- define "cpro.securitycontext" -}}
{{- $SecurityContext := .securitycontext -}}
{{- $root := .ctx -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $SecurityContext "seccompProfile") }}
        {{- $SecurityContext = omit $SecurityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
{{- end }}
{{- if and ( $root.Values.seLinuxOptions.enabled) (hasKey .securitycontext "seLinuxOptions") }}
{{- required "seLinux is configured at both global and securityContext level. Only One of the values to be set." "" }}
{{- end }}
{{- if eq ( toString ( .securitycontext.fsGroup )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "fsGroup" -}}
{{- end }}
{{- if eq ( toString ( .securitycontext.runAsUser )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "runAsUser" -}}
{{- end }}
{{- if $SecurityContext  }}
{{- toYaml $SecurityContext -}}
{{- end }}
{{- end -}}

{{/*
CPRO container security context
*/}}
{{- define "cpro.containerSecurityContext" -}}
{{- $SecurityContext := .cSecCtx -}}
{{- $root := .ctx -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $SecurityContext "seccompProfile") }}
        {{- $SecurityContext = omit $SecurityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
{{- end }}
{{- if and ( hasKey $SecurityContext "runAsGroup" ) ( eq ( toString ( $SecurityContext.runAsGroup )) "auto" ) }}
{{- $SecurityContext = omit $SecurityContext "runAsGroup" -}}
{{- end }}
{{- if and ( hasKey $SecurityContext "runAsUser" ) ( eq ( toString ( $SecurityContext.runAsUser )) "auto" )  }}
{{- $SecurityContext = omit $SecurityContext "runAsUser" -}}
{{- end }}
{{- if $SecurityContext  }}
{{- toYaml $SecurityContext -}}
{{- end }}
{{- end -}}


{{/*
readOnlyRootFilesystem condition for restserver
*/}}
{{- define "cpro.restserver.containerSecurityContext" -}}
{{- $data_csc := dict "cSecCtx" .Values.restserver.containerSecurityContext "ctx" . -}}
{{- $csc := include "cpro.containerSecurityContext" $data_csc | fromYaml  -}}
{{- $newDict :=  pick $csc "readOnlyRootFilesystem"   }}
{{- if ( get $newDict "readOnlyRootFilesystem" ) }}
{{- printf "%t" ( get $newDict "readOnlyRootFilesystem" )  }}
{{- else }}
{{- printf "" }}
{{- end }}
{{- end }}

{{- define "cpro.nodeExporterScc" -}}
{{- $SecurityContext := .securitycontext -}}
{{- $root := .ctx -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
  {{- if semverCompare ">=1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
seccompProfiles:
{{- printf "- '*'" | nindent 0 -}}
  {{- end }}
{{- end }}
{{- end -}}
