{{/*
Check to enable syslog feature.

controller level flag takes priority over the global.
Below table shows when the syslog is enabled
 _________________________________________  _______________________________________ _____________________________________
|                                          |                                       |                                     |
| controller.unifiedLogging.syslog.enabled | .global.unifiedLogging.syslog.enabled | "csf-common-lib.v1.coalesceBoolean" |
|__________________________________________|_______________________________________|_____________________________________|
|                                          |                                       |           "false"                   |
|------------------------------------------|---------------------------------------|-------------------------------------|
|       false                              |                                       |           "false"                   |
|------------------------------------------|---------------------------------------|-------------------------------------|
|                                          |       false                           |           "false"                   |
|------------------------------------------|---------------------------------------|-------------------------------------|
|       false                              |       true                            |           "false"                   |
|------------------------------------------|---------------------------------------|-------------------------------------|
|       true                               |       false                           |           "true"                    |
|------------------------------------------|---------------------------------------|-------------------------------------|
|       true                               |                                       |           "true"                    |
|------------------------------------------|---------------------------------------|-------------------------------------|
|                                          |       true                            |           "true"                    |
|__________________________________________|_______________________________________|_____________________________________|

*/}}
{{- define "citm-ingress.isSyslogEnabled" -}}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.controller.unifiedLogging.syslog.enabled .Values.global.unifiedLogging.syslog.enabled false )) "true"  }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}


{{- define "citm-ingress.rsyslog-client-container-securityContext" -}}
allowPrivilegeEscalation: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.privilegeEscalation }}
runAsNonRoot: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.runAsNonRoot }}
{{- if eq (include "citm-ingress.addSeccompProfile" .) "true" }}
seccompProfile:
  type: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seccompProfile.type }}
{{- if eq .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seccompProfile.type "Localhost" }}
  localhostProfile: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seccompProfile.path }}
{{- end }}
{{- end }}
capabilities:
  drop:
    - {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.dropCapabilities }}
{{- if eq .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seLinuxOptions.enabled true }}
seLinuxOptions:
  level: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seLinuxOptions.level }}
  role: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seLinuxOptions.role }}
  type: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seLinuxOptions.type }}
  user: {{ .Values.controller.unifiedLogging.syslog.rsyslog.containerSecurityContext.seLinuxOptions.user }}
{{- end }}
readOnlyRootFilesystem: {{ .Values.controller.unifiedLogging.syslog.rsyslog.securityContext.readOnlyRootFilesystem }}
{{- if not (eq (include "citm-ingress.rsyslog.securityContextrunAsUser" . ) "auto") }}
runAsUser: {{ include "citm-ingress.rsyslog.securityContextrunAsUser" . }}
{{- end }}
{{- end -}}


