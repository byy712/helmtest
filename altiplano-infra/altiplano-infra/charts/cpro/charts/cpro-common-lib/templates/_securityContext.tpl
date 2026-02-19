
## Examples

* Workload (named core)
** code snippet
+
----
{{- include "cpro-common-lib.v1.containerSecurityContext" (dict "root" . "context" .Values.core.containerSecuritycontext ) | nindent 5 }}

* root refers to .Values(root) level and context referes to .Values.core.containerSecuritycontext (workload) level
----

{{/*
container security context. The below function will be used only for the new containers and also to the containers which are not using the readonlyfilesystem and allowPrivilegeEscalation from the root level.
*/}}
{{- define "cpro-common-lib.v1.containerSecurityContext" -}}
{{- $root := .root -}}
{{- $SecurityContext := .context -}}
{{- if  $root.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints" }}
    {{- if semverCompare "<1.24.0-0" $root.Capabilities.KubeVersion.GitVersion }}
      {{- if (hasKey $SecurityContext "seccompProfile") }}
        {{- $SecurityContext = omit $SecurityContext "seccompProfile" }}
      {{- end }}
    {{- end }}
 {{- end }}
{{- if eq ( toString ( $SecurityContext.runAsGroup )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "runAsGroup" -}}
{{- end }}
{{- if eq ( toString ( $SecurityContext.runAsUser )) "auto" }}
{{- $SecurityContext = omit $SecurityContext "runAsUser" -}}
{{- end }}
{{- if $SecurityContext  }}
{{- toYaml $SecurityContext -}}
{{- end }}
{{- end -}}
