{{/* certManager apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.certManager" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3/Certificate" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else }}
{{- print "cert-manager.io/v1alpha2" }}
{{- end }}
{{- end }}

{{/* Role apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.role" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* RoleBinding  apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.roleBinding" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* clusterRole apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.clusterRole" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* clusterRoleBinding apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.clusterRoleBinding" -}}
{{- print "rbac.authorization.k8s.io/v1" }}
{{- end }}

{{/* Statefulset apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.stateFullset" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1/StatefulSet" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta1" }}
{{- end }}
{{- end }}

{{/* BrPolicy apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.brpolicy" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{/* Job apiversion */}}
{{- define "cpro-grafana.grafanaApiVersion.job" -}}
{{- if .Capabilities.APIVersions.Has "batch/v1/Job" }}
{{- print "batch/v1" -}}
{{- else -}}
{{- print "batch/v1beta1" -}}
{{- end }}
{{- end -}}

{{/* Version for podSecurityPolicy */}}
{{- define "cpro-grafana.grafanaApiVersion.podSecurityPolicy" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1beta1/PodSecurityPolicy" }}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end }}
{{- end -}}

{{/* Version for PodDisruptionBudget */}}
{{- define "cpro-grafana.grafanaApiVersion.pdb" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1/PodDisruptionBudget" }}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end }}
{{- end -}}

{{/* Ingress aiversions */}}
{{- define "cpro-grafana.grafanaApiVersion.ingress" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" }}
{{- print "networking.k8s.io/v1" }}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" }}
{{- end }}
{{- end }}
{{/* apiversion for VirtualService */}}

{{- define "cpro-grafana.grafanaApiVersion.virtualService" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/VirtualService" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{/* apiversion for DestinationRule */}}

{{- define "cpro-grafana.grafanaApiVersion.destinationRule" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/DestinationRule" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}

{{/* apiversion for Gateway */}}
{{- define "cpro-grafana.grafanaApiVersion.gateway" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Gateway" }}
{{- print "networking.istio.io/v1beta1" }}
{{- else }}
{{- print "networking.istio.io/v1alpha3" }}
{{- end }}
{{- end }}