{{- define "citm-ingress.rsyslog-client-container" -}}
{{- if eq (include "citm-ingress.isSyslogEnabled" . ) "true" }} 
- name: {{ include "csf-common-lib.v1.containerName" (tuple . ( include "citm-ingress.containerNameSuffix" (tuple ( include "citm-ingress.name" .) "rsyslog-client" ))) }}
  image: "{{ include "citm-ingress.imageMapper" (tuple $ .Values.controller.unifiedLogging.syslog.rsyslog .Values.internalRsyslogClientRegistry) }}"
  imagePullPolicy: "{{ .Values.controller.imagePullPolicy }}"
  args:
    {{- if .Values.controller.unifiedLogging.syslog.rsyslog.extraArgs }}
      {{- range $key:= .Values.controller.unifiedLogging.syslog.rsyslog.extraArgs }}
      - {{ $key }}
      {{- end }}
    {{- end }}
  securityContext:
{{ include "citm-ingress.rsyslog-client-container-securityContext" . | indent 4}}
  resources:
{{ toYaml .Values.controller.unifiedLogging.syslog.rsyslog.resources | indent 4 }}
{{- include "citm-ingress.rsyslog-client-probes" . | indent 2 }}
  env:
    - name: SYSLOG_ENABLED
      value: "true"
    - name: CRONTAB_FILE_PATH
      value: "{{ .Values.controller.unifiedLogging.syslog.logrotate.dir }}/{{ .Values.controller.unifiedLogging.syslog.logrotate.cron.file }}"
    - name: LOG_ROTATE_CONF_PATH
      value: "{{ .Values.controller.unifiedLogging.syslog.logrotate.dir }}/{{ .Values.controller.unifiedLogging.syslog.logrotate.file }}"
    - name: SUPERCRONIC_OUTPUT_FILE
      value: "{{ .Values.controller.unifiedLogging.syslog.logrotate.supercronic.output_file }}"
    - name: SUPERCRONIC_ERROR_FILE
      value: "{{ .Values.controller.unifiedLogging.syslog.logrotate.supercronic.error_file }}"
    - name: LOGRUNNER_DIR
      value: {{ .Values.controller.unifiedLogging.syslog.logRunner.dir }}
    - name: LOGRUNNER_FILE
      value: {{ .Values.controller.unifiedLogging.syslog.logRunner.file }}
    - name: RSYSLOG_DIR
      value: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}"
    - name: RSYSLOG_CONF_FILE
      value: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.file }}"
    - name: INPUT_FILE_PATH
      value: "{{ .Values.controller.unifiedLogging.syslog.logRunner.dir }}/{{ .Values.controller.unifiedLogging.syslog.logRunner.file }}"
    - name: OUTPUT_FORWARD_TARGET
      value: "{{ .Values.controller.unifiedLogging.syslog.host }}"
    - name: OUTPUT_FORWARD_PORT
      value: "{{ .Values.controller.unifiedLogging.syslog.port }}"
    - name: TZ
      value: {{ template "citm-ingress.rsyslog.timeZoneName" . }}
  volumeMounts:
    - name: logrunner-volume
      mountPath: {{ .Values.controller.unifiedLogging.syslog.logRunner.dir }}
    - name: logrotate-cronie-file
      mountPath: {{ .Values.controller.unifiedLogging.syslog.logrotate.dir }}
    - name: rsyslog-conf-file
      mountPath: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/{{ .Values.controller.unifiedLogging.syslog.rsyslog.file }}"
      subPath: {{ .Values.controller.unifiedLogging.syslog.rsyslog.file }}
    - name: rsyslogd-dir
      mountPath: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/conf"
  {{- if eq (include "citm-ingress.rsyslog-client-remote-enableTLS" .) "true" }}
    - name: rsyslog-tls-volume
      mountPath: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/certs"
  {{- end }}
    - name: rsyslog-config-volume
      mountPath: "{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}"
{{- end }}
{{- end -}}


{{/*
*Setting the securityContext runAsUser for rsyslog client container
*/}}
{{- define "citm-ingress.rsyslog.securityContextrunAsUser" -}}
{{- if or (eq (toString .Values.global.securityContext.runAsUser) "auto") (eq (toString .Values.securityContext.runAsUser) "auto") -}}
{{- printf "%s" "auto" -}}
{{- else if .Values.global.securityContext.runAsUser -}}
{{- printf "%d" (.Values.global.securityContext.runAsUser | int) -}}
{{- else -}}
{{- printf "%d" (.Values.controller.unifiedLogging.syslog.rsyslog.securityContext.runAsUser | int) -}}
{{- end -}}
{{- end -}}

{{/*
Setting the Timezone
*/}}
{{- define "citm-ingress.rsyslog.timeZoneName" -}}
{{ .Values.controller.unifiedLogging.syslog.rsyslog.timeZoneEnv | default .Values.global.timeZoneEnv | default "UTC" | quote }}
{{- end -}}

