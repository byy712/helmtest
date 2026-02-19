{{- define "cpro.wait4Certs2BeConsumed.template" }}
{{- $root := .root }}
{{- $workload := .workload }}
{{- $container := $root.Values.certManagerConfig }}
{{$data_csc := dict "cSecCtx" $root.Values.certManagerConfig.wait4Certs2BeConsumed.containerSecurityContext "ctx" $root }}
- name: {{ template "cpro.prometheus.certmanager.initcontainer" $root }}
  {{- include "cpro.prometheus.distro.image" (dict "root" $root "workload" $workload "container" $container  ) | nindent 2}}
  {{- include "cpro.terminationMessage" $root | nindent 2 }}
  resources:
{{- include "cpro-common-lib.v1.resources" ( dict "root" $root "workloadresources" $root.Values.certManagerConfig.wait4Certs2BeConsumed.resources "defaultcpulimit" "10m") | nindent 4 }}
  command:
  - /bin/fileSizeValidator
  args:
  - --log-level={{ $root.Values.certManagerConfig.wait4Certs2BeConsumed.logLevel }}
  - --log-fmt={{ $root.Values.certManagerConfig.wait4Certs2BeConsumed.logFmt | quote }}
  - --timeout={{ $root.Values.certManagerConfig.wait4Certs2BeConsumed.timeout }}
  {{- range $name, $path := .certMountPaths }}
  - --mount-path={{ $path }}
  {{- end }}
  {{- range $root.Values.certManagerConfig.wait4Certs2BeConsumed.fileNames }}
  - --file-name={{ . }}
  {{- end }}
  volumeMounts:
  {{- range $name, $path := .certMountPaths }}
  - name: {{ $name }}
    mountPath: {{ $path }}
  {{- end }}
  securityContext:
    {{- include "cpro.containerSecurityContext" $data_csc | nindent 4 }}
{{- end }}

{{- define "cpro.server.waitForCerts" }}
{{- $root := . }}
{{- $workload := $root.Values.server }}
{{- $container := $root.Values.certManagerConfig }}
{{ $_ := set . "cproServerWaitForCerts" false }}
{{ $certs := dict }}
{{- if ($root.Values.certManagerConfig.wait4Certs2BeConsumed.enabled) }}

{{- if and ( $root.Values.alertmanager.enabled ) (eq $root.Values.alertmanager.tls_auth_config.tls.externalSecret "") ($root.Values.alertmanager.tls_auth_config.tls.enabled) }}
{{ $_ := set . "cproServerWaitForCerts" true }}
{{ $_ := set $certs "alertmanager-tls" $root.Values.server.alertmanagerCertMountPath }}
{{- end }}

{{- if and ( $root.Values.pushgateway.enabled ) (eq $root.Values.pushgateway.tls_auth_config.tls.externalSecret "") ($root.Values.pushgateway.tls_auth_config.tls.enabled) }}
{{ $_ := set . "cproServerWaitForCerts" true }}
{{ $_ := set $certs "pushgateway-tls" $root.Values.server.pushgatewayCertMountPath }}
{{- end }}

{{- if and ( $root.Values.server.enabled ) (eq $root.Values.server.tls_auth_config.tls.externalSecret "") ($root.Values.server.tls_auth_config.tls.enabled) }}
{{ $_ := set . "cproServerWaitForCerts" true }}
{{ $_ := set $certs "client-tls" $root.Values.server.serverCertMountPath }}
{{ $_ := set $certs "server-tls" "/var/lib/certs" }}
{{- end }}

{{- if and ( $root.Values.nodeExporter.enabled ) (eq $root.Values.nodeExporter.tls_auth_config.tls.externalSecret "") ($root.Values.nodeExporter.tls_auth_config.tls.enabled) }}
{{ $_ := set . "cproServerWaitForCerts" true }}
{{ $_ := set $certs "nodeexporter-tls" $root.Values.server.nodeexporterCertMountPath }}
{{- end }}

{{- if and ( $root.Values.kubeStateMetrics.enabled ) (eq $root.Values.kubeStateMetrics.tls_auth_config.tls.externalSecret "") ($root.Values.kubeStateMetrics.tls_auth_config.tls.enabled) }}
{{ $_ := set . "cproServerWaitForCerts" true }}
{{ $_ := set $certs "kubestatemetrics-tls" $root.Values.server.kubeStateMetricsCertMountPath }}
{{- end }}

{{- end }}

{{- if .cproServerWaitForCerts }}
{{ $_ := set . "certMountPaths" $certs }}
{{ include "cpro.wait4Certs2BeConsumed.template" (dict "root" $root "workload" $workload "container" $container) }}
{{- end }}

{{- end }}
