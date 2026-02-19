{{- define "bssc-indexmgr.istio.properties" -}}
{{- $_ := set . "istioCni" .Values.istio.cni.enabled | default .Values.global.istio.cni.enabled }}
{{- end }}

{{- define "bssc-indexmgr.istio.initIstio" -}}
{{- $_ := set . "istio" .Values.istio }}
{{- end -}}

{{- define "bssc-indexmgr.istio.psp" -}}
{{- include "bssc-indexmgr.istio.initIstio" . }}
{{- include "bssc-indexmgr.istio.properties" . }}
{{- if and ($.istio.enabled ) (not $.istioCni) (.Values.rbac.enabled) (.Values.rbac.psp.create) (.Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy") }}
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
{{- include "bssc-indexmgr.commonLabels" (tuple .  "indexmgr" ) | indent 4 }}
{{- include "bssc-indexmgr.csf-toolkit-helm.labels" (tuple .) | nindent 4 }}
  annotations:
{{- include "bssc-indexmgr.csf-toolkit-helm.annotations" (tuple . .Values.rbac.psp.annotations) | nindent 4 }}
  name: {{ template "bssc-indexmgr.fullname" . }}-istio-psp
spec:
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  allowedCapabilities:
  - 'NET_ADMIN'
  - 'NET_RAW'
  volumes:
    - 'downwardAPI'
    - 'configMap'
    - 'emptyDir'
    - 'secret'
    - 'hostPath'
    - 'projected'
{{- end -}}
{{- end -}}


{{- define "bssc-indexmgr.istio.scc" -}}
{{- include "bssc-indexmgr.istio.initIstio" . }}
{{- include "bssc-indexmgr.istio.properties" . }}
{{- if and ($.istio.enabled) (not $.istioCni) (.Values.rbac.enabled) (.Values.rbac.scc.create) (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: {{ template "bssc-indexmgr.fullname" . }}-istio-scc
  labels:
{{- include "bssc-indexmgr.commonLabels" (tuple .  "indexmgr" ) | indent 4 }}
{{- include "bssc-indexmgr.csf-toolkit-helm.labels" (tuple .) | nindent 4 }}
  annotations:
{{- include "bssc-indexmgr.csf-toolkit-helm.annotations" (tuple . .Values.rbac.scc.annotations) | nindent 4 }}
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
readOnlyRootFilesystem: true
defaultAddCapabilities: []
requiredDropCapabilities:
- 'KILL'
- 'MKNOD'
- 'SETUID'
- 'SETGID'
allowedCapabilities:
- 'NET_ADMIN'
- 'NET_RAW'
runAsUser:
  type: MustRunAsNonRoot
fsGroup:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
{{- if semverCompare ">= 1.24.0-0" .Capabilities.KubeVersion.GitVersion }}
seccompProfiles:
- runtime/default
{{- end }}  
groups: []
users: []
volumes:
- 'secret'
- 'emptyDir'
- 'configMap'
- 'projected'
- 'downwardAPI'
- 'persistentVolumeClaim'
{{- end -}}
{{- end -}}