{{/*
Rsyslog Client Main Conf
*/}}
{{- define "citm-ingress.rsyslog-client-main-conf" -}}
$WorkDirectory {{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}

{{- if or (eq (include "citm-ingress.rsyslog-client-remote-enableTLS" .) "true") (.Values.controller.unifiedLogging.syslog.rsyslog.globalCustomConfigs ) }}
$IncludeConfig {{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/conf/rsyslog.global.conf
{{- end }}

$IncludeConfig {{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/conf/rsyslog.input.conf
$IncludeConfig {{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/conf/unified-logging.conf
$IncludeConfig {{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/conf/rsyslog.actions.conf
{{- end -}}



{{/*
Rsyslog Client Global Conf
*/}}
{{- define "citm-ingress.rsyslog-client-global-conf" -}}
# GLOBAL DIRECTIVES

{{- if .Values.controller.unifiedLogging.syslog.rsyslog.globalCustomConfigs }}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.globalCustomConfigs . }}
{{- else if eq (include "citm-ingress.rsyslog-client-remote-enableTLS" .) "true" }}
global(DefaultNetstreamDriver="gtls"
  DefaultNetstreamDriverCAFile="{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/certs/ca.crt"
  DefaultNetstreamDriverKeyFile="{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/certs/tls.key"
  DefaultNetstreamDriverCertFile="{{ .Values.controller.unifiedLogging.syslog.rsyslog.dir }}/certs/tls.crt"
)
{{- end -}}
{{- end -}}


{{/*
Rsyslog Client Input Conf
Take inputCustomConfigs if provided else use the default.
*/}}
{{- define "citm-ingress.rsyslog-client-input-conf" -}}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.inputCustomConfigs -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.inputCustomConfigs . }}
{{- else -}}
module(load="imfile")
input(type="imfile"
      File="{{ .Values.controller.unifiedLogging.syslog.logRunner.dir }}/{{ .Values.controller.unifiedLogging.syslog.logRunner.file }}"
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.inputExtraArgs -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.inputExtraArgs . | nindent 6}}
{{- end -}}
)
{{- end -}}
{{- end -}}


{{/*
Rsyslog Client Logging Format
Take inputCustomConfigs if provided else use the default.
*/}}
{{- define "citm-ingress.rsyslog-client-unified-logging-format-conf" -}}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.unifiedLoggingCustomConfigs -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.unifiedLoggingCustomConfigs . }}
{{- else -}}
template(name="Unified_Logging_Format" type="list") {
    constant(value="<")
    property(name="pri")
    constant(value=">")
    property(name="msg" droplastlf="on")
}
{{- end -}}
{{- end -}}

{{/*
Rsyslog Client Ouput Conf
Take actionsCustomConfigs if provided else use the default.
*/}}
{{- define "citm-ingress.rsyslog-client-actions-conf" -}}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.actionsCustomConfigs -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.actionsCustomConfigs . }}
{{- else -}}
action(type="omfwd" template="Unified_Logging_Format"
      target="{{ required "Syslog is enabled, provide a valid remote syslog host" (include "citm-ingress.rsyslog-client-remote-host" .) }}"
      port="{{ required "Syslog is enabled, provide a valid remote syslog port" (include "citm-ingress.rsyslog-client-remote-port" .) }}"
{{- if required "Syslog is enabled, provide a valid protocol" (or .Values.global.unifiedLogging.syslog.protocol .Values.controller.unifiedLogging.syslog.protocol) }}
      {{- if eq (lower (include "citm-ingress.rsyslog-client-remote-protocol" .)) "udp" }}
      protocol="udp"
      {{- else }}
      protocol="tcp"
      {{- end }}
{{- end -}}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.actionsExtraArgs -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.actionsExtraArgs . | nindent 6}}
{{- end -}}
{{- if eq (include "citm-ingress.rsyslog-client-remote-enableTLS" .) "true" -}}
{{ tpl .Values.controller.unifiedLogging.syslog.rsyslog.rsyslogTLSExtraArgs . | nindent 6}}
{{- end -}}
)
{{- end -}}
{{- end -}}

{{/*
Logrotate Conf
*/}}
{{- define "citm-ingress.logrotate-conf" -}}
{{ tpl (toYaml .Values.controller.unifiedLogging.syslog.logrotate.conf) . | required "Values.controller.unifiedLogging.syslog.logrotate.conf can't be empty" }}
{{- end -}}


{{/*
Cronjob Conf
*/}}
{{- define "citm-ingress.cronjob-conf" -}}
{{ tpl (toYaml .Values.controller.unifiedLogging.syslog.logrotate.cron.conf) . | required ".Values.controller.unifiedLogging.syslog.logrotate.cron.conf cant be empty" }}
{{ printf "%s" "# An empty line is required at the end of this file for a valid cron file." -}}
{{- end -}}


{{/*
Rsyslog Client Container Probes
*/}}
{{- define "citm-ingress.rsyslog-client-probes" -}}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.probe.enabled }}
startupProbe:
  exec:
    command:
  {{- range .Values.controller.unifiedLogging.syslog.rsyslog.probe.startup.command }}
    - {{ . | quote }}
  {{- end }}
  initialDelaySeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.startup.delay }}
  periodSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.startup.period }}
  timeoutSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.startup.timeout }}
  failureThreshold: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.startup.maxfailure }}
