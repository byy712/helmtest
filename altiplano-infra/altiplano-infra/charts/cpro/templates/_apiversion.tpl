{{/* kind API Version for statefulset */}}
{{- define "cpro.apiVersion.sts" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1/StatefulSet" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta1" }}
{{- end }}
{{- end }}

{{/* kind API Version for podSecurityPolicy */}}
{{- define "cpro.apiVersion.podSecurityPolicy" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy" }}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end }}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodDisruptionBudget
*/}}

{{- define "cpro.apiVersion.pdb" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end }}
{{- end -}}

{{/* New-apiversion for Job */}}
{{- define "cpro.apiVersion.jobApiversion" -}}
{{- if .Capabilities.APIVersions.Has "batch/v1/Job" }}
{{- print "batch/v1" -}}
{{- else -}}
{{- print "batch/v1beta1" -}}
{{- end }}
{{- end -}}

{{/* apiversion for BrPolicy */}}
{{/* "cbur.bcmt.local/v1" and "cbur.csf.nokia.com/v1" are the commonly used api version for brpolicy  */}}
{{- define "cpro.apiVersion.brpolicyapiversion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{/* apiversion for BrHook */}}
{{/* "cbur.bcmt.local/v1" and "cbur.csf.nokia.com/v1" are the commonly used api version for brHook  */}}
{{- define "cpro.apiVersion.brHookapiversion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrHook" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{/* New-apiversion for certManager */}}
{{- define "cpro.apiVersion.certManagerApiversion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else }}
{{- print "cert-manager.io/v1alpha2" }}
{{- end }}
{{- end }}

{{/* New-apiversion for PeerAuthentication */}}
{{- define "cpro.apiVersion.peerAuthentication" -}}
{{- print "security.istio.io/v1beta1" -}}
{{- end -}}

{{/* New-apiversion for Gateway */}}
{{- define "cpro.apiVersion.gatewayApiversion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Gateway" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{/* apiversion for VirtualService */}}

{{- define "cpro.apiVersion.virtualService" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/VirtualService" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{/* apiversion for DestinationRule */}}

{{- define "cpro.apiVersion.destinationRule" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/DestinationRule" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{/* apiversion for Role */}}
{{- define "cpro.apiVersion.roleApiversion" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* apiversion for RoleBinding */}}
{{- define "cpro.apiVersion.roleBindingApiversion" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* apiversion for DeploymentAPI */}}
{{- define "cpro.apiVersion.DeploymentAPI" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1/Deployment" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/* Ingress aiversions */}}
{{- define "cpro.apiVersion.ingress" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" }}
{{- print "networking.k8s.io/v1" }}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" }}
{{- end }}
{{- end }}

{{/* apiversion for NetworkPolicy */}}

{{- define "cpro.apiVersion.networkPolicy" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/NetworkPolicy" }}
{{- print "networking.k8s.io/v1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}

{{/* clusterRoleBinding apiversion */}}
{{- define "cpro.apiVersion.clusterRoleBinding" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}


{{/* apiversion for DaemonSet */}}
{{- define "cpro.apiVersion.DaemonSetAPI" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1/DaemonSet" -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for securitycontextconstraints..
*/}}
{{- define "cpro.prometheus.apiVersion.scc" -}}
{{- print "security.openshift.io/v1" -}}
{{- end -}}
