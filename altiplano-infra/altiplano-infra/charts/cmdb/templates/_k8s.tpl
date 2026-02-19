{{/* vim: set filetype=mustache: */}}
{{/*
* Return the K8s version as Mj.Mn
*/}}
{{- define "cmdb.k8sver" -}}
{{- $mj := .Capabilities.KubeVersion.Major | trimAll "+" | default "1" -}}
{{- $mn := .Capabilities.KubeVersion.Minor | trimAll "+" | default "24" -}}
{{- printf "%s.%s" $mj $mn -}}
{{- end -}}