livenessProbe:
  exec:
    command:
  {{- range .Values.controller.unifiedLogging.syslog.rsyslog.probe.liveness.command }}
    - {{ . | quote }}
  {{- end }}
  initialDelaySeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.liveness.delay }}
  periodSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.liveness.period }}
  timeoutSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.liveness.timeout }}
  failureThreshold: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.liveness.maxfailure }}
readinessProbe:
  exec:
    command:
  {{- range .Values.controller.unifiedLogging.syslog.rsyslog.probe.readiness.command }}
    - {{ . | quote }}
  {{- end }}
  initialDelaySeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.readiness.delay }}
  periodSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.readiness.period }}
  timeoutSeconds: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.readiness.timeout }}
  failureThreshold: {{ .Values.controller.unifiedLogging.syslog.rsyslog.probe.readiness.maxfailure }}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Generic Volume or not
*/}}
{{- define "citm-ingress.rsyslog-client-isGenericVolumeEnabled" -}}
{{- $generic_local_unset := or (eq (.Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.enabled | toString) "<nil>") (eq (.Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.enabled | toString) "") }}
{{- if .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.enabled }}
{{- print "true" }}
{{- else if and $generic_local_unset (eq .Values.global.ephemeralVolume.generic.enabled true) }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Global or Local host
*/}}
{{- define "citm-ingress.rsyslog-client-remote-host" -}}
{{- if .Values.controller.unifiedLogging.syslog.host }}
{{- printf "%s" .Values.controller.unifiedLogging.syslog.host -}}
{{- else }}
{{- printf "%s" .Values.global.unifiedLogging.syslog.host -}}
{{- end }}
{{- end -}}


{{/*
Rsyslog Client Container Use Global or Local Port
*/}}
{{- define "citm-ingress.rsyslog-client-remote-port" -}}
{{- if .Values.controller.unifiedLogging.syslog.port }}
{{- printf "%s" (.Values.controller.unifiedLogging.syslog.port | toString) -}}
{{- else }}
{{- printf "%s" (.Values.global.unifiedLogging.syslog.port | toString) -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Global or Local Protocol
*/}}
{{- define "citm-ingress.rsyslog-client-remote-protocol" -}}
{{- if .Values.controller.unifiedLogging.syslog.protocol }}
{{- printf "%s" .Values.controller.unifiedLogging.syslog.protocol -}}
{{- else }}
{{- printf "%s" .Values.global.unifiedLogging.syslog.protocol -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use TLS or not
*/}}
{{- define "citm-ingress.rsyslog-client-remote-enableTLS" -}}
{{- if or (.Values.controller.unifiedLogging.syslog.tls.secretRef.name) (.Values.global.unifiedLogging.syslog.tls.secretRef.name) }}
{{- printf "%s" "true" -}}
{{- else }}
{{- printf "%s" "false" -}}
{{- end }}
{{- end -}}


{{/*
Rsyslog Client Container Use Global or Local TLS secret
*/}}
{{- define "citm-ingress.rsyslog-client-remote-tlsSecretName" -}}
{{- if .Values.controller.unifiedLogging.syslog.tls.secretRef.name }}
{{- printf "%s" (.Values.controller.unifiedLogging.syslog.tls.secretRef.name | toString) -}}
{{- else }}
{{- printf "%s" (.Values.global.unifiedLogging.syslog.tls.secretRef.name | toString) -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Global or Local TLS secret caCrt key
*/}}
{{- define "citm-ingress.rsyslog-client-remote-tlsSecretName-caCrt" -}}
{{- if .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt }}
{{- printf "%s" .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt -}}
{{- else }}
{{- printf "%s" .Values.global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Global or Local TLS secret tlsKey key
*/}}
{{- define "citm-ingress.rsyslog-client-remote-tlsSecretName-tlsKey" -}}
{{- if .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey }}
{{- printf "%s" .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey -}}
{{- else }}
{{- printf "%s" .Values.global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Use Global or Local TLS secret tlsCrt key
*/}}
{{- define "citm-ingress.rsyslog-client-remote-tlsSecretName-tlsCrt" -}}
{{- if .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt }}
{{- printf "%s" .Values.controller.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt -}}
{{- else }}
{{- printf "%s" .Values.global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt -}}
{{- end }}
{{- end -}}

{{/*
Rsyslog Client Container Volumes
*/}}
{{- define "citm-ingress.rsyslog-client-volumes" -}}
- name: logrunner-volume
{{- if eq (include "citm-ingress.rsyslog-client-isGenericVolumeEnabled" . ) "true" }}
  ephemeral:
    volumeClaimTemplate:
      metadata:
        labels:
            app: {{ template "citm-ingress.name" . }}
            component: "{{ .Values.controller.name }}"
            release: {{ .Release.Name }}
            {{- include "citm-ingress.commonLabels" .  | indent 12  }}
      spec:
        accessModes: [ "ReadWriteOnce" ]
        {{- if (eq "-" .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.storageClass) }}
        storageClassName: ""
        {{- else }}
        storageClassName: {{ .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.storageClass | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.resources.requests "ephemeral-storage" | quote }}
          limits:
            storage: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.resources.limits "ephemeral-storage" | quote }}
{{- else }}
  emptyDir:
    {{- if .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.medium }}
    medium: {{ .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.medium | quote }}
    {{ end }}
    sizeLimit: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.sizeLimit | quote }}
{{ end }}
- name: rsyslog-config-volume
{{- if eq (include "citm-ingress.rsyslog-client-isGenericVolumeEnabled" . ) "true" }}
  ephemeral:
    volumeClaimTemplate:
      metadata:
        labels:
            app: {{ template "citm-ingress.name" . }}
            component: "{{ .Values.controller.name }}"
            release: {{ .Release.Name }}
            {{- include "citm-ingress.commonLabels" .  | indent 12  }}
      spec:
        accessModes: [ "ReadWriteOnce" ]
        {{- if (eq "-" .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.storageClass) }}
        storageClassName: ""
        {{- else }}
        storageClassName: {{ .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.storageClass | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.resources.requests "ephemeral-storage" | quote }}
          limits:
            storage: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.generic.resources.limits "ephemeral-storage" | quote }}
{{- else }}
  emptyDir:
    {{- if .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.medium }}
    medium: {{ .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.medium | quote }}
    {{ end }}
    sizeLimit: {{ index .Values.controller.unifiedLogging.syslog.rsyslog.ephemeralVolume.emptyDir.sizeLimit | quote }}
{{ end }}
- name: logrotate-cronie-file
  configMap:
    name: {{ template "citm-ingress.fullname" . }}-logrotate
    items:
      - key: logrotate.conf
        path: {{ .Values.controller.unifiedLogging.syslog.logrotate.file }}
      - key: logrotate-cron.conf
        path: {{ .Values.controller.unifiedLogging.syslog.logrotate.cron.file }}
- name: rsyslog-conf-file
  configMap:
    name: {{ template "citm-ingress.fullname" . }}-logrotate  #rsyslog-conf-file-map
    items:
      - key: rsyslog-conf-file-map-key
        path: rsyslog.conf
- name: rsyslogd-dir
  configMap:
    name: {{ template "citm-ingress.fullname" . }}-logrotate  #rsyslogd-dir-map
    items:
      - key: rsyslog-global-conf-key
        path: rsyslog.global.conf
      - key: rsyslog-input-conf-key
        path: rsyslog.input.conf
      - key: rsyslog-unified-logging-format-conf-key
        path: unified-logging.conf
      - key: rsyslog-actions-conf-key
        path: rsyslog.actions.conf
{{- if eq (include "citm-ingress.rsyslog-client-remote-enableTLS" .) "true" }}
- name: rsyslog-tls-volume
  secret:
    secretName: "{{ (include "citm-ingress.rsyslog-client-remote-tlsSecretName" .) }}"
    items:
      - key: "{{ (include "citm-ingress.rsyslog-client-remote-tlsSecretName-caCrt" .) }}"
        path: ca.crt
      - key: "{{ (include "citm-ingress.rsyslog-client-remote-tlsSecretName-tlsKey" .) }}"
        path: tls.key
      - key: "{{ (include "citm-ingress.rsyslog-client-remote-tlsSecretName-tlsCrt" .) }}"
        path: tls.crt
{{- end }}
{{- end -}}